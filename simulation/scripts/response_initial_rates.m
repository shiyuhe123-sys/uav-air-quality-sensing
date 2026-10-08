function [p,audit] = response_initial_rates(p,flight)
%RESPONSE_INITIAL_RATES Use last measured body rate at/before initialization.
% RATE is logged gyro body angular rate (deg/s), not Euler angle derivative.
% Euler measurements already include AHRS trim: never subtract trim again.
start=p.RTL.SourceInterval_s(1);q=flight.Messages.RATE;
t=seconds(q.LogTime);good=all(isfinite(q{:,{'R','P','Y'}}),2);
index=find(t<=start & good,1,'last');assert(~isempty(index));
assert(start-t(index)<.2,'Initial angular-rate sample is stale.');
roll=-p.RTL.InitialState.phi0;pitch=-p.RTL.InitialState.theta0;
body=deg2rad(q{index,{'R','P','Y'}})';
transform=[1,sin(roll)*tan(pitch),cos(roll)*tan(pitch);...
    0,cos(roll),-sin(roll);0,sin(roll)/cos(pitch),cos(roll)/cos(pitch)];
euler=transform*body;model=euler.*[-1;-1;1];
p.RTL.InitialState.phi_dot0=model(1);
p.RTL.InitialState.theta_dot0=model(2);
p.RTL.InitialState.psi_dot0=model(3);
audit=struct('StartLogTime_s',start,'RateLogTime_s',t(index),...
    'BodyRates_degps',q{index,{'R','P','Y'}},'ModelEulerRates_radps',model',...
    'Rule','Last finite RATE at/before start; body-to-Euler conversion; negate roll/pitch. Used once, never injected during flight. Small autopilot/vehicle trim-frame uncertainty remains.');
end
