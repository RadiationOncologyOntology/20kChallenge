function [newLabels] = mapSiteIdsToNames(oldLabels)
anonymizedBoolean = true;
if ~iscell(oldLabels)
    oldLabels = num2cell(oldLabels);
end
newLabels = oldLabels;
for i_site = 1:length(oldLabels)
    switch oldLabels{i_site}
        case {'Site 1', 1}
            if anonymizedBoolean
                newLabels{i_site} = 'Site F';
            else
                newLabels{i_site} = 'CENSORED';
            end
        case {'Site 3', 3}
            if anonymizedBoolean
                newLabels{i_site} = 'Site B';
            else
                newLabels{i_site} = 'CENSORED';
            end
        case {'Site 4', 4}
            if anonymizedBoolean
                newLabels{i_site} = 'Site A';
            else
                newLabels{i_site} = 'CENSORED';
            end
        case {'Site 14', 14}
            if anonymizedBoolean
                newLabels{i_site} = 'Site E';
            else
                newLabels{i_site} = 'CENSORED';
            end
        case {'Site 16', 16}
            if anonymizedBoolean
                newLabels{i_site} = 'Site D';
            else
                newLabels{i_site} = 'CENSORED';
            end
        case {'Site 19', 19}
            if anonymizedBoolean
                newLabels{i_site} = 'Site C';
            else
                newLabels{i_site} = 'CENSORED';
            end
        case {'Site 20', 20}
            if anonymizedBoolean
                newLabels{i_site} = 'Site G';
            else
                newLabels{i_site} = 'CENSORED';
            end
        case {'Site 24', 24}
            if anonymizedBoolean
                newLabels{i_site} = 'Site H';
            else
                newLabels{i_site} = 'CENSORED';
            end
        otherwise
            error('Unkown site ID.')
    end
end