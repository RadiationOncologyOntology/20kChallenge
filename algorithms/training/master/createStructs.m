function [instance,state,sites] = createStructs(functionInput,userInput,siteOutput)
% Create the 3 main structs (instance, state, sites) from the various
% sources of information (functionInput, userInput, siteOutput).
% instance: variables that determine this learning instance, the variables
% are relevant to all sites and the master.
% state: variables that determine the state of the learning run and vary
% over iterations.
% sites: a struct with one row for each site. Each row defines the
% corresponding site and is passed between site and master to exchange
% the necessary information.

% In the first iteration, all structs need to be created. Later, structs
% are either loaded or re-constructed from site output/function input.
if functionInput.itNumber == 1
    % initialize sites struct. The order must adheres to the order of
    % siteIds provided in functionInput
    for i_siteIds = 1:length(functionInput.siteIds)
        sites(i_siteIds).id = functionInput.siteIds(i_siteIds);
        sites(i_siteIds).x = NaN(size(userInput.x));
        sites(i_siteIds).u = NaN(size(userInput.u));
        sites(i_siteIds).z = NaN(size(userInput.z));
        sites(i_siteIds).zOld = NaN(size(userInput.z));
        sites(i_siteIds).obj = NaN;
    end
    
    % initialize instance struct
    instance.maxIter = userInput.maxIter;
    instance.siteIds = functionInput.siteIds;    
    
    instance.xInitialization = userInput.x;
    instance.uInitialization = userInput.u;
    instance.zInitialization = userInput.z;
    
    instance.displayProgress = userInput.displayProgress;
    instance.trainingDateStart = userInput.trainingDateStart;
    instance.trainingDateEnd = userInput.trainingDateEnd;
    instance.sparqlQuery = userInput.sparqlQuery;
    instance.endpointKey = userInput.endpointKey;
    instance.dataSplitSeed = userInput.dataSplitSeed;
    instance.variableNames = userInput.variableNames;
    instance.outcomeName = userInput.outcomeName;
    instance.featureNames = userInput.featureNames;
    instance.categoricalFeatureRange = userInput.categoricalFeatureRange;
    instance.rundId = functionInput.runId;
    instance.rho = userInput.rho;
    instance.alpha = userInput.alpha;
    instance.lambda = userInput.lambda;
    instance.absTol = userInput.absTol;
    instance.relTol = userInput.relTol;
    instance.xFinal = NaN(size(userInput.x));
    
    % initialize state struct
    state.stage = NaN;
    state.abort = functionInput.abort;
    state.itNumber = functionInput.itNumber;
    state.hasConverged = false;
    
    
else
    % load instance struct
    load(fullfile(functionInput.pathToTempFolder,'structs'),'instance')
    
    % use siteOutput struct as sites struct
    sites = siteOutput;
    
    % load state struct and update
    load(fullfile(functionInput.pathToTempFolder,'structs'),'state')
    state.abort = functionInput.abort;
    state.itNumber = functionInput.itNumber;
    
end

end