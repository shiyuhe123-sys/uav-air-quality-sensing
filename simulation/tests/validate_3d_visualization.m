%% Validate the 3-D visualisation data and coordinate convention
testFolder = fileparts(mfilename("fullpath"));
projectRoot = fileparts(testFolder);
outputFolder = fullfile(projectRoot,"outputs");
validationFolder = fullfile(outputFolder,"validation");
if ~isfolder(validationFolder), mkdir(validationFolder); end
addpath(fullfile(projectRoot,"model"),fullfile(projectRoot,"scripts"));
load_system(fullfile(projectRoot,"model","Drone_simulation.slx"));
savedRun = load(fullfile(validationFolder,"visualization_last_run.mat"));
flightData = savedRun.flightData;

assert(isa(flightData,"timeseries"),"Visualisation data must be a timeseries.");
time = flightData.Time(:);
states = squeeze(flightData.Data);
assert(size(states,1) == numel(time) && size(states,2) == 6, ...
    "Visualisation data must contain [x y z phi theta psi].");
assert(all(isfinite(time)) && all(isfinite(states),"all"), ...
    "Visualisation data contains a nonfinite value.");
assert(all(diff(time) > 0),"Visualisation time must be strictly increasing.");

sampleIndex = unique(round(linspace(1,numel(time),min(100,numel(time)))));
maximumOrthogonalityError = 0;
maximumDeterminantError = 0;
maximumThrustAxisError = 0;
for index = sampleIndex
    phi = states(index,4);
    theta = states(index,5);
    psi = states(index,6);
    rollRotation = [1 0 0; 0 cos(phi) -sin(phi); 0 sin(phi) cos(phi)];
    pitchRotation = [cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];
    yawRotation = [cos(psi) -sin(psi) 0; sin(psi) cos(psi) 0; 0 0 1];
    rotation = yawRotation*pitchRotation*rollRotation;
    expectedThrustAxis = [ ...
        cos(psi)*sin(theta)*cos(phi) + sin(psi)*sin(phi); ...
        sin(psi)*sin(theta)*cos(phi) - cos(psi)*sin(phi); ...
        cos(theta)*cos(phi)];
    maximumOrthogonalityError = max(maximumOrthogonalityError, ...
        norm(rotation.'*rotation-eye(3),"fro"));
    maximumDeterminantError = max(maximumDeterminantError,abs(det(rotation)-1));
    maximumThrustAxisError = max(maximumThrustAxisError, ...
        norm(rotation(:,3)-expectedThrustAxis));
end

modelWorkspace = get_param("Drone_simulation","ModelWorkspace");
target = [modelWorkspace.getVariable("x_des"), ...
          modelWorkspace.getVariable("y_des"), ...
          modelWorkspace.getVariable("z_des")];
targetYaw = modelWorkspace.getVariable("visual_demo_yaw");
finalPositionError = states(end,1:3)-target;
finalYawError = states(end,6)-targetYaw;

figureHandle = animate_drone_3d(flightData, ...
    FrameRate=10,PlaybackSpeed=1000,ArmLength=0.35,Target=target, ...
    TrailLength=inf,RealTime=false,Visible="off");
close(figureHandle);

results = struct;
results.samples = numel(time);
results.final_position_error_m = finalPositionError;
results.final_yaw_error_rad = finalYawError;
results.maximum_rotation_orthogonality_error = maximumOrthogonalityError;
results.maximum_rotation_determinant_error = maximumDeterminantError;
results.maximum_thrust_axis_error = maximumThrustAxisError;
results.animation_smoke_test = true;
results.passed = max(abs(finalPositionError)) < 0.1 && ...
    abs(finalYawError) < deg2rad(1) && ...
    maximumOrthogonalityError < 1e-12 && ...
    maximumDeterminantError < 1e-12 && ...
    maximumThrustAxisError < 1e-12;

save(fullfile(validationFolder,"visualization_validation.mat"),"results");
fprintf("Visualisation samples: %d\n",results.samples);
fprintf("Final position error [x y z]: [%g %g %g] m\n",finalPositionError);
fprintf("Final yaw error: %g deg\n",rad2deg(finalYawError));
fprintf("Maximum rotation orthogonality error: %.3g\n",maximumOrthogonalityError);
fprintf("Maximum displayed/plant thrust-axis error: %.3g\n",maximumThrustAxisError);
fprintf("Visualisation validation passed: %d\n",results.passed);
