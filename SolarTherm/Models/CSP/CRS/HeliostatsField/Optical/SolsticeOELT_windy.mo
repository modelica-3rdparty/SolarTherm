within SolarTherm.Models.CSP.CRS.HeliostatsField.Optical;
model SolsticeOELT_windy "Lookup table generated by Solstice"
extends OpticalEfficiency;
    import SolarTherm.Models.CSP.CRS.HeliostatsField.Optical.SolsticePyFunc;
    import SI = Modelica.SIunits;
	//import nSI = Modelica.SIunits.Conversions.NonSIunits;
	//import SI = Modelica.SIunits;

    parameter SolarTherm.Types.Solar_angles angles=SolarTherm.Types.Solar_angles.dec_hra
    "Table angles"
        annotation (Dialog(group="Table data interpretation"));

	parameter String ppath = Modelica.Utilities.Files.loadResource("modelica://SolarTherm/Resources/Library") "Absolute path to the Python script";
	parameter String pname = "run_solstice_windy" "Name of the Python script";
	//parameter String pfunc = "run_simul" "Name of the Python functiuon"; 

    parameter String psave = Modelica.Utilities.Files.loadResource("modelica://SolarTherm/Resources/tmp/solstice-result/demo") "the directory for saving the results"; 
    parameter String field_type = "polar" "Other options are : surround";
    parameter String rcv_type = "flat" "other options are : flat, cylinder, stl";  
	parameter String wea_file = Modelica.Utilities.Files.loadResource("modelica://SolarTherm/Data/Weather/example_TMY3.motab"); 
  parameter String sunshape = "buie" "Buie sunshape (buie) or pillbox sunshape (pillbox)"; 
  parameter Real buie_csr=0.02 "circum solar ratio for Buie sunshape";  
  
	parameter Integer argc =25 "Number of variables to be passed to the C function";
	
	parameter Boolean set_swaying_optical_eff = false "if true = optical efficiency will depend on the wind speed (swaying effect)";
	parameter Boolean get_optics_breakdown = false "if true, the breakdown of the optical performance will be processed";
  parameter Boolean optics_verbose = false "[H&T] true if to save all the optical simulation details";
  parameter Boolean optics_view_scene = false "[H&T] true if to visualise the optical simulation scene (generate vtk files)";
  
    //parameter Boolean single_field = true "True for single field, false for multi tower";
    //parameter Boolean concrete_tower = true "True for concrete, false for thrust tower";
    parameter Real method = 1 "method of the system deisng, 1 is design from the PB, and 2 is design from the field";
    parameter Real n_helios=1000 "Number of heliostats";
    parameter SI.HeatFlowRate Q_in_rcv = 1e6;
    parameter SI.Length H_rcv=10 "Receiver aperture height";
    parameter SI.Length W_rcv=10 "Receiver aperture width";
    parameter Real n_H_rcv=10 "num of grid in the vertical direction (for flux map)";
    parameter Real n_W_rcv=10 "num of grid in the horizontal/circumferetial direction (for flux map)";
    parameter nSI.Angle_deg tilt_rcv = 0 "tilt of receiver in degree relative to tower axis";
    parameter SI.Length W_helio = 10 "width of heliostat in m";
    parameter SI.Length H_helio = 10 "height of heliostat in m";
    parameter SI.Length H_tower = 100 "Tower height";
    parameter SI.Length R_tower = 0.01 "Tower diameter";
    parameter SI.Length R1=80 "distance between the first row heliostat and the tower";
    parameter Real fb=0.7 "factor to grow the field layout";
 	parameter SI.Efficiency helio_refl = 0.9 "The effective heliostat reflectance";
    parameter SI.Angle slope_error = 1.53e-3 "slope error of heliostats, in radiance";
    parameter SI.Angle slope_error_windy = 2e-3 "a larger optical error of heliostats under windy conditions, in radiance";

    parameter Real n_row_oelt = 3 "number of rows of the look up table (simulated days in a year)";
    parameter Real n_col_oelt = 3 "number of columns of the lookup table (simulated hours per day)";
    parameter Real n_rays = 5e6 "number of rays for the optical simulation";
    parameter Real n_procs = 0 "number of processors, 0 is using maximum available num cpu, 1 is 1 CPU,i.e run in series mode";

    parameter String tablefile(fixed=false);
    parameter Integer tablefile_status(fixed=false);  
    parameter Integer windy_optics(fixed=false) "simulate the windy oelt or not? 1 is yes, 0 is no";
  	parameter Integer verbose(fixed=false) "save all the optical simulation details or not? 1 is yes, 0 is no";
  	parameter Integer gen_vtk(fixed=false) "visualise the optical simulation scene or not? 1 is yes, 0 is no";
  
    SI.Angle angle1;
    SI.Angle angle2;
    SI.Efficiency nu_windy;
    SI.Efficiency nu_spil_windy;
    SI.Efficiency nu_cosine_windy;
    SI.Efficiency nu_spil;
    SI.Efficiency nu_cosine;

  Modelica.Blocks.Tables.CombiTable2D nu_table(
    tableOnFile=true,
    tableName="optics",
    smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
    fileName=tablefile)
  annotation (Placement(transformation(extent={{12,12},{32,32}})));
  
  Modelica.Blocks.Tables.CombiTable2D nu_table_windy(
    tableOnFile=true,
    tableName= if set_swaying_optical_eff then "optics_windy" else "optics",
    smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
    fileName=tablefile)
  annotation (Placement(visible = true, transformation(extent = {{16, -38}, {36, -18}}, rotation = 0)));


  Modelica.Blocks.Tables.CombiTable2D nu_table_spil(
    tableOnFile=true,
    tableName= if get_optics_breakdown then "eta_spillage" else "optics",
    smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
    fileName=tablefile)
  annotation (Placement(visible = true, transformation(extent = {{16, -38}, {36, -18}}, rotation = 0)));

  Modelica.Blocks.Tables.CombiTable2D nu_table_spil_windy(
    tableOnFile=true,
    tableName= if get_optics_breakdown and set_swaying_optical_eff then "eta_spillage_windy" else "optics",
    smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
    fileName=tablefile)
  annotation (Placement(visible = true, transformation(extent = {{16, -38}, {36, -18}}, rotation = 0)));


  Modelica.Blocks.Tables.CombiTable2D nu_table_cosine(
    tableOnFile=true,
    tableName= if get_optics_breakdown then "eta_cosine" else "optics",
    smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
    fileName=tablefile)
  annotation (Placement(visible = true, transformation(extent = {{16, -38}, {36, -18}}, rotation = 0)));

  Modelica.Blocks.Tables.CombiTable2D nu_table_cosine_windy(
    tableOnFile=true,
    tableName= if get_optics_breakdown and set_swaying_optical_eff then "eta_cosine_windy" else "optics",
    smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
    fileName=tablefile)
  annotation (Placement(visible = true, transformation(extent = {{16, -38}, {36, -18}}, rotation = 0)));

    
  Modelica.Blocks.Sources.RealExpression angle2_input(y=to_deg(angle2))
    annotation (Placement(transformation(extent={{-38,6},{-10,26}})));
    
  Modelica.Blocks.Sources.RealExpression angle1_input(y=to_deg(angle1))
    annotation (Placement(transformation(extent={{-38,22},{-10,42}})));

