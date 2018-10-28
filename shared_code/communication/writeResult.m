function writeResult(functionInput,instance)
%   Save the instance struct to a json-coded .txt-file as the final output.

% prepare path name
finalResultFile = fullfile(functionInput.pathToMasterOutputFolder,'Result.txt');
% write instance struct as json string
jsonString = jsonencode(instance);
% open the result text file
fileId = fopen(finalResultFile,'w');
% print json string to file
fprintf(fileId,jsonString);
% close file
fclose(fileId);
end