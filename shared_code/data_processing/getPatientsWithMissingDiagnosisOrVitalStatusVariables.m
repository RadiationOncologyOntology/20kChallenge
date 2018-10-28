function [patientWithMissingValuesInd] = getPatientsWithMissingDiagnosisOrVitalStatusVariables(dataCell,dataHeader)
diseaseDateInd = find(strcmp('diseaseDate',dataHeader));
vitalStatusDateInd = find(strcmp('vitalStatusDate',dataHeader));
vitalStatusLabelInd = find(strcmp('vitalStatusLabel',dataHeader));

if any(isempty([diseaseDateInd vitalStatusDateInd vitalStatusLabelInd]))
    error('Diagnosis date, vital status date or vital status label columns not found in sparql_vlp output.')
end

patientWithMissingValuesInd = cellfun(@isempty,dataCell(:,diseaseDateInd)) | cellfun(@isempty,dataCell(:,vitalStatusDateInd)) | cellfun(@isempty,dataCell(:,vitalStatusLabelInd));
end