initial algorithm
  if set_swaying_optical_eff then windy_optics:=1;
  else windy_optics:=0;
  end if;
  
  if optics_verbose then verbose:=1;
  else verbose:=0;
  end if;

  if optics_view_scene then gen_vtk:=1;
  else gen_vtk:=0;
  end if;

initial equation
  tablefile_status = SolsticePyFunc(ppath, pname, psave, 
  		field_type, rcv_type, wea_file, sunshape, argc, 
  		{"method","csr","Q_in_rcv", "n_helios", "H_rcv", "W_rcv","n_H_rcv", "n_W_rcv", "tilt_rcv", "W_helio", "H_helio", "H_tower", "R_tower", "R1", "fb", "helio_refl", "slope_error", "slope_error_windy", "windy_optics", "n_row_oelt", "n_col_oelt", "n_rays", "n_procs" ,"verbose", "gen_vtk"}, 
  		{method, buie_csr, Q_in_rcv, n_helios, H_rcv, W_rcv,n_H_rcv, n_W_rcv, tilt_rcv, W_helio, H_helio, H_tower, R_tower, R1, fb, helio_refl, slope_error, slope_error_windy, windy_optics, n_row_oelt, n_col_oelt, n_rays, n_procs, verbose, gen_vtk}
  		); 

  tablefile = SolsticeStatusFunc(tablefile_status, psave);

