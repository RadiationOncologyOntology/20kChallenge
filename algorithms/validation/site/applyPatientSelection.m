function [dataMatrix,dataHeader,sites] = applyPatientSelection(dataCell,dataHeader,instance,sites)
[sites.totalPatientCountBeforeSelection,sites.completeCasePatientCountBeforeSelection] = computeTotalAndCompleteCasePatientCount(dataCell,dataHeader);
% remove patients without diseaseDate (diagnosis date) or vitalStatusDate or vitalStatusLabel
[patientWithMissingValuesInd] = getPatientsWithMissingDiagnosisOrVitalStatusVariables(dataCell,dataHeader);
dataCell(patientWithMissingValuesInd,:) = [];
[sites.totalPatientCountAfterMissingDiagnOrVitStatVarDel,sites.completeCasePatientCountAfterMissingDiagnOrVitStatVarDel] = computeTotalAndCompleteCasePatientCount(dataCell,dataHeader);
% identify training patients by given cutoffs which are needed for imputation
[trainPatientInds] = getPatientsTreatedInInterval(dataCell,dataHeader,instance.trainingDateStart,instance.trainingDateEnd);
dataCell_training_patients = dataCell(trainPatientInds,:);
[sites.totalPatientCountAfterYearCutoffsTraining,sites.completeCasePatientCountAfterYearCutoffsTraining] = computeTotalAndCompleteCasePatientCount(dataCell_training_patients,dataHeader);
% identify validation patients by given cutoffs
[validationPatientInds] = getPatientsTreatedInInterval(dataCell,dataHeader,instance.validationDateStart,instance.validationDateEnd);
dataCell_validation_patients = dataCell(validationPatientInds,:);
[sites.totalPatientCountAfterYearCutoffsValidation,sites.completeCasePatientCountAfterYearCutoffsValidation] = computeTotalAndCompleteCasePatientCount(dataCell_validation_patients,dataHeader);
% logicprob imputation
[dataCell_validation_patients] = doTnmsLogicProbImputation(dataCell_validation_patients,dataCell_training_patients,dataHeader);
[sites.totalPatientCountAfterImputation,sites.completeCasePatientCountAfterImputation] = computeTotalAndCompleteCasePatientCount(dataCell_validation_patients,dataHeader);
% remove rows with missing values in any column after imputation
dataCell_validation_patients(any(cellfun(@isempty,dataCell_validation_patients),2),:) = [];
[sites.totalPatientCountAfterIncompleteCaseDeletion,sites.completeCasePatientCountAfterIncompleteCaseDeletion] = computeTotalAndCompleteCasePatientCount(dataCell_validation_patients,dataHeader);
% convert to numerical variables
[dataMatrix,dataHeader] = convertVariableCellToNumericVariables(dataCell_validation_patients,dataHeader);

% remove patients with missing outcome (missing outcomes are only possible
% because of insufficient follow-up)
outcomeInd = strcmp(dataHeader,instance.outcomeName);
dataMatrix(isnan(dataMatrix(:,outcomeInd)),:) = [];

% check if there are any NaNs in the relevant columns of the dataMatrix. Throw an error if there are.
variableInds = cellfun(@(x) find(strcmp(dataHeader,x)),instance.variableNames);
if any(any(isnan(dataMatrix(:,variableInds))))
    error('There are NaNs in dataMatrix. This should not be possible: something does not work the way it should.')
end
[sites.totalPatientCountAfterPatientSelection,sites.completeCasePatientCountAfterPatientSelection] = computeTotalAndCompleteCasePatientCount(dataMatrix(:,variableInds),[]);
end