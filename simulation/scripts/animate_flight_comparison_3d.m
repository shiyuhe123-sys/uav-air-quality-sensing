function figureHandle = animate_flight_comparison_3d( ...
        realFlight, digitalTwin, options)
%ANIMATE_FLIGHT_COMPARISON_3D Animate logged and simulated quadrotors.
%   Both inputs contain [north east up roll pitch yaw] in SI units and
%   radians. The two vehicles share one time axis and one 3-D world frame.

arguments
    realFlight
    digitalTwin
    options.FrameRate (1,1) double {mustBePositive} = 24
    options.PlaybackSpeed (1,1) double {mustBePositive} = 0.5
    options.ArmLength (1,1) double {mustBePositive} = 0.12
    options.TrailLength (1,1) double {mustBePositive} = inf
    options.RealTime (1,1) logical = true
    options.RecordVideo (1,1) logical = true
    options.VideoFile (1,1) string = "real_vs_digital_twin_hover.mp4"
    options.Title (1,1) string = "Logged aircraft and replayed digital twin"
    options.RealLabel (1,1) string = "Logged path"
    options.SimLabel (1,1) string = "Digital-twin path"
    options.AttitudeErrorSign (1,3) double = [1,1,1]
    options.Visible (1,1) string ...
        {mustBeMember(options.Visible, ["on", "off"])} = "on"
    options.TimeOffset (1,1) double = 0
    options.PhaseTimeline table = table
end

[realTime, realStates] = unpackStateSeries(realFlight);
[simTime, simStates] = unpackStateSeries(digitalTwin);
startTime = max(realTime(1), simTime(1));
endTime = min(realTime(end), simTime(end));
assert(endTime > startTime, "FlightComparisonAnimation:NoTimeOverlap", ...
    "The logged and simulated state series do not overlap in time.");

frameStep = options.PlaybackSpeed / options.FrameRate;
frameTime = (startTime:frameStep:endTime).';
if frameTime(end) < endTime
    frameTime(end+1, 1) = endTime;
end
realFrames = interp1(realTime, realStates, frameTime, "linear");
simFrames = interp1(simTime, simStates, frameTime, "linear");

combinedPosition = [realFrames(:, 1:3); simFrames(:, 1:3)];
margin = max(0.35, 2.5 * options.ArmLength);
xLimits = paddedLimits(combinedPosition(:, 1), margin);
yLimits = paddedLimits(combinedPosition(:, 2), margin);
zLimits = paddedLimits([0; combinedPosition(:, 3)], margin);

figureHandle = figure( ...
    "Name", "Real Flight vs Digital Twin", ...
    "Color", "white", ...
    "Position", [100 100 1100 720], ...
    "Visible", options.Visible);
axesHandle = axes(figureHandle);
hold(axesHandle, "on");
grid(axesHandle, "on");
axis(axesHandle, "equal");
xlim(axesHandle, xLimits);
ylim(axesHandle, yLimits);
zlim(axesHandle, zLimits);
xlabel(axesHandle, "North (m)");
ylabel(axesHandle, "East (m)");
zlabel(axesHandle, "Up (m)");
title(axesHandle, options.Title);
view(axesHandle, 38, 26);
set(axesHandle, "Projection", "perspective", "FontSize", 11);

groundX = xLimits([1 2 2 1]);
groundY = yLimits([1 1 2 2]);
patch(axesHandle, groundX, groundY, zeros(1, 4), ...
    [0.72 0.78 0.72], "FaceAlpha", 0.16, ...
    "EdgeColor", [0.65 0.70 0.65], "HandleVisibility", "off");

realColour = [0.05 0.35 0.82];
realSecondary = [0.25 0.70 0.95];
simColour = [0.95 0.42 0.08];
simSecondary = [1.00 0.72 0.18];
plot3(axesHandle, realFrames(:, 1), realFrames(:, 2), realFrames(:, 3), ...
    "Color", 0.65 * realColour + 0.35, "LineWidth", 1.0, ...
    "DisplayName", options.RealLabel);
plot3(axesHandle, simFrames(:, 1), simFrames(:, 2), simFrames(:, 3), ...
    "--", "Color", 0.65 * simColour + 0.35, "LineWidth", 1.0, ...
    "DisplayName", options.SimLabel);
