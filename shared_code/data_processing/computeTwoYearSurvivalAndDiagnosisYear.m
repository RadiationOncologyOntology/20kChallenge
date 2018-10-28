function [outputMatrix,outputLabel] = computeTwoYearSurvivalAndDiagnosisYear(dataCell,dataHeader)
%% survival
% find labels in header
diseaseDateInd = find(strcmp('diseaseDate',dataHeader));
followupDateInd = find(strcmp('vitalStatusDate',dataHeader));
vitalStatusInd = find(strcmp('vitalStatusLabel',dataHeader));
% select relevant columns
diseaseDateCol = dataCell(:,diseaseDateInd);
followupDateCol = dataCell(:,followupDateInd);
vitalStatusCol = dataCell(:,vitalStatusInd);
%convert columns to datenum
diseaseDateDatenumCol = datenum(datetime(diseaseDateCol,'InputFormat','yyyy-MM-dd'));
followupDateDatenumCol = datenum(datetime(followupDateCol,'InputFormat','yyyy-MM-dd'));
% compute follow-up or survival days
daysUntilLastFollowup = followupDateDatenumCol - diseaseDateDatenumCol;

%% twoYearSurvival
[curOut] = computeBinarySurvivalVariableAllowingMissingDates(vitalStatusCol,daysUntilLastFollowup,2);
outputLabel{1,1} = 'twoYearSurvival';
outputMatrix(:,1) = curOut;
%% disagnosisYear
curOut = year(datetime(diseaseDateCol,'InputFormat','yyyy-MM-dd'));
outputLabel{1,2} = 'diagnosisYear';
outputMatrix(:,2) = curOut;
end

function [outcome] = computeBinarySurvivalVariableAllowingMissingDates(vitalStatusCol,daysUntilLastFollowup,yearCutoff)

numeroRows = size(vitalStatusCol,1);

for i_rows = 1:numeroRows
    if strcmp('',vitalStatusCol{i_rows}) % missing vital status
        outcome(i_rows) = NaN;
    elseif strcmp('Death',vitalStatusCol{i_rows}) && daysUntilLastFollowup(i_rows) <= (yearCutoff*365.24) % died until day yearCutoff * 365.24
        outcome(i_rows) = 0;
    elseif strcmp('Death',vitalStatusCol{i_rows}) && daysUntilLastFollowup(i_rows) > (yearCutoff*365.24) % died after day yearCutoff * 365.24
        outcome(i_rows) = 1;
    elseif strcmp('Life',vitalStatusCol{i_rows}) && daysUntilLastFollowup(i_rows) <= (yearCutoff*365.24) % alive but not enough follow up
        outcome(i_rows) = NaN;
    elseif strcmp('Life',vitalStatusCol{i_rows}) && daysUntilLastFollowup(i_rows) > (yearCutoff*365.24) % alive after day yearCutoff * 365.24
        outcome(i_rows) = 1;
    elseif isnan(daysUntilLastFollowup(i_rows)) % diagnosisDate or followupDate are empty
        outcome(i_rows) = NaN;
    else
        error('Unrecognized vitalStatusLabel or date entries.')
    end
end

end