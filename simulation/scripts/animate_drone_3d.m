function figureHandle = animate_drone_3d(stateSeries, options)
%ANIMATE_DRONE_3D Animate quadrotor position and ZYX Euler attitude.
%   FIGUREHANDLE = ANIMATE_DRONE_3D(STATESERIES) displays a simple
%   quadrotor driven by a six-column timeseries containing
%   [x y z phi theta psi]. The display uses a Z-up world frame and the
%   body-to-world rotation Rz(psi)*Ry(theta)*Rx(phi).

arguments
    stateSeries
    options.FrameRate (1,1) double {mustBePositive} = 30
    options.PlaybackSpeed (1,1) double {mustBePositive} = 4
    options.ArmLength (1,1) double {mustBePositive} = 0.35
    options.Target (1,3) double = [NaN NaN NaN]
    options.TrailLength (1,1) double {mustBePositive} = 20
    options.RealTime (1,1) logical = true
    options.RecordVideo (1,1) logical = false
    options.VideoFile (1,1) string = "quadrotor_flight.mp4"
    options.Visible (1,1) string {mustBeMember(options.Visible,["on","off"])} = "on"
end

[time, states] = unpackStateSeries(stateSeries);
frameStep = options.PlaybackSpeed/options.FrameRate;
frameTime = (time(1):frameStep:time(end)).';
if frameTime(end) < time(end)
    frameTime(end+1,1) = time(end);
end
frameStates = interp1(time, states, frameTime, "linear");

armLength = options.ArmLength;
rotorRadius = 0.28*armLength;
margin = max(1, 2.5*armLength);
xLimits = [min(states(:,1))-margin, max(states(:,1))+margin];
yLimits = [min(states(:,2))-margin, max(states(:,2))+margin];
zLimits = [min(0,min(states(:,3))-0.3*margin), max(states(:,3))+margin];
if diff(zLimits) < 2*margin
    zLimits(2) = zLimits(1) + 2*margin;
end

figureHandle = figure( ...
    "Name", "Quadrotor 3-D Flight Visualization", ...
    "Color", "white", ...
    "Visible", options.Visible);
axesHandle = axes(figureHandle);
hold(axesHandle, "on");
grid(axesHandle, "on");
axis(axesHandle, "equal");
xlim(axesHandle, xLimits);
ylim(axesHandle, yLimits);
zlim(axesHandle, zLimits);
xlabel(axesHandle, "World x (m)");
ylabel(axesHandle, "World y (m)");
zlabel(axesHandle, "World z (m)");
view(axesHandle, 38, 26);
set(axesHandle, "Projection", "perspective");

groundX = xLimits([1 2 2 1]);
groundY = yLimits([1 1 2 2]);
patch(axesHandle, groundX, groundY, zeros(1,4), [0.72 0.78 0.72], ...
    "FaceAlpha", 0.18, "EdgeColor", [0.65 0.70 0.65]);
if all(isfinite(options.Target))
    plot3(axesHandle, options.Target(1), options.Target(2), options.Target(3), ...
        "p", "MarkerSize", 15, "MarkerFaceColor", [0.15 0.7 0.2], ...
        "MarkerEdgeColor", [0.05 0.35 0.1]);
end

trail = plot3(axesHandle, NaN, NaN, NaN, "-", ...
    "Color", [0.15 0.45 0.85], "LineWidth", 1.8);
armXHandle = plot3(axesHandle, NaN, NaN, NaN, "-", ...
    "Color", [0.85 0.2 0.18], "LineWidth", 6);
armYHandle = plot3(axesHandle, NaN, NaN, NaN, "-", ...
    "Color", [0.15 0.35 0.85], "LineWidth", 6);
rotorHandles = gobjects(4,1);
for rotorIndex = 1:4
    rotorHandles(rotorIndex) = plot3(axesHandle, NaN, NaN, NaN, ...
        "Color", [0.12 0.12 0.12], "LineWidth", 2);
end
bodyHandle = plot3(axesHandle, NaN, NaN, NaN, "o", ...
    "MarkerSize", 8, "MarkerFaceColor", [0.15 0.15 0.15], ...
    "MarkerEdgeColor", "black");
headingHandle = plot3(axesHandle, NaN, NaN, NaN, "-", ...
    "Color", [1 0.65 0], "LineWidth", 3);
