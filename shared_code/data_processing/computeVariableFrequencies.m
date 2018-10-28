function [sites] = computeVariableFrequencies(dataCell,dataHeader,sites)
% This function computes column labels
% (variableLabels), categories in each column (categories), and
% corresponding frequencies (freq).
% This will not work with continuous variables.
%%
%calculate summary statistics per variable

numeroColumns = size(dataCell,2);
numeroRows = size(dataCell,1);
categoryLimit = 0.1 * numeroRows; % stops printing categories for a variable if the number of categories exceeds this limit
rowLimit = 50; % stops the algorithm if there are fewer patients than this limit

if numeroRows < rowLimit
    error(['Less than ' num2str(rowLimit) ' patients on site: stop execution.'])
else
    sites.patientCount = size(dataCell,1); % number of patients/rows    
    sites.variableLabels = dataHeader;
    
    for i_features = 1:numeroColumns
        uniqueCats = unique(dataCell(:,i_features)); % unique categories
        % if there is only one category, place it in a cell
        if ischar(uniqueCats)
            uniqueCats = {uniqueCats};
        end
        
        if length(uniqueCats) <= categoryLimit
            sites.categories{i_features} = uniqueCats;
            numeroCats = length(sites.categories{i_features});
            for i_cats = 1:numeroCats
                curFreq = sum(strcmp(sites.categories{i_features}{i_cats},dataCell(:,i_features)));
                sites.freq{i_features}(i_cats) = curFreq;                   
            end
        else
            sites.categories{i_features} = {['More than 0.1 * number of rows (' num2str(categoryLimit) ') categories.']}; % prevents numeric variables from creating many categories and essentially printing data
            sites.freq{i_features}(1) = 0;
        end
    end
end
end