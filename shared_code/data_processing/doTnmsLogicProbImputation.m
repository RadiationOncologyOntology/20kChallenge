function [dataCellTargetSet] = doTnmsLogicProbImputation(dataCellTargetSet,dataCellReferenceSet,dataHeader)
% find columns for T, N, M, and overall stage
tInd = find(strcmp('tLabel',dataHeader));
nInd = find(strcmp('nLabel',dataHeader));
mInd = find(strcmp('mLabel',dataHeader));
sInd = find(strcmp('stageLabel',dataHeader));
diseaseDateInd = find(strcmp('diseaseDate',dataHeader));

if any(isempty([tInd nInd mInd sInd diseaseDateInd]))
    error('T, N, M, stage, or diagnosis date columns not found in sparql_vlp output.')
end

% logicprob imputation
tnms = dataCellTargetSet(:,[tInd nInd mInd sInd]); %tnmstage
tnms_years = year(datetime(dataCellTargetSet(:,diseaseDateInd),'InputFormat','yyyy-MM-dd')); %date of diagnosis
tnms_prob_impute_ref = dataCellReferenceSet(:,[tInd nInd mInd sInd]);
tnms_prob_impute_ref_years = year(datetime(dataCellReferenceSet(:,diseaseDateInd),'InputFormat','yyyy-MM-dd')); %date of diagnosis
verbose_bool = false;
rng(1);
[tnms_imputed, ~, ~] = fTnmsImpute20kChallenge(tnms, tnms_years, tnms_prob_impute_ref, tnms_prob_impute_ref_years, verbose_bool);

dataCellTargetSet(:,[tInd nInd mInd sInd]) = tnms_imputed;
end