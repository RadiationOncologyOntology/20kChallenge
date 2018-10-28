%% load resultStruct struct
clear
clc
addpath('..\shared_code')
% open result file
[fileName,pathName] = uigetfile('..\..\..\vlp_result_files\*.txt','Select validation result .txt-file');
fileId = fopen(fullfile(pathName,fileName),'r');

% read json string from file
jsonString = fscanf(fileId,'%s');

% close file
fclose(fileId);

%turn json string into struct.
resultStruct = jsondecode(jsonString);



%% plot ROC plot from resultStruct-struct metrics

% defaults
[figDefaults] = loadFigureDefaults;
siteOrder = figDefaults.siteOrder; % in what order sites should be displayed
figure_dims = figDefaults.figureDimsCalibration;
imageWhiteMargin = figDefaults.imageWhiteMargin;
linewidth = figDefaults.linewidthThick;
fontsizeXYAxis = figDefaults.fontsizeXYAxis;
fontsizeInGraph = figDefaults.fontsizeInGraph;
xlabel_str = '1 - Specificity';
ylabel_str = 'Sensitivity';
legendPosition = [0.62 0.12 0.3 0.35];
xlims = [-0.05, 1.05];
ylims = [-0.05, 1.05];
diagonal_number_of_dashes = 50;
legend_x1 = 0.68;
legend_x2 = legend_x1 + 0.07;
legend_x3 = legend_x2 + 0.15;
legend_y1 = 0.02;
legend_spacing = 0.05;
number_of_sites = numel(resultStruct.siteIds);

[linecolors] = colorPickerQualitative();
linecolors = flipud(linecolors);    % flip to match other figures

linestyles = {'-', '-', '-', '-', '-', '-', '-', '-'};
siteNames = resultStruct.siteIds;
siteNames = mapSiteIdsToNames(siteNames);
saveOn = true;

% figure
figure('position', figure_dims, 'color', [1 1 1]);
hold on;
box off;
axis equal;

% plot diagonal line with custom spacing
dashpoints_xy = linspace(0, 1, 2*diagonal_number_of_dashes);
dashpoints_xy = reshape(dashpoints_xy, 2, diagonal_number_of_dashes);
line([dashpoints_xy dashpoints_xy], [dashpoints_xy dashpoints_xy], 'color', 'k');

% loop over sites
for i_site = 1:number_of_sites
    siteInd = siteOrder(i_site);
    plotHandle(i_site) = plot(resultStruct.xRoc{siteInd}, resultStruct.yRoc{siteInd},...
        '-', 'linewidth', linewidth, 'color', linecolors(i_site, :), 'linestyle', linestyles{i_site});
end

% labels
xlabel(xlabel_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);
ylabel(ylabel_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);

% remove upper ticks
removeTicksUnusedAxes('equal');

% limits
ylim(ylims);
xlim(xlims);

% force 1 decimal on both axes
axisLabelsDecimals('xticklabel', 1);
axisLabelsDecimals('yticklabel', 1);

% ticks outside
set(gca,'tickdir','out')

% manual legend
legendLabel = siteNames;
legendMarginWhite = 0.03;

% big white background rectangle
topY = .4;
patch([legend_x1 - legendMarginWhite, 1, 1, legend_x1 - legendMarginWhite], [legend_y1 - legendMarginWhite, legend_y1 - legendMarginWhite, topY topY], [1 1 1])

% small white background rectangle for legend title
height = .07;
patch([legend_x1 - legendMarginWhite, 1, 1, legend_x1 - legendMarginWhite], [topY, topY, topY+height, topY+height], [1 1 1])
text(legend_x2, topY+height/2, 'Site', 'fontsize', fontsizeInGraph, 'fontweight', 'bold')
text(legend_x3-.003, topY+height/2, 'AUC', 'fontsize', fontsizeInGraph, 'fontweight', 'bold')

% loop over legend entries in reverse order to match other plot legends
for i_legendEntry = 1:number_of_sites
    siteInd = siteOrder(i_legendEntry);
    
    curSiteName = legendLabel{siteInd};
    curColor = linecolors(i_legendEntry,:);
    curAUC = resultStruct.auc(siteInd);
    
    % the y value of the current plotline/sitename/auc
    curY = legend_y1+legend_spacing*(number_of_sites-(i_legendEntry-1)-1); % reversed legend order
    
    % manual legend plotlines
    linelength = .05;
    line([legend_x1 legend_x1+linelength], [curY curY], 'linewidth',linewidth,'Color',curColor)
    
    % sitename and auc
    text(legend_x2, curY, curSiteName, 'fontsize', fontsizeInGraph);
    text(legend_x3, curY, sprintf('%.2f',curAUC), 'fontsize', fontsizeInGraph);
end


% save
if saveOn
    printCrop([mfilename '_roc_crop.png'],'-dpng','-r300',imageWhiteMargin)
end