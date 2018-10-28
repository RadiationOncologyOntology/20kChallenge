function [figDefaults] = loadFigureDefaults

% figure dimensions
figDefaults.figureDimsHistogram = [200 100 1100 700];
figDefaults.figureDimsCalibration = [200 100 900 700];

% font size
figDefaults.fontsizeXYAxis = 12;
figDefaults.fontsizeInGraph = 11;

% line widths
figDefaults.linewidthThick = 3;
figDefaults.linewidthThin = 2;
figDefaults.linewidthThinniest = 1.2;

% site order
figDefaults.siteOrder = [3 2 6 5 4 1 7 8];

% transparancy
figDefaults.faceAlpha = .8;

% image white margin
figDefaults.imageWhiteMargin = 10;

end