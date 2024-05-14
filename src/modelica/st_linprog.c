#include "linprog/linprog.h"

#include <glpk.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#define ST_LINPROG_DEBUG

#ifdef ST_LINPROG_DEBUG
# define MSG(FMT,...) fprintf(stdout,"%s:%d: " FMT "\n",__FILE__,__LINE__,##__VA_ARGS__)
# define MSG1(FMT,...) fprintf(stdout,"%s:%d: " FMT,__FILE__,__LINE__,##__VA_ARGS__)
# define MSG2(FMT,...) fprintf(stdout,FMT,##__VA_ARGS__)
# define MSGL fprintf(stdout,"\n")
#else
# define MSG(...) ((void)0)
# define MSG1(...) ((void)0)
# define MSG2(...) ((void)0)
# define MSGL ((void)0)
#endif

#if 0
#include <ModelicaUtilities.h>
typedef int ErrorCallback(const char *fmt,...);

ErrorCallback st_linprog_errcallback;

int st_linprog_errcallback(const char *fmt,...){
	va_list args;
	vfprintf(stderr,fmt,args);
	va_end(args);
}

//#define ERR(FMT,...) (*errcallback)("%s:%d: " FMT "\n",__FILE__,__LINE__,##__VA_ARGS__)
//#define ERR(FMT,...) (*errcallback)(FMT "\n",##__VA_ARGS__)
#endif
#define ERR(FMT,...) fprintf(stderr,"%s:%d: " FMT "\n",__FILE__,__LINE__,##__VA_ARGS__)

#define ST_ERRVAL (-999999.)
/**
	Calculate an optimal dispatch strategy
	
	Maximise revenue over a specified forecast horizon, given varying DNI and
	varying spot-market selling price for electricity. This function
	implements a linearised model of the CSP system.
	
	@param wd            Weather data, loaded from a .motab file.
	                     According to the TMY3 standard, DNI reported at each
	                     timestep is the mean DNI for the preceding hour.
	                     Hence, if we want to calculate the energy collected
	                     for the ith interval (hour), we should read the value
	                     from the data file at t = t0 + i*dt.
	                     http://www.nrel.gov/docs/fy07osti/41364.pdf
	@param pd            Price data, as loaded from a .motab file.
	                     The PriceData should contain columns 'time' and either
	                     'price' or 'tod' (=time-of-day factor).
	                     NOTE: PriceData is being interpreted as values in 
	                     advance, so that if we want to know the price for
	                     the ith hour (see `i`, below) we will read the value of
	                     PriceData at t = t0 + (i-1)*dt, which will be the 
	                     selling price for any electricity sold in the interval 
	                     from t = t0 + (i-1)*dt to t = t0 + i*dt.
	                     Hence, we should have pd spanning the time interval
	                     [t0, t0+horizon*dt).
	                     NOTE: if forecasting timestep is greater than the
	                     `wd` or `pd` timestep, we currently ignore the 
	                     intervening values.
	@param horizon       forecast horizon (hours)
	@param dt            forecasting timestep (hours)
	@param time_simul    current simulation timestep (seconds)
	@param etaC          efficiency of the solar collector (array of values for
	                     each of the forecast timesteps), including the effect
	                     of both thermal and optical losses. NOTE: etaC[0]
	                     should be the value for the first hour, etaC[1] for the
	                     second hour, etc, up to horizon-1.
	@param etaG          power block (generator) efficiency (constant value)
	@param DEmax         max dispatched THERMAL energy in an hour (MWhth)
	@param SLmax         maximum storage level (MWhth)
	@param SLinit        initial storage level, at time_simul (MWhth?)
	@param SLmin         minimum allowed storage level (MWhth)
	@param A             total heliostat field area, m²
	
	FIXME as Philipe has pointed out, the correct implementation should allow
	for weather file and price file with unequal timestep size, by using
	interpolation.

	This should if possible be done using ModelicaStandardTables (ie
	ExternalCombiTable1D) instead of a different approach. But maybe we
	can do it from here in the C code, including the end-of-year wraparound?
	
	FIXME end-of-year wraparound is not yet implemented, will need checking.
*/
double st_linprog(MotabData *wd, MotabData *pd
		,int horizon, double dt, double t0
		,double etaC[], double etaG
		,double DEmax, double SLmax, double SLinit
		,double SLmin, double A
){
/*	ErrorCallback *errcallback = st_linprog_errcallback;
#ifdef ST_HAVE_MODELICA
	if(use_modelicaerror){
		errcallback = &ModelicaFormatError;
	}
#endif
*/
	
	MSG("t = %f",t0);

	double wdstep, pdstep;
	assert(0 == motab_check_timestep(wd,&wdstep));
	//assert(wdstep == 3600.);
	assert(0 == motab_check_timestep(pd,&pdstep));
	//assert(pdstep == 3600.);
	
	static MotabData *wdcache, *pdcache;
	if(wdcache != wd){
		wdcache = wd;
		if(wdstep != dt)ERR("Warning: weather file timestep is %f s, different"
			" from forecasting timestep %f s (message is only shown once)",wdstep, dt);
	}
	if(pdcache != pd){
		pdcache = pd;
		if(pdstep != dt)ERR("Warning: price file timestep is %fs, different"
			" from forecasting timestep %fs (message is only shown once)",pdstep, dt);
	}

	//const int time_index = time_simul / 3600;
	
	// check that wd and pd can cover the required time range

	MSG("t = %f s, dt = %f s:",t0,dt);
	MSG("DEmax = %f MWth",DEmax);
	MSG("SLmax = %f MWhth",SLmax);
	MSG("SLinit = %f MWhth",SLinit);
	MSG("SLmin = %f MWhth",SLmin);

	if(NULL==wd)return ST_ERRVAL;
	if(NULL==pd)return ST_ERRVAL;

	MSG("nrows wd = %d",wd->nrows);
	
	//assert(pd->nrows == 8760);
	//assert(wd->nrows == 8760);
	
	int price_col = motab_find_col_by_label(pd,"price");
	if(price_col == -1){
		price_col = motab_find_col_by_label(pd,"tod");
	}
	assert(price_col != -1);

	int dni_col = motab_find_col_by_label(wd,"dni");
	assert(dni_col != -1);

#define MP(I) (\
	/*MSG("MP(%d) at t=%f",I,t0+((I)-1)*dt),*/\
	motab_get_value_wraparound(pd,    t0+((I)-1)*dt,price_col)\
	)
