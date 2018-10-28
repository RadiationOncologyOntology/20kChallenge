clear
clc
addpath('..\shared_code')
% open result file
[fileName,pathName] = uigetfile('..\..\..\vlp_result_files\*.txt','Select statistics result .txt-file');
fileId = fopen(fullfile(pathName,fileName),'r');

% read json string from file
jsonString = fscanf(fileId,'%c');

% close file
fclose(fileId);

%turn json string into struct.
x = jsondecode(jsonString);



numeroSites = length(x.siteIds);
numeroVariables = length(x.variableLabels)/numeroSites;

if mod(numeroVariables,1) ~= 0
    error('The number of variables cannot be determined.')
end

% json does not support multi-dimensional cells
x.categories = reshape(x.categories,numeroSites,numeroVariables);
x.freq = reshape(x.freq,numeroSites,numeroVariables);
x.variableLabels = reshape(x.variableLabels,numeroSites,numeroVariables);
% json returns a site's output directly in x.categories and x.freq, so it
% needs to be placed in an extra cell each to conform with the format for multiple sites
if numeroSites == 1
    x.categories = {x.categories};
    x.freq = {x.freq};
end

% use variable labels from the first site
variableLabels = x.variableLabels(1,:);

%% check that variable labels are equal across sites
for i_sites = 1:numeroSites
    if  ~isequal(x.variableLabels{1},x.variableLabels{i_sites})
        error('Variable labels differ across sites.')
    end
end
%% concatenate site cells
% place the first site's categories as initialization
variableCats = x.categories(1,:);
if numeroSites > 1
    for i_sites = 2:numeroSites
        for i_vars = 1:numeroVariables
            variableCats{i_vars} = [variableCats{i_vars}; x.categories{i_sites,i_vars}];
        end
    end
end
%% make a unique list of categories per variable
for i_vars = 1:numeroVariables
    if isempty(variableCats{i_vars})
        variableCats{i_vars} = {''};
        numeroCats(i_vars) = 0;
    else
        variableCats{i_vars} = unique(variableCats{i_vars});
        numeroCats(i_vars) = length(variableCats{i_vars});
    end
    
end

%% freq cell
freq = cell(1,numeroSites);
for i_sites = 1:numeroSites
    for i_vars = 1:numeroVariables
        for i_cat = 1:numeroCats(i_vars)
            % find the index in the site's category array corresponding to
            % the unique category
            catInd = find(strcmp(variableCats{i_vars}{i_cat},x.categories{i_sites,i_vars}));
            if ~isempty(catInd) % if the category is found, look up frequency in site
                if length(x.freq{i_sites,i_vars}) == 1
                    freq{i_sites}{i_vars}(i_cat) = x.freq{i_sites,i_vars};
                else
                    freq{i_sites}{i_vars}(i_cat) = x.freq{i_sites,i_vars}(catInd);
                end
            else
                freq{i_sites}{i_vars}(i_cat) = 0;
            end
        end
    end
end

% put site names in first row
for i_sites = 1:numeroSites
    outputTable(1,(i_sites+1)) = {['Site ' num2str(x.siteIds(i_sites))]};
end

% start row pointer in row 2 where the first label should be
curVarInd = 2;

% iteratively add variable categories and site frequencies
for i_vars = 1:numeroVariables
    % add label
    outputTable{curVarInd,1} = variableLabels{i_vars};
    % add categories
    outputTable((curVarInd + 1):(curVarInd + numeroCats(i_vars)),1) = variableCats{i_vars};
    % iteratively add frequencies per site
    for i_sites = 1:numeroSites
        outputTable((curVarInd + 1):(curVarInd + numeroCats(i_vars)),(i_sites + 1)) = num2cell(freq{i_sites}{i_vars});
    end
    % move row pointer to the bottom
    curVarInd = curVarInd + numeroCats(i_vars) + 1;
end

%% save tables etc.
outputFileName = 'summarystats_statistics.xls';
deleteFileIfExists(outputFileName);
xlswrite(outputFileName,outputTable);

% create machine readable table
[statsTable] = createTableFromFrequencies(freq,variableCats,variableLabels,x);
% save table as .mat for variable histogram barplot
outputFileName = 'statsTable_statistics.mat';
deleteFileIfExists(outputFileName);
save(outputFileName,'statsTable')
% save as .csv for looking at it
outputFileName = 'statsTable_statistics.csv';
deleteFileIfExists(outputFileName);
writetable(statsTable,outputFileName,'WriteRowNames',true,'Delimiter',';')
