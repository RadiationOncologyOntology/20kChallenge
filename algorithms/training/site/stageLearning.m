function [sites] = stageLearning(functionInput,sites,instance)
% This stage dummy codes the data and applies the x-update.

% load data. Data needs to be dummy-coded. This is not done in iteration 1,
% so in iteration 2 (first learning iteration), we need to load the
% non-dummy-coded data, code it, and save it again. This dummy-coded data
% will be loaded in any iteration >2. Dummy-coding coding could have been
% done in iteration 1 (stage data reading) but preprocessing steps in future projects,
% e.g., rescaling, need information from all sites that is not available in
% iteration 1. 
if exist(fullfile(functionInput.pathToTempFolder,'data.mat'),'file') == 2
    % load queried & imputed data into matlab workspace
    load(fullfile(functionInput.pathToTempFolder,'data.mat'),'outcome','features','dataHeader')
    
elseif exist(fullfile(functionInput.pathToTempFolder,'data_first_iteration.mat'),'file') == 2
    % load dataset from stage 0
    load(fullfile(functionInput.pathToTempFolder,'data_first_iteration.mat'),'dataMatrix','dataHeader');
      
    % separate features and outcome
    [features,outcome] = createFeatureAndOutcomeVariables(dataMatrix,dataHeader,instance);
        
    % fix a 'bug' of jsondecode() that turns cells of single arrays into
    % arrays instead of cells (we expect categoricalFeatureRange to be a
    % cell)
    if isnumeric(instance.categoricalFeatureRange)
        instance.categoricalFeatureRange = {instance.categoricalFeatureRange};
    end
    %dummy coding
    [features,dataHeader] = createBinaryVariablesGivenRange(features,~cellfun(@isempty,instance.categoricalFeatureRange),instance.featureNames,instance.categoricalFeatureRange);
    % save data
    save(fullfile(functionInput.pathToTempFolder,'data.mat'),'outcome','features','dataHeader')
else
    error('.mat file with local data missing.')
end

% x update
[sites] = updateX(outcome,features,sites,instance);

% compute progress metrics (SSE to compute RMSE)
[sites] = computeProgressMetrics(features,outcome,sites);
end