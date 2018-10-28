function [sites,state,instance] = readSiteInput(functionInput)
% Load .mat file received from the master and and place
% the three structs sites, state, instance in the workspace.

pathToInputMatFileFromMaster = fullfile(functionInput.pathToInputFileFromMaster,'site_input.mat');
load(pathToInputMatFileFromMaster,'outputStruct')
sites = outputStruct.sites;
state = outputStruct.state;
instance = outputStruct.instance;
end