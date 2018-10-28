function [functionInput] = formatSiteFunctionInput(functionInput)
% convert function input variables from string to numeric values
functionInput.itNumber = str2double(functionInput.itNumber);
end