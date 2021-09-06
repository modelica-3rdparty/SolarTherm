within SolarTherm.Models.CSP.CRS.HeliostatsField;
model HeliostatsField_defocus
  extends Interfaces.Models.Heliostats;
  parameter nSI.Angle_deg lon=133.889 "Longitude (+ve East)" annotation(Dialog(group="System location"));
  parameter nSI.Angle_deg lat=-23.795 "Latitude (+ve North)" annotation(Dialog(group="System location"));
  parameter Integer n_h=1 "Number of heliostats" annotation(Dialog(group="Technical data"));
  parameter SI.Area A_h=4 "Heliostat's Area" annotation(Dialog(group="Technical data"));
  parameter Real he_av=0.99 "Heliostat availability" annotation(Dialog(group="Technical data"));
  replaceable model Optical =
      SolarTherm.Models.CSP.CRS.HeliostatsField.Optical.Constant
  constrainedby
    SolarTherm.Models.CSP.CRS.HeliostatsField.Optical.OpticalEfficiency
    "Total optical efficency"
    annotation (Dialog(group="Technical data",__Dymola_label="nu"), choicesAllMatching=true);
  parameter Boolean use_on = false
    "= true to display when solar field is connected"
      annotation (Dialog(group="Operating strategy"), Evaluate=true, HideResult=true, choices(checkBox=true));
  parameter Boolean use_defocus = false "= true to use defocus strategy"
      annotation (Dialog(group="Operating strategy"), Evaluate=true, HideResult=true, choices(checkBox=true));
  parameter Boolean use_wind = false "= true to use Wind-stop strategy"
      annotation (Dialog(group="Operating strategy"), Evaluate=true, HideResult=true, choices(checkBox=true));
  parameter SI.Angle ele_min=from_deg(8) "Heliostat stow deploy angle" annotation(min=0,Dialog(group="Operating strategy"));
  parameter SI.HeatFlowRate Q_design=529.412 "Receiver design input power (without heat losses)" annotation(min=0,Dialog(group="Operating strategy"));
  parameter Real nu_start=0.60 "Receiver energy start-up fraction" annotation(min=0,Dialog(group="Operating strategy"));
  parameter Real nu_min=0.25 "Minimum receiver turndown energy fraction" annotation(min=0,Dialog(group="Operating strategy"));
  Real nu_ope_field "Efficiency of the field on operation";
  //parameter Real nu_defocus=1 "Receiver limiter energy fraction at defocus state" annotation(Dialog(group="Operating strategy",enable=use_defocus));
  parameter SI.Velocity Wspd_max=15 "Wind stow speed" annotation(min=0,Dialog(group="Operating strategy",enable=use_wind));

  parameter SI.Energy E_start=90e3 "Start-up energy of a single heliostat" annotation(Dialog(group="Parasitic loads"));
  parameter SI.Power W_track=0.055e3 "Tracking power for a single heliostat" annotation(Dialog(group="Parasitic loads"));
  
  Optical optical(hra=solar.hra, dec=solar.dec, lat=lat,dni=solar.dni);
  SI.HeatFlowRate Q_rec_inc_max;
  SI.HeatFlowRate Q_rec_inc;
  SI.HeatFlowRate Q_avail;
  SI.HeatFlowRate Q_field_avail;
  //SI.HeatFlowRate Q_optic_loss;

  Modelica.Blocks.Interfaces.BooleanOutput on if use_on annotation (Placement(
        transformation(extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={0,-100}),                           iconTransformation(extent={{-12,-12},
            {12,12}},
        rotation=-90,
        origin={0,-100})));
  Modelica.Blocks.Interfaces.BooleanInput defocus if use_defocus annotation (Placement(
        transformation(extent={{-126,-88},{-86,-48}}),iconTransformation(extent={{-110,
            -72},{-86,-48}})));

  Modelica.Blocks.Interfaces.RealInput Wspd if use_wind annotation (Placement(
        transformation(extent={{-126,50},{-86,90}}), iconTransformation(extent={
            {-110,50},{-86,74}})));

  SI.Angle elo;
  SI.Angle ele;
  SI.Angle zen;
  SI.Angle zen2;
  SI.Angle azi;
  SI.Energy E_dni;
  SI.Energy E_avail;
  //SI.Energy E_rec_inc_max;
  SI.Energy E_defoc_ele;
  SI.Energy E_defoc_wind;
  SI.Energy E_defoc_max;
  SI.Energy E_defoc_low;
  SI.Energy E_defoc_storage;
  SI.Energy E_defoc_HX;
  SI.Energy E_optic_loss;
  SI.Energy E_rec_inc;
  
  
  SI.HeatFlowRate Q_field_HX_max "Variable heat flow rate for dumping due to field oversizing";
  SI.HeatFlowRate Q_field_PB_in "Heat flow rate limiter at defocus state" annotation(Dialog(group="Operating strategy",enable=use_defocus));
  SI.Power W_loss;
  Real damping;
//protected
  Boolean on_hf;
