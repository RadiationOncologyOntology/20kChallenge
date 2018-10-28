function [totalPatientCount,completeCasePatientCount] = computeTotalAndCompleteCasePatientCount(inputData,dataHeader)
% This function computes the patient counts in the entire inputData
% cell/matrix. It also computes complete case patient counts: the patient counts MINUS the patients that
% do not have 2-year survival information.
if iscell(inputData)
    totalPatientCount = size(inputData,1);
    % compute two-year survival and diagnosis year (the date is unnecessary
    % here)
    [twoYearSurvivalAndDiagnosisYear,outputLabel] = computeTwoYearSurvivalAndDiagnosisYear(inputData,dataHeader);
    twoYearSurvival = twoYearSurvivalAndDiagnosisYear(:,1); % keep only two-year survival
    hasSurvivalInformation = ~isnan(twoYearSurvival); % check which row has non-NaN two-year survival
    isCompleteCase = ~any(cellfun(@isempty,inputData),2); % check which row has complete columns
    completeCasePatientCount = sum((isCompleteCase & hasSurvivalInformation)); % check which row has both
elseif ismatrix(inputData)
    % if it is a matrix we assume that it contains tnms and survival information
    totalPatientCount = size(inputData,1);
    completeCasePatientCount = sum(~any(isnan(inputData),2));
else
    error('inputData is not a cell or a matrix')
end

end