realTrail = plot3(axesHandle, NaN, NaN, NaN, ...
    "Color", realColour, "LineWidth", 2.2, ...
    "HandleVisibility", "off");
simTrail = plot3(axesHandle, NaN, NaN, NaN, "--", ...
    "Color", simColour, "LineWidth", 2.2, ...
    "HandleVisibility", "off");
errorLine = plot3(axesHandle, NaN, NaN, NaN, ":", ...
    "Color", [0.25 0.25 0.25], "LineWidth", 1.5, ...
    "HandleVisibility", "off");

realDrone = createDroneHandles(axesHandle, realColour, realSecondary);
simDrone = createDroneHandles(axesHandle, simColour, simSecondary);
legend(axesHandle, "Location", "southoutside", ...
    "Orientation", "horizontal", "NumColumns", 2);

statusLabel = text(axesHandle, 0.02, 0.96, "", ...
    "Units", "normalized", "FontWeight", "bold", ...
    "FontSize", 11, "VerticalAlignment", "top");
detailLabel = text(axesHandle, 0.02, 0.89, "", ...
    "Units", "normalized", "FontSize", 10, ...
    "VerticalAlignment", "top");

video = [];
if options.RecordVideo
    videoFolder = fileparts(options.VideoFile);
    if strlength(videoFolder) > 0 && ~isfolder(videoFolder)
        mkdir(videoFolder);
    end
    video = VideoWriter(char(options.VideoFile), "MPEG-4");
    video.FrameRate = options.FrameRate;
    open(video);
    videoCleanup = onCleanup(@() close(video));
end

for frameIndex = 1:numel(frameTime)
    frameStart = tic;
    realPosition = realFrames(frameIndex, 1:3).';
    simPosition = simFrames(frameIndex, 1:3).';
    updateDrone(realDrone, realPosition, realFrames(frameIndex, 4:6), ...
        options.ArmLength);
    updateDrone(simDrone, simPosition, simFrames(frameIndex, 4:6), ...
        options.ArmLength);

    trailStartTime = frameTime(frameIndex) - options.TrailLength;
    trailStartIndex = find(frameTime >= trailStartTime, 1, "first");
    set(realTrail, ...
        "XData", realFrames(trailStartIndex:frameIndex, 1), ...
        "YData", realFrames(trailStartIndex:frameIndex, 2), ...
        "ZData", realFrames(trailStartIndex:frameIndex, 3));
    set(simTrail, ...
        "XData", simFrames(trailStartIndex:frameIndex, 1), ...
        "YData", simFrames(trailStartIndex:frameIndex, 2), ...
        "ZData", simFrames(trailStartIndex:frameIndex, 3));
    set(errorLine, ...
        "XData", [realPosition(1), simPosition(1)], ...
        "YData", [realPosition(2), simPosition(2)], ...
        "ZData", [realPosition(3), simPosition(3)]);

    positionError = norm(simPosition - realPosition);
    attitudeErrorDeg = wrappedAttitudeErrorDeg( ...
        simFrames(frameIndex, 4:6), realFrames(frameIndex, 4:6)).*options.AttitudeErrorSign;
    statusLabel.String = sprintf( ...
        "t = %.2f s     position separation = %.3f m", ...
        frameTime(frameIndex)+options.TimeOffset, positionError);
    if ~isempty(options.PhaseTimeline)
        phaseIndex=find(options.PhaseTimeline.StartTime_s<=frameTime(frameIndex),1,'last');
        if ~isempty(phaseIndex)
            statusLabel.String=statusLabel.String+"     "+options.PhaseTimeline.Phase(phaseIndex);
        end
    end
    detailLabel.String = sprintf( ...
        "attitude error: roll %+.2f deg   pitch %+.2f deg   yaw %+.2f deg", ...
        attitudeErrorDeg(1), attitudeErrorDeg(2), attitudeErrorDeg(3));

    drawnow limitrate;
    if options.RecordVideo
        writeVideo(video, getframe(figureHandle));
    end
    if options.RealTime
        pause(max(0, 1 / options.FrameRate - toc(frameStart)));
    end
end
end


