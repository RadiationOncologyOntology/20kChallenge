function [instance] = mergePatientCounts(sites,instance)
%   This function merges the patient counts from each site.

for i_siteIndices = 1:length(sites)
    instance.patientCount(i_siteIndices) = sites(i_siteIndices).patientCount; % number of patients/rows
    % before selection
    instance.totalPatientCountBeforeSelection(i_siteIndices) = sites(i_siteIndices).totalPatientCountBeforeSelection;
    instance.completeCasePatientCountBeforeSelection(i_siteIndices) = sites(i_siteIndices).completeCasePatientCountBeforeSelection;
    % after deleting patients with missing diagnosis date, vital status, vital status date
    instance.totalPatientCountAfterMissingDiagnOrVitStatVarDel(i_siteIndices) = sites(i_siteIndices).totalPatientCountAfterMissingDiagnOrVitStatVarDel;
    instance.completeCasePatientCountAfterMissingDiagnOrVitStatVarDel(i_siteIndices) = sites(i_siteIndices).completeCasePatientCountAfterMissingDiagnOrVitStatVarDel;
    % after year cutoffs training
    instance.totalPatientCountAfterYearCutoffsTraining(i_siteIndices) = sites(i_siteIndices).totalPatientCountAfterYearCutoffsTraining;
    instance.completeCasePatientCountAfterYearCutoffsTraining(i_siteIndices) = sites(i_siteIndices).completeCasePatientCountAfterYearCutoffsTraining;
    % after year cutoffs validation
    instance.totalPatientCountAfterYearCutoffsValidation(i_siteIndices) = sites(i_siteIndices).totalPatientCountAfterYearCutoffsValidation;
    instance.completeCasePatientCountAfterYearCutoffsValidation(i_siteIndices) = sites(i_siteIndices).completeCasePatientCountAfterYearCutoffsValidation;
    % after imputation
    instance.totalPatientCountAfterImputation(i_siteIndices) = sites(i_siteIndices).totalPatientCountAfterImputation;
    instance.completeCasePatientCountAfterImputation(i_siteIndices) = sites(i_siteIndices).completeCasePatientCountAfterImputation;
    % after incomplete case deletion
    instance.totalPatientCountAfterIncompleteCaseDeletion(i_siteIndices) = sites(i_siteIndices).totalPatientCountAfterIncompleteCaseDeletion;
    instance.completeCasePatientCountAfterIncompleteCaseDeletion(i_siteIndices) = sites(i_siteIndices).completeCasePatientCountAfterIncompleteCaseDeletion;
    % after patient selection
    instance.totalPatientCountAfterPatientSelection(i_siteIndices) = sites(i_siteIndices).totalPatientCountAfterPatientSelection;
    instance.completeCasePatientCountAfterPatientSelection(i_siteIndices) = sites(i_siteIndices).completeCasePatientCountAfterPatientSelection;
end
end