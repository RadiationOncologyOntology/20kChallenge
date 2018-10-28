function [sites] = computeCalibrationPlot(outcome,prediction,linearpredictor,sites)
%% calibration plot calculate metrics for storage in sites-struct

% hard-coded stuff
number_of_quantiles = 10;
number_of_bins = 20;
confidence_percentage = 95;        % e.g. 95% CI
confidence_algorithm = 'Wilson';   % binomial CI approx algorithm used in confint() function : 'Wald' 'Wilson' 'Agresti-Coull' 'Jeffreys' 'Clopper-Pearson' 'arc-sine' 'logit' 'Anscombe'
% Reference for confint() is: Anderson Winkler & Tom Nichols, University of Oxford, Brainder.org, 2012, https://brainder.org/2012/04/21/confidence-intervals-for-bernoulli-trials/
% Reference comparing the different intervals: Brown, Statistical Science. 2001 16(2):101-133)


% 1: labels
calib_histogram_positive_label = 'Alive';
calib_histogram_negative_label = 'Dead';

% 2: calibration-in-the-large == b      log reg of linear predictor     S' = a*S + b	with a==1 and b free
number_of_patients = numel(outcome);
% fit a logistic regression with a new linear predictor that is equal to b0 +
% b1*x+linearpredictor. As long as we use zeros for x, glmfit attemps to
% fit b0 and b1 but it keeps b1 at 0 because there is no variation. If we
% changed x to a value above 1, it cannot distinguish b0 and b1 and assigns
% all weight to b1 (the larger constant).
% If we change x to a value in (0,1], Matlab still assigns all weight to b0.
% (It seems to always select the larger x to assign all weight.)
recalib_b = glmfit(zeros(number_of_patients, 1), outcome, 'binomial', 'link', 'logit', 'offset', linearpredictor); % crude fix (asking for output [recalib_b, recalib_dev, recalib_stats] gives crash when ill conditioned)
calib_legend_caliblarge = recalib_b(1);
% If you add calib_legend_caliblarge to your old prediction, the mean of
% the updated prediction will be equal to the mean of the outcome.

% 3: calibration slope == a             log reg of linear predictor     S' = a*S + b	with a and b free
recalib_b = glmfit(linearpredictor, outcome, 'binomial', 'link', 'logit');
calib_legend_calibslope = recalib_b(2);


% 4: quantiles and their confidence intervals
% divide the patients over the quantiles
[prediction_sorted, sortindex] = sortrows(prediction);
outcome_sorted = outcome(sortindex);
quant_groupsize = floor(number_of_patients / number_of_quantiles);
quant_groupsizes = quant_groupsize .* ones(number_of_quantiles,1);
leftover = number_of_patients - sum(quant_groupsizes);
if leftover
    % divide n leftover patients over first n quantiles
    quant_groupsizes(1:leftover) = quant_groupsizes(1:leftover)+1;
end
quant_groupsizes_ends   = cumsum(quant_groupsizes);
quant_groupsizes_starts = [1; quant_groupsizes_ends(1:end-1)+1];
if sum(quant_groupsizes) ~= numel(outcome)
    error('total number of patients is not the same as the sum of the patients in the subgroups');
end

% construct quantile cell
quants_columns = {'quantile_nr', 'ptnr_start', 'ptnr_end', 'npts', 'pred_prct_start', 'pred_prct_end', 'npred', 'nobs', 'mean_pred', 'mean_obs', 'ci_low', 'ci_high'};
quants_array = nan(number_of_quantiles, numel(quants_columns));
for i_quantile = 1:number_of_quantiles
    % get subgroup of patients
    quant_min = quant_groupsizes_starts(i_quantile);
    quant_max = quant_groupsizes_ends(i_quantile);
    
    if quant_max > number_of_patients % this is probably old code that can go
        quant_max = number_of_patients;
    end
    
    quant_prediction = prediction_sorted(quant_min:quant_max);
    quant_outcome = outcome_sorted(quant_min:quant_max);
    
    % quantile nr, ptnr_start, ptnr_end, npts
    quants_array(i_quantile, 1)  = i_quantile;
    quants_array(i_quantile, 2)  = quant_min;
    quants_array(i_quantile, 3)  = quant_max;
    quants_array(i_quantile, 4)  = quant_max - quant_min + 1;
    
    % quantile start percentage, end percentage
    quants_array(i_quantile, 5)  = prediction_sorted(quant_min);
    quants_array(i_quantile, 6)  = prediction_sorted(quant_max);
    
    % number prediction, number outcome
    quants_array(i_quantile, 7)  = mean(quant_prediction) * quants_array(i_quantile,4);
    quants_array(i_quantile, 8)  = sum(quant_outcome);
    
    % mean prediction, mean outcome
    quants_array(i_quantile, 9)  = mean(quant_prediction);
    quants_array(i_quantile, 10) = mean(quant_outcome);
    
    % compute CI for bernoulli trial using desired algorithm (confint ref see top of script)
    [L,U] = confint(numel(quant_outcome), sum(quant_outcome), 1-(confidence_percentage/100), confidence_algorithm);
    quants_array(i_quantile, 11) = L;
    quants_array(i_quantile, 12) = U;
end

% store quantile coordinates
calib_quantiles_x = quants_array(:,9);
calib_quantiles_y = quants_array(:,10);

% store quantile confidence intervals
calib_quantiles_confidence_low = quants_array(:,11);
calib_quantiles_confidence_high = quants_array(:,12);


% 6: histograms for positive and negative class
% width of single bin
histbinwidth = 1/number_of_bins;

% calculate negative class histogram
[binneg_n, binneg_cen] = hist(prediction_sorted(outcome_sorted==0), histbinwidth/2:histbinwidth:(1-histbinwidth/2));
calib_histogram_negative_bins_x = binneg_cen;
calib_histogram_negative_bins_y = binneg_n;

% calculate positive class histogram
[binpos_n, binpos_cen] = hist(prediction_sorted(outcome_sorted==1), histbinwidth/2:histbinwidth:(1-histbinwidth/2));
calib_histogram_positive_bins_x = binpos_cen;
calib_histogram_positive_bins_y = binpos_n;

% store in sites-struct
sites.calib_legend_caliblarge = calib_legend_caliblarge;
sites.calib_legend_calibslope = calib_legend_calibslope;
sites.calib_quantiles_x = calib_quantiles_x;
sites.calib_quantiles_y = calib_quantiles_y;
sites.calib_quantiles_confidence_low = calib_quantiles_confidence_low;
sites.calib_quantiles_confidence_high = calib_quantiles_confidence_high;
sites.calib_histogram_positive_label = calib_histogram_positive_label;
sites.calib_histogram_positive_bins_x = calib_histogram_positive_bins_x;
sites.calib_histogram_positive_bins_y = calib_histogram_positive_bins_y;
sites.calib_histogram_negative_label = calib_histogram_negative_label;
sites.calib_histogram_negative_bins_x = calib_histogram_negative_bins_x;
sites.calib_histogram_negative_bins_y = calib_histogram_negative_bins_y;
end