timeLabel = text(axesHandle, 0.02, 0.96, "", ...
    "Units", "normalized", "FontWeight", "bold", "FontSize", 11);

rotorAngle = linspace(0,2*pi,40);
rotorShape = [rotorRadius*cos(rotorAngle); rotorRadius*sin(rotorAngle); zeros(size(rotorAngle))];
rotorCentres = [armLength, -armLength, 0, 0; 0, 0, armLength, -armLength; 0, 0, 0, 0];

video = [];
if options.RecordVideo
    video = VideoWriter(char(options.VideoFile), "MPEG-4");
    video.FrameRate = options.FrameRate;
    open(video);
    videoCleanup = onCleanup(@() close(video));
end

for frameIndex = 1:numel(frameTime)
    frameStart = tic;
    position = frameStates(frameIndex,1:3).';
    phi = frameStates(frameIndex,4);
    theta = frameStates(frameIndex,5);
    psi = frameStates(frameIndex,6);
    rotation = zyxRotation(phi,theta,psi);

    armX = position + rotation*[-armLength armLength; 0 0; 0 0];
    armY = position + rotation*[0 0; -armLength armLength; 0 0];
    set(armXHandle, "XData", armX(1,:), "YData", armX(2,:), "ZData", armX(3,:));
    set(armYHandle, "XData", armY(1,:), "YData", armY(2,:), "ZData", armY(3,:));

    for rotorIndex = 1:4
        rotor = position + rotation*(rotorCentres(:,rotorIndex) + rotorShape);
        set(rotorHandles(rotorIndex), "XData", rotor(1,:), ...
            "YData", rotor(2,:), "ZData", rotor(3,:));
    end

    heading = [position, position + rotation*[1.45*armLength;0;0]];
    set(headingHandle, "XData", heading(1,:), "YData", heading(2,:), "ZData", heading(3,:));
    set(bodyHandle, "XData", position(1), "YData", position(2), "ZData", position(3));

    trailStartTime = frameTime(frameIndex) - options.TrailLength;
    trailStartIndex = find(frameTime >= trailStartTime, 1, "first");
    trailStates = frameStates(trailStartIndex:frameIndex,1:3);
    set(trail, "XData", trailStates(:,1), "YData", trailStates(:,2), "ZData", trailStates(:,3));
    timeLabel.String = sprintf("t = %.1f s   roll = %.1f deg   pitch = %.1f deg   yaw = %.1f deg", ...
        frameTime(frameIndex), rad2deg(phi), rad2deg(theta), rad2deg(psi));
    title(axesHandle, "Quadrotor true-state trajectory");
    drawnow;

    if options.RecordVideo
        writeVideo(video, getframe(figureHandle));
    end
    if options.RealTime
        pause(max(0, 1/options.FrameRate - toc(frameStart)));
    end
end
end

function [time,states] = unpackStateSeries(stateSeries)
if isa(stateSeries,"timeseries")
    time = stateSeries.Time(:);
    states = squeeze(stateSeries.Data);
elseif isstruct(stateSeries) && isfield(stateSeries,"time") && isfield(stateSeries,"signals")
    time = stateSeries.time(:);
    states = stateSeries.signals.values;
else
    error("animate_drone_3d:UnsupportedInput", ...
        "Input must be a timeseries or a Structure With Time value.");
end
if size(states,1) ~= numel(time) && size(states,2) == numel(time)
    states = states.';
end
assert(size(states,1) == numel(time) && size(states,2) == 6, ...
    "State data must contain one row per time sample and six columns.");
valid = isfinite(time) & all(isfinite(states),2);
time = time(valid);
states = states(valid,:);
[time,uniqueIndex] = unique(time,"stable");
states = states(uniqueIndex,:);
assert(numel(time) >= 2, "At least two finite time samples are required.");
end

function rotation = zyxRotation(phi,theta,psi)
rollRotation = [1 0 0; 0 cos(phi) -sin(phi); 0 sin(phi) cos(phi)];
pitchRotation = [cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];
yawRotation = [cos(psi) -sin(psi) 0; sin(psi) cos(psi) 0; 0 0 1];
rotation = yawRotation*pitchRotation*rollRotation;
end
