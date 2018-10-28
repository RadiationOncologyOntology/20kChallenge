%% load sites struct
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

%% plot calibration plot from resultStruct-struct metrics

% defaults
[figDefaults] = loadFigureDefaults;
figure_dims = figDefaults.figureDimsCalibration;
imageWhiteMargin = figDefaults.imageWhiteMargin;
fontsizeXYAxis = figDefaults.fontsizeXYAxis;
linewidth = figDefaults.linewidthThinniest;
hist_fontsize = figDefaults.fontsizeInGraph;
legend_fontsize = figDefaults.fontsizeInGraph;
xlabel_str = 'Predicted probability';
ylabel_str = 'Observed frequency';
xlims = [-0.05, 1.05];
ylims = [-0.15, 1.05];
quantile_marker_size = 110;
diagonal_number_of_dashes = 50;
loess_span_prct = 90;
hist_y_pos = -0.05;
hist_y_maxsize = 0.08;
hist_text_y_margin = 0.02;
hist_text_x = 1.0;
hist_hline_color = [0 0 0];%[.6 .6 .6];
legend_xa = 0.05;
legend_xb = 0.45;
legend_xc = 0.55; % only used for two sites because of their quantile positions
legend_xd = 0.95; % only used for two sites because of their quantile positions
legend_y1 = .95;
legend_y2 = .3; % only used for two sites because of their quantile positions
legend_yspacing = 0.06;
saveOn = true;


% get preferred site order
[figDefaults] = loadFigureDefaults;
siteOrder = figDefaults.siteOrder; 

% get site colors
[siteColors] = colorPickerQualitative();
siteColors = flipud(siteColors);    % flip because we made a mistake in colorPickerQualitative() and the bar plot (we think)
[~,maxSortInd] = sort(siteOrder,'ascend');
siteColors = siteColors(maxSortInd,:); % magic fix to color problem

% get site names
siteIds = resultStruct.siteIds;
siteNames = mapSiteIdsToNames(siteIds);


