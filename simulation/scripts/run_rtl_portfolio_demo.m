function result = run_rtl_portfolio_demo(action)
%RUN_RTL_PORTFOLIO_DEMO Public, conditional same-flight RTL demonstration.
%   'verify' reruns frozen coefficients using the committed derived inputs.
%   'animate' displays the committed trajectory without rerunning simulation.
%   Original raw flight coordinates and the private flight log are unnecessary.
if nargin<1,action="animate";end
action=string(action);assert(ismember(action,["verify","animate"]));
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'model'),fullfile(root,'scripts'));
folder=fullfile(root,'evidence','rtl');
cfg=jsondecode(fileread(fullfile(folder,'configuration.json')));
duration=cfg.Duration_s;
r=struct('SourceInterval_s',cfg.Window_s(:)', 'Duration_s',duration,...
    'InitialState',cfg.InitialState);
r.AttitudeDataset=Simulink.SimulationData.Dataset;
for k=1:4,r.AttitudeDataset=r.AttitudeDataset.addElement(readseries(folder,sprintf('AttitudeInput%d',k)));end
r.AltitudeCommand=readseries(folder,'AltitudeCommand');
r.AnimationATT=readseries(folder,'AnimationATT');
names={'GPS','CTUN','ATT','EKFVelocity'};
for k=1:numel(names),r.(names{k})=readtable(fullfile(folder,[names{k},'.csv']),TextType="string");end
p=struct('RTL',r,'Physics',cfg.Physics,'Gravity_mps2',cfg.Gravity_mps2,...
    'HoverRotorSpeed_radps',cfg.HoverRotorSpeed_radps);
names={'NorthTarget','EastTarget','AccelerationCommand','ManualEnable'};
for k=1:numel(names),p.(names{k})=readseries(folder,names{k});end
p.ManualEnable.DataInfo.Interpolation=tsdata.interpolation('zoh');
assert(all(p.ManualEnable.Data==0),'The active comparison must remain RTL-only.');
frozen=readtable(fullfile(folder,'frozen-trajectory.csv'),TextType="string");
if action=="verify"
    % Resolve the preserved block SIDs before configuring SimulationInput.
    load_system(fullfile(root,'model','Drone_Response_v5.slx'));
    in=response_v5_input(p,cfg.Configuration,cfg.MaximumThrust_N,duration);
    out=sim(in);
    plan=struct('Components',string(cfg.Components(:)),'ToleranceFor8',cfg.ToleranceFor8(:)');
    score=general_response_score(r,out,plan,cfg.Window_s(:)');
    state=out.flight_visualization;
    difference=max(abs(state.Data-interp1(frozen.Time_s,frozen{:,2:end},state.Time)),[],'all');
    metricDifference=max(abs(score.Components.Error-cfg.ExpectedErrors(:)));
    assert(difference<5e-5,'Packaged trajectory differs from the frozen reference.');
    assert(metricDifference<1e-5,'Packaged native-time metrics changed.');
    assert(isequal(score.SampleCounts,cfg.ExpectedSampleCounts(:)'));
    assert(abs(state.Time(end)-duration)<1e-8);
    result=struct('Score',score,'MaximumStateDifference',difference,...
        'MaximumMetricDifference',metricDifference,'Window_s',cfg.Window_s(:)',...
        'Interpretation',"Conditional same-flight RTL tracking; one logged initial state and recorded targets. Whole-flight and independent-flight prediction remain unresolved.");
    output=fullfile(root,'outputs','validation','rtl_public_package');
    if ~isfolder(output),mkdir(output);end
    writetable(score.Components,fullfile(output,'metrics.csv'));
    writelines(jsonencode(result,PrettyPrint=true),fullfile(output,'verification.json'));
    disp(score.Components);fprintf('Public package state/metric differences: %.3g / %.3g\n',difference,metricDifference);
    return
end
first=max([r.GPS.Time_s(1),r.CTUN.Time_s(1),r.AnimationATT.Time(1)]);
last=min([duration,r.GPS.Time_s(end),r.CTUN.Time_s(end),r.AnimationATT.Time(end)]);
time=linspace(first,last,ceil((last-first)*48)+1)';
logged=timeseries([interp1(r.GPS.Time_s,r.GPS{:,{'North_m','East_m'}},time),...
    interp1(r.CTUN.Time_s,r.CTUN.Alt,time),interp1(r.AnimationATT.Time,r.AnimationATT.Data,time)],time);
simulated=timeseries(interp1(frozen.Time_s,[frozen{:,2:4},unwrap(frozen{:,5:7},[],1)],time),time);
result=animate_flight_comparison_3d(logged,simulated,RecordVideo=false,RealTime=true,Visible="on",...
    PlaybackSpeed=.5,FrameRate=24,ArmLength=.35,TimeOffset=cfg.Window_s(1),...
    PhaseTimeline=table(0,"RTL",'VariableNames',{'StartTime_s','Phase'}),...
    AttitudeErrorSign=[-1,-1,1],Title="Conditional same-flight RTL: logged initialization and recorded targets",...
    RealLabel="GPS XY + CTUN height + logged ATT",SimLabel="Frozen v5 simulation");
end
function sig=readseries(folder,name)
values=readmatrix(fullfile(folder,[name,'.csv']));
assert(size(values,1)>=2 && all(isfinite(values),'all') && all(diff(values(:,1))>0));
sig=timeseries(values(:,2:end),values(:,1));
end
