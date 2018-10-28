function [sites] = stageDataReading(functionInput,sites,instance)
% This stage reads the data from the site, selects patients, and computes patient counts.
[dataCell,dataHeader] = getData(functionInput,instance);

% apply patient selection
[dataMatrix,dataHeader,sites] = applyPatientSelection(dataCell,dataHeader,instance,sites);
% quality check: reorder data and data header to obey order in instance.variableNames
[dataMatrix,dataHeader] = reorderData(dataMatrix,dataHeader,instance);

% save data for later iterations
save(fullfile(functionInput.pathToTempFolder,'data_first_iteration.mat'),'dataMatrix','dataHeader');

% count patients on this site
sites.patientCount = size(dataMatrix,1); % number of patients/rows
end