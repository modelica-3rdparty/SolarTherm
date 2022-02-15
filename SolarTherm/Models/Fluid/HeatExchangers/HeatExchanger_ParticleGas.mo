within SolarTherm.Models.Fluid.HeatExchangers;

model HeatExchanger_ParticleGas

import SI = Modelica.SIunits;
import CN = Modelica.Constants;

function LMTD
    input SI.Temperature T_hot_in;
    input SI.Temperature T_hot_out;
    input SI.Temperature T_cold_in;
    input SI.Temperature T_cold_out;
    output Real LMTD;
    
    protected
    Real delta_T1 = T_hot_in - T_cold_out;
    Real delta_T2 = T_hot_out - T_cold_in;
    
    algorithm
    LMTD := (delta_T1 - delta_T2)/ (Modelica.Math.log (delta_T1/delta_T2));
    
end LMTD;

import SolarTherm.Utilities.SurrogateModelsSingleOutput.*;

/*Neural Network*/
parameter String saved_model_dir = Modelica.Utilities.Files.loadResource("modelica://SolarTherm/Data/SurrogateModels/ParticleGasHX/surrogate_model");
parameter Boolean use_neural_network = true;
parameter Integer inputsize = 11;
parameter Integer outputsize = 1;
parameter Real[inputsize] X_max = {14.9807997423875,14.9807997423875,298.15,972.5555659639,1996.67581024453,1272.96858290273,972.378508161418,1999.30167647194,1282.52244184563,323.149752495861,1034.01381489696};
parameter Real[inputsize] X_min = {3.00012982940802,3.00012982940802,298.15,573.664546017781,255.355206431462,878.079631577602,723.293883223611,501.177597091302,779.729330767114,243.151089536449,443.712776411833};
parameter Real out_max = 2993.06526355177;
parameter Real out_min = 252.136593278538;

STNeuralNetwork session = STNeuralNetwork(saved_model_dir) if use_neural_network == true
"Initialise neural network session if use_neural_network == true";
/*
Real[inputsize] X = {
    W_HX,
    H_HX,
    T_in_AIR_DP,
    T_out_AIR_DP,
    m_dot_AIR_DP,
    T_in_PCL_DP,
    T_out_PCL_DP,
    m_dot_PCL_DP,
    T_in_pcl, --> from hot tank
    T_in_air, --> ambient temp
    T_out_air --> what we want
}
*/


/*HTF properties*/
replaceable package PCL = SolarTherm.Media.SolidParticles.CarboHSP_utilities;
replaceable package AIR = Modelica.Media.Air.ReferenceAir.Air_Utilities;

replaceable package Med_PCL = SolarTherm.Media.SolidParticles.CarboHSP_ph;
replaceable package Med_AIR = Modelica.Media.Air.ReferenceAir.Air_ph;

/*Controller parameters*/
parameter Real level_on = 20;
parameter Real level_off = 5;

/*Particle thermophysical properties*/
parameter SI.Length D_particle = 5e-3 "Particle diameter in m";
parameter SI.Efficiency eta_particle = 0.403 * (D_particle * 100)^0.14 "Particle volume fraction as a function of DP (source: P45 report)";
parameter SI.Volume V_particle = 4/3 * CN.pi * (D_particle/2) ^3 "Particle volume m3";
parameter SI.Volume A_particle = 4 * CN.pi * (D_particle/2) ^2 "Particle surface area m2";

/*On-design parameters*/
parameter Integer num_seg = 6 "Segmentation of heat exchanger";
parameter SI.Pressure p_working = 1e5 "Working pressure in Pa";

parameter SI.Length W_HX = 8 "Heat exchanger air manifold width in m";
parameter SI.Length H_HX = 8 "Heat exchanger air manifold height in m";

parameter SI.Temperature T_in_AIR_DP = 25 + 273.15 "Air inlet temperature at design point (K)";
parameter SI.Temperature T_out_AIR_DP = 500 + 273.15 "Air outlet temperature at design point (K)";
parameter SI.MassFlowRate m_dot_AIR_DP = 1000 "Desired mass flow rate of air at design point (kg/s)";

parameter SI.Temperature T_in_PCL_DP = 1073.15 "Particles inlet temperature at design point (K)";
parameter SI.Temperature T_out_PCL_DP = 550 + 273.15 "Particles outlet temperature at design point (K). Equals to the cold tank target temperature";

