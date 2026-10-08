function flight = run_day1_flight_import(rawBinPath)
%RUN_DAY1_FLIGHT_IMPORT Process a user-supplied ArduPilot DataFlash BIN log.
%   Requires Python with pymavlink. Generated files may contain GPS locations
%   and remain under ignored simulation/data and simulation/outputs folders.
arguments
    rawBinPath (1,1) string
end
root=fileparts(fileparts(mfilename('fullpath')));
processed=fullfile(root,'data','processed','flight_20260928_141743');
output=fullfile(root,'outputs','validation','flight_20260928_day1');
flight=import_flight_log(rawBinPath,processed);
plot_flight_log_day1(flight,output);
summarize_flight_log_day1(flight,output);
fprintf('Flight import complete: %s\n',output);
end
