function mainMaster(varargin)
% Manages the learning run on the master.

try
    % in the compiled version, the varargin cell differs compared to the local
    % simulation
    if length(varargin) == 1
        varargin = varargin{1};
    end
    
    % place all function input in a struct
    functionInput = struct('runId',varargin{1},...
        'itNumber',varargin{2},...
        'pathToSiteOutputFolder',varargin{3},...
        'pathToMasterOutputFolder',varargin{4},...
        'pathToTempFolder',varargin{5},...
        'abort',varargin{6},...
        'siteIds',varargin{7},...
        'pathToUserInputFile',varargin{8},...
        'pathToLogFile',varargin{9});
    
    writeToLog(['Master starts iteration ' num2str(functionInput.itNumber) '.'], functionInput);
    % format function input
    [functionInput] = formatMasterFunctionInput(functionInput);
    
    % read user input in first iteration, read site output in later iterations
    if functionInput.itNumber == 1
        siteOutput = [];
        % read user input
        [userInput] = readUserInput(functionInput);
        
    elseif functionInput.itNumber > 1
        % user input is not needed anymore
        userInput = [];
        % read site output
        [siteOutput] = readSiteOutput(functionInput);
    else
        error('itNumber is wrong.')
    end
    % create structs/load & update structs
    [instance,state,sites] = createStructs(functionInput,userInput,siteOutput);
    
    % control stage progression
    if isnan(state.stage) % algorithm just started in iteration 1: start with stage 0 (data reading at each site)
        state.stage = 0;
    elseif state.stage == 0 % algorithm is in iteration 2, sites have finished reading data (stage 0).
        [sites,state,instance] = stageInitializeAdmm(sites,state,instance);  
    elseif state.stage == 1
        [sites,state,instance] = stageLearning(functionInput,sites,state,instance);
    end
        
    % remove unnecessary fields to reduce traffic during learning
    if state.stage == 1
        adjInstance = instance;
        allFields = fields(adjInstance);
        requiredFields = {'siteIds','featureNames' 'outcomeName' 'imputationType' 'categoricalFeatureRange' 'rho' 'patientCount'};
        unneededFields = setdiff(allFields,requiredFields);
        adjInstance = rmfield(adjInstance,unneededFields);
    else
        adjInstance = instance;
    end
    % write site input
    writeSiteInput(functionInput,sites,state,adjInstance);
        
    % save instance & state structs
    save(fullfile(functionInput.pathToTempFolder,'structs'),'instance','state')
    
    % log file
    writeToLog(['Master finishes iteration ' num2str(functionInput.itNumber) '.'], functionInput);
catch myException
    if exist('functionInput','var')
        writeToLog(myException.identifier,functionInput)
        writeToLog(myException.message,functionInput)
        for i_error = 1:length(myException.stack)
            writeToLog(myException.stack(i_error).name,functionInput)
            writeToLog(num2str(myException.stack(i_error).line),functionInput)
        end
        error('Matlab encountered an error, it was caught and, if possible, written to the log file. See log file.')
    else
        error('Matlab encountered an error before functionInput was created. So, nothing is written to the log file.')
    end
    
end
end