protected
  SI.Power W_loss1;
  SI.Power W_loss2;
  //SI.Time t_start=30*60;
  parameter SI.Time t_start=3600 "Start-up traking delay";
  discrete Modelica.SIunits.Time t_on(start=0, fixed=true) "Sunrise time instant";
  Modelica.Blocks.Interfaces.BooleanInput on_internal
    "Needed to connect to conditional connector";
  Modelica.Blocks.Interfaces.BooleanInput defocus_internal
    "Needed to connect to conditional connector";
  Modelica.Blocks.Interfaces.RealInput Wspd_internal
    "Needed to connect to conditional connector";
  parameter SI.HeatFlowRate Q_start=nu_start*Q_design "Heliostat field start power" annotation(min=0,Dialog(group="Operating strategy"));
  parameter SI.HeatFlowRate Q_min=nu_min*Q_design "Heliostat field turndown power" annotation(min=0,Dialog(group="Operating strategy"));
 

initial equation
   on_internal=Q_rec_inc_max>Q_start;
equation
  if use_on then
    connect(on,on_internal);
  end if;
  if use_defocus then
    connect(defocus,defocus_internal);
  else
    defocus_internal = false;
  end if;
  if use_wind then
    connect(Wspd,Wspd_internal);
  else
    Wspd_internal = -1;
  end if;
  nu_ope_field = optical.nu/(1-optical.nu_unavail);
  on_hf=(ele>ele_min) and
                     (Wspd_internal<Wspd_max);
  if ele>ele_min then
    //Q_avail = max(he_av*n_h*A_h*solar.dni,0);
    der(E_defoc_ele) = 0;
    if Wspd_internal<Wspd_max then
      Q_avail = max(he_av*n_h*A_h*solar.dni,0);
      der(E_defoc_wind) = 0;
    else
      Q_avail = 0;
      der(E_defoc_wind) = max(he_av*n_h*A_h*solar.dni,0);
    end if;
  else
    Q_avail = 0;
    der(E_defoc_wind) = 0;
    der(E_defoc_ele) = max(he_av*n_h*A_h*solar.dni,0);
  end if;
  //Q_avail = if on_hf then max(he_av*n_h*A_h*solar.dni,0) else 0;
  
  Q_field_avail= if on_hf then max(n_h*A_h*solar.dni*min(he_av,1-optical.nu_unavail),0) else 0;
  Q_rec_inc_max= if on_hf then max(he_av*n_h*A_h*solar.dni*optical.nu,0) else 0;
  
  when Q_rec_inc_max>Q_start then
    on_internal=true;
  elsewhen Q_rec_inc_max<Q_min then
    on_internal=false;
  end when;

  if on_internal then
    if defocus_internal then
      Q_rec_inc=min(Q_field_PB_in,Q_rec_inc_max);
      der(E_defoc_storage) = (min(Q_field_HX_max,Q_rec_inc_max)-Q_rec_inc)/nu_ope_field;
      der(E_defoc_HX) = (Q_rec_inc_max-min(Q_field_HX_max,Q_rec_inc_max))/nu_ope_field;
      der(E_defoc_low) = 0;
    else
      Q_rec_inc=min(Q_field_HX_max,Q_rec_inc_max);
      der(E_defoc_HX)=(Q_rec_inc_max-Q_rec_inc)/nu_ope_field;
      der(E_defoc_storage) = 0;
      der(E_defoc_low) = 0;
    end if;      
    der(E_optic_loss) = Q_field_avail-(Q_rec_inc_max-Q_rec_inc)/nu_ope_field-Q_rec_inc;
  else 
    Q_rec_inc=0;
    der(E_defoc_low) = Q_field_avail;
    der(E_defoc_HX)=0;
    der(E_defoc_storage) = 0;
    der(E_optic_loss) = 0;
  end if;
  
  
  //Q_rec_inc= if on_internal then (if defocus_internal then min(Q_defocus,Q_rec_inc_max) else min(Q_field_HX_max,Q_rec_inc_max)) else 0;
  heat.Q_flow= -Q_rec_inc;
  elo=SolarTherm.Models.Sources.SolarFunctions.eclipticLongitude(solar.dec);
//   optical.hra=solar.hra;
//   optical.dec=solar.dec;

  ele=SolarTherm.Models.Sources.SolarFunctions.elevationAngle(
    solar.dec,
    solar.hra,
    lat);
  zen=pi/2-ele;
  zen2=SolarTherm.Models.Sources.SolarFunctions.aparentSolarZenith(
    solar.dec,
    solar.hra,
    lat);
  azi=SolarTherm.Models.Sources.SolarFunctions.solarAzimuth(
    solar.dec,
    solar.hra,
    lat);

  der(E_dni) = he_av*n_h*A_h*solar.dni;
  der(E_avail) = Q_avail;
  der(E_defoc_max) = Q_avail-Q_field_avail;
  der(E_rec_inc) = Q_rec_inc;
  damping= if on_internal then Q_rec_inc/(Q_rec_inc_max+1e-3) else 1;
  W_loss1=if ele>1e-2 then n_h*he_av*damping*W_track else 0;
  when ele>1e-2 then
    t_on=time;
  end when;
  W_loss2= if time<t_on+t_start then n_h*he_av*damping*E_start/t_start else 0;
  W_loss=W_loss1+W_loss2;
  annotation (Documentation(info="<html>
</html>", revisions="<html>
<ul>
<li>Alberto de la Calle:<br>Released first version. </li>
</ul>
</html>"));
end HeliostatsField_defocus;