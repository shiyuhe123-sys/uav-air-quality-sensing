%% Validate sensor model, flight modes, and yaw-aware position control
% This script uses SimulationInput overrides, so it does not change the
% parameter file or leave a test mode selected in the saved model.

mdl = "Drone_simulation";
testFolder = fileparts(mfilename("fullpath"));
projectRoot = fileparts(testFolder);
modelFolder = fullfile(projectRoot,"model");
outputFolder = fullfile(projectRoot,"outputs","validation");
if ~isfolder(outputFolder), mkdir(outputFolder); end
modelFile = fullfile(modelFolder,"Drone_simulation.slx");
addpath(modelFolder);
load_system(modelFile);

streamBlocks = [ ...
    mdl + "/XY_Translation", ...
    mdl + "/Altitude_Dynamics", ...
    mdl + "/Roll_Dynamics", ...
    mdl + "/Pitch_Dynamics", ...
    mdl + "/Yaw_Dynamics", ...
    mdl + "/Sensor_Model", ...
    mdl + "/Flight_Mode_Manager", ...
    mdl + "/Yaw_Aware_Position_Mapping", ...
    mdl + "/Attitude_Mode_Selector", ...
    mdl + "/Motor_1", ...
    mdl + "/Motor_2", ...
    mdl + "/Motor_3", ...
    mdl + "/Motor_4"];
streamPorts = {1:2, 1, 1, 1, 1, 1:6, 1:7, 1:2, 1:2, 2, 2, 2, 2};

cleanup = onCleanup(@() disableStreaming(streamBlocks, streamPorts));

common = struct( ...
    "sensor_noise_enabled", 0, ...
    "disturbances_enabled", 0);

autoZeroYaw = common;
autoZeroYaw.flight_mode = 3;
autoZeroYaw.psi_des = 0;
caseAutoZeroYaw = runCase(mdl, "Mode 3 - auto, zero yaw", 60, autoZeroYaw, streamBlocks, streamPorts);

autoYaw = common;
autoYaw.flight_mode = 3;
autoYaw.psi_des = deg2rad(45);
caseAutoYaw = runCase(mdl, "Mode 3 - auto, 45 deg yaw", 60, autoYaw, streamBlocks, streamPorts);

positionHold = common;
positionHold.flight_mode = 2;
positionHold.x_hold = 1;
positionHold.y_hold = -1;
positionHold.z_hold = 0.8;
positionHold.psi_hold = deg2rad(20);
casePositionHold = runCase(mdl, "Mode 2 - position hold", 45, positionHold, streamBlocks, streamPorts);

manual = common;
manual.flight_mode = 1;
manual.phi_manual = deg2rad(3);
manual.theta_manual = deg2rad(-2);
manual.z_manual = 0.8;
manual.psi_manual = deg2rad(10);
caseManual = runCase(mdl, "Mode 1 - manual attitude", 20, manual, streamBlocks, streamPorts);

noisy = common;
noisy.flight_mode = 3;
noisy.sensor_noise_enabled = 1;
noisy.psi_des = 0;
caseNoisyA = runCase(mdl, "Mode 3 - noisy sensors A", 40, noisy, streamBlocks, streamPorts);
caseNoisyB = runCase(mdl, "Mode 3 - noisy sensors B", 40, noisy, streamBlocks, streamPorts);

disturbed = common;
disturbed.flight_mode = 3;
disturbed.disturbances_enabled = 1;
disturbed.psi_des = 0;
caseDisturbed = runCase(mdl, "Mode 3 - all disturbances", 60, disturbed, streamBlocks, streamPorts);

combined = common;
combined.flight_mode = 3;
combined.sensor_noise_enabled = 1;
combined.disturbances_enabled = 1;
combined.psi_des = deg2rad(30);
caseCombined = runCase(mdl, "Mode 3 - yaw, noise, and disturbances", 60, combined, streamBlocks, streamPorts);

autoTarget = [4, 2, 1, 0];
autoYawTarget = [4, 2, 1, deg2rad(45)];
holdTarget = [1, -1, 0.8, deg2rad(20)];
manualTarget = [deg2rad(3), deg2rad(-2), 0.8, deg2rad(10)];