/*Calculated parameters*/
parameter SI.Power Q_HX_DP = m_dot_AIR_DP * (AIR.h_pT(p_working, T_out_AIR_DP) - AIR.h_pT(p_working, T_in_AIR_DP)) "HX thermal rating (W)";
    
parameter SI.MassFlowRate m_dot_PCL_DP = Q_HX_DP / (PCL.h_T(T_in_PCL_DP) - PCL.h_T(T_out_PCL_DP)) "Particles mass flow rate at design point (kg/s)";

parameter SI.Velocity[num_seg] U_air_DP(fixed=false) "Air velocity in m/s";

parameter SI.Temperature[num_seg+1] T_AIR_DP(
    each fixed=false
) "Temperature of the air across the HX at design point";

parameter SI.Temperature[num_seg+1] T_PCL_DP(
    each fixed=false
) "Temperature of the particles across the HX at design point";

parameter SI.Area A_HX(fixed=false, min = 1) "Heat exchanger area (m^2)";

parameter SI.SpecificEnthalpy[num_seg+1] h_PCL_DP(
    each fixed=false,
    start = linspace(PCL.h_T(T_in_PCL_DP), PCL.h_T(T_out_PCL_DP), num_seg+1),
    min = fill(0, num_seg+1)    
);
parameter SI.SpecificEnthalpy[num_seg+1] h_AIR_DP(
    each fixed=false,
    start = linspace(AIR.h_pT(p_working,T_out_AIR_DP), AIR.h_pT(p_working,T_in_AIR_DP), num_seg+1),
    min = fill(0, num_seg+1)
);

parameter SI.Area[num_seg] A_HX_dis(each fixed=false) "Heat exchanger segment area in m2";
parameter Real[num_seg] Nu_DP(each fixed=false) "Nusselt number at each HX segment";
parameter Real[num_seg] Pr_DP(each fixed=false) "Prandtl number at each HX segment";
parameter Real[num_seg] Re_DP(each fixed=false) "Reynolds number at each HX segment";
parameter SI.Density[num_seg] rho_air_DP(each fixed=false) "Air density at each HX segment kg/m3";
parameter SI.DynamicViscosity[num_seg] mu_air_DP(each fixed=false) "Air DynamicViscosity at each HX segment Pa.s";
parameter SI.SpecificHeatCapacity[num_seg] cp_air_DP(each fixed=false) "Air specific heat at each HX segment J/kg.K";
parameter SI.ThermalConductivity[num_seg] k_air_DP(each fixed=false) "Air thermal conductivity W/m.K";
parameter SI.CoefficientOfHeatTransfer[num_seg] U_HX_DP(each fixed=false) "Coefficient of heat transfer U-value in W m^-2 K^-1";

/*Parameter boolean*/
parameter Boolean HX_always_off = false;

/*Off design variables*/
SI.Temperature T_out_air "Later on this will be the air inlet temp.";
SI.MassFlowRate m_dot_air "Desired mass flow rate of air at operation";

//SI.Velocity U_air "Air flow speed";
//SI.Temperature T_out_pcl "The one that we calculate";
/*
Real[num_seg] Nu(each fixed=false) "Nusselt number at each HX segment";
Real[num_seg] Pr(each fixed=false) "Prandtl number at each HX segment";
Real[num_seg] Re(each fixed=false) "Reynolds number at each HX segment";
SI.Density[num_seg] rho_air(each fixed=false) "Air density at each HX segment kg/m3";
SI.DynamicViscosity[num_seg] mu_air(each fixed=false) "Air DynamicViscosity at each HX segment Pa.s";
SI.SpecificHeatCapacity[num_seg] cp_air(each fixed=false) "Air specific heat at each HX segment J/kg.K";
SI.ThermalConductivity[num_seg] k_air(each fixed=false) "Air thermal conductivity W/m.K";
SI.CoefficientOfHeatTransfer[num_seg] U_HX(each fixed=false) "Coefficient of heat transfer U-value in W m^-2 K^-1";
*/

SI.SpecificEnthalpy h_pcl_in;
SI.SpecificEnthalpy h_pcl_out;
SI.SpecificEnthalpy h_air_in;
SI.SpecificEnthalpy h_air_out;
SI.Temperature T_pcl_in;
SI.Temperature T_pcl_out;
SI.Power Q_HX "Heat duty HX";
Real[inputsize] X "input to neural network";
SI.MassFlowRate m_dot_pcl "mass flow rate of pcl at operation";

