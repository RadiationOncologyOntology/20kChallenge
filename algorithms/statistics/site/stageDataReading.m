function [sites] = stageDataReading(functionInput,sites,instance)
% This stage reads the data from the site and computes summary statistics.
[dataCell,dataHeader] = getData(functionInput,instance);

% compute summary stats for variables at this site
[sites] =  computeVariableFrequencies(dataCell,dataHeader,sites);
end