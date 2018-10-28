function [headValues, tableResult] = parseJsonQueryResults( binaryData,functionInput)
%PARSEJSONQUERYRESULTS Parses the binary JSON data, which is output of a
%SPARQL query.
% Input parameters:
%   - binaryData: binary data coming from the HTTP result
%   - functionInput: input arguments from mainSite(); passed in for
%                    debugging (writeToLog() requires .pathToLogFile)
% Output parameters:
%   - headValues: the "column" names specified as variables in the SELECT
%       part of the SPARQL query
%   - tableResult: cell matrix containing the results

jsonData = jsondecode(binaryData);

%if "SubmitSparqlQueryResult" exists as field, we are interpreting the
%Varian Learning Portal JSON result
if isfield(jsonData, 'SubmitSparqlQueryResult')
    jsonData = jsondecode(jsonData.SubmitSparqlQueryResult);
end

%retrieve the variable names
headValues = jsonData.head.vars;

numeroVariables = length(headValues);
numeroRows = size(jsonData.results.bindings,1);

%% Replacement for dataTable = cell2mat(jsonData.results.bindings');
% dataTable will be a struct with rows for each row in the queried data
% and columns for each variable in the queried data
dataTable = struct;
% i_vars is the number of variables requested in the SPARQL query
% i_rows is the number of rows returned from the SPARQL query (as seen in
% the blazegraph interface)
for i_vars = 1:numeroVariables
    curVar = headValues{i_vars};
    for i_rows = 1:numeroRows
        % class of .bindings is struct if queried data is complete and cell
        % otherwise. Indexing is adjusted accordingly.
        if isstruct(jsonData.results.bindings)
            if isfield(jsonData.results.bindings(i_rows),curVar)
                dataTable(i_rows,1).(curVar) =  jsonData.results.bindings(i_rows).(curVar);
            end
        elseif iscell(jsonData.results.bindings)
            if isfield(jsonData.results.bindings{i_rows},curVar)
                dataTable(i_rows,1).(curVar) =  jsonData.results.bindings{i_rows}.(curVar);
            end
        else
            error('jsonData.results.bindings is neither struct nor cell.')
        end
    end
end
%%


%determine output cell matrix
tableResult = cell(size(dataTable,1), size(headValues,2));

%loop over all columns
for i=1:numeroVariables
    currentVar = headValues{i};
    
    %loop over all rows
    for j=1:numeroRows
        %get the specific row
        row = dataTable(j);
        
        if isfield(row, currentVar) & ~isempty(row.(currentVar))
            %get the column information for this row
            colStruct = row.(currentVar);
            
            %retrieve the column value for this row
            value = colStruct.value;
            
            %check if it's a literal, if yes, convert properly
            if(strcmp(colStruct.type,'literal'))
                dataType = 'NotAvailable';
                if isfield(colStruct, 'datatype')
                    dataType = colStruct.datatype;
                end
                value = parseLiteral(dataType, value);
            end
        else
            value = '';
        end
        
        %add the value to the final cell matrix
        tableResult(j,i) = {value};
    end
end
end

