function [sites,state,instance] = stageEvaluation(functionInput,sites,state,instance)
% This stage computes or arranges model performance metrics computed at the site.

% store each site's AUC in instance struct
for i_sites = 1:length(sites)
    % roc
    instance.auc(i_sites) = sites(i_sites).auc;
    instance.aucCi{i_sites} = sites(i_sites).aucCi;
    
    instance.xRoc{i_sites} = sites(i_sites).xRoc;
    instance.yRoc{i_sites} = sites(i_sites).yRoc;
    
    instance.xRocCi{i_sites} = sites(i_sites).xRocCi;
    instance.yRocCi{i_sites} = sites(i_sites).yRocCi;
    
    % calibration
    instance.calib_legend_caliblarge(i_sites) = sites(i_sites).calib_legend_caliblarge;
    instance.calib_legend_calibslope(i_sites) = sites(i_sites).calib_legend_calibslope;
    instance.calib_quantiles_x(i_sites,:) = sites(i_sites).calib_quantiles_x;
    instance.calib_quantiles_y(i_sites,:) = sites(i_sites).calib_quantiles_y;
    instance.calib_quantiles_confidence_low(i_sites,:) = sites(i_sites).calib_quantiles_confidence_low;
    instance.calib_quantiles_confidence_high(i_sites,:) = sites(i_sites).calib_quantiles_confidence_high;
    instance.calib_histogram_positive_label{i_sites} = sites(i_sites).calib_histogram_positive_label;
    instance.calib_histogram_positive_bins_x(i_sites,:) = sites(i_sites).calib_histogram_positive_bins_x;
    instance.calib_histogram_positive_bins_y(i_sites,:) = sites(i_sites).calib_histogram_positive_bins_y;
    instance.calib_histogram_negative_label{i_sites} = sites(i_sites).calib_histogram_negative_label;
    instance.calib_histogram_negative_bins_x(i_sites,:) = sites(i_sites).calib_histogram_negative_bins_x;
    instance.calib_histogram_negative_bins_y(i_sites,:) = sites(i_sites).calib_histogram_negative_bins_y;
    
    % sum squared error per iteration (the z computed in an iteraiton) per site
    instance.sumSquareErrorPerSite(i_sites,:) = sites(i_sites).sumSquareError;
end

% merge patient counts from sites
[instance] = mergePatientCounts(sites,instance);
instance.totalPatientCountInValidation = sum(instance.patientCount);
% compute root mean square error per iteration
instance.rmse = sqrt(sum(instance.sumSquareErrorPerSite,1)/instance.totalPatientCountInValidation);

% write output
writeResult(functionInput,instance)
% write AUC per site to log
writeToLog(['AUC per site: ' num2str(instance.auc)],functionInput);
end