equation
  if angles==SolarTherm.Types.Solar_angles.elo_hra then
    angle1=SolarTherm.Models.Sources.SolarFunctions.eclipticLongitude(dec);
    angle2=hra;
  elseif angles==SolarTherm.Types.Solar_angles.dec_hra then
    angle1=dec;
    angle2=hra;
  elseif angles==SolarTherm.Types.Solar_angles.ele_azi then
    angle1=SolarTherm.Models.Sources.SolarFunctions.elevationAngle(dec,hra,lat);
    angle2=SolarTherm.Models.Sources.SolarFunctions.solarAzimuth(dec,hra,lat);
  else
    angle1=SolarTherm.Models.Sources.SolarFunctions.solarZenith(dec,hra,lat);
    angle2=SolarTherm.Models.Sources.SolarFunctions.solarAzimuth(dec,hra,lat);
  end if;
  
  nu=max(0,nu_table.y);
  nu_windy=max(0,nu_table_windy.y);

  nu_spil=if get_optics_breakdown then max(0,nu_table_spil.y) else 0;
  nu_spil_windy=if get_optics_breakdown and set_swaying_optical_eff then max(0,nu_table_spil_windy.y) else 0;

  nu_cosine=if get_optics_breakdown then max(0,nu_table_cosine.y) else 0;
  nu_cosine_windy=if get_optics_breakdown and set_swaying_optical_eff then max(0,nu_table_cosine_windy.y) else 0;

  connect(angle1_input.y, nu_table.u1) annotation (Line(points={{-8.6,32},{2,32},
          {2,28},{10,28}}, color={0,0,127}));
  connect(angle1_input.y, nu_table_windy.u1) annotation(
    Line(points = {{-8, 32}, {2, 32}, {2, -22}, {14, -22}, {14, -22}}, color = {0, 0, 127}));
  connect(angle1_input.y, nu_table_spil.u1) annotation (Line(points={{-8.6,32},{2,32},
          {2,28},{10,28}}, color={0,0,127}));
  connect(angle1_input.y, nu_table_spil_windy.u1) annotation(
    Line(points = {{-8, 32}, {2, 32}, {2, -22}, {14, -22}, {14, -22}}, color = {0, 0, 127}));
  connect(angle1_input.y, nu_table_cosine.u1) annotation (Line(points={{-8.6,32},{2,32},
          {2,28},{10,28}}, color={0,0,127}));
  connect(angle1_input.y, nu_table_cosine_windy.u1) annotation(
    Line(points = {{-8, 32}, {2, 32}, {2, -22}, {14, -22}, {14, -22}}, color = {0, 0, 127}));


  connect(angle2_input.y, nu_table.u2) annotation(
    Line(points = {{-8, 16}, {10, 16}, {10, 16}, {10, 16}}, color = {0, 0, 127}));
  connect(angle2_input.y, nu_table_windy.u2) annotation(
    Line(points = {{-8, 16}, {-8, 16}, {-8, -34}, {14, -34}, {14, -34}}, color = {0, 0, 127}));
  connect(angle2_input.y, nu_table_spil.u2) annotation(
    Line(points = {{-8, 16}, {10, 16}, {10, 16}, {10, 16}}, color = {0, 0, 127}));
  connect(angle2_input.y, nu_table_spil_windy.u2) annotation(
    Line(points = {{-8, 16}, {-8, 16}, {-8, -34}, {14, -34}, {14, -34}}, color = {0, 0, 127}));
  connect(angle2_input.y, nu_table_cosine.u2) annotation(
    Line(points = {{-8, 16}, {10, 16}, {10, 16}, {10, 16}}, color = {0, 0, 127}));
  connect(angle2_input.y, nu_table_cosine_windy.u2) annotation(
    Line(points = {{-8, 16}, {-8, 16}, {-8, -34}, {14, -34}, {14, -34}}, color = {0, 0, 127}));

end SolsticeOELT_windy;
