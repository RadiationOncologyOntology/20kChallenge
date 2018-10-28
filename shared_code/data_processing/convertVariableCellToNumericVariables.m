function [outputMatrix,outputLabel] = convertVariableCellToNumericVariables(dataCell,dataHeader)
% converts the sparql query output into numeric values according to
% supercategories, years, two-year survival definitions
[numeroRows,numeroCols] = size(dataCell);

%% T
% find column index for tLabel
inputInd = find(strcmp('tLabel',dataHeader));
% place tlabel column into new variable
curCol = dataCell(:,inputInd);
% initialize empty column for numeric values
curOut = [];
% loop over each row in curCol and map to numeric value in curOut
for i_rows = 1:numeroRows
    switch curCol{i_rows}
        case {'T0 Stage Finding'}
            curOut(i_rows) = 0;
        case {'T1 Stage Finding','T1a Stage Finding','T1b Stage Finding','T1c Stage Finding','T1mi Stage Finding','Tis Stage Finding'}
            curOut(i_rows) = 1;
        case {'T2 Stage Finding','T2a Stage Finding','T2b Stage Finding'}
            curOut(i_rows) = 2;
        case 'T3 Stage Finding'
            curOut(i_rows) = 3;
        case 'T4 Stage Finding'
            curOut(i_rows) = 4;
        case 'TX Stage Finding'
            curOut(i_rows) = 5;
        case ''
            curOut(i_rows) = NaN;
        otherwise
            error(['Unknown entry: ' curCol{i_rows}])
    end
end
% define column label for outputMatrix
outputLabel{1} = 'tLabel';
% store curOut in outputMatrix
outputMatrix(:,1) = curOut;
%% N
inputInd = find(strcmp('nLabel',dataHeader));
curCol = dataCell(:,inputInd);
curOut = [];
for i_rows = 1:numeroRows
    switch curCol{i_rows}
        case 'N0 Stage Finding'
            curOut(i_rows) = 0;
        case 'N1 Stage Finding'
            curOut(i_rows) = 1;
        case 'N2 Stage Finding'
            curOut(i_rows) = 2;
        case 'N3 Stage Finding'
            curOut(i_rows) = 3;
        case 'NX Stage Finding'
            curOut(i_rows) = 4;
        case ''
            curOut(i_rows) = NaN;
        otherwise
            error(['Unknown entry: ' curCol{i_rows}])
    end
end
outputLabel{2} = 'nLabel';
outputMatrix(:,2) = curOut;
%% M
inputInd = find(strcmp('mLabel',dataHeader));
curCol = dataCell(:,inputInd);
curOut = [];
for i_rows = 1:numeroRows
    switch curCol{i_rows}
        case {'M0 Stage Finding'}
            curOut(i_rows) = 0;
        case {'M1 Stage Finding','M1a Stage Finding','M1b Stage Finding','M1c Stage Finding'}
            curOut(i_rows) = 1;
        case 'MX Stage Finding'
            curOut(i_rows) = 2;
        case ''
            curOut(i_rows) = NaN;
        otherwise
            error(['Unknown entry: ' curCol{i_rows}])
    end
end

outputLabel{3} = 'mLabel';
outputMatrix(:,3) = curOut;

%% Stage
inputInd = find(strcmp('stageLabel',dataHeader));
curCol = dataCell(:,inputInd);
curOut = [];
for i_rows = 1:numeroRows
    switch curCol{i_rows}
        case 'Stage 0'
            curOut(i_rows) = 0;
        case {'Stage I','Stage IA','Stage IA1','Stage IA2','Stage IA3','Stage IB'}
            curOut(i_rows) = 1;
        case {'Stage II','Stage IIA','Stage IIB'}
            curOut(i_rows) = 2;
        case {'Stage III','Stage IIIA','Stage IIIB','Stage IIIC'}
            curOut(i_rows) = 3;
        case {'Stage IV','Stage IVA','Stage IVB'}
            curOut(i_rows) = 4;
        case 'Occult Stage'
            curOut(i_rows) = 5;
        case ''
            curOut(i_rows) = NaN;
        otherwise
            error(['Unknown entry: ' curCol{i_rows}])
    end
end

outputLabel{4} = 'stageLabel';
outputMatrix(:,4) = curOut;

%% survival
% find labels in header
diseaseDateInd = find(strcmp('diseaseDate',dataHeader));
followupDateInd = find(strcmp('vitalStatusDate',dataHeader));
vitalStatusInd = find(strcmp('vitalStatusLabel',dataHeader));
% select relevant columns
diseaseDateCol = dataCell(:,diseaseDateInd);
followupDateCol = dataCell(:,followupDateInd);
vitalStatusCol = dataCell(:,vitalStatusInd);
%convert columns to datenum
diseaseDateDatenumCol = datenum(datetime(diseaseDateCol,'InputFormat','yyyy-MM-dd'));
followupDateDatenumCol = datenum(datetime(followupDateCol,'InputFormat','yyyy-MM-dd'));
% compute follow-up or survival days
daysUntilLastFollowup = followupDateDatenumCol - diseaseDateDatenumCol;

%% halfYearSurvival
[curOut] = computeBinarySurvivalVariable(vitalStatusCol,daysUntilLastFollowup,0.5);
outputLabel{5} = 'halfYearSurvival';
outputMatrix(:,5) = curOut;
%% oneYearSurvival
[curOut] = computeBinarySurvivalVariable(vitalStatusCol,daysUntilLastFollowup,1);
outputLabel{6} = 'oneYearSurvival';
outputMatrix(:,6) = curOut;
%% oneAndHalfYearSurvival
[curOut] = computeBinarySurvivalVariable(vitalStatusCol,daysUntilLastFollowup,1.5);
outputLabel{7} = 'oneAndHalfYearSurvival';
outputMatrix(:,7) = curOut;
%% twoYearSurvival
% if patient misses vital status: exclude (NaN)
% if death and daysUntilLastFollowup <= 2*365.24 --> 0
% if death and daysUntilLastFollowup > 2*365.24 --> 1
% if alive and daysUntilLastFollowup <= 2*365.24 --> NaN (not enough follow up)
% if alive and daysUntilLastFollowup > 2*365.24 --> 1
[curOut] = computeBinarySurvivalVariable(vitalStatusCol,daysUntilLastFollowup,2);
outputLabel{8} = 'twoYearSurvival';
outputMatrix(:,8) = curOut;
%% twoAndHalfYearSurvival
[curOut] = computeBinarySurvivalVariable(vitalStatusCol,daysUntilLastFollowup,2.5);
outputLabel{9} = 'twoAndHalfYearSurvival';
outputMatrix(:,9) = curOut;
%% threeYearSurvival
[curOut] = computeBinarySurvivalVariable(vitalStatusCol,daysUntilLastFollowup,3);
outputLabel{10} = 'threeYearSurvival';
outputMatrix(:,10) = curOut;
%% threeAndHalfYearSurvival
[curOut] = computeBinarySurvivalVariable(vitalStatusCol,daysUntilLastFollowup,3.5);
outputLabel{11} = 'threeAndHalfYearSurvival';
outputMatrix(:,11) = curOut;

%% disagnosisYear
curOut = year(datetime(diseaseDateCol,'InputFormat','yyyy-MM-dd'));
outputLabel{12} = 'diagnosisYear';
outputMatrix(:,12) = curOut;
end