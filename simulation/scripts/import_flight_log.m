function flight = import_flight_log(rawBinPath, outputFolder)
%IMPORT_FLIGHT_LOG Import an ArduPilot BIN log into analysis-ready MATLAB data.
%   FLIGHT = IMPORT_FLIGHT_LOG(RAWBINPATH, OUTPUTFOLDER) extracts every log
%   message type to CSV using pymavlink, imports timestamped messages as
%   native-rate timetables, constructs a local ENU trajectory, and saves a
%   reproducible MAT dataset. The source BIN file is never modified.

arguments
    rawBinPath (1, 1) string
    outputFolder (1, 1) string
end

assert(isfile(rawBinPath), "FlightLog:MissingFile", ...
    "Flight log does not exist: %s", rawBinPath);

scriptFolder = fileparts(mfilename("fullpath"));
projectRoot = fileparts(scriptFolder);
extractor = fullfile(projectRoot, "tools", "extract_ardupilot_bin.py");
assert(isfile(extractor), "FlightLog:MissingExtractor", ...
    "Extractor does not exist: %s", extractor);

if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
csvFolder = fullfile(outputFolder, "csv");
if ~isfolder(csvFolder)
    mkdir(csvFolder);
end

command = sprintf('python "%s" --input "%s" --output "%s"', ...
    extractor, rawBinPath, csvFolder);
[status, commandOutput] = system(command);
assert(status == 0, "FlightLog:ExtractionFailed", ...
    "pymavlink extraction failed:\n%s", commandOutput);

manifestPath = fullfile(csvFolder, "manifest.json");
assert(isfile(manifestPath), "FlightLog:MissingManifest", ...
    "Extractor did not create manifest.json.");
manifest = readstruct(manifestPath);

csvFiles = dir(fullfile(csvFolder, "*.csv"));
messages = struct;
messageNames = strings(numel(csvFiles), 1);
messageCounts = zeros(numel(csvFiles), 1);

for index = 1:numel(csvFiles)
    csvPath = fullfile(csvFiles(index).folder, csvFiles(index).name);
    messageName = erase(string(csvFiles(index).name), ".csv");
    tableData = readtable(csvPath, "TextType", "string", ...
        "VariableNamingRule", "preserve");
    fieldName = matlab.lang.makeValidName(messageName);

    if ismember("LogTimeS", string(tableData.Properties.VariableNames))
        validTime = isfinite(tableData.LogTimeS);
        tableData = tableData(validTime, :);
        rowTimes = seconds(tableData.LogTimeS);
        tableData.LogTimeS = [];
        timetableData = table2timetable(tableData, "RowTimes", rowTimes);
        timetableData.Properties.DimensionNames{1} = 'LogTime';
        messages.(fieldName) = timetableData;
        messageCounts(index) = height(timetableData);
    else
        messages.(fieldName) = tableData;
        messageCounts(index) = height(tableData);
    end
    messageNames(index) = messageName;
end

requiredMessages = ["ATT", "BAT", "CTUN", "MODE", "POS", "RCIN", "RCOU", "VIBE"];
missingMessages = requiredMessages(~isfield(messages, cellstr(requiredMessages)));
assert(isempty(missingMessages), "FlightLog:MissingMessages", ...
    "Required log messages are missing: %s", strjoin(missingMessages, ", "));

trajectory = buildLocalTrajectory(messages.POS);
rtlTime = firstModeTime(messages.MODE, 6, seconds(0));
loiterTime = firstModeTime(messages.MODE, 5, rtlTime);
emergencyStopTime = messageTime(messages.MSG, "RC8: MotorEStop HIGH", "last");
crashDisarmTime = messageTime(messages.MSG, "Crash: Disarming", "first");
phases = table( ...
    ["StableHover"; "BatteryFailsafeRTL"; "PilotLoiter"; "EmergencyStop"], ...
    [seconds(64); rtlTime; loiterTime; emergencyStopTime], ...
    [seconds(70); loiterTime; emergencyStopTime; crashDisarmTime], ...
    ["Calibration and validation"; "Safety and RTL validation"; ...
     "Mode transition validation"; "Safety logic only"], ...
    'VariableNames', {'Name', 'StartTime', 'EndTime', 'Use'});

flight = struct;
flight.Manifest = manifest;
flight.Messages = messages;
flight.Trajectory = trajectory;
flight.Phases = phases;
flight.MessageSummary = sortrows(table(messageNames, messageCounts, ...
    'VariableNames', {'Message', 'Count'}), "Message");
flight.SourceBin = rawBinPath;
flight.CreatedUTC = datetime("now", "TimeZone", "UTC");

datasetPath = fullfile(outputFolder, "flight_data.mat");
save(datasetPath, "flight", "-v7.3");
writetable(flight.MessageSummary, fullfile(outputFolder, "message_summary.csv"));
writetable(phases, fullfile(outputFolder, "flight_phases.csv"));

fprintf("Imported %d message types from %s.\n", numel(csvFiles), rawBinPath);
fprintf("Saved dataset: %s\n", datasetPath);
end


function trajectory = buildLocalTrajectory(positionData)
requiredVariables = ["Lat", "Lng", "RelHomeAlt"];
missingVariables = requiredVariables(~ismember(requiredVariables, ...
    string(positionData.Properties.VariableNames)));
assert(isempty(missingVariables), "FlightLog:MissingPositionFields", ...
    "POS is missing: %s", strjoin(missingVariables, ", "));

latitude = double(positionData.Lat);
longitude = double(positionData.Lng);
altitude = double(positionData.RelHomeAlt);
validPosition = isfinite(latitude) & isfinite(longitude) & ...
    isfinite(altitude) & abs(latitude) <= 90 & abs(longitude) <= 180;
assert(any(validPosition), "FlightLog:NoValidPosition", ...
    "POS contains no valid latitude, longitude and altitude samples.");

originIndex = find(validPosition, 1, "first");
latitude0 = latitude(originIndex);
longitude0 = longitude(originIndex);
earthRadiusM = 6378137;
eastM = earthRadiusM * cosd(latitude0) .* deg2rad(longitude - longitude0);
northM = earthRadiusM .* deg2rad(latitude - latitude0);

trajectory = timetable(eastM, northM, altitude, validPosition, ...
    'RowTimes', positionData.Properties.RowTimes, ...
    'VariableNames', {'East_m', 'North_m', 'Up_m', 'ValidPosition'});
trajectory.Properties.DimensionNames{1} = 'LogTime';
trajectory.Properties.VariableUnits = ["m", "m", "m", ""];
trajectory.Properties.UserData = struct( ...
    "ReferenceLatitude_deg", latitude0, ...
    "ReferenceLongitude_deg", longitude0, ...
    "Frame", "local ENU approximation");
end


function time = firstModeTime(modeData, modeNumber, afterTime)
mask = modeData.Mode == modeNumber & modeData.LogTime >= afterTime;
index = find(mask, 1, "first");
assert(~isempty(index), "FlightLog:MissingModeTransition", ...
    "Mode %d was not found after %.3f seconds.", modeNumber, seconds(afterTime));
time = modeData.LogTime(index);
end


function time = messageTime(messageData, pattern, occurrence)
indices = find(contains(messageData.Message, pattern));
assert(~isempty(indices), "FlightLog:MissingEventMessage", ...
    "Log message was not found: %s", pattern);
if occurrence == "last"
    index = indices(end);
else
    index = indices(1);
end
time = messageData.LogTime(index);
end