/** as noted above, DNI for the ith period (counting from 1) is at t0+i*dt */
#define DNI(I) (\
	/*MSG("DNI(%d) at t=%f",(I),t0+(I)*dt),*/\
	motab_get_value_wraparound(wd,       t0+(I)*dt,dni_col)\
	)

/** efficiency in each hour will be taken from the supplied array. FIXME we 
	should be intpolating those values as-needed now, or ahead of time */
#define ETAC(I) etaC[i-1]

	// Initialise problem object lp
	glp_prob *P = glp_create_prob();

	/* VARIABLES IN THE PROBLEM
	
	SL(i) (Storage Level) : Energy stored in the tank at end of ith hour [MWh_th]
	      Note: `SLinit` is the energy stored in the tank at the start of the 1st
	      hour, which is a supplied constant.
	DE(i) (Dispatch Energy) : Sold energy rate [MW_th], during the ith hour
	SE(i) (Storage Energy) : The input energy in the tank from the sun [MW_th], during the ith hour
	XE(i) (Dumped Energy) : Lost energy [MW_th], during the ith hour
	
	Note that these symbols SL(i) are not actually 'variables' but rather
	column numbers in the GLPK problem, and resolve into values from 1..4·N.
	
	`i`=1 means the first hour, i=2 means the second hour, etc.

	NOTE!! in GLPK, the indices count from 1, not 0!! This is very odd behaviour
	suggesting that possibly that a Fortran programmer might has lost their way.
	*/
	// These 4·N equations are organised with column indices as follows:
#define N (horizon)
#define SL(I) (I)
#define DE(I) (SL(N) + I)
#define SE(I) (DE(N) + I)
#define XE(I) (SE(N) + I)

	glp_add_cols(P, XE(N));
	
	MSG("Number of cols = %d",XE(N));
	