results = struct;
results.auto_zero_yaw.final = finalState(caseAutoZeroYaw);
results.auto_zero_yaw.target = autoTarget;
results.auto_zero_yaw.error = results.auto_zero_yaw.final([1 2 3 6]) - autoTarget;
results.auto_yaw.final = finalState(caseAutoYaw);
results.auto_yaw.target = autoYawTarget;
results.auto_yaw.error = results.auto_yaw.final([1 2 3 6]) - autoYawTarget;
results.position_hold.final = finalState(casePositionHold);
results.position_hold.target = holdTarget;
results.position_hold.error = results.position_hold.final([1 2 3 6]) - holdTarget;
results.manual.final = finalState(caseManual);
results.manual.target = manualTarget;
results.manual.error = results.manual.final([4 5 3 6]) - manualTarget;
results.noisy.final_a = finalState(caseNoisyA);
results.noisy.final_b = finalState(caseNoisyB);
results.noisy.target = autoTarget;
results.noisy.error = results.noisy.final_a([1 2 3 6]) - autoTarget;
results.noisy.repeat_difference = results.noisy.final_b - results.noisy.final_a;
results.noisy.max_motor_thrust_N = maxMotorThrust(caseNoisyA);
results.disturbed.final = finalState(caseDisturbed);
results.disturbed.target = autoTarget;
results.disturbed.error = results.disturbed.final([1 2 3 6]) - autoTarget;
results.disturbed.max_motor_thrust_N = maxMotorThrust(caseDisturbed);
results.combined.final = finalState(caseCombined);
results.combined.target = [4, 2, 1, deg2rad(30)];
results.combined.error = results.combined.final([1 2 3 6]) - results.combined.target;
results.combined.max_motor_thrust_N = maxMotorThrust(caseCombined);
results.motor_limit_N = 12.5;
results.passed = ...
    max(abs(results.auto_zero_yaw.error)) < 0.03 && ...
    max(abs(results.auto_yaw.error)) < 0.05 && ...
    max(abs(results.position_hold.error)) < 0.05 && ...
    max(abs(results.manual.error([1 2 4]))) < deg2rad(1) && ...
    abs(results.manual.error(3)) < 0.1 && ...
    max(abs(results.noisy.error)) < 0.1 && ...
    max(abs(results.noisy.repeat_difference)) < 1e-10 && ...
    max(abs(results.disturbed.error)) < 0.1 && ...
    max(abs(results.combined.error)) < 0.1 && ...
    max([results.noisy.max_motor_thrust_N, ...
         results.disturbed.max_motor_thrust_N, ...
         results.combined.max_motor_thrust_N]) <= results.motor_limit_N + 1e-9;

save(fullfile(outputFolder, "guidance_sensor_validation.mat"), ...
    "results", "caseAutoZeroYaw", "caseAutoYaw", "casePositionHold", ...
    "caseManual", "caseNoisyA", "caseNoisyB", "caseDisturbed", "caseCombined");

fprintf("Auto zero-yaw final [x y z phi theta psi]:\n");
disp(results.auto_zero_yaw.final);
fprintf("Auto 45-deg-yaw final [x y z phi theta psi]:\n");
disp(results.auto_yaw.final);
fprintf("Position-hold final [x y z phi theta psi]:\n");
disp(results.position_hold.final);
fprintf("Manual-attitude final [x y z phi theta psi]:\n");
disp(results.manual.final);
fprintf("Noisy auto final [x y z phi theta psi]:\n");
disp(results.noisy.final_a);
fprintf("Noisy repeat final-state difference:\n");
disp(results.noisy.repeat_difference);
fprintf("Noisy-case maximum motor thrust: %.6f N\n", results.noisy.max_motor_thrust_N);
fprintf("Disturbance-only final [x y z phi theta psi]:\n");
disp(results.disturbed.final);
fprintf("Combined yaw/noise/disturbance final [x y z phi theta psi]:\n");
disp(results.combined.final);
fprintf("Combined-case maximum motor thrust: %.6f N\n", results.combined.max_motor_thrust_N);
fprintf("Validation passed: %d\n", results.passed);

function captured = runCase(mdl, caseName, stopTime, overrides, blocks, ports)
    for blockIndex = 1:numel(blocks)
        for portIndex = ports{blockIndex}
            Simulink.sdi.markSignalForStreaming(blocks(blockIndex), portIndex, "on");
        end
    end
    simIn = Simulink.SimulationInput(mdl);
    simIn = simIn.setModelParameter( ...
        "StopTime", num2str(stopTime), ...
        "SignalLogging", "on", ...
        "SignalLoggingName", "logsout", ...
        "ReturnWorkspaceOutputs", "on");
    names = fieldnames(overrides);
    for variableIndex = 1:numel(names)
        simIn = simIn.setVariable(names{variableIndex}, ...
            overrides.(names{variableIndex}), "Workspace", mdl);
    end
    simOut = sim(simIn);
    logged = simOut.logsout;
    assert(logged.numElements > 0, "No signals were logged for %s.", caseName);
    captured = struct("name", caseName, "signals", struct);
    for signalIndex = 1:logged.numElements
        signal = logged{signalIndex};
        field = matlab.lang.makeUniqueStrings( ...
            matlab.lang.makeValidName(signal.Name), fieldnames(captured.signals));
        captured.signals.(field) = signal.Values;
    end
end

function state = finalState(captured)
    state = [ ...
        captured.signals.x_true.Data(end), ...
        captured.signals.y_true.Data(end), ...
        captured.signals.z_true.Data(end), ...
        captured.signals.phi_true.Data(end), ...
        captured.signals.theta_true.Data(end), ...
        captured.signals.psi_true.Data(end)];
end

function maximum = maxMotorThrust(captured)
    fields = fieldnames(captured.signals);
    thrustFields = fields(startsWith(fields, "T"));
    maximum = -inf;
    for fieldIndex = 1:numel(thrustFields)
        maximum = max(maximum, max(captured.signals.(thrustFields{fieldIndex}).Data));
    end
end

function disableStreaming(blocks, ports)
    for blockIndex = 1:numel(blocks)
        for portIndex = ports{blockIndex}
            Simulink.sdi.markSignalForStreaming(blocks(blockIndex), portIndex, "off");
        end
    end
end
