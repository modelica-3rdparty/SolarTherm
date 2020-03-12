within SolarTherm.Models.CSP.CRS.HeliostatsField.Optical;
model SolsticeOELT "Lookup table generated by Solstice"
extends OpticalEfficiency;
    import SolarTherm.Models.CSP.CRS.HeliostatsField.Optical.SolsticePyFunc;
    import SI = Modelica.SIunits;
	//import nSI = Modelica.SIunits.Conversions.NonSIunits;
	//import SI = Modelica.SIunits;

    parameter SolarTherm.Types.Solar_angles angles=SolarTherm.Types.Solar_angles.dec_hra
    "Table angles"
        annotation (Dialog(group="Table data interpretation"));

	parameter String ppath = Modelica.Utilities.Files.loadResource("modelica://SolarTherm/Resources/Include/SolsticePy") "Absolute path to the Python script";
	parameter String pname = "run_solstice" "Name of the Python script";
	parameter String pfunc = "run_simul" "Name of the Python functiuon"; 

    parameter String psave = Modelica.Utilities.Files.loadResource("modelica://SolarTherm/Resources/Include/SolsticePy/result/demo") "the directory for saving the results";  
    //parameter String psave="/media/ye/Researches/solstice-system/test0";
	parameter Integer argc =14 "Number of variables to be passed to the C function";

    //parameter String field_type = "polar" "Other options are : surround";
    //parameter Boolean single_field = true "True for single field, false for multi tower";
    //parameter Boolean concrete_tower = true "True for concrete, false for thrust tower";
    //parameter String rcv_type = "particle" "other options are : flat, cylindrical, stl";
    parameter SI.HeatFlowRate Q_in_rcv = 1e6;
    parameter SI.Length H_rcv=10 "Receiver aperture height";
    parameter SI.Length W_rcv=10 "Receiver aperture width";
    parameter nSI.Angle_deg tilt_rcv = 0 "tilt of receiver in degree relative to tower axis";
    parameter SI.Length W_helio = 10 "width of heliostat in m";
    parameter SI.Length H_helio = 10 "height of heliostat in m";
    parameter SI.Length H_tower = 100 "Tower height";
    parameter SI.Length R_tower = 0.01 "Tower diameter";
    parameter SI.Length R1=80 "distance between the first row heliostat and the tower";
    parameter Real fb=0.7 "factor to grow the field layout";
    parameter SI.Efficiency rho_helio = 0.9 "reflectivity of heliostat max =1";
    parameter SI.Angle slope_error = 2e-3 "slope error of the heliostat in mrad";
    parameter Real n_row_oelt = 3 "number of rows of the look up table (simulated days in a year)";
    parameter Real n_col_oelt = 3 "number of columns of the lookup table (simulated hours per day)";

    parameter String tablefile(fixed=false);

    SI.Angle angle1;
    SI.Angle angle2;

  Modelica.Blocks.Tables.CombiTable2D nu_table(
    tableOnFile=true,
    tableName="optics",
    smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
    fileName=tablefile)
    annotation (Placement(transformation(extent={{12,12},{32,32}})));
  Modelica.Blocks.Sources.RealExpression angle2_input(y=to_deg(angle2))
    annotation (Placement(transformation(extent={{-38,6},{-10,26}})));
  Modelica.Blocks.Sources.RealExpression angle1_input(y=to_deg(angle1))
    annotation (Placement(transformation(extent={{-38,22},{-10,42}})));

initial algorithm
tablefile := SolsticePyFunc(ppath, pname, pfunc, psave, argc, {"Q_in_rcv", "H_rcv", "W_rcv", "tilt_rcv", "W_helio", "H_helio", "H_tower", "R_tower", "R1", "fb", "rho_helio","slope_error", "n_row_oelt", "n_col_oelt"}, {Q_in_rcv, H_rcv, W_rcv, tilt_rcv, W_helio, H_helio, H_tower, R_tower, R1, fb, rho_helio,slope_error, n_row_oelt, n_col_oelt}); 

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
  connect(angle2_input.y, nu_table.u2)
    annotation (Line(points={{-8.6,16},{10,16}}, color={0,0,127}));
  connect(angle1_input.y, nu_table.u1) annotation (Line(points={{-8.6,32},{2,32},
          {2,28},{10,28}}, color={0,0,127}));


end SolsticeOELT;