% loop over sites
number_of_sites = length(resultStruct.siteIds);
for i_site = 1:number_of_sites
    siteInd = siteOrder(i_site);
    % figure
    figure('position', figure_dims, 'color', [1 1 1]);
    hold on;
    box on;
    axis square;
    
    % plot diagonal
    dashpoints_xy = linspace(0, 1, 2*diagonal_number_of_dashes);
    dashpoints_xy = reshape(dashpoints_xy, 2, diagonal_number_of_dashes);
    line([dashpoints_xy dashpoints_xy], [dashpoints_xy dashpoints_xy], 'color', 'k');  
    
    % plot error bars
    errorbars_x = [resultStruct.calib_quantiles_x(siteInd,:); resultStruct.calib_quantiles_x(siteInd,:)];
    errorbars_y = [resultStruct.calib_quantiles_confidence_low(siteInd,:); resultStruct.calib_quantiles_confidence_high(siteInd,:)];
    line(errorbars_x, errorbars_y, 'color', 'k', 'linewidth', linewidth);
        
    % plot quantiles
    scatter(resultStruct.calib_quantiles_x(siteInd,:), resultStruct.calib_quantiles_y(siteInd,:), quantile_marker_size, '^', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', siteColors(siteInd,:), 'linewidth', linewidth);
    
    
    % plot histogram
    % normalize positive/negative bins based on bin with most count
    max_bin_count = max([resultStruct.calib_histogram_negative_bins_y(siteInd,:), resultStruct.calib_histogram_positive_bins_y(siteInd,:)]);
    positive_bins_y_normalized =  resultStruct.calib_histogram_positive_bins_y(siteInd,:) / (max_bin_count / hist_y_maxsize) + hist_y_pos;
    negative_bins_y_normalized = -resultStruct.calib_histogram_negative_bins_y(siteInd,:) / (max_bin_count / hist_y_maxsize) + hist_y_pos;
    
    % negative/positive histograms, override horizontal line with gray line
    bar(resultStruct.calib_histogram_positive_bins_x(siteInd,:), positive_bins_y_normalized, 1, 'facecolor', siteColors(siteInd,:), 'basevalue', hist_y_pos, 'showbaseline', 'off', 'edgecolor', 'k', 'linewidth', linewidth);
    bar(resultStruct.calib_histogram_negative_bins_x(siteInd,:), negative_bins_y_normalized, 1, 'facecolor', siteColors(siteInd,:), 'basevalue', hist_y_pos, 'showbaseline', 'off', 'edgecolor', 'k', 'linewidth', linewidth);
    line([0 1], [hist_y_pos hist_y_pos], 'color', hist_hline_color, 'linewidth', linewidth);
    
    % add histograms text
    positive_bins_last_y = positive_bins_y_normalized(end);
    negative_bins_last_y = negative_bins_y_normalized(end);
    
    text(hist_text_x, positive_bins_last_y + hist_text_y_margin, resultStruct.calib_histogram_positive_label{siteInd}, 'fontsize', hist_fontsize, 'horizontalalignment', 'right', 'verticalalignment', 'bottom')
    text(hist_text_x, negative_bins_last_y - hist_text_y_margin, resultStruct.calib_histogram_negative_label{siteInd}, 'fontsize', hist_fontsize, 'horizontalalignment', 'right', 'verticalalignment', 'top')
    
    
    % plot legend (top left)
    % rectangle
    legendMarginWhite = 0.03;
    if siteInd == 2 || siteInd == 3 % fix legend positions for 2 sites where calibration quantiles overlap with legend
        legend_x1 = legend_xc;
        legend_x2 = legend_xd;
        legend_y = legend_y2;
    else
        legend_x1 = legend_xa;
        legend_x2 = legend_xb;
        legend_y = legend_y1;
    end
    patchHandle = patch([legend_x1 - legendMarginWhite, legend_x2+legendMarginWhite, legend_x2+legendMarginWhite, legend_x1 - legendMarginWhite],...
        [legend_y + legendMarginWhite, legend_y+legendMarginWhite, legend_y-3*legend_yspacing-1.2*legendMarginWhite, legend_y-3*legend_yspacing-1.2*legendMarginWhite], [1 1 1]);
    uistack(patchHandle,'bottom');
    
    % sitename
    text(legend_x1, legend_y, siteNames{siteInd}, 'FontSize', legend_fontsize, 'fontweight', 'bold')
    
    % left hand text
    text(legend_x1, legend_y - 1*legend_yspacing, 'Calibration-in-the-large:', 'FontSize', legend_fontsize)
    text(legend_x1, legend_y - 2*legend_yspacing, 'Calibration slope:', 'FontSize', legend_fontsize)
    text(legend_x1, legend_y - 3*legend_yspacing, 'AUC:', 'FontSize', legend_fontsize)
    
    % values
    value_auc        = resultStruct.auc(siteInd);
    value_caliblarge = resultStruct.calib_legend_caliblarge(siteInd);
    value_calibslope = resultStruct.calib_legend_calibslope(siteInd);
    
    % right hand text
    text(legend_x2, legend_y-1*legend_yspacing, sprintf('%.2f', value_caliblarge), 'FontSize', legend_fontsize, 'horizontalalignment', 'right')
    text(legend_x2, legend_y-2*legend_yspacing, sprintf('%.2f', value_calibslope), 'FontSize', legend_fontsize, 'horizontalalignment', 'right')
    text(legend_x2, legend_y-3*legend_yspacing, sprintf('%.2f', value_auc), 'FontSize', legend_fontsize, 'horizontalalignment', 'right')
    
    % remove upper ticks
    removeTicksUnusedAxes('square');
    
    % limits
    set(gca,'xlim', xlims, 'ylim', ylims, 'xtick', 0:.1:1, 'ytick', 0:.1:1);
    
    % force 1 decimal on both axes
    axisLabelsDecimals('xticklabel', 1);
    axisLabelsDecimals('yticklabel', 1);
        
    % ticks outside
    set(gca,'tickdir','out')
  
    % labels
    xlabel(xlabel_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);
    ylabel(ylabel_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);
    
    % save
    if saveOn
        printCrop([mfilename '_' siteNames{siteInd} '_calib_crop.png'],'-dpng','-r300', imageWhiteMargin)
    end
    
end
%% collect numbers for results table
% load figure defaults to get the preferred site order
siteOrder = figDefaults.siteOrder;

siteInfoTable = table;
siteInfoTable.siteName = resultStruct.siteIds;
siteInfoTable.trueSiteName = mapSiteIdsToNames(siteInfoTable.siteName);
siteInfoTable.calibrationInTheLarge = round(resultStruct.calib_legend_caliblarge,2);
siteInfoTable.calibrationSlope = round(resultStruct.calib_legend_calibslope,2);

% order rows according to preferred site order
siteInfoTable = siteInfoTable(siteOrder,:);

disp('Result table with calibration values:')
disp(siteInfoTable)