#define NAMEMAX 255
	char sss[NAMEMAX];
	for(int i=1; i<=N; ++i){
		snprintf(sss,NAMEMAX,"SL%02d",i); glp_set_col_name(P,SL(i),sss);
		snprintf(sss,NAMEMAX,"DE%02d",i); glp_set_col_name(P,DE(i),sss);
		snprintf(sss,NAMEMAX,"SE%02d",i); glp_set_col_name(P,SE(i),sss);
		snprintf(sss,NAMEMAX,"XE%02d",i); glp_set_col_name(P,XE(i),sss);
	}

	MSG("COLUMN NAMES");
	for(int i=1;i<XE(N);++i){
		MSG("%3d: %s",i,glp_get_col_name(P,i));
	}

	/* OBJECTIVE FUNCTION
	
		max ∑(DEi·MPi·ηG)                      Maximise the revenue over the
		                                       forecast interval.
	*/
	glp_set_obj_dir(P, GLP_MAX);
	for(int i=1; i<= N; ++i){
		//MSG("i = %d",i);
		double mp_i = MP(i);
		assert(mp_i != MOTAB_NO_REAL);
		glp_set_obj_coef(P,DE(i),mp_i*etaG);
	}
	
	/* VARIABLE BOUNDS
		
		SLmin ≤ SLi ≤ SLmax
		0 ≤ DEi ≤ DEmax
		0 ≤ SEi ≤ A · ηC · DNIi
		0 ≤ XEi ≤ A · ηC · DNIi
	*/
	for(int i=1; i<= N; ++i){
		double dni_i = DNI(i);
		double etac_i = ETAC(i);
		assert(dni_i != MOTAB_NO_REAL);
		
		glp_set_col_bnds(P, SL(i), GLP_DB, SLmin, SLmax             );
		glp_set_col_bnds(P, DE(i), GLP_DB, 0    , DEmax             );
		if(dni_i == 0 || etac_i == 0){
			glp_set_col_bnds(P, SE(i), GLP_FX,0.,0.);
			glp_set_col_bnds(P, XE(i), GLP_FX,0.,0.);
		}else{
			glp_set_col_bnds(P, SE(i), GLP_DB, 0, A * etac_i * dni_i );
			glp_set_col_bnds(P, XE(i), GLP_DB, 0, A * etac_i * dni_i );
		}
	}
		
	/* CONSTRAINTS */
	
	// 2N+1 constraint equations are mapped as follows:
#define SEB(I) (I)    // stored energy balance, 1..N
#define EDX(I) (I+N)  // energy stored and dumped N+1...2N
#define LEB    (1+2*N)// 2N+1.

	glp_add_rows(P, LEB);
	
	MSG("Number of rows = %d",LEB);

	/*
	1. Dispatched energy balance (N equations)
		SLi - SLi-1 = SEi - DEi        Change in storage level equals
		                               net (stored minus dispatche) energy.	
		                               
		Terms on the left hand side are positive, right hand side negative.
	*/
	for(unsigned i=1;i<=N;++i){
		double dni_i = DNI(i);
		double etac_i = ETAC(i);	
		if(i == 1){
			//MSG("SL(%d) = %d, SE(%i) = %d, DE(%d) = %d", i,SL(i),i,SE(i),i,DE(i));
			glp_set_mat_row(P, SEB(i), 3
				,   (int[]){0, SL(i),  SE(i),  DE(i)}
				,(double[]){0,  +1. ,    -1.,    +1.}
			);
			glp_set_row_bnds(P,SEB(i),GLP_FX,SLmin,99999);
		}else{
			//MSG("SL(%d) = %d, SE(%i) = %d, DE(%d) = %d", i,SL(i),i,SE(i),i,DE(i));
			glp_set_mat_row(P, SEB(i), 4
				,   (int[]){0, SL(i),  SL(i-1),  SE(i),  DE(i)}
				,(double[]){0, +1. ,    -1.  ,    -1.,    +1.}
			);
			glp_set_row_bnds(P,SEB(i),GLP_FX,0.,99999);
		}
		snprintf(sss,NAMEMAX,"SEB%02d",i); glp_set_row_name(P,SEB(i),sss);
	/*
	2. Stored energy balance (N equations)
		SEi + XEn = A·ηC·DNIi·Δt       Collected energy is either stored (SE)
		                               or dumped (XE).
	*/
		glp_set_mat_row(P, EDX(i), 2
			,   (int[]){0, SE(i),  XE(i)}
			,(double[]){0,  +1. ,    +1.}
		);
		glp_set_row_bnds(P,EDX(i),GLP_FX,A*etac_i*dni_i,99999);
		snprintf(sss,NAMEMAX,"EDX%02d",i); glp_set_row_name(P,EDX(i),sss);
	}
	/*
	3. Long-term energy balance (1 equation)
		∑(DEi-SEi) = 0                 No net change in storage level over
		                               the forecast interval.
		-- or --
		SL(N) = SLinit.
	*/
	glp_set_mat_row(P,LEB, 1
		,   (int[]){0, SL(N)}
		,(double[]){0,  +1. }
	);
	glp_set_row_bnds(P,LEB,GLP_FX,SLinit,99999);
	glp_set_row_name(P,LEB,"LEB");

	// Message attribute
	glp_smcp parm;
	glp_init_smcp(&parm);
