within examples;
model FlowPathStress
	// Importing modules
	extends Modelica.Icons.Example;
	import SI = Modelica.SIunits;
	import Modelica.SIunits.Conversions.*;
	import SolarTherm.Utilities.*;
	
	// Parameters
	parameter Boolean hardwired = false "true for hard-wired or false to calculated values";
	parameter Integer N = 100 "Number of tube segments in flowpath";
	parameter Boolean verbose = false;
	parameter String fileName = Modelica.Utilities.Files.loadResource("modelica://SolarTherm/Data/Data/flow_paths.csv");
	parameter String wea_file = Modelica.Utilities.Files.loadResource("modelica://SolarTherm/Data/Weather/Daggett_Ca_TMY32.motab");
	parameter Integer fpath = 6 "Number of flowpaths";
	parameter SI.Temperature T_rec_in = from_degC(520) "Receiver inlet temperature (Celsius)";
	parameter SI.Radius tb_r_i = 0.02895 "Tube inner radius";
	parameter SI.Radius tb_r_o = 0.03015 "Tube outer radius";
	parameter SI.Density rho = SolarTherm.Media.Sodium.Sodium_utilities.rho_T(T_rec_in) "Density of sodium";
	parameter SI.Area area = Modelica.Constants.pi*tb_r_i^2 "Inner tube area";
	parameter SI.MassFlowRate m_flow_tb = if hardwired then 3.5269595732913426 else 2.97*rho*area "Tube mass flow rate";

	parameter Integer nt = 91;
	parameter SI.Length dz = 14.5/50 "Longitude of the pipe segment";
	parameter SI.ThermalResistance R_fouling = 0;
	parameter SI.ThermalConductivity kp = 21 "Thermal conductivity of pipe metal";
	parameter SI.Efficiency ab = 0.98 "Coating absorptance";
	parameter SI.Efficiency em = 0.91 "Coating emmisivity";
	parameter SI.LinearExpansionCoefficient alpha = 18.5e-6 "Linear expansion coefficient of pipe metal";
	parameter SI.Stress E = 165e9 "Young's modulus of elasticity of pipe metal";
	parameter Real nu = 0.31 "Coefficient of Poisson for pipe metal";
	parameter SI.CoefficientOfHeatTransfer h_ext = 30 "Heat transfer coefficiente due to external convection";

	// Models
	Modelica.Blocks.Types.ExternalCombiTable1D wea_table = Modelica.Blocks.Types.ExternalCombiTable1D(
		tableName = "data",
		fileName = wea_file,
		table = fill(0.0, 0, 2),
		columns = 1:11,
		smoothness = Modelica.Blocks.Types.Smoothness.ContinuousDerivative);

	// Thermo-elastic stress
	Real stress_fpath1[N];
	Real stress_fpath2[N];
	Real stress_fpath3[N];
	Real stress_fpath4[N];
	Real stress_fpath5[N];
	Real stress_fpath6[N];

	// Surface temperature at tube crown
	Real T_crow_fpath1[N];
	Real T_crow_fpath2[N];
	Real T_crow_fpath3[N];
	Real T_crow_fpath4[N];
	Real T_crow_fpath5[N];
	Real T_crow_fpath6[N];

	// Surface temperature at tube crown
	Real T_fluid_fpath1[N];
	Real T_fluid_fpath2[N];
	Real T_fluid_fpath3[N];
	Real T_fluid_fpath4[N];
	Real T_fluid_fpath5[N];
	Real T_fluid_fpath6[N];

	// Solar flux distribution along flowpath
	SI.HeatFlux solar_flux_fpath1[N];
	SI.HeatFlux solar_flux_fpath2[N];
	SI.HeatFlux solar_flux_fpath3[N];
	SI.HeatFlux solar_flux_fpath4[N];
	SI.HeatFlux solar_flux_fpath5[N];
	SI.HeatFlux solar_flux_fpath6[N];

protected
	// Importing flux data
	String stringVector[N] = Modelica.Utilities.Streams.readFile(fileName);
	Real real[N,fpath];
	Integer k;
	SI.Temperature Tamb "Ambient temperature at design";

algorithm
	Tamb := from_degC(horizon_function(6955200, 5, wea_table));
	for i in 1:N loop
		k:=0;
		for j in 1:fpath loop
			(real[i,j], k) := Modelica.Utilities.Strings.scanReal(stringVector[i], k+1);
		end for;
		solar_flux_fpath1[i] := real[i,1]*1e3;
		solar_flux_fpath2[i] := real[i,2]*1e3;
		solar_flux_fpath3[i] := real[i,3]*1e3;
		solar_flux_fpath4[i] := real[i,4]*1e3;
		solar_flux_fpath5[i] := real[i,5]*1e3;
		solar_flux_fpath6[i] := real[i,6]*1e3;
	end for;
equation
	(T_crow_fpath1, T_fluid_fpath1, stress_fpath1) = NASHTubeStress(tb_r_i, tb_r_o, dz, m_flow_tb, T_rec_in, Tamb, solar_flux_fpath1, nt, N, R_fouling, ab, em, kp, h_ext, alpha, E, nu);
	(T_crow_fpath2, T_fluid_fpath2, stress_fpath2) = NASHTubeStress(tb_r_i, tb_r_o, dz, m_flow_tb, T_rec_in, Tamb, solar_flux_fpath2, nt, N, R_fouling, ab, em, kp, h_ext, alpha, E, nu);
	(T_crow_fpath3, T_fluid_fpath3, stress_fpath3) = NASHTubeStress(tb_r_i, tb_r_o, dz, m_flow_tb, T_rec_in, Tamb, solar_flux_fpath3, nt, N, R_fouling, ab, em, kp, h_ext, alpha, E, nu);
	(T_crow_fpath4, T_fluid_fpath4, stress_fpath4) = NASHTubeStress(tb_r_i, tb_r_o, dz, m_flow_tb, T_rec_in, Tamb, solar_flux_fpath4, nt, N, R_fouling, ab, em, kp, h_ext, alpha, E, nu);
	(T_crow_fpath5, T_fluid_fpath5, stress_fpath5) = NASHTubeStress(tb_r_i, tb_r_o, dz, m_flow_tb, T_rec_in, Tamb, solar_flux_fpath5, nt, N, R_fouling, ab, em, kp, h_ext, alpha, E, nu);
	(T_crow_fpath6, T_fluid_fpath6, stress_fpath6) = NASHTubeStress(tb_r_i, tb_r_o, dz, m_flow_tb, T_rec_in, Tamb, solar_flux_fpath6, nt, N, R_fouling, ab, em, kp, h_ext, alpha, E, nu);
	annotation(experiment(StartTime=0.0, StopTime=1.0, Interval=0.2, Tolerance=1e-06));
end FlowPathStress;
