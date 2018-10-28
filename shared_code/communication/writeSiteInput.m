function writeSiteInput(functionInput,sites,state,instance)
% This function places the three relevant structs (sites, state, instance)
% into one struct outputStruct. It saves the struct in a .mat file for each
% corresponding site. A site only receives the row in the sites struct
% that corresponds to that site.

for i_siteIds = 1:length(instance.siteIds)
    % find the index of the i_siteIds-th site in the site struct
    siteIndex = find([sites.id] == instance.siteIds(i_siteIds));
    
    % create struct of structs
    outputStruct = struct;
    outputStruct.sites = sites(siteIndex);
    outputStruct.state = state;
    outputStruct.instance = instance;
       
    % create folder path with input for the corresponding site
    pathToFolderForSite = fullfile(functionInput.pathToMasterOutputFolder,['input_' num2str(instance.siteIds(i_siteIds))]);
    % create folder (all input for a given site needs to be in a folder with a pre-defined name)
    mkdir(pathToFolderForSite)
    % create file name for .mat file containing site input
    pathToFileForSite = fullfile(pathToFolderForSite,'site_input.mat');
    % save outputStruct in .mat file
    save(pathToFileForSite,'outputStruct')   
end

end