#ifdef ST_LINPROG_DEBUG
	parm.msg_lev = GLP_MSG_ALL; // GLP_MSG_ERR;
#else
	parm.msg_lev = GLP_MSG_OFF;
#endif

	// Solve the lp
	int res = glp_simplex(P,&parm);
	int printres = 0;
	char *msg;
	if(res == 0){
		MSG("LP successfully solved");
	}else{
		switch(res){
		case GLP_EBADB: msg = "Invalid initial basis";break;
		case GLP_ESING: msg = "Singular matrix";break;
		case GLP_ECOND: msg = "Ill-conditioned matrix";break;
		case GLP_EBOUND:msg = "Incorrect bounds";break;
		case GLP_EFAIL: msg = "Solver failure";break;
		default: msg = "unrecognised error code";
		}

		//ERR("glp_simplex returned error code %d (%s)",res,msg);
		printres = 1;
		//return 0;
	}
	
	if(printres){
		//glp_print_sol(P,"glpksolution.txt");

		// Get the value of the optimal obj. function
		MSG("OPTIMAL OBJ FUNCTION = %f USD",glp_get_obj_val(P));

#define PRVEC(FN,LABEL,UNITS) {\
			MSG1("%-20s%10s %-7s:",LABEL,#FN,"(" UNITS ")"); \
			for(int i=1;i <= N; i++){ \
				MSG2("%s%10.1f", (i==1?"":", "), FN(i)); \
			} \
			MSGL; \
		}

#define PRVEC1(FN,LABEL,UNITS) {\
			MSG1("%-20s%10s %-7s:",LABEL,#FN,"(" UNITS ")"); \
			for(int i=1;i <= N; i++){ \
				MSG2("%s%10.1f", (i==1?"":", "), glp_get_col_prim(P,FN(i))); \
			} \
			MSGL; \
		}

#define PRCE(LABEL,UNITS) {\
			MSG1("%-20s%10s %-7s:",LABEL,"CE","(" UNITS ")"); \
			for(int i=1;i <= N; i++){ \
				double ce = ETAC(i)*DNI(i)*A;\
				MSG2("%s%10.1f", (i==1?"":", "),ce); \
			} \
			MSGL; \
		}

#define PRREV(LABEL,UNITS) {\
			MSG1("%-20s%10s %-7s:",LABEL,"REV","(" UNITS ")"); \
			for(int i=1;i <= N; i++){ \
				double rev = etaG*MP(i)*glp_get_col_prim(P,DE(i));\
				MSG2("%s%10.1f", (i==1?"":", "),rev); \
			} \
			MSGL; \
		}
		
		PRVEC(DNI,"DNI","W/m2");
		PRVEC(ETAC,"eta_C","1");
		PRVEC(MP,"Market price","USD");
		PRCE("Collected heat","MWth");
		PRVEC1(XE,"Dumped heat","MWth");
		PRVEC1(SE,"Stored heat","MWth");
		PRVEC1(DE,"Dispatched heat","MWth");
		MSG("%-20s%10s %-7s: %10.1f","Initial storage lev","SLinit","(MWth)",SLinit);
		PRVEC1(SL,"Storage level","MWth");
		PRREV("Revenue","USD");

	}
	
	double optimalDispatch = glp_get_col_prim(P,DE(1));

	MSG("OPTIMAL DISPATCH FOR THE NEXT HOUR: %f",optimalDispatch);

	/*Free all the memory used in this script*/
	glp_free_env();

	if(res){
		ERR("GLPK error %d: %s",res,msg);
		return -987654321;
	}

	/*end of the code*/
	return optimalDispatch;
}

