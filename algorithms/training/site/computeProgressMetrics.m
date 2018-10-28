function [sites] = computeProgressMetrics(features,outcome,sites)
% compute the sum square error using previous ADMM iteration's z.
% needed for progress visualization
predictionZ = glmval(sites.z,features,'logit');
sites.sumSquareError = sum((outcome-predictionZ).^2);
end