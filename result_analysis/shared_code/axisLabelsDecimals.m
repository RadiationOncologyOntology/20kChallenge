function axisLabelsDecimals(selectedAxis, numDecimals)
% selectedAxis can be 'yticklabel' or 'xticklabel'
% numDecimals needs to be a whole and positive number

% build the formatting specification based on the number of desired decimals
formatSpec = ['%.' num2str(numDecimals) 'f'];

% get the current labels (cell of strings)
tickLabels = get(gca, selectedAxis);

% adjust the labels using sprintf and formatspec
tickLabels = cellfun(@(x) sprintf(formatSpec, str2double(x)), tickLabels, 'un', 0);

% update the ticklabels in the figure
set(gca, selectedAxis, tickLabels);