/**
	Calculate an optimal dispatch strategy for renewable powered thermal processes
	
	Maximise revenue over a specified forecast horizon, given varying PV and
	Wind electricity. This function	implements a linearised model of 
	the thermal system.
	
	@param pvd           PV power data, loaded from a .motab file.
	                     The PV data should contain columns 'time' and
	                     'power'.
	                     PV power data is calculated from TMY3 file in SAM.
	                     According to the TMY3 standard, DNI reported at each
	                     timestep is the mean DNI for the preceding hour.
	                     Hence, if we want to calculate the energy collected
	                     for the ith interval (hour), we should read the value
	                     from the data file at t = t0 + i*dt.
	                     http://www.nrel.gov/docs/fy07osti/41364.pdf
	@param wnd           Wind power data, as loaded from a .motab file.
	                     The Wind data should contain columns 'time' and
	                     'power'.
	                     Wind power data is calculated from TMY3 file in SAM.
	                     Hence, if we want to calculate the energy collected
	                     for the ith interval (hour), we should read the value
	                     from the data file at t = t0 + i*dt.
	                     NOTE: if forecasting timestep is greater than the
	                     `pvd` or `wnd` timestep, we currently ignore the 
	                     intervening values.
	@param horizon       forecast horizon (hours)
	@param dt            forecasting timestep (hours)
	@param time_simul    current simulation timestep (seconds)
	@param etaH          electric heater efficiency (constant value)
	@param etaG          power block (generator) efficiency (constant value)
	@param DEmax         max dispatched THERMAL energy in an hour (MWhth)
	@param SLmax         maximum storage level (MWhth)
	@param SLinit        initial storage level, at time_simul (MWhth?)
	@param SLmin         minimum allowed storage level (MWhth)
	@param P_elec_max         Maximum heater capacity

	FIXME end-of-year wraparound is not yet implemented, will need checking.
*/
double st_linprog_variability(MotabData *pvd, MotabData *wnd
		,double P_elec_max_pv, double P_elec_max_wind
		,double P_elec_pv_ref_size, double P_elec_wind_ref_size
		,int horizon, double dt, double t0
		,double etaH, double etaG
		,double DEmax, double SLmax, double SLinit
		,double SLmin, double ramp_up_fraction, double P_elec_max
		,double pre_dispatched_heat
){
	MSG("\n\nt = %f",t0);

	double pvdstep, wndstep;
	assert(0 == motab_check_timestep(pvd,&pvdstep));
	assert(0 == motab_check_timestep(wnd,&wndstep));
	
	static MotabData *pvdcache, *wndcache;
	if(pvdcache != pvd){
		pvdcache = pvd;
		if(pvdstep != dt)ERR("Warning: pv file timestep is %f s, different"
			" from forecasting timestep %f s (message is only shown once)",pvdstep, dt);
	}
	if(wndcache != wnd){
		wndcache = wnd;
		if(wndstep != dt)ERR("Warning: wind file timestep is %fs, different"
			" from forecasting timestep %fs (message is only shown once)",wndstep, dt);
	}

	// check that pvd and wnd can cover the required time range

	MSG("t = %f s, dt = %f s:",t0,dt);
	MSG("P_elec_max_pv = %f MWt",P_elec_max);
	MSG("P_elec_max_wind = %f MWt",P_elec_max);
	MSG("P_elec_pv_ref_size = %f MWt",P_elec_max);
	MSG("P_elec_wind_ref_size = %f MWt",P_elec_max);
	MSG("P_elec_max = %f MWt",P_elec_max);
	MSG("etaH = %f MWt",etaH);
	MSG("etaG = %f MWt",etaG);
	MSG("DEmax = %f MWth",DEmax);
	MSG("SLmax = %f MWhth",SLmax);
	MSG("SLinit = %f MWhth",SLinit);
	MSG("SLmin = %f MWhth",SLmin);
	MSG("ramp_up_fraction = %f",ramp_up_fraction);
	MSG("pre_dispatched_heat = %f",pre_dispatched_heat);

	if(NULL==pvd)return ST_ERRVAL;
	if(NULL==wnd)return ST_ERRVAL;

	MSG("nrows pvd = %d",pvd->nrows);
	
	//assert(wnd->nrows == 8760);
	//assert(pvd->nrows == 8760);
	
	int wind_col = motab_find_col_by_label(wnd,"power");
	assert(wind_col != -1);

	int pv_col = motab_find_col_by_label(pvd,"power");
	assert(pv_col != -1);

#define WND(I) (\
	/*MSG("WND(%d) at t=%f",I,t0+((I)-1)*dt),*/\
	1e-6*P_elec_max_wind / P_elec_wind_ref_size*motab_get_value_wraparound(wnd,    t0+(I)*dt,wind_col)\
	)
