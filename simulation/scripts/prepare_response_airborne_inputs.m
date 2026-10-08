function p = prepare_response_airborne_inputs(source,requested,configuration,physics,gravity,rotorSpeed)
%PREPARE_RESPONSE_AIRBORNE_INPUTS Frozen model inputs from a specified new log.
% requested=[start,end] must be an explicitly selected airborne interval.
% Configuration/physics are frozen aircraft coefficients, never prior states.
% Supports Stabilize(0), RTL(6) and Loiter(5); ground/crash are not modeled.
arguments
    source (1,1) string
    requested (1,2) double {mustBeFinite}
    configuration (1,1) struct
    physics (1,1) struct
    gravity (1,1) double {mustBePositive}
    rotorSpeed (1,1) double {mustBePositive}
end
assert(requested(2)>requested(1));s=load(source,'flight');f=s.flight;
ct=clean(f.Messages.CTUN,{'DAlt','Alt','CRt','ThO','ThH'});
at=clean(f.Messages.ATT,{'DesRoll','DesPitch','DesYaw','Roll','Pitch','Yaw'});
g=f.Messages.GPS;g=clean(g(g.I==0 & g.Status>=3,:),{'Lat','Lng','Alt'});
v=f.Messages.XKF1;v=clean(v(v.C==0,:),{'VN','VE','VD','PN','PE'});
pos=clean(f.Messages.POS,{'Lat','Lng','RelOriginAlt'});
streams={ct,at,g,v,pos};first=zeros(1,5);last=first;
for k=1:5
    t=seconds(streams{k}.LogTime);first(k)=t(1);last(k)=t(end);
    mask=t>=requested(1)-.2 & t<=requested(2)+.2;
    assert(sum(mask)>=10 && max(diff(t(mask)))<.5,'Flight signal coverage is inadequate.');
end
a=max([requested(1),first]);b=min([requested(2),last]);
if isfield(f.Messages,'MSG')
    messages=f.Messages.MSG;t=seconds(messages.LogTime);
    stop=t(messages.Message=="RC8: MotorEStop HIGH" & t>a);
    if ~isempty(stop),b=min(b,stop(1)-1e-6);end
end
assert(b-a>1,'Requested airborne interval has insufficient coverage.');
ct0=values(ct,a);gps0=values(g,a);pos0=values(pos,a);vel0=values(v,a);
% Keep enough boundary data for interpolation; unwrap only around this replay.
ta=seconds(at.LogTime);at=at(ta>=a-.2 & ta<=b+.2,:);
angles0=values(at,a,true);angles0=ardupilot_to_model_attitude(angles0(4:6));
r=struct('SourceDataset',source,'SourceInterval_s',[a,b],'Duration_s',b-a);
r.InitialState=struct('x0',0,'y0',0,'z0',ct0(2),'vx0',vel0(1),'vy0',vel0(2),...
    'vz0',-vel0(3),'phi0',angles0(1),'theta0',angles0(2),'psi0',angles0(3),...
    'phi_dot0',0,'theta_dot0',0,'psi_dot0',0);
r.GPSAltitudeOffset_m=ct0(2)-gps0(3);r.POSAltitudeOffset_m=ct0(2)-pos0(3);
r.CTUN=native(ct,a,b);r.ATT=native(at,a,b);
r.ATT{:,2:end}=rad2deg(unwrap(deg2rad(r.ATT{:,2:end}),[],1));
r.GPS=position(g,a,b,gps0,r.GPSAltitudeOffset_m,'Alt');
r.POS=position(pos,a,b,pos0,r.POSAltitudeOffset_m,'RelOriginAlt');
r.EKFVelocity=native(v(:,{'VN','VE','VD'}),a,b);
t=times(at,a,b);angles=values(at,t,true);commands=ardupilot_to_model_attitude(angles(:,1:3));
r.AttitudeDataset=Simulink.SimulationData.Dataset;
for k=1:3,r.AttitudeDataset=r.AttitudeDataset.addElement(timeseries(commands(:,k),t-a));end
r.AnimationATT=timeseries(ardupilot_to_model_attitude(angles(:,4:6)),t-a);
tc=times(ct,a,b);collective=values(ct,tc);
r.AttitudeDataset=r.AttitudeDataset.addElement(timeseries(collective(:,4),tc-a));
modes=f.Messages.MODE;mt=seconds(modes.LogTime);
index=find(mt<=a,1,'last');assert(~isempty(index));
inside=find(mt>a & mt<b);modeTime=[a;mt(inside)];mode=[modes.Mode(index);modes.Mode(inside)];
assert(all(ismember(mode,[0,5,6])),'Airborne interval contains an unsupported mode.');
isAuto=mode~=0;starts=find(isAuto & [true;~isAuto(1:end-1)]);
enableTime=a;enableValue=1;targetTime=a;targetValue=zeros(1,3);
origin=vel0(4:5);activation=zeros(numel(starts),1);
for j=1:numel(starts)
    begin=modeTime(starts(j));endIndex=find(~isAuto & modeTime>begin,1);
    finish=b;if ~isempty(endIndex),finish=modeTime(endIndex);end
    names={'PSCN','PSCE','PSCD'};fields={'TPN','TPE','DAD'};
    target=cell(1,3);available=zeros(1,3);
    for k=1:3
        assert(isfield(f.Messages,names{k}),'Required autonomous target stream missing.');
        q=clean(f.Messages.(names{k}),fields(k));tq=seconds(q.LogTime);
        q=q(tq>=begin & tq<=finish,:);tq=seconds(q.LogTime);
        assert(height(q)>=5 && tq(1)-begin<.2 && max(diff(tq))<.5,'Autonomous target gap is too large.');
        available(k)=tq(1);target{k}=q;
    end
    activation(j)=max(available);
    enableTime=[enableTime;activation(j)];enableValue=[enableValue;0]; %#ok<AGROW>
    if finish<b,enableTime=[enableTime;finish];enableValue=[enableValue;1];end %#ok<AGROW>
    t=activation(j);
    for k=1:3,tq=seconds(target{k}.LogTime);t=[t;tq(tq>activation(j) & tq<finish)];end %#ok<AGROW>
    t=unique([t;finish]);y=zeros(numel(t),3);
    for k=1:3
        q=target{k};tq=seconds(q.LogTime);
        y(:,k)=interp1(tq,q{:,1},min(t,tq(end)));
        if k<=2,y(:,k)=y(:,k)-origin(k);else,y(:,k)=-y(:,k);end
    end
    targetTime=[targetTime;t];targetValue=[targetValue;y]; %#ok<AGROW>
