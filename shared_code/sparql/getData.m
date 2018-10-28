function [dataCell,dataHeader] = getData(functionInput,instance)
% if the sparqlQuery is emtpy, it is assumed that you are in a local
% simulation, so you read data from a .mat file.
if ~isempty(instance.sparqlQuery)
    % Add sparql proxy and query information to logging variable
    writeToLog('============================= SPARQL ====================',functionInput);
    writeToLog(['proxy: ' functionInput.sparqlProxy],functionInput);
    writeToLog(['endpointKey: ' instance.endpointKey],functionInput);
    writeToLog(['sparqlToken: ' functionInput.sparqlToken],functionInput);
    writeToLog('query :',functionInput);
    writeToLog(instance.sparqlQuery,functionInput);
    writeToLog('=========================================================',functionInput);
    
    % Perform the sparql query using the code specifically made to work
    % with the proxy in the Varian Learning Portal
    [dataHeader, dataCell, extra] = sparql_vlp(functionInput.sparqlProxy,instance.sparqlQuery,instance.endpointKey,functionInput.sparqlToken,functionInput);
    
    % Add to logging a line indicating data read was finished
    writeToLog(['Data was read: ' num2str(size(dataCell, 1)) ' rows, ' num2str(size(dataCell,2)) ' columns.' ],functionInput);
    
    % assume that all output from SPARQL is char, if not make it an empty char
    isChar = strcmp('char',cellfun(@class,dataCell,'UniformOutput',false));
    dataCell(~isChar) = {''}; % replace all non-char cells by empty string cells
else
    % code for local simulation
    load(fullfile(functionInput.pathToTempFolder,'dataRaw.mat'),'dataCell','dataHeader');
end
end


