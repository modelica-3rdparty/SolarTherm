within SolarTherm.Storage;
model FluidTank "Fluid tank"
	extends Modelica.Fluid.Interfaces.PartialTwoPort(
		allowFlowReversal=false);
	import SI = Modelica.SIunits;
	parameter SI.Mass m_max = 0 "Maximum mass";
	parameter SI.Mass m_start = 0 "Starting mass";
	parameter Medium.Temperature T_start = system.T_start "Starting temperature";
	parameter Medium.Pressure p_fixed = system.p_ambient "Fixed pressure";

	parameter SolarTherm.Utilities.Finances.Money C_cap = 0 "Capital costs";
	parameter SolarTherm.Utilities.Finances.MoneyPerYear C_main = 0 "Maintenance costs";
	SI.Mass m(min=0, max=m_mass) "Mass in tank";

	Medium.BaseProperties mprop;
initial equation
	m = m_start;
	mprop.T = T_start;
equation
	mprop.p = p_fixed;
	der(m) = port_a.m_flow + port_b.m_flow;
	port_b.h_outflow = mprop.h;
	port_a.h_outflow = mprop.h;
	der(m*mprop.h) = port_a.m_flow*inStream(port_a.h_outflow)
					+ port_b.m_flow*port_b.h_outflow;
end FluidSimple;
