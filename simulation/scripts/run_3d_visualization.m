%% Run the quadrotor demonstration and open the 3-D animation
scriptFolder = fileparts(mfilename("fullpath"));
projectRoot = fileparts(scriptFolder);
modelFolder = fullfile(projectRoot,"model");
outputFolder = fullfile(projectRoot,"outputs");
imageFolder = fullfile(outputFolder,"images");
validationFolder = fullfile(outputFolder,"validation");
if ~isfolder(imageFolder), mkdir(imageFolder); end
if ~isfolder(validationFolder), mkdir(validationFolder); end
modelFile = fullfile(modelFolder,"Drone_simulation.slx");
addpath(modelFolder,scriptFolder);
mdl = "Drone_simulation";
load_system(modelFile);
modelWorkspace = get_param(mdl,"ModelWorkspace");
reload(modelWorkspace);

frameRate = modelWorkspace.getVariable("visual_frame_rate");
playbackSpeed = modelWorkspace.getVariable("visual_playback_speed");
armLength = modelWorkspace.getVariable("visual_arm_length");
trailLength = modelWorkspace.getVariable("visual_trail_length");
stopTime = modelWorkspace.getVariable("visual_demo_stop_time");
demoYaw = modelWorkspace.getVariable("visual_demo_yaw");
demoDisturbances = modelWorkspace.getVariable("visual_demo_disturbances");
demoSensorNoise = modelWorkspace.getVariable("visual_demo_sensor_noise");
recordVideo = logical(modelWorkspace.getVariable("visual_record_video"));
target = [modelWorkspace.getVariable("x_des"), ...
          modelWorkspace.getVariable("y_des"), ...
          modelWorkspace.getVariable("z_des")];

simIn = Simulink.SimulationInput(mdl);
simIn = simIn.setModelParameter( ...
    "StopTime",num2str(stopTime), ...
    "ReturnWorkspaceOutputs","on");
simIn = simIn.setVariable("flight_mode",3,"Workspace",mdl);
simIn = simIn.setVariable("psi_des",demoYaw,"Workspace",mdl);
simIn = simIn.setVariable("disturbances_enabled",demoDisturbances,"Workspace",mdl);
simIn = simIn.setVariable("sensor_noise_enabled",demoSensorNoise,"Workspace",mdl);
simulationOutput = sim(simIn);
assert(any(strcmp(simulationOutput.who,"flight_visualization")), ...
    "The Visualization_Output subsystem did not return flight_visualization.");
flightData = simulationOutput.flight_visualization;

save(fullfile(validationFolder,"visualization_last_run.mat"),"flightData");
videoFile = fullfile(outputFolder,"quadrotor_flight.mp4");
figureHandle = animate_drone_3d(flightData, ...
    FrameRate=frameRate, ...
    PlaybackSpeed=playbackSpeed, ...
    ArmLength=armLength, ...
    Target=target, ...
    TrailLength=trailLength, ...
    RealTime=true, ...
    RecordVideo=recordVideo, ...
    VideoFile=videoFile);
exportgraphics(figureHandle,fullfile(imageFolder,"flight_visualization_preview.png"), ...
    "Resolution",180);

fprintf("3-D visualisation complete. Final [x y z] = [%.4f %.4f %.4f] m, yaw = %.3f deg.\n", ...
    flightData.Data(end,1),flightData.Data(end,2),flightData.Data(end,3), ...
    rad2deg(flightData.Data(end,6)));
