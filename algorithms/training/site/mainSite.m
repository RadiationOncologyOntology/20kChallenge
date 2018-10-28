function mainSite(varargin)
% Manages the learning run on the site(s).

try
    % in the compiled version, the varargin cell differs compared to the local
    % simulation
    if length(varargin) == 1
        varargin = varargin{1};
    end
    
    % place all function input in a struct
    functionInput = struct('runId', varargin{1},...
        'itNumber',varargin{2},...
        'pathToInputFileFromMaster',varargin{3},...
        'pathToOutputFile',varargin{4},...
        'pathToTempFolder',varargin{5},...
        'pathToLogFile',varargin{6},...
        'sparqlProxy',varargin{7},...
        'sparqlToken',varargin{8},...
        'dataProxyType',varargin{9}...
        );
    
    % format function input
    [functionInput] = formatSiteFunctionInput(functionInput);
    
    % read input from master
    [sites,state,instance]= readSiteInput(functionInput);
        
    writeToLog(['Site ' num2str(sites.id) ' starts iteration ' num2str(functionInput.itNumber) '.'], functionInput);
    % control stage progression
    switch state.stage
        case 0 % algorithm is in first iteration, read data on site
            [sites] = stageDataReading(functionInput,sites,instance);
        case 1 % algorithm is learning (x-update)
            [sites] = stageLearning(functionInput,sites,instance);
    end
    
    % write site output
    writeSiteOutput(sites,functionInput)
    
    
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