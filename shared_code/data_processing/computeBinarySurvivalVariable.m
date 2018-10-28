function [outcome] = computeBinarySurvivalVariable(vitalStatusCol,daysUntilLastFollowup,yearCutoff)

numeroRows = size(vitalStatusCol,1);

for i_rows = 1:numeroRows
    if strcmp('',vitalStatusCol{i_rows}) % missing vital status
        outcome(i_rows) = NaN;
        error('vital Status is NaN during survival calculation but patients with NaN should have been removed earlier: something does not work the way it should.')
    elseif strcmp('Death',vitalStatusCol{i_rows}) && daysUntilLastFollowup(i_rows) <= (yearCutoff*365.24) % died until day yearCutoff * 365.24
        outcome(i_rows) = 0;
    elseif strcmp('Death',vitalStatusCol{i_rows}) && daysUntilLastFollowup(i_rows) > (yearCutoff*365.24) % died after day yearCutoff * 365.24
        outcome(i_rows) = 1;
    elseif strcmp('Life',vitalStatusCol{i_rows}) && daysUntilLastFollowup(i_rows) <= (yearCutoff*365.24) % alive but not enough follow up
        outcome(i_rows) = NaN;
    elseif strcmp('Life',vitalStatusCol{i_rows}) && daysUntilLastFollowup(i_rows) > (yearCutoff*365.24) % alive after day yearCutoff * 365.24
        outcome(i_rows) = 1;
    else
        error('Unrecognized vitalStatusLabel or date entries.')
    end
end

end