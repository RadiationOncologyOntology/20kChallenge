function [sites] = stageDataReadingAndValidation(functionInput,sites,instance)
% This stage reads the data from the site, applies patient selection, and computes summary stats/model performance metrics.
[dataCell,dataHeader] = getData(functionInput,instance);

% apply patient selection
[dataMatrix,dataHeader,sites] = applyPatientSelection(dataCell,dataHeader,instance,sites);
% quality check: reorder data and data header to obey order in instance.variableNames
[dataMatrix,dataHeader] = reorderData(dataMatrix,dataHeader,instance);

% separate features and outcome
[features,outcome] = createFeatureAndOutcomeVariables(dataMatrix,dataHeader,instance);

% fix a 'bug' of jsondecode() that turns cells of single arrays into
% arrays instead of cells (we expect  categoricalFeatureRange to be a
% cell)
if isnumeric(instance.categoricalFeatureRange)
    instance.categoricalFeatureRange = {instance.categoricalFeatureRange};
end
%dummy coding
[features,dataHeader] = createBinaryVariablesGivenRange(features,~cellfun(@isempty,instance.categoricalFeatureRange),instance.featureNames,instance.categoricalFeatureRange);

% compute AUC for site
[sites] = computePerformanceMetrics(features,outcome,instance,sites);

% count patients on this site
sites.patientCount = size(dataMatrix,1); % number of patients/rows
end