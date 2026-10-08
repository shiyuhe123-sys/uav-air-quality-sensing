function plot_flight_log_day1(flight, outputFolder)
%PLOT_FLIGHT_LOG_DAY1 Create the Day 1 flight-log trajectory and overview.

arguments
    flight (1, 1) struct
    outputFolder (1, 1) string
end

if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

trajectory = flight.Trajectory;
valid = trajectory.ValidPosition;
timeS = seconds(trajectory.Properties.RowTimes);
phaseTimeS = seconds(flight.Phases.StartTime);
phaseLabels = ["Hover"; "RTL"; "Loiter"; "E-stop"];
phaseIndices = zeros(height(flight.Phases), 1);
for index = 1:height(flight.Phases)
    [~, phaseIndices(index)] = min(abs(timeS - phaseTimeS(index)));
end

trajectoryFigure = figure("Name", "Actual flight trajectory", "Color", "white");
tiledlayout(1, 2, "TileSpacing", "compact");
nexttile;
scatter(trajectory.East_m(valid), trajectory.North_m(valid), 14, timeS(valid), "filled");
hold on;
scatter(trajectory.East_m(phaseIndices), trajectory.North_m(phaseIndices), ...
    45, "black", "filled");
text(trajectory.East_m(phaseIndices), trajectory.North_m(phaseIndices), ...
    "  " + phaseLabels, "FontSize", 8);
axis equal;
grid on;
xlabel("East (m)");
ylabel("North (m)");
title("Actual horizontal path");
colorScale = colorbar;
colorScale.Label.String = "Log time (s)";

nexttile;
scatter3(trajectory.East_m(valid), trajectory.North_m(valid), ...
    trajectory.Up_m(valid), 14, timeS(valid), "filled");
hold on;
scatter3(trajectory.East_m(phaseIndices), trajectory.North_m(phaseIndices), ...
    trajectory.Up_m(phaseIndices), 45, "black", "filled");
text(trajectory.East_m(phaseIndices), trajectory.North_m(phaseIndices), ...
    trajectory.Up_m(phaseIndices), "  " + phaseLabels, "FontSize", 8);
grid on;
axis equal;
xlabel("East (m)");
ylabel("North (m)");
zlabel("Relative altitude (m)");
title("Actual 3-D flight path");
colorScale = colorbar;
colorScale.Label.String = "Log time (s)";
view(35, 25);
exportgraphics(trajectoryFigure, fullfile(outputFolder, "actual_flight_path.png"), ...
    "Resolution", 180);

attitude = flight.Messages.ATT;
battery = flight.Messages.BAT;
control = flight.Messages.CTUN;

overviewFigure = figure("Name", "Flight log overview", "Color", "white");
tiledlayout(3, 1, "TileSpacing", "compact");
nexttile;
plot(attitude.LogTime, attitude.Roll, attitude.LogTime, attitude.Pitch);
grid on;
ylabel("Angle (deg)");
legend("Roll", "Pitch", "Location", "best");
title("Logged attitude");

nexttile;
plot(control.LogTime, control.Alt, control.LogTime, control.DAlt);
grid on;
ylabel("Altitude (m)");
legend("Actual", "Desired", "Location", "best");
title("Altitude response");

nexttile;
yyaxis left;
plot(battery.LogTime, battery.Volt);
ylabel("Voltage (V)");
yyaxis right;
plot(battery.LogTime, battery.Curr);
ylabel("Current (A)");
grid on;
xlabel("Time from log start (s)");
title("Battery and power");
exportgraphics(overviewFigure, fullfile(outputFolder, "flight_log_overview.png"), ...
    "Resolution", 180);
end
