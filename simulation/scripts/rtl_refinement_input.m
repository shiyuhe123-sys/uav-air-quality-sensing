function in = rtl_refinement_input(p,cfg,mdl)
%RTL_REFINEMENT_INPUT Fixed log inputs, simulation-only calibration settings.
if nargin<3,mdl='Drone_RTL_refinement_v3';end
in=Simulink.SimulationInput(mdl);
ki=0;if isfield(cfg,'Ki'),ki=cfg.Ki;end
in=in.setModelParameter('StopTime',sprintf('%.15g',p.RTL.Duration_s),'MaxStep','0.01','RelTol','1e-6','AbsTol','1e-8','ReturnWorkspaceOutputs','on');
in=in.setExternalInput(p.RTL.AttitudeDataset);
vars=struct('rtl_altitude_command',p.RTL.AltitudeCommand,'rtl_altitude_accel_command',p.AccelerationCommand,...
    'rtl_north_target',p.NorthTarget,'rtl_east_target',p.EastTarget,'flight_mode',3,'replay_enabled',1,...
    'm',3,'mg',3*p.Gravity_mps2,'inv_m',1/3,'omega_init',p.HoverRotorSpeed_radps,...
    'rtl_drag_rate',cfg.DragRate,'Kp_z',cfg.Kp,'Kd_z',cfg.Kd,'Ki_z',ki,'rtl_accel_ff_gain',cfg.FeedforwardGain,...
    'Kp_x',cfg.KpX,'Kd_x',cfg.KdX,'Kp_y',cfg.KpY,'Kd_y',cfg.KdY,...
    'Kp_psi',cfg.KpYaw,'Kd_psi',cfg.KdYaw);
names=fieldnames(vars);for k=1:numel(names),in=in.setVariable(names{k},vars.(names{k}),'Workspace',mdl);end
names=fieldnames(p.RTL.InitialState);
for k=1:numel(names),in=in.setVariable(names{k},p.RTL.InitialState.(names{k}),'Workspace',mdl);end
% Parallel PID filtered derivative: N*(D*error - filter_state).
% Initialize its state from the known initial error/rate, never later outputs.
altError=p.RTL.AltitudeCommand.Data(1)-p.RTL.InitialState.z0;
filterStates=[cfg.Kd*altError,0,0,0,0,0];ids=[63,244,247,184,8,92];
if cfg.ConditionAllFilters
    ex=p.NorthTarget.Data(1)-p.RTL.InitialState.x0;
    ey=p.EastTarget.Data(1)-p.RTL.InitialState.y0;
    exdot=slope(p.NorthTarget)-p.RTL.InitialState.vx0;
    eydot=slope(p.EastTarget)-p.RTL.InitialState.vy0;
    theta0=max(-0.1745,min(0.1745,cfg.KpX*ex+cfg.KdX*exdot));
    phi0=max(-0.1745,min(0.1745,-cfg.KpY*ey-cfg.KdY*eydot));
    yaw=p.RTL.InitialState.psi0;
    theta=max(-0.1745,min(0.1745,cos(yaw)*theta0-sin(yaw)*phi0));
    phi=max(-0.1745,min(0.1745,sin(yaw)*theta0+cos(yaw)*phi0));
    eyaw=p.RTL.AttitudeDataset{3}.Data(1)-yaw;
    yawdot=slope(p.RTL.AttitudeDataset{3})-p.RTL.InitialState.psi_dot0;
    ezdot=slope(p.RTL.AltitudeCommand)-p.RTL.InitialState.vz0;
    filterStates=[cfg.Kd*(altError-ezdot/100),cfg.KdX*(ex-exdot/100),...
        cfg.KdY*(ey-eydot/100),0.5*(phi-p.RTL.InitialState.phi0),...
        0.28*(theta-p.RTL.InitialState.theta0),cfg.KdYaw*(eyaw-yawdot/100)];
end
for k=1:numel(ids)
    in=in.setBlockParameter(Simulink.ID.getFullName(sprintf('%s:%d',mdl,ids(k))),...
        'InitialConditionForFilter',sprintf('%.15g',filterStates(k)));
end
end

function value=slope(sig)
value=(sig.Data(2)-sig.Data(1))/(sig.Time(2)-sig.Time(1));
end
