clear
clc
userInput.maxIter = 10000;
%% adjust values here
% sparql query & endpointKey for sparql
% when using the local simulation: leave .sparqlQuery and .endpointKey empty
userInput.sparqlQuery = '';
userInput.endpointKey = '';

% randomization seed (yet unused)
userInput.dataSplitSeed = 1;

% regression coefficients (copied from training output: b)
userInput.coefficients = [];
% zLog (copied from training output: resultStruct.zLog)
userInput.zLog = [];
% train on patients with diagnosis date after this date
userInput.trainingDateStart = datenum(datetime('01-01-1978','InputFormat','dd-MM-yyyy'));
% train on patients with diagnosis date before this date MUST ALLOW FOR ENOUGH FOLLOW UP
userInput.trainingDateEnd = datenum(datetime('31-12-2011','InputFormat','dd-MM-yyyy')); 
% validate on patients with diagnosis date after this date
% userInput.validationDateStart = userInput.trainingDateStart; % if you want to validate on training data
userInput.validationDateStart = datenum(datetime('01-01-2012','InputFormat','dd-MM-yyyy'));
% validate on patients with diagnosis date before this date MUST ALLOW FOR ENOUGH FOLLOW UP
% userInput.validationDateEnd = userInput.trainingDateEnd; % if you want to validate on training data
userInput.validationDateEnd = datenum(datetime('31-12-2015','InputFormat','dd-MM-yyyy')); 

% name of outcome variable
userInput.outcomeName = 'twoYearSurvival';
% names of features
userInput.featureNames = {'tLabel' 'nLabel' 'mLabel' 'stageLabel'};

% for each feature in userInput.featureNames: if the feature is a
% categorical with more than 2 categories, provide the vector of possible
% values (needs to be numerical) For binary and continuous variables, use [].
% Note for future updates: categoricalFeatureRange is a bit of a misnomer - consider renaming.
userInput.categoricalFeatureRange = cell(1,length(userInput.featureNames));
userInput.categoricalFeatureRange{1} = [1 0 2 3 4 5]; % tLabel PLACE REFERENCE CATEGORY AT FRONT; USE THE SAME AS IN PLRT
userInput.categoricalFeatureRange{2} = [0:4]; % nLabel PLACE REFERENCE CATEGORY AT FRONT; USE THE SAME AS IN PLRT
userInput.categoricalFeatureRange{3} = [0:2]; % mLabel PLACE REFERENCE CATEGORY AT FRONT; USE THE SAME AS IN PLRT
userInput.categoricalFeatureRange{4} = [1 0 2 3 4 5]; % stageLabel PLACE REFERENCE CATEGORY AT FRONT; USE THE SAME AS IN PLRT

%%
% names of all variables, automatically constructed from earlier input
userInput.variableNames = [userInput.featureNames userInput.outcomeName];
% loop to calculate the number of coefficients for x,u,z
numberOfCoefficients = 1; % start with 1 for the 'intercept'
for i_catFeatRange = 1:length(userInput.categoricalFeatureRange)
    if isempty(userInput.categoricalFeatureRange{i_catFeatRange})
        numberOfCoefficients = numberOfCoefficients + 1;
    else
        numberOfCoefficients = numberOfCoefficients + (numel(userInput.categoricalFeatureRange{i_catFeatRange}) - 1); % you create (numel()- 1) dummy variables
    end 
end
userInput.x = zeros(numberOfCoefficients,1);
userInput.u = zeros(numberOfCoefficients,1);
userInput.z = ones(numberOfCoefficients,1);


% create json string from userInput struct and save to text file
jsonString = jsonencode(userInput);

fileId = fopen('userInputFile_validation.txt','w');
fprintf(fileId,jsonString);
fclose(fileId);
