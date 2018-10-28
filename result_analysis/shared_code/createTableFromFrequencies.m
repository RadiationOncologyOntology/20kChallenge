function [statsTable] = createTableFromFrequencies(freq,variableCats,variableLabels,resultStruct)
%% store all frequencies in a matrix where each row represents a site
% place frequencies for each variable of a site in one row
for i_sites = 1:length(freq)
    freqRow = [];
    for i_vars = 1:length(freq{i_sites})
        freqRow = [freqRow freq{i_sites}{i_vars}];
    end
    % place this row in a matrix
    freqMatrix(i_sites,:) = freqRow;   
end

%% create column names in the format: variable label + variable value

% initialize an empty cell of the correct size
columnNames = cell(1,size(freqMatrix,2));
% use a counter to fill the cells consecutively
colCounter = 0;
% loop through each variable label
for i_vars = 1:length(variableCats)
    % loop through each value of that variable
    for i_cats = 1:length(variableCats{i_vars})
        % increment counter
        colCounter = colCounter + 1;
        % construct column name
        colName = [variableLabels{i_vars} variableCats{i_vars}{i_cats}];
        % remove forbidden symbols (Matlab table restrictions)
        colName = strrep(colName,'-','');
        colName = strrep(colName,' ','');
        colName = strrep(colName,'.','');
        colName = strrep(colName,'*','');
        colName = strrep(colName,'(','');
        colName = strrep(colName,')','');
        % place column name in the cell
   columnNames{colCounter} = colName; 
    end
end

% create statistics table from frequency matrix
statsTable = array2table(freqMatrix);
% place column names in table
statsTable.Properties.VariableNames = columnNames;

% place site numbers as row names
for i_sites = 1:length(freq)
    statsTable.Properties.RowNames(i_sites) = {['Site ' num2str(resultStruct.siteIds(i_sites))]};
end

end