end
[enableTime,order]=sort(enableTime);enableValue=enableValue(order);
[enableTime,index]=unique(enableTime,'last');enableValue=enableValue(index);
if enableTime(end)<b,enableTime=[enableTime;b];enableValue=[enableValue;enableValue(end)];end
[targetTime,index]=unique(targetTime,'last');targetValue=targetValue(index,:);
if targetTime(end)<b,targetTime=[targetTime;b];targetValue=[targetValue;targetValue(end,:)];end
p=struct('RTL',r,'Configuration',configuration,'Physics',physics,'Gravity_mps2',gravity,...
    'HoverRotorSpeed_radps',rotorSpeed,'RequestedInterval_s',requested,'TargetOriginNE_m',origin,...
    'PreparationUTC',datetime('now','TimeZone','UTC'));
p.NorthTarget=timeseries(targetValue(:,1),targetTime-a);
p.EastTarget=timeseries(targetValue(:,2),targetTime-a);
p.AccelerationCommand=timeseries(targetValue(:,3),targetTime-a);
p.ManualEnable=timeseries(enableValue,enableTime-a);
p.ManualEnable.DataInfo.Interpolation=tsdata.interpolation('zoh');
if isempty(activation)
    r.AltitudeCommand=timeseries([r.InitialState.z0;r.InitialState.z0],[0;b-a]);
else
    t=[activation(1);tc(tc>activation(1) & tc<b);b];
    altitude=interp1(tc,collective(:,1),t);
    r.AltitudeCommand=timeseries([r.InitialState.z0;altitude],[0;t-a]);
end
p.RTL=r;[p,audit]=response_initial_rates(p,f);p.InitialRateAudit=audit;
p.ModeTimeline=table(modeTime,mode,'VariableNames',{'StartLogTime_s','LoggedMode'});
p.AutonomousActivationLogTimes_s=activation;
p.Notes=["Explicit supported airborne window. New log supplies initial state, one-time datums, measured-rate initialization and all logged command/reference streams.";...
    "Same frozen aircraft/controller coefficients; no previous-flight measured states or output fitting, no mode/split resets.";...
    "Manual desired ATT/ThO, autonomous recorded internal position/altitude targets with own feedback; conditional replay, not full ArduPilot autopilot replication.";...
    "Ground/spoolup/stop/crash dynamics excluded. Inactive controllers run in shadow; no firmware integrator-management replica. New-flight accuracy must be evaluated, never assumed." ];
end
function q=clean(q,names)
q=q(:,names);q=q(all(isfinite(q{:,:}),2),:);assert(all(diff(seconds(q.LogTime))>0));
end
function t=times(q,a,b)
t=seconds(q.LogTime);t=[a;t(t>a & t<b);b];
end
function data=values(q,t,angles)
if nargin<3,angles=false;end;data=q{:,:};
if angles,data=unwrap(deg2rad(data),[],1);end
data=interp1(seconds(q.LogTime),data,t);assert(all(isfinite(data),'all'));
end
function q=native(q,a,b)
t=seconds(q.LogTime);mask=t>=a & t<=b;q=timetable2table(q(mask,:),'ConvertRowTimes',false);
q=addvars(q,t(mask)-a,'Before',1,'NewVariableNames','Time_s');
end
function q=position(q,a,b,origin,offset,altitude)
q=native(q,a,b);q=table(q.Time_s,6378137*deg2rad(q.Lat-origin(1)),...
    6378137*cosd(origin(1))*deg2rad(q.Lng-origin(2)),q.(altitude)+offset,...
    'VariableNames',{'Time_s','North_m','East_m','Up_m'});
end
