function [dataMatrix,dataHeader,sites] = applyPatientSelection(dataCell,dataHeader,instance,sites)
[sites.totalPatientCountBeforeSelection,sites.completeCasePatientCountBeforeSelection] = computeTotalAndCompleteCasePatientCount(dataCell,dataHeader);
% remove patients without diseaseDate (diagnosis date) or vitalStatusDate or vitalStatusLabel
[patientWithMissingValuesInd] = getPatientsWithMissingDiagnosisOrVitalStatusVariables(dataCell,dataHeader);
dataCell(patientWithMissingValuesInd,:) = [];
[sites.totalPatientCountAfterMissingDiagnOrVitStatVarDel,sites.completeCasePatientCountAfterMissingDiagnOrVitStatVarDel] = computeTotalAndCompleteCasePatientCount(dataCell,dataHeader);
% keep patients within cutoffs
[patientInds] = getPatientsTreatedInInterval(dataCell,dataHeader,instance.trainingDateStart,instance.trainingDateEnd);
dataCell_patients_in_interval = dataCell(patientInds,:);
[sites.totalPatientCountAfterYearCutoffs,sites.completeCasePatientCountAfterYearCutoffs] = computeTotalAndCompleteCasePatientCount(dataCell_patients_in_interval,dataHeader);
% imputation
[dataCell_patients_in_interval] = doTnmsLogicProbImputation(dataCell_patients_in_interval,dataCell_patients_in_interval,dataHeader);
[sites.totalPatientCountAfterImputation,sites.completeCasePatientCountAfterImputation] = computeTotalAndCompleteCasePatientCount(dataCell_patients_in_interval,dataHeader);
% remove rows with missing values in any column after imputation
dataCell_patients_in_interval(any(cellfun(@isempty,dataCell_patients_in_interval),2),:) = [];
[sites.totalPatientCountAfterIncompleteCaseDeletion,sites.completeCasePatientCountAfterIncompleteCaseDeletion] = computeTotalAndCompleteCasePatientCount(dataCell_patients_in_interval,dataHeader);
% convert to numerical variables
[dataMatrix,dataHeader] = convertVariableCellToNumericVariables(dataCell_patients_in_interval,dataHeader);

% remove patients with missing outcome
outcomeInd = strcmp(dataHeader,instance.outcomeName);
dataMatrix(isnan(dataMatrix(:,outcomeInd)),:) = [];

% check if there are any NaNs in the relevant columns of the dataMatrix. Throw an error if there are.
variableInds = cellfun(@(x) find(strcmp(dataHeader,x)),instance.variableNames);
if any(any(isnan(dataMatrix(:,variableInds))))
    error('There are NaNs in dataMatrix. This should not be possible: something does not work the way it should.')
end
[sites.totalPatientCountAfterPatientSelection,sites.completeCasePatientCountAfterPatientSelection] = computeTotalAndCompleteCasePatientCount(dataMatrix(:,variableInds),dataHeader);
end