/*
SI.Temperature[num_seg+1] T_air(
    each fixed=false
) "Temperature of the air across the HX at design point";

SI.Temperature[num_seg+1] T_pcl(
    each fixed=false
) "Temperature of the particles across the HX at design point";


SI.SpecificEnthalpy[num_seg+1] h_pcl(
    each fixed=false,
    start = linspace(PCL.h_T(T_in_PCL_DP), PCL.h_T(T_out_PCL_DP), num_seg+1)
);
SI.SpecificEnthalpy[num_seg+1] h_air(
    each fixed=false,
    start = linspace(AIR.h_pT(p_working,T_out_AIR_DP), AIR.h_pT(p_working,T_in_AIR_DP), num_seg+1)
);
*/


Boolean on;

/*Fluid Connection*/
Modelica.Fluid.Interfaces.FluidPort_a particle_port_in(redeclare package Medium = Med_PCL) annotation(
  Placement(visible = true, transformation(origin = {-70, 30}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-70, 30}, extent = {{-4, -4}, {4, 4}}, rotation = 0)));

Modelica.Fluid.Interfaces.FluidPort_b particle_port_out(redeclare package Medium = Med_PCL) annotation(
  Placement(visible = true, transformation(origin = {70, 30}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {70, 30}, extent = {{-4, -4}, {4, 4}}, rotation = 0)));
Modelica.Blocks.Interfaces.RealInput L_hot_tank annotation(
    Placement(visible = true, transformation(origin = {23, 45}, extent = {{-9, -9}, {9, 9}}, rotation = -90), iconTransformation(origin = {23, 45}, extent = {{-9, -9}, {9, 9}}, rotation = -90)));
Modelica.Blocks.Interfaces.RealInput T_amb annotation(
    Placement(visible = true, transformation(origin = {-23, 45}, extent = {{-9, -9}, {9, 9}}, rotation = -90), iconTransformation(origin = {-23, 45}, extent = {{-9, -9}, {9, 9}}, rotation = -90)));
initial equation
/*
  DESIGN POINT CALCULATION
*/
on = L_hot_tank > level_on and L_hot_tank > level_off;

/*Boundary condition*/
h_PCL_DP[1] = PCL.h_T(T_in_PCL_DP);
h_PCL_DP[num_seg+1] = PCL.h_T(T_out_PCL_DP);

h_AIR_DP[1] = AIR.h_pT(p_working, T_out_AIR_DP);
h_AIR_DP[num_seg+1] = AIR.h_pT(p_working, T_in_AIR_DP);

T_PCL_DP[1] = T_in_PCL_DP;
T_PCL_DP[num_seg+1] = T_out_PCL_DP;

T_AIR_DP[1] = T_out_AIR_DP;
T_AIR_DP[num_seg+1] = T_in_AIR_DP;

/*Find the enthalpy and temperature*/
for i in 1: num_seg loop
    h_PCL_DP[i] - h_PCL_DP[i+1] =  Q_HX_DP/num_seg/m_dot_PCL_DP;
    h_AIR_DP[i] - h_AIR_DP[i+1] =  Q_HX_DP/num_seg/m_dot_AIR_DP;
end for;

for i in 2: num_seg loop
    T_PCL_DP[i] = PCL.T_h(h_PCL_DP[i]);
    T_AIR_DP[i] = AIR.T_ph(p_working, h_AIR_DP[i]);
end for;

