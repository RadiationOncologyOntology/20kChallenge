function [ value ] = parseLiteral( dataType, value )
%PARSELITERAL Process value according to dataType

switch char(dataType)
    case 'http://www.w3.org/2001/XMLSchema#int'
        value = str2num(strrep(value, ',', '.'));
    case 'http://www.w3.org/2001/XMLSchema#integer'
        value = str2num(strrep(value, ',', '.'));
    case 'http://www.w3.org/2001/XMLSchema#double'
        value = str2double(strrep(value, ',', '.'));
    case 'http://www.w3.org/2001/XMLSchema#date'
        value = value;
    otherwise
        % deactivated to prevent massive log files
        %             warning(['no conversion defined for data-type: ' dataType]);
end

end