function handles = createDroneHandles(ax, primaryColour, secondaryColour)
handles.ArmX = plot3(ax, NaN, NaN, NaN, "-", ...
    "Color", primaryColour, "LineWidth", 5, ...
    "HandleVisibility", "off");
handles.ArmY = plot3(ax, NaN, NaN, NaN, "-", ...
    "Color", secondaryColour, "LineWidth", 5, ...
    "HandleVisibility", "off");
handles.Body = plot3(ax, NaN, NaN, NaN, "o", ...
    "MarkerSize", 7, "MarkerFaceColor", primaryColour, ...
    "MarkerEdgeColor", "black", "HandleVisibility", "off");
handles.Heading = plot3(ax, NaN, NaN, NaN, "-", ...
    "Color", primaryColour, "LineWidth", 2.5, ...
    "HandleVisibility", "off");
handles.Rotors = gobjects(4, 1);
for index = 1:4
    handles.Rotors(index) = plot3(ax, NaN, NaN, NaN, ...
        "Color", primaryColour, "LineWidth", 1.5, ...
        "HandleVisibility", "off");
end
end


function updateDrone(handles, position, eulerAngles, armLength)
phi = eulerAngles(1);
theta = eulerAngles(2);
psi = eulerAngles(3);
rotation = zyxRotation(phi, theta, psi);
armX = position + rotation * [-armLength armLength; 0 0; 0 0];
armY = position + rotation * [0 0; -armLength armLength; 0 0];
set(handles.ArmX, "XData", armX(1, :), ...
    "YData", armX(2, :), "ZData", armX(3, :));
set(handles.ArmY, "XData", armY(1, :), ...
    "YData", armY(2, :), "ZData", armY(3, :));
set(handles.Body, "XData", position(1), ...
    "YData", position(2), "ZData", position(3));

heading = [position, position + rotation * [1.45 * armLength; 0; 0]];
set(handles.Heading, "XData", heading(1, :), ...
    "YData", heading(2, :), "ZData", heading(3, :));

rotorRadius = 0.28 * armLength;
rotorAngle = linspace(0, 2 * pi, 30);
rotorShape = [rotorRadius * cos(rotorAngle); ...
    rotorRadius * sin(rotorAngle); zeros(size(rotorAngle))];
rotorCentres = [armLength, -armLength, 0, 0; ...
    0, 0, armLength, -armLength; 0, 0, 0, 0];
for index = 1:4
    rotor = position + rotation * (rotorCentres(:, index) + rotorShape);
    set(handles.Rotors(index), "XData", rotor(1, :), ...
        "YData", rotor(2, :), "ZData", rotor(3, :));
end
end


function [time, states] = unpackStateSeries(stateSeries)
assert(isa(stateSeries, "timeseries"), ...
    "FlightComparisonAnimation:UnsupportedInput", ...
    "Inputs must be timeseries values.");
time = stateSeries.Time(:);
states = squeeze(stateSeries.Data);
if size(states, 1) ~= numel(time) && size(states, 2) == numel(time)
    states = states.';
end
assert(size(states, 1) == numel(time) && size(states, 2) == 6, ...
    "Flight comparison data must have six state columns.");
valid = isfinite(time) & all(isfinite(states), 2);
time = time(valid);
states = states(valid, :);
[time, uniqueIndex] = unique(time, "stable");
states = states(uniqueIndex, :);
assert(numel(time) >= 2, ...
    "Flight comparison data needs at least two finite samples.");
end


function limits = paddedLimits(values, margin)
limits = [min(values) - margin, max(values) + margin];
if diff(limits) < 2 * margin
    centre = mean(limits);
    limits = centre + [-margin, margin];
end
end


function errorDeg = wrappedAttitudeErrorDeg(simulated, actual)
difference = simulated - actual;
errorDeg = rad2deg(atan2(sin(difference), cos(difference)));
end


function rotation = zyxRotation(phi, theta, psi)
rollRotation = [1 0 0; 0 cos(phi) -sin(phi); 0 sin(phi) cos(phi)];
pitchRotation = [cos(theta) 0 sin(theta); 0 1 0; ...
    -sin(theta) 0 cos(theta)];
yawRotation = [cos(psi) -sin(psi) 0; ...
    sin(psi) cos(psi) 0; 0 0 1];
rotation = yawRotation * pitchRotation * rollRotation;
end
