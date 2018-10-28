function [patientInds] = getPatientsTreatedInInterval(dataCell,dataHeader,startYear,endYear)
% find indices of patients treated in the interval [startYear,endYear]

% find labels in header
diseaseDateInd = find(strcmp('diseaseDate',dataHeader));

% select relevant columns
diseaseDateCol = dataCell(:,diseaseDateInd);

%convert columns to datenum
diseaseDateDatenumCol = datenum(datetime(diseaseDateCol,'InputFormat','yyyy-MM-dd'));

% check for dates in interval
patientInds = (diseaseDateDatenumCol >= startYear & diseaseDateDatenumCol <= endYear);
end