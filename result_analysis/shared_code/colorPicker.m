function colors = colorPicker(numberOfColors,includeMissing)
% color scheme: light to dark violet and grey (grey is used for missing)

if includeMissing
    numberOfColors = numberOfColors - 1;
end
switch numberOfColors
    case 2
        colors = ['rgb(231,225,239)','rgb(221,28,119)']; % handmade from  colorbrewer 3
    case 3
        colors = ['rgb(231,225,239)','rgb(201,148,199)','rgb(221,28,119)']; % colorbrewer 3
    case 4
        colors = ['rgb(241,238,246)','rgb(215,181,216)','rgb(223,101,176)','rgb(206,18,86)']; % colorbrewer 4
    case 5
        colors = ['rgb(241,238,246)','rgb(215,181,216)','rgb(223,101,176)','rgb(221,28,119)','rgb(152,0,67)']; % colorbrewer 5
    case 6
        colors = ['rgb(241,238,246)','rgb(212,185,218)','rgb(201,148,199)','rgb(223,101,176)','rgb(221,28,119)','rgb(152,0,67)']; % colorbrewer 6
    case 7
        colors = ['rgb(241,238,246)','rgb(212,185,218)','rgb(201,148,199)','rgb(223,101,176)','rgb(231,41,138)','rgb(206,18,86)','rgb(145,0,63)']; % colorbrewer 7
    case 8
        colors = ['rgb(247,244,249)','rgb(231,225,239)','rgb(212,185,218)','rgb(201,148,199)','rgb(223,101,176)','rgb(231,41,138)','rgb(206,18,86)','rgb(145,0,63)']; % colorbrewer 8
    otherwise
        error(['invalid number of colors (' num2str(numberOfColors) ') requested for function ''colorpicker'''])
end

% add missing
if includeMissing
    colors = [colors 'rgb(115,115,115)'];
end

% colorbrewer notation to matlab array
colors = strrep(colors,'rgb(','');
colors = strrep(colors,')',',');
colors = strsplit(colors,',');
colors = str2double(colors);
colors = colors(1:end-1);
colors = reshape(colors, 3, length(colors)/3)';
colors = colors./255;
end