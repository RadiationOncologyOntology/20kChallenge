clear
clc
%% adjust values here
% sparql query & endpointKey
% when using the local simulation: leave .sparqlQuery and .endpointKey empty
userInput.sparqlQuery = '';
userInput.endpointKey = '';

%%
% create json string from userInput struct and save to text file
jsonString = jsonencode(userInput);

fileId = fopen('userInputFile_statistics.txt','w');
fprintf(fileId,jsonString);
fclose(fileId);