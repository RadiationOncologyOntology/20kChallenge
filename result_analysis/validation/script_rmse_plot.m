%% load resultStruct struct
clear
clc
addpath('..\shared_code')
%% training data
% open result file
[fileName,pathName] = uigetfile('..\..\..\vlp_result_files\*.txt','Select validation result .txt-file for TRAINING cohort');
fileId = fopen(fullfile(pathName,fileName),'r');

% read json string from file
jsonString = fscanf(fileId,'%s');

% close file
fclose(fileId);

% turn json string into struct
resultStructTraining = jsondecode(jsonString);
%% validation data
% open result file
[fileName,pathName] = uigetfile('..\..\..\vlp_result_files\*.txt','Select validation result .txt-file for VALIDATION cohort');
fileId = fopen(fullfile(pathName,fileName),'r');

% read json string from file
jsonString = fscanf(fileId,'%s');

% close file
fclose(fileId);

%turn json string into struct.
resultStructValidation = jsondecode(jsonString);


%% inputs
% defaults
[figDefaults] = loadFigureDefaults;
figure_dims = figDefaults.figureDimsHistogram;
xlabel_str = 'Iteration';
ylabel_left_str = 'RMSE';
ylabel_right_str = 'Regression coefficient';
legendEntries = {'RMSE Training','RMSE Validation','Regression coefficients'};
legendPosition = [0.648190909090909 0.637214285714286 0.200000000000000 0.140000000000000];
fontsizeXYAxis = figDefaults.fontsizeXYAxis;
fontsizeInGraph = figDefaults.fontsizeInGraph;
numeroIterations = length(resultStructValidation.rmse);
ylimsLeft = [0.39 0.82];
ylimsRight = [-1.8 1.3];
xLims = [0 82];
linewidthRmse = figDefaults.linewidthThick;
linewidthCoefficients = figDefaults.linewidthThin;
imageWhiteMargin = figDefaults.imageWhiteMargin;

% pick dark blue & violet
linecolors = colorPickerQualitative;
linecolors = linecolors([4 8],:);

% pick grey & and combine with previous colors
linecolorsNew = colorPicker(4,true);
linecolorsNew(end,:) = linecolorsNew(end,:)*1.4; % slightly lighter grey
linecolors(3,:) = linecolorsNew(end,:);

saveOn = true;
%% plotting
% figure
figureHandle = figure('position', figure_dims, 'color', [1 1 1]);
set(figureHandle,'defaultAxesColorOrder',[0,0,0; 0,0,0])

% we use two yaxes (yyaxis) which always places the right y axis in the
% front. We overcome this by moving the coefficient graphs (which belong to the
% right axis) in -1 on the z-direction. So, they are behind the RMSE. 
set(gca,'sortmethod', 'depth') % workaround for plotting coefficients behind RMSE, this allows plotting based on z-depth

box on;
hold on;

% plot rmses on left axis
yyaxis left
phTraining = plot(resultStructTraining.rmse,'LineStyle','-','Marker','*','Color',linecolors(1,:),'LineWidth',linewidthRmse);
phValidation = plot(resultStructValidation.rmse,'LineStyle','-','Marker','*','Color',linecolors(2,:),'LineWidth',linewidthRmse);

ylabel(ylabel_left_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);
ylim(ylimsLeft);

% force 2 decimals
axisLabelsDecimals('yticklabel', 2);

% plot coefficients on right axis
yyaxis right

phCoefficients = line((1:size(resultStructTraining.zLog,2))',...
    resultStructTraining.zLog',...
    -ones(size(resultStructTraining.zLog)),...
    'Marker','none','Color',linecolors(3,:),'LineStyle','-','LineWidth',linewidthCoefficients);

ylabel(ylabel_right_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);
ylim(ylimsRight);
xlim(xLims);

% force 1 decimal, this causes a bug when zooming in the figure editor
% because the tick labels are turned into a cell of strings which are
% repeated when moving/zooming the figure.
axisLabelsDecimals('yticklabel', 1);

% legend
legendEntries = strcat({'  '}, legendEntries); % add 2 spaces in front of legend labels
legendHandle = legend(legendEntries,'FontSize',fontsizeInGraph,'Position', legendPosition);

% labels
xlabel(xlabel_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);

% remove upper ticks
removeTicksUnusedAxes('');

% ticks outside
set(gca,'tickdir','out')

%% coefficient labels (Look at RIGHT AXIS for coordinates!)
numeroCoefficients = size(resultStructTraining.zLog,1);

% coefficient labels
coefficientLabels = {'Intercept','T0','T2','T3','T4','TX','N1','N2','N3','NX','M1','MX','0','II','III','IV','Occult'};

% labels x positions: first use a linspace ordering for x coordinates and then manually adjust
coefficientLabelsXPosition = round(linspace(2,numeroIterations-1,numeroCoefficients));
coefficientLabelsXPosition(1) = 34; %intercept
coefficientLabelsXPosition(2) = 64; %t0
coefficientLabelsXPosition(3) = 52; %t2
coefficientLabelsXPosition(4) = 25; %t3
coefficientLabelsXPosition(5) = 60; %t4
coefficientLabelsXPosition(6) = 75; %tx
coefficientLabelsXPosition(7) = 50; %n1
coefficientLabelsXPosition(8) = 32; %n2
coefficientLabelsXPosition(9) = 33; %n3
coefficientLabelsXPosition(10) = 12; %nx
coefficientLabelsXPosition(11) = 20; %m1
coefficientLabelsXPosition(12) = 20; %mx
coefficientLabelsXPosition(13) = 57;
coefficientLabelsXPosition(14) = 13; %stageII
coefficientLabelsXPosition(15) = 75; %stageIII
coefficientLabelsXPosition(16) = 27; %stageIV
coefficientLabelsXPosition(17) = 20; %stageOccult

% labels y positions: get them from zLog and then manually adjust
for i_coefficient = 1:numeroCoefficients
    coefficientLabelsYPosition(i_coefficient) = resultStructTraining.zLog(i_coefficient, coefficientLabelsXPosition(i_coefficient));
end
% slightly move one label in the y dimension for better visuals
coefficientLabelsYPosition(10) = 0.125; %nx
% place labels
for i_coefficient = 1:numeroCoefficients
    text(coefficientLabelsXPosition(i_coefficient),...
        coefficientLabelsYPosition(i_coefficient),...
        coefficientLabels{i_coefficient},...
        'FontSize', fontsizeInGraph,'fontweight','bold','Color',linecolors(end,:),'HorizontalAlignment','center','BackgroundColor',[1 1 1],'Margin',0.00001);
end


% save
if saveOn
    printCrop([mfilename '_rmse_crop.png'],'-dpng','-r300',imageWhiteMargin)
end