//Loop over each HX segment -  index 1 is at the particle inlet port (air outlet port)
for i in 1:num_seg loop
    U_air_DP[i] = m_dot_AIR_DP/(
        AIR.rho_pT(p_working, 0.5 * (T_AIR_DP[i] + T_AIR_DP[i+1])) * W_HX * H_HX
    );

    //Let's calculate the U_air_DP[i] -- all air properties are evaluated at the average temperature
    rho_air_DP[i] = AIR.rho_pT(p_working, 0.5 * (T_AIR_DP[i] + T_AIR_DP[i+1]));
    
    mu_air_DP[i] = AIR.Transport.eta_dT(
        rho_air_DP[i],
        0.5 * (T_AIR_DP[i] + T_AIR_DP[i+1])
    );
    cp_air_DP[i] = AIR.cp_dT(
        rho_air_DP[i],
        0.5 * (T_AIR_DP[i] + T_AIR_DP[i+1])
    );
    
    k_air_DP[i] = AIR.Transport.lambda_dT(
        rho_air_DP[i],
        0.5 * (T_AIR_DP[i] + T_AIR_DP[i+1])      
    );
    
    Re_DP[i] =  rho_air_DP[i]* U_air_DP[i] * V_particle / ((1-eta_particle) * A_particle * mu_air_DP[i]);
    
    Pr_DP[i] = cp_air_DP[i] * mu_air_DP[i] / k_air_DP[i];
    
    Nu_DP[i] = 8.74 + 9.34 * (
        6 * (1-eta_particle)^0.2 * Re_DP[i]^0.2 * Pr_DP[i]^(1/3)
    );
    
    U_HX_DP[i] = Nu_DP[i] * k_air_DP[i] / D_particle;
    
    /*Calculate the required area*/
    //A_HX_dis[i] = (Q_HX_DP / num_seg) / (U_HX_DP[i] * 0.5 * ((T_PCL_DP[i] - T_AIR_DP[i]) + (T_PCL_DP[i+1] - T_AIR_DP[i+1]))) "Simmon Kamerling said that LMTD gives the same result as average delta temp";
    A_HX_dis[i] = (Q_HX_DP / num_seg) / (U_HX_DP[i] * LMTD(T_PCL_DP[i], T_PCL_DP[i+1], T_AIR_DP[i+1], T_AIR_DP[i]));   
end for;

A_HX = sum(A_HX_dis);

equation
/*
  OFF DESIGN CALCULATION
*/
when L_hot_tank > level_on then
    on = true;
elsewhen L_hot_tank < level_off then
    on = false;
end when;

h_pcl_in = inStream(particle_port_in.h_outflow);

T_pcl_in = PCL.T_h(h_pcl_in);

T_out_air = T_out_AIR_DP;
m_dot_air = m_dot_AIR_DP;
h_air_in = AIR.h_pT(p_working,T_amb);
h_air_out = AIR.h_pT(p_working,T_out_air);
Q_HX = m_dot_air * (h_air_out- h_air_in);

if use_neural_network then
    X = {    
        W_HX,
        H_HX,
        T_in_AIR_DP,
        T_out_AIR_DP,
        m_dot_AIR_DP,
        T_in_PCL_DP,
        T_out_PCL_DP,
        m_dot_PCL_DP,
        T_pcl_in,
        T_amb,
        T_out_air
  };
    
else
    X = fill(0,inputsize);
end if;

if on then
  if HX_always_off then
    m_dot_pcl = 0;
    h_pcl_out = PCL.h_T(T_out_PCL_DP);
  else
      if use_neural_network then
          m_dot_pcl = predict(
              session, X, inputsize, X_max, X_min, out_max, out_min
          );
      else
          m_dot_pcl = m_dot_PCL_DP "Mass flow rate of particle at design point";
      end if;
      h_pcl_out = h_pcl_in - Q_HX/particle_port_in.m_flow;
  end if;
    
else
    m_dot_pcl = 0 "Shut down the HX";
    h_pcl_out = PCL.h_T(T_out_PCL_DP);

end if;

T_pcl_out = PCL.T_h(h_pcl_out);

/*Connection equations*/
particle_port_in.m_flow = m_dot_pcl;

particle_port_in.p = particle_port_out.p;

particle_port_in.m_flow + particle_port_out.m_flow = 0 "Mass balance";

particle_port_in.h_outflow = inStream(particle_port_out.h_outflow);

particle_port_out.h_outflow = h_pcl_out;



