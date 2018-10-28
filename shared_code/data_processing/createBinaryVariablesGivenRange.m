function [binarizedData,binarizedDataNames] = createBinaryVariablesGivenRange(data,catVarLogical,variableNames,valueRange)
% convert categorical variables into multiple columns of binary vectors
% the first value in each cell of valueRange acts as the reference for that
% variable.
% valueRange should contain unique values for each variable.
%% if variableNames is [], generate names
if isempty(variableNames)
    for ii = 1:size(data,2)
   variableNames{ii} = ['var' num2str(ii)];  
    end
end

%%
binarizedData = []; % start with an empty output variable
binarizedDataNames = {}; % start with an empty output for variable names
for ii = 1:size(data,2)
    if catVarLogical(ii) == 0 % if the current variable is non-categorical, just attach it as the next column
        binarizedData = [binarizedData data(:,ii)];
        binarizedDataNames = [binarizedDataNames variableNames{ii}];  
    else
        uniqueValues = valueRange{ii}; % list all unique values in the current column
        uniqueValues = uniqueValues(2:end);
        binarizedVariable = nan(size(data,1),numel(uniqueValues)); % initialize a matrix of nans (nans are easier to stop in case of a mistake)
        binarizedVariableNames = [];
        for jj = 1:numel(uniqueValues) % loop through the number of unique values
            binarizedVariable(:,jj) = data(:,ii) == uniqueValues(jj); % column jj contains 1s where the current variable has unique value jj
            binarizedVariableNames{jj} = [variableNames{ii} '_' num2str(uniqueValues(jj))];
        end
        binarizedData = [binarizedData binarizedVariable]; % attach binarized variable to output matrix
        binarizedDataNames = [binarizedDataNames binarizedVariableNames];
    end
end
end