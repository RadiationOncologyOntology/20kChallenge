function writeSiteOutput(sites,functionInput)
% Stores the sites struct in a .mat file to be sent to the master.

% retrieve path to output folder from mainSite.m function input
pathToOutputFolder = functionInput.pathToOutputFile;
% create output folder
mkdir(pathToOutputFolder)
% create path to output .mat file
pathToOutputFile = fullfile(pathToOutputFolder,'site_output.mat');
% save sites struct in .mat file
save(pathToOutputFile,'sites')
end