/** as noted above, PV for the ith period (counting from 1) is at t0+i*dt */
#define PV(I) (\
	/*MSG("PV(%d) at t=%f",(I),t0+(I)*dt),*/\
	1e-6*P_elec_max_pv / P_elec_pv_ref_size*motab_get_value_wraparound(pvd,    t0+(I)*dt,pv_col)\
	)

	// Initialise problem object lp
	glp_prob *P = glp_create_prob();

	/* VARIABLES IN THE PROBLEM
	
	SL(i) (Storage Level) : Energy stored in the tank at end of ith hour [MWh_th]
	      Note: `SLinit` is the energy stored in the tank at the start of the 1st
	      hour, which is a supplied constant.
	DE(i) (Dispatch Energy) : Sold energy rate [MW_th], during the ith hour
	SE(i) (Storage Energy) : The input energy in the tank from the sun [MW_th], during the ith hour
	XE(i) (Dumped Energy) : Lost energy [MW_th], during the ith hour
	
	Note that these symbols SL(i) are not actually 'variables' but rather
	column numbers in the GLPK problem, and resolve into values from 1..4·N.
	
	`i`=1 means the first hour, i=2 means the second hour, etc.

	NOTE!! in GLPK, the indices count from 1, not 0!! This is very odd behaviour
	suggesting that possibly that a Fortran programmer might has lost their way.
	*/
	// These 4·N equations are organised with column indices as follows:

#define INCLUDE_RR
//#define INCLUDE_DEO
#define N (horizon)
#define SL(I) (I)
#define DE(I) (SL(N) + I)
#define SE(I) (DE(N) + I)
#define XE(I) (SE(N) + I)
#define RR(I) (XE(N) + I)

#ifdef INCLUDE_RR
	glp_add_cols(P, RR(N));
#else
	glp_add_cols(P, XE(N));
#endif

	MSG("Number of cols = %d",XE(N));
	
#define NAMEMAX 255
	char sss[NAMEMAX];
	for(int i=1; i<=N; ++i){
		snprintf(sss,NAMEMAX,"SL%02d",i); glp_set_col_name(P,SL(i),sss);
		snprintf(sss,NAMEMAX,"DE%02d",i); glp_set_col_name(P,DE(i),sss);
		snprintf(sss,NAMEMAX,"SE%02d",i); glp_set_col_name(P,SE(i),sss);
		snprintf(sss,NAMEMAX,"XE%02d",i); glp_set_col_name(P,XE(i),sss);
		#ifdef INCLUDE_RR
			snprintf(sss,NAMEMAX,"RR%02d",i); glp_set_col_name(P,RR(i),sss);
		#endif
	}

	double LCOH = 78;
	double RampCost = 0.0;
	/* OBJECTIVE FUNCTION*/
	glp_set_obj_dir(P, GLP_MAX);
	for(int i=1; i<= N; ++i){
		glp_set_obj_coef(P,DE(i),etaG*LCOH);
		#ifdef INCLUDE_RR
			glp_set_obj_coef(P,RR(i),-RampCost);
		#endif
	}
	
	/* VARIABLE BOUNDS*/
	for(int i=1; i<= N; ++i){
		double pvd_i = PV(i);
		double wnd_i = WND(i);
		assert(wnd_i != MOTAB_NO_REAL);
		assert(pvd_i != MOTAB_NO_REAL);
		double p_heat_i = (pvd_i + wnd_i)*etaH;
		if(p_heat_i > P_elec_max){
			p_heat_i = P_elec_max;
		}
		glp_set_col_bnds(P, SL(i), GLP_DB, SLmin, SLmax             );
		glp_set_col_bnds(P, DE(i), GLP_DB, 0    , DEmax             );
		#ifdef INCLUDE_RR
			glp_set_col_bnds(P, RR(i), GLP_DB, 0, ramp_up_fraction*DEmax);
		#endif
		if(pvd_i == 0 && wnd_i == 0){
			glp_set_col_bnds(P, SE(i), GLP_FX,0.,0.);
			glp_set_col_bnds(P, XE(i), GLP_FX,0.,0.);
		}else{
			glp_set_col_bnds(P, SE(i), GLP_DB, 0, p_heat_i);
			glp_set_col_bnds(P, XE(i), GLP_DB, 0, p_heat_i);
		}
	}
		
	/* CONSTRAINTS */
	
	// 2N+1 constraint equations are mapped as follows:
