function writeToLog(logText,functionInput)
% Write line (string) to log file

logText = [logText '\r\n']; % always end line after string
% open log file (path retrieved from mainMaster.m or mainSite.m function input)
fid = fopen(functionInput.pathToLogFile, 'a');
% print line
fprintf(fid, logText);
% close log file
fclose(fid);

end