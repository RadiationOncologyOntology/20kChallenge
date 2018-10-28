function [instance] = mergeVariableFrequencies(sites,instance)
% This function combines summary statisticcs from each site: column labels
% (variableLabels), categories in each column (categories), and
% corresponding frequencies (freq).
% This will not work with continuous variables.

for i_siteIndices = 1:length(sites)
    numeroVariables = length(sites(i_siteIndices).categories);
    for i_variables = 1:numeroVariables
    instance.categories{i_siteIndices,i_variables} = sites(i_siteIndices).categories{i_variables};
    instance.freq{i_siteIndices,i_variables} = sites(i_siteIndices).freq{i_variables};
    instance.variableLabels{i_siteIndices,i_variables} = sites(i_siteIndices).variableLabels{i_variables};
    end
end
end