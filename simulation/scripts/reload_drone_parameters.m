%% Reload Drone_simulation model-workspace parameters
% Run this after editing Drone_parameters.m while the model is already open.
modelName = 'Drone_simulation';
if ~bdIsLoaded(modelName)
    scriptFolder = fileparts(mfilename('fullpath'));
    modelFile = fullfile(fileparts(scriptFolder),'model',[modelName '.slx']);
    load_system(modelFile);
end
modelWorkspace = get_param(modelName,'ModelWorkspace');
modelWorkspace.reload;
clear modelName modelWorkspace scriptFolder modelFile
