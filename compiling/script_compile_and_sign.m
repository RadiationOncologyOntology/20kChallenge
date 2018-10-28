clear
clc
%% user input
algoType = ''; % 'training' 'validation','statistics'
% path to the location of the repository on local machine
pathToRepository = '';
% path to the Varian File Signer on your local machine (do not store in repository)
pathToFileSigner = '';
% text file with password of the Varian File Signer provided by Varian (do not store in repository)
pathToFileSignerPassword = '';

%% construct path variables
% path to compiling folder in the repository
pathToCompilingFolder = fullfile(pathToRepository,'compiling');
% path to folder where compiled master exe will be stored and later zippped
pathToMasterZipFolder = fullfile(pathToCompilingFolder,'master');
% path to folder where compiled site exe will be stored and later zippped
pathToSiteZipFolder = fullfile(pathToCompilingFolder,'site');

% path to algorithm-specific code
pathAlgorithmSpecificCode = fullfile(pathToRepository,'algorithms',algoType);

%% delete old zippping folders
if exist(pathToMasterZipFolder,'dir') == 7
    rmdir(pathToMasterZipFolder,'s');
end
if exist(pathToSiteZipFolder,'dir') == 7
    rmdir(pathToSiteZipFolder,'s');
end
%% create new zipping folders
mkdir(pathToMasterZipFolder)
mkdir(pathToSiteZipFolder)
%% compile
% add shared code to path
addpath(genpath(fullfile(pathToRepository,'shared_code')))

disp('Creating .exe for master...');
% compiles mainMaster.m and places it in the zipping folder
mcc('-m',fullfile(pathAlgorithmSpecificCode,'master','mainMaster.m'),'-d',pathToMasterZipFolder)

disp('Creating .exe for sites...');
% compiles mainSite.m and places it in the zipping folder
mcc('-m',fullfile(pathAlgorithmSpecificCode,'site','mainSite.m'),'-d',pathToSiteZipFolder)
%% sign master and site folder
% read file signer password
fileSignerPassword = fileread(pathToFileSignerPassword);
% sign .zip-file
dos([pathToFileSigner ' ' pathToCompilingFolder ' ' fileSignerPassword])
