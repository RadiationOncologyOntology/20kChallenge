clear
clc

% open result file
[fileName,pathName] = uigetfile('..\..\..\vlp_result_files\*.txt','Select training result .txt-file');
fileId = fopen(fullfile(pathName,fileName),'r');

% read json string from file
jsonString = fscanf(fileId,'%s');

% close file
fclose(fileId);

%turn json string into struct.
resultStruct = jsondecode(jsonString);

b = resultStruct.zLog(:,end);
bRounded = round(b,2);
disp('Final beta coefficients:')
disp(round(b,2))

disp('Final obj:')
disp(resultStruct.objLog(end))

disp('Final log loss obj:')
disp(resultStruct.objLossLog(end))

disp('Final regularization obj:')
disp(resultStruct.objRegLog(end))

