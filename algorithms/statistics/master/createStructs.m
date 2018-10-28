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
    % initialize sites struct. The order must adhere to the order of
    % siteIds provided in functionInput
    for i_siteIds = 1:length(functionInput.siteIds)
        sites(i_siteIds).id = functionInput.siteIds(i_siteIds);
    end
    
    % initialize instance struct
    instance.siteIds = functionInput.siteIds;
    
    instance.sparqlQuery = userInput.sparqlQuery;
    instance.endpointKey = userInput.endpointKey;
    
    instance.rundId = functionInput.runId;
    
    % initialize state struct
    state.stage = NaN;
    state.abort = functionInput.abort;
    state.itNumber = functionInput.itNumber;
else
    % load instance struct from last iteration
    load(fullfile(functionInput.pathToTempFolder,'structs'),'instance')
    
    % use siteOutput struct as sites struct
    sites = siteOutput;
    
    % load state struct from last iteration and update
    load(fullfile(functionInput.pathToTempFolder,'structs'),'state')
    state.abort = functionInput.abort;
    state.itNumber = functionInput.itNumber;

end

end