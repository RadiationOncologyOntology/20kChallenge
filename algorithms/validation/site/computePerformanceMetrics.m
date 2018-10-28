function [sites] = computePerformanceMetrics(features,outcome,instance,sites)

prediction = glmval(instance.coefficients,features,'logit');
linearPredictor = [ones(size(features,1),1) features] * instance.coefficients;
%% ROC
[xRocPlusCi,yRocPlusCi,~,aucPlusCi] = perfcurve(outcome,prediction,1,'NBoot',1000);
sites.auc = aucPlusCi(1);
sites.aucCi = aucPlusCi(2:3);

sites.xRoc = xRocPlusCi(:,1);
sites.xRocCi = xRocPlusCi(:,2:3);

sites.yRoc = yRocPlusCi(:,1);
sites.yRocCi = yRocPlusCi(:,2:3);

%% calibration plot
[sites] = computeCalibrationPlot(outcome,prediction,linearPredictor,sites);

%% sum of square error for each z
numeroIterations = size(instance.zLog,2);
for i_zLog = 1:numeroIterations
    predictionZLog = glmval(instance.zLog(:,i_zLog),features,'logit');
    sites.sumSquareError(i_zLog) = sum((outcome-predictionZLog).^2);
end
end