#define SEB(I) (I)    // stored energy balance, 1..N
#define EDX(I) (I+N)  // energy stored and dumped N+1...2N
#define LEB    (1+2*N)// 2N+1.

	glp_add_rows(P, LEB);
	
	MSG("Number of rows = %d",LEB);

	/*
	1. Dispatched energy balance (N equations)
		SLi - SLi-1 = SEi - DEi        Change in storage level equals
		                               net (stored minus dispatche) energy.	
		                               
		Terms on the left hand side are positive, right hand side negative.
	*/
	for(unsigned i=1;i<=N;++i){
		double pvd_i = PV(i);
		double wnd_i = WND(i);
		double p_heat_i = (pvd_i + wnd_i)*etaH;
		if(p_heat_i > P_elec_max){
			p_heat_i = P_elec_max;
		}
		if(i == 1){
			//MSG("SL(%d) = %d, SE(%i) = %d, DE(%d) = %d", i,SL(i),i,SE(i),i,DE(i));
			glp_set_mat_row(P, SEB(i), 3
				,   (int[]){0, SL(i),  SE(i),  DE(i)}
				,(double[]){0,  +1. ,    -1.,    +1.}
			);
			glp_set_row_bnds(P,SEB(i),GLP_FX,SLmin,99999);
		}else{
			//MSG("SL(%d) = %d, SE(%i) = %d, DE(%d) = %d", i,SL(i),i,SE(i),i,DE(i));
			glp_set_mat_row(P, SEB(i), 4
				,   (int[]){0, SL(i),  SL(i-1),  SE(i),  DE(i)}
				,(double[]){0, +1. ,    -1.  ,    -1.,    +1.}
			);
			glp_set_row_bnds(P,SEB(i),GLP_FX,0.,99999);
		}
		snprintf(sss,NAMEMAX,"SEB%02d",i); glp_set_row_name(P,SEB(i),sss);
	/*
	2. Stored energy balance (N equations)
		SEi + XEn = ηH·(PVi + WNDi)·Δt       Collected energy is either stored (SE)
		                                     or dumped (XE).
	*/
		glp_set_mat_row(P, EDX(i), 2
			,   (int[]){0, SE(i),  XE(i)}
			,(double[]){0,  +1. ,    +1.}
		);
		glp_set_row_bnds(P,EDX(i),GLP_FX,p_heat_i,99999);
		snprintf(sss,NAMEMAX,"EDX%02d",i); glp_set_row_name(P,EDX(i),sss);
	}
	/*
	3. Long-term energy balance (1 equation)
		∑(DEi-SEi) = 0                 No net change in storage level over
		                               the forecast interval.
		-- or --
		SL(N) = SLinit.
	*/
	glp_set_mat_row(P,LEB, 1
		,   (int[]){0, SL(N)}
		,(double[]){0,  +1. }
	);
	glp_set_row_bnds(P,LEB,GLP_FX,SLinit,99999);
	glp_set_row_name(P,LEB,"LEB");

	#ifdef INCLUDE_RR
		glp_add_rows(P, 2 * N);
		int base_idx_for_ramps = 2*N + 2;
		double DE0 = pre_dispatched_heat;

		for(unsigned i=1; i<=N; ++i){
			int row_idx_pos = base_idx_for_ramps + 2 * (i - 1);
			int row_idx_neg = base_idx_for_ramps + 2 * (i - 1) + 1;

			if(i == 1){
				#ifdef INCLUDE_DEO
					// RR(1) >= DE(1) - DE0
					glp_set_mat_row(P, row_idx_pos, 2
					,    (int[]){0, DE(1), RR(1)}
					, (double[]){0,    +1,   -1});
					glp_set_row_bnds(P, row_idx_pos, GLP_UP, DE0, 0);

					// RR(1) >= DE0 - DE(1)
					glp_set_mat_row(P, row_idx_neg, 2
					,    (int[]){0, DE(1), RR(1)}
					, (double[]){0,    -1,   -1});
					glp_set_row_bnds(P, row_idx_neg, GLP_UP,-DE0, 0);
				#else
					glp_set_mat_row(P, row_idx_pos, 1
					,    (int[]){0, RR(1)}
					, (double[]){0,   +1});
					glp_set_row_bnds(P, row_idx_pos, GLP_FX, 0.0, 0.0);
				#endif
			} else {
				// RR(i) >= DE(i) - DE(i-1)
				glp_set_mat_row(P, row_idx_pos, 3
				,    (int[]){0, DE(i), DE(i-1), RR(i)}
				, (double[]){0,    +1,      -1,   -1});
				glp_set_row_bnds(P, row_idx_pos, GLP_UP, 0, 0);

				// RR(i) >= DE(i-1) - DE(i)
				glp_set_mat_row(P, row_idx_neg, 3
				,    (int[]){0, DE(i-1), DE(i), RR(i)}
				, (double[]){0,      +1,    -1,   -1});
				glp_set_row_bnds(P, row_idx_neg, GLP_UP, 0, 0);
			}
		}
	#else
		glp_add_rows(P, 2 * N - 2);
		int base_idx_for_ramps = 2*N + 2;

		for(unsigned i=2; i<=N; ++i){
			int row_idx_pos = base_idx_for_ramps + 2 * (i - 2);
			int row_idx_neg = base_idx_for_ramps + 2 * (i - 2) + 1;

			// 0 >== DE(i) - DE(i-1)
			glp_set_mat_row(P, row_idx_pos, 2
			,    (int[]){0, DE(i), DE(i-1)}
			, (double[]){0,     1,     -1});
			glp_set_row_bnds(P, row_idx_pos, GLP_UP, ramp_up_fraction*DEmax, 0);

			// 0 >= DE(i-1) - DE(i)
			glp_set_mat_row(P, row_idx_neg, 2
			,    (int[]){0, DE(i-1), DE(i)}
			, (double[]){0,      +1,   -1});
			glp_set_row_bnds(P, row_idx_neg, GLP_UP, ramp_up_fraction*DEmax, 0);
		}
	#endif

	// Message attribute
	glp_smcp parm;
	glp_init_smcp(&parm);