//Boundary condition
/*
U_air = m_dot_air/(
    AIR.rho_pT(p_working, 0.5 * (T_in_air + T_air[1])) * W_HX * H_HX
);
h_pcl[1] = PCL.h_T(T_pcl[1]);
h_pcl[num_seg+1] = PCL.h_T(T_pcl[num_seg+1]);
h_air[1] = AIR.h_pT(p_working, T_air[1]);
h_air[num_seg+1] = AIR.h_pT(p_working, T_air[num_seg+1]);

T_air[1] = T_out_air "known";
T_air[num_seg+1] = T_in_air "known";
T_pcl[1] = T_in_pcl "From hot tank, known";
T_pcl[num_seg+1] = T_out_pcl "Needs to be calculated";
*/
/*
h_pcl[1] = inStream(particle_port_in.h_outflow);
h_pcl[num_seg+1] = PCL.h_T(T_pcl[num_seg+1]);
h_air[1] = AIR.h_pT(p_working, T_air[1]);
h_air[num_seg+1] = AIR.h_pT(p_working, T_air[num_seg+1]);

T_air[1] = T_out_air "known";
T_air[num_seg+1] = T_in_air "known";
T_pcl[1] = PCL.T_h(h_pcl[1]) "From hot tank, known";
T_pcl[num_seg+1] = T_out_pcl "Needs to be calculated";

for i in 2: num_seg loop
    T_pcl[i] = PCL.T_h(h_pcl[i]);
    T_air[i] = AIR.T_ph(p_working, h_air[i]);
end for;

for i in 2: num_seg loop
    m_dot_air * (h_air[i] - h_air[i+1]) =  m_dot_pcl * (h_pcl[i] - h_pcl[i+1]);
end for;

for i in 1:num_seg loop
  rho_air[i] = AIR.rho_pT(p_working, 0.5 * (T_air[i] + T_air[i+1]));
  
  mu_air[i] = AIR.Transport.eta_dT(
      rho_air[i],
      0.5 * (T_air[i] + T_air[i+1])
  );
  cp_air[i] = AIR.cp_dT(
      rho_air[i],
      0.5 * (T_air[i] + T_air[i+1])
  );
  
  k_air[i] = AIR.Transport.lambda_dT(
      rho_air[i],
      0.5 * (T_air[i] + T_air[i+1])     
  );
  
  Re[i] =  rho_air[i]* U_air * V_particle / ((1-eta_particle) * A_particle * mu_air[i]);
  
  Pr[i] = cp_air[i] * mu_air[i] / k_air[i];
  
  Nu[i] = 8.74 + 9.34 * (
      6 * (1-eta_particle)^0.2 * Re[i]^0.2 * Pr[i]^(1/3)
  );
  
  U_HX[i] = Nu[i] * k_air[i] / D_particle;
  
  m_dot_air * (h_air[i] - h_air[i+1])  = U_HX[i] * A_HX_dis[i] * 0.5 * (T_pcl[i] - T_air[i] + T_pcl[i+1] - T_air[i+1]);
  
end for;
*/
//Since there is no way to turn off the HX, the port is forced to draw zero mass flow rate
//particle_port_in.m_flow = if on then m_dot_pcl else 0;
//m_dot_pcl = if particle_port_in.m_flow >  100 then particle_port_in.m_flow else m_dot_PCL_DP;




//particle_port_out.h_outflow = if abs(m_dot_pcl - m_dot_PCL_DP) < 1 then PCL.h_T(T_pcl[1]) else h_pcl[num_seg+1];



  annotation(
    Diagram(graphics = {Rectangle(origin = {-1, 9}, extent = {{-59, 31}, {61, -49}}), Text(origin = {1, 1}, extent = {{-53, -17}, {51, 17}}, textString = "RECUPERATOR"), Line(origin = {0, -30}, points = {{70, 0}, {-70, 0}, {-70, 0}}), Line(origin = {0, 30}, points = {{-70, 0}, {70, 0}, {70, 0}}), Polygon(origin = {0, 30}, points = {{-4, 4}, {-4, -4}, {4, 0}, {-4, 4}, {-4, 4}}), Polygon(origin = {0, -30}, points = {{4, 4}, {4, -4}, {-4, 0}, {4, 4}, {4, 4}})}, coordinateSystem(initialScale = 0.1)),
    Icon(graphics = {Rectangle(origin = {-3, -9}, extent = {{-57, 49}, {63, -31}}), Text(origin = {0, 1}, extent = {{-48, -15}, {48, 15}}, textString = "RECUPERATOR"), Line(origin = {0, 30}, points = {{-70, 0}, {70, 0}, {70, 0}}), Line(origin = {0, -30}, points = {{-70, 0}, {70, 0}, {70, 0}}), Polygon(origin = {0, 30}, points = {{-4, 4}, {-4, -4}, {4, 0}, {-4, 4}, {-4, 4}}), Polygon(origin = {-2, -30}, points = {{4, 4}, {4, -4}, {-4, 0}, {4, 4}, {4, 4}})}, coordinateSystem(initialScale = 0.1)),
    Documentation(info = "<html>
		<p>This heat recuperator is a counter-flow HX. Closure equations are based on the equality of m_flow*delta_H for both sides and m_flow*delta_H= UA_i*DTAve_i, DTAve being the average of the temperature difference between the inlet and the outlet of the sub-HX.</p>
<p>The UA_i must be given as parameters from the on-design analysis.&nbsp;</p>
		
		</html>"));
end HeatExchanger_ParticleGas;
