%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPARQL query executor function
% Author: Johan van Soest (johan.vansoest@maastro.nl)
% Updated for 20k challenge
% Description: This function will try to execute a SPARQL query (given by
% the 2nd input parameter) on a SPARQL endpoint (given by the 1st input
% parameter). When successful (HTTP response code is 200), the XML file
% will be parsed into a cell-array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [headValues, tableResult, extra] = sparql_vlp(endpoint,query,endpointKey,proxyToken,functionInput)

header(1) = http_createHeader('Accept', 'application/json');
header(2) = http_createHeader('Content-Type', 'application/json; charset=utf-8');

queryAdapted = escapeString(query);

queryAdapted = strrep(queryAdapted, sprintf('\n'), ' ');
queryAdapted = strrep(queryAdapted, sprintf('\r'), ' ');
queryAdapted = strrep(queryAdapted, '\n', ' ');
queryAdapted = strrep(queryAdapted, '\r', ' ');
queryAdapted = strrep(queryAdapted, '"', '\"');

requestBody = ['{ "token" : "', proxyToken, '", "endpoint" : "', endpointKey, '", "query" : "', queryAdapted, '" }'];
if(isempty(proxyToken))
    requestBody = ['query=' char(java.net.URLEncoder.encode(query, 'UTF-8'))];
	header(1) = http_createHeader('Accept', 'application/sparql-results+json;charset=UTF-8');
	header = header(1);
end

%open the URL, including the query as a GET-parameter
[binaryData, extra] = urlread2(endpoint,'POST',requestBody,header);

[headValues, tableResult] = parseJsonQueryResults(binaryData,functionInput);
end