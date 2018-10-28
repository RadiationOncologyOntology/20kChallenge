function [siteOutput] = readSiteOutput(functionInput)
% Opens .mat files received from each site and combines their sites
% structs.

for i_siteIds = 1:length(functionInput.siteIds)

    % construct path to site output folder
    pathToSiteOutputFolder = fullfile(functionInput.pathToSiteOutputFolder,['DistOutput_' num2str(functionInput.siteIds(i_siteIds))]);
    % construct path to site output file
    pathToSiteOutputFile = fullfile(pathToSiteOutputFolder,'site_output.mat');
    % load sites struct for given site
    siteOutputDump = load(pathToSiteOutputFile,'sites');
    newSite = siteOutputDump.sites;
    
    %%
    % check that the site struct is indeed from the expected site
    if functionInput.siteIds(i_siteIds) ~= newSite.id
        error('Site order is messed up.')
    end
    
    % construct siteOutput struct
    if i_siteIds == 1
        siteOutput = newSite;
    else
        siteOutput = [siteOutput newSite];
    end
end
end