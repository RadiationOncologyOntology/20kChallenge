function [userInput] = readUserInput(functionInput)
% Reads the json string from user input file and converts it to a struct.

% open file on path retreived from mainMaster function input parameters
fileId = fopen(functionInput.pathToUserInputFile,'r');

% read json string from file
jsonString = fscanf(fileId,'%c');

% close file
fclose(fileId);

%turn json string into struct.
userInput = jsondecode(jsonString);
end