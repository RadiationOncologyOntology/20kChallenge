function createProgressFigures(functionInput,instance)
% This function plots a progress figure in the VLP: RMSE versus iterations
% on the left y-axis and regression coefficients versus iterations on the
% right y-axis. Code is highly tailored to create a suitable figure for
% this research. It will probably break in any other context.

% prepare path to image output folder
imageFolderPath = fullfile(functionInput.pathToMasterOutputFolder,'Images');

%% inputs
% defaults
[figDefaults] = loadFigureDefaults;
figure_dims = figDefaults.figureDimsHistogram;
xlabel_str = 'Iteration';
ylabel_left_str = 'RMSE';
ylabel_right_str = 'Regression coefficient';
legendEntries = {'RMSE Training (left axis)','Regression coefficients (right axis)'};
fontsizeXYAxis = figDefaults.fontsizeXYAxis;
fontsizeInGraph = figDefaults.fontsizeInGraph;
numeroIterations = size(instance.zLog,2);
ylimsLeft = [-0.02 max(0.72,1.1 * max(instance.rootMeanSquareErrorLog))];
ylimsRight = [min(-1.52, 1.1 * min(instance.zLog(:))) max(1.52, 1.1 * max(instance.zLog(:)))];
linewidthRmse = figDefaults.linewidthThick;
linewidthCoefficients = figDefaults.linewidthThin;

% line color choice & adjustments
linecolors = [221 28 119;161 161 161]/255; % violet and gray
%% plotting
% figure
figureHandle = figure('position', figure_dims, 'color', [1 1 1],'visible','off');
set(figureHandle,'defaultAxesColorOrder',[0,0,0; 0,0,0]);

set(gca,'sortmethod', 'depth'); % workaround for plotting coefficients behind RMSE, this allows plotting based on z-depth

box on;
hold on;

% plot rmses on left axis (unfortunately 'yyaxis right' is always on top)
yyaxis left
phTraining = plot(instance.rootMeanSquareErrorLog,'LineStyle','-','Marker','*','Color',linecolors(1,:),'LineWidth',linewidthRmse);
ylabel(ylabel_left_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);
ylim(ylimsLeft);

% force 2 decimals
axisLabelsDecimals('yticklabel', 2);

% plot coefficients on right axis (unfortunately 'yyaxis right' is always on top)
yyaxis right
phCoefficients = line((1:size(instance.zLog,2))',...
    instance.zLog',...
    -ones(size(instance.zLog)),...
    'Marker','none','Color',linecolors(2,:),'LineStyle','-','LineWidth',linewidthCoefficients);

ylabel(ylabel_right_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);
ylim(ylimsRight);

% force 1 decimal
axisLabelsDecimals('yticklabel', 1);

% legend
legendEntries = strcat({'  '}, legendEntries); % add 2 spaces in front of legend labels
legendHandle = legend(legendEntries,'FontSize',fontsizeInGraph,'Location','northoutside');

% labels
xlabel(xlabel_str, 'fontweight', 'bold', 'fontsize', fontsizeXYAxis);

%% coefficient labels (Look at RIGHT AXIS for coordinates!)
numeroCoefficients = size(instance.zLog,1);

% coefficient labels
coefficientLabels = {'Intercept','T0','T2','T3','T4','TX','N1','N2','N3','NX','M1','MX','0','II','III','IV','Occult'};

% labels x positions: first use a linspace ordering for x coordinates and then manually adjust
coefficientLabelsXPosition = round(linspace(2,numeroIterations-1,numeroCoefficients));

% labels y positions: get them from zLog and then manually adjust
for i_coefficient = 1:numeroCoefficients
    coefficientLabelsYPosition(i_coefficient) = instance.zLog(i_coefficient, coefficientLabelsXPosition(i_coefficient));
end
% place labels
for i_coefficient = 1:numeroCoefficients
    text(coefficientLabelsXPosition(i_coefficient),...
        coefficientLabelsYPosition(i_coefficient),...
        coefficientLabels{i_coefficient},...
        'FontSize', fontsizeInGraph,'fontweight','bold','Color',linecolors(end,:),'HorizontalAlignment','center','BackgroundColor',[1 1 1],'Margin',0.00001);
end

% create images folder
mkdir(imageFolderPath);
% print figure to folder
print(fullfile(imageFolderPath,'progress.png'),'-dpng','-r300');
close(figureHandle);
end


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

% transparancy
figDefaults.faceAlpha = .8;

% image white margin
figDefaults.imageWhiteMargin = 10;
end

function axisLabelsDecimals(selectedAxis, numDecimals)
% selectedAxis can be 'yticklabel' or 'xticklabel'
% numDecimals needs to be a whole and positive number

% build the formatting specification based on the number of desired decimals
formatSpec = ['%.' num2str(numDecimals) 'f'];

% get the current labels (cell of strings)
tickLabels = get(gca, selectedAxis);

% adjust the labels using sprintf and formatspec
tickLabels = cellfun(@(x) sprintf(formatSpec, str2double(x)), tickLabels, 'un', 0);

% update the ticklabels in the figure
set(gca, selectedAxis, tickLabels);
end