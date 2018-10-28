function [numericSiteIds] = convertStrVecToNumVec(siteIds)
% PURPOSE:
%   Site IDs are normally provided by a string possibily including
%   separators. These need to be converted to vectors of numericals so that
%   Matlab can use them. 
% INPUT:
%   siteIds = string of site IDs, needs to be separated by non-numericals;
% OUTPUT:
%   numericSiteIds = vector of site IDs, numerical;

%% CODE
% Extract all numbers (digits including adjacent digits) into a cell array, they are still strings
idCell = regexp(siteIds,'\d*\d\d*','match');
% Convert separate cells with string digits to matrix of numbers
numericSiteIds = cellfun(@str2num,idCell)';

end