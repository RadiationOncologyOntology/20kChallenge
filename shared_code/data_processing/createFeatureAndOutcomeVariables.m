function [features,outcome] = createFeatureAndOutcomeVariables(dataMatrix,dataHeader,instance)
% Take the data matrix on the site and create a matrix of features and a
% vector of outcomes. The order of the feature matrix obeys the order in
% instance.featureNames.

% create outcome variable
outcomeInd = strcmp(dataHeader,instance.outcomeName);
outcome = dataMatrix(:,outcomeInd);

% initialize matrix
features = nan(size(dataMatrix,1),length(instance.featureNames));
% iteratively add feature to matrix
for i_features = 1:length(instance.featureNames)
    featureInd = strcmp(dataHeader,instance.featureNames(i_features));
    features(:,i_features) = dataMatrix(:,featureInd);
end

end