#ifdef ST_LINPROG_DEBUG
	parm.msg_lev = GLP_MSG_ALL; // GLP_MSG_ERR;
#else
	parm.msg_lev = GLP_MSG_OFF;
#endif

	// Solve the lp
	int res = glp_simplex(P,&parm);
	int printres = 0;
	char *msg;
	if(res == 0){
		MSG("LP successfully solved");
		printres = 1;
	}else{
		switch(res){
		case GLP_EBADB: msg = "Invalid initial basis";break;
		case GLP_ESING: msg = "Singular matrix";break;
		case GLP_ECOND: msg = "Ill-conditioned matrix";break;
		case GLP_EBOUND:msg = "Incorrect bounds";break;
		case GLP_EFAIL: msg = "Solver failure";break;
		default: msg = "unrecognised error code";
		}

		//ERR("glp_simplex returned error code %d (%s)",res,msg);
		printres = 1;
		//return 0;
	}
	
	if(printres){
		//glp_print_sol(P,"glpksolution.txt");

		// Get the value of the optimal obj. function
		MSG("OPTIMAL OBJ FUNCTION = %f USD",glp_get_obj_val(P));

	}
	
	double optimalDispatch = glp_get_col_prim(P,DE(1));

		MSG("     SL,   SE,   XE,   DE,   RR");
	for(int i=1;i<N;++i){
		#ifdef INCLUDE_RR
			MSG("%3d: %.2f,%.2f,%.2f,%.2f,%.2f",i,glp_get_col_prim(P,SL(i)),glp_get_col_prim(P,SE(i)),glp_get_col_prim(P,XE(i)),glp_get_col_prim(P,DE(i)),glp_get_col_prim(P,RR(i)));
		#else
			MSG("%3d: %.2f,%.2f,%.2f,%.2f",i,glp_get_col_prim(P,SL(i)),glp_get_col_prim(P,SE(i)),glp_get_col_prim(P,XE(i)),glp_get_col_prim(P,DE(i)));
		#endif
	}
	MSG("OPTIMAL DISPATCH FOR THE NEXT HOUR: %f",optimalDispatch);

	/*Free all the memory used in this script*/
	glp_free_env();

	if(res){
		ERR("GLPK error %d: %s",res,msg);
		return -987654321;
	}

	/*end of the code*/
	return optimalDispatch;
}

// vim: ts=4:sw=4:noet:tw=80
