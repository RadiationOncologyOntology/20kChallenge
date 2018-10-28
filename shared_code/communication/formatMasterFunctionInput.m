function [functionInput] = formatFunctionInput(functionInput)
% convert function input variables from string to numeric values
functionInput.runId = str2double(functionInput.runId);
functionInput.itNumber = str2double(functionInput.itNumber);
functionInput.abort = str2double(functionInput.abort);
functionInput.siteIds = convertStrVecToNumVec(functionInput.siteIds);
end