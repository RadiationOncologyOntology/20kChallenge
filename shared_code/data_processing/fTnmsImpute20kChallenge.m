function [tnms_imputed, tnms_imputed_codes, tnms_imputed_editions] = fTnmsImpute20kChallenge(tnms, tnms_years, tnms_prob_ref, tnms_prob_ref_years, verbose_bool)
% impute TNM and stage using TNM AJCC 1st to 8th edition logic rules. If the
% logic gives multiple possibilities then probability imputation is
% performed based on the sub distribution of similar/matching patients in
% the tnms reference cell (can be the same as the first input).
%
% INPUTS
% ------
%  tnms                     cell of strings, columns T N M stage, no header
%
%  tnms_years               years of diagnosis for tnms, used to determine the tnms-library edition to be used
%
%  tnms_prob_ref            this is the cell that is used for probabilistic imputation (if empty no probabilistic imputation is performed)
%                           it will we be logically imputed first to maximize complete cases in this reference cell
%
%  tnms_prob_ref_years      years of diagnosis for tnms_prob_ref, used to determine the tnms-library edition to be used
%
%  verbose_bool             show per-patient console info
%
%
% OUTPUTS
% -------
%  tnms_imputed             cell of strings, columns T N M stage, no header, tnms_imputed
%                           values based on tnm-logic and if inconclusive followed by
%                           probabilistic imputation (if tnms_prob_ref was
%                           provided)
%
%  tnms_imputed_codes       codes for imputation results of tnms_imputed-cell, positive indicates imputation performed (see fImputationCodes())
%    0                      cell was not empty	row follows tnm-logic	no imputation
%   -7                      all cells filled    row breaks tnm-logic	no imputation
%   -8                      all cells empty     nothing to do           no imputation
%   -9                      cell was empty      no tnm-edition avail    no imputation
%  	-1                      cell was empty      row breaks tnm-logic	no imputation
%    1                      cell was empty      row follows tnm-logic   tnm-logic conclusive (1 result)     tnm-logic imputation
%    2                      cell was empty      row follows tnm-logic   tnm-logic inconclusive (>1 result)	probabilistic imputation based on matching patients
%   -2                      cell was empty      row follows tnm-logic   tnm-logic inconclusive (>1 result)	probabilistic imputation based on matching patients failed (no matching patients)
%
%  tnms_imputed_editions    tnms-library edition used for imputing the tnms-entry



%% init
% hard-coded start and end effective dates for tnm editions 1 to 8 (according to https://cancerstaging.org/references-tools/deskreferences/Pages/default.aspx)
tnm_edition_windows = [1, 1978, 1983; 2, 1984, 1988; 3, 1989, 1992; 4, 1993, 1997; 5, 1998, 2002; 6, 2003, 2009; 7, 2010, 2017; 8, 2018, 2020];

% labelstyle of tnms/tnms_prob_ref inputs, 'csv' (20k data model) or 'ontology' (NCI thesaurus)
labelstyle = 'ontology';

% determine if probability imputation is requested based on whether a reference cell has been supplied (if empty->no prob impute, not-empty->prob impute)
logicprob_bool = ~isempty(tnms_prob_ref);


%% perform imputation using all tnm editions (editions in 'tnm_edition_windows' and 'fTnmsLibraryFromEdition()' need to align)
tnms_imputed_all_editions = cell(size(tnm_edition_windows,1),1); % tnms imputation result for all editions
tnms_imputed_codes_all_editions = cell(size(tnm_edition_windows,1),1); % tnms_imputed_codes for all editions
for i_edition = 1:size(tnm_edition_windows,1)
    % load the current tnm edition library (allowed combinations)
    cur_edition = tnm_edition_windows(i_edition, 1);
    tnms_library = fTnmsLibraryFromEdition(cur_edition, labelstyle);
    
    if verbose_bool
        fprintf('Currently imputing using tnm edition:  %d\n', cur_edition)
    end
    
    % start with logic imputation only, to maximize our complete cases, no reference cell required
    [tnms_imputed, tnms_imputed_codes] = fTnmsImputation(tnms, {}, tnms_library, verbose_bool);
    
    % repeat with logic probability imputation if requested
    if logicprob_bool
        % logic imputation for the tnms reference cell, to maximize our complete cases
        [tnms_prob_ref, ~] = fTnmsImputation(tnms_prob_ref, {}, tnms_library, verbose_bool);
        
        % filter the tnms reference cell used for probability imputation based on the current edition only (we don't want to probability impute across different editions)
        year_min = tnm_edition_windows(i_edition, 2);
        year_max = tnm_edition_windows(i_edition, 3);
        cur_edition_idx = tnms_prob_ref_years >= year_min & tnms_prob_ref_years <= year_max;
        tnms_prob_impute_ref_cur_edition = tnms_prob_ref(cur_edition_idx,:);
        
        % filter the tnms reference cell for probability imputation to only contain complete cases
        complete_rows = ~any(strcmp(tnms_prob_impute_ref_cur_edition, ''), 2);
        tnms_prob_impute_ref_cur_edition = tnms_prob_impute_ref_cur_edition(complete_rows,:);
        
        % perform the probabilistic imputation
        [tnms_imputed, tnms_imputed_codes_logicprob] = fTnmsImputation(tnms_imputed, tnms_prob_impute_ref_cur_edition, tnms_library, verbose_bool);
        
        % combine the codes of logic and logicprob 
        % Update tnms_imputed_codes with new codes from
        % tnms_imputed_codes_logicprob because some cells are now filled
        % after logic-prob imputation.
        code_nr = fImputationCodes('cell empty_agrees probabilistic');
        tnms_imputed_codes(tnms_imputed_codes_logicprob == code_nr) = code_nr;
        code_nr = fImputationCodes('cell empty_agrees probabilistic failed');
        tnms_imputed_codes(tnms_imputed_codes_logicprob == code_nr) = code_nr;
    end
    
    % collect imputations of current edition in master cell and clear current
    tnms_imputed_all_editions{i_edition} = tnms_imputed;
    tnms_imputed_codes_all_editions{i_edition} = tnms_imputed_codes;
end

% loop over every patient to select the correct imputation based on the diagnosis year (if the imputation failed, use older tnm edition)
n_rows = size(tnms_imputed, 1);
n_cols = size(tnms_imputed, 2);
n_editions = size(tnm_edition_windows,1);
tnms_imputed = cell(n_rows, n_cols);
tnms_imputed_codes = nan(n_rows, n_cols);
tnms_imputed_editions = nan(n_rows,1);
for i_row = 1:n_rows
    % determine tnm edition for this patient based on year
    cur_year = tnms_years(i_row);
    cur_edition_row = find(cur_year >= tnm_edition_windows(:,2), 1, 'last');
    
    % continue if the edition is available (in other words if the patient year is within one of the tnm edition years)
    if cur_edition_row
        % collect all tnms editions imputations and the codes for this patient/row
        cur_tnms_imputed_editions = cell(n_editions, n_cols);
        cur_tnms_imputed_codes_editions = nan(n_editions, n_cols);
        for i_tnms_edition = 1:n_editions
            cur_tnms_imputed_editions(i_tnms_edition,:) = tnms_imputed_all_editions{i_tnms_edition}(i_row,:);
            cur_tnms_imputed_codes_editions(i_tnms_edition,:) = tnms_imputed_codes_all_editions{i_tnms_edition}(i_row,:);
        end
        
        % restrict editions according to patient year and all previous editions (remove editions that are newer than the patient year)
        cur_tnms_imputed_editions = cur_tnms_imputed_editions(1:cur_edition_row,:);
        cur_tnms_imputed_codes_editions = cur_tnms_imputed_codes_editions(1:cur_edition_row,:);
        
        % find the last complete row (which is the edition closest to the diagnosis year that has a complete imputation)
        complete_imputation_edition_boolean = any(strcmp(cur_tnms_imputed_editions, ''), 2) == 0;
        last_complete_row = find(complete_imputation_edition_boolean,1,'last');
        
        % use this last complete row if it is non empty
        if last_complete_row
            cur_edition_row = last_complete_row;
        end
        
        % all tnm edition imputations failed the logic, return the incomplete edition one based on the patient year
        cur_tnms_imputed = cur_tnms_imputed_editions(cur_edition_row,:);
        cur_tnms_imputed_codes = cur_tnms_imputed_codes_editions(cur_edition_row,:);
        cur_tnms_imputed_edition = tnm_edition_windows(cur_edition_row, 1);
    else
        % can't find tnm edition for year of this patient, can't impute anything, return input entry
        cur_tnms_imputed = tnms(i_row, :);
        code_nr = fImputationCodes('cell empty_no edition');
        cur_tnms_imputed_codes = code_nr*strcmp(cur_tnms_imputed,''); % repeat for all the empty tnms entries of the current patient
        cur_tnms_imputed_edition = nan;
    end
    
    % store in final result and clear current
    tnms_imputed(i_row, :) = cur_tnms_imputed;
    tnms_imputed_codes(i_row,:) = cur_tnms_imputed_codes;
    tnms_imputed_editions(i_row) = cur_tnms_imputed_edition;
    clear cur_tnms_imputed cur_tnms_imputed_codes cur_tnms_imputed_edition
end
if verbose_bool
    % print some info to console
    fprintf('\nincomplete cases before imputation:  %d/%d\t%.1f%%\n', sum(any(strcmp(tnms,''),2)), size(tnms,1), 100*sum(any(strcmp(tnms,''),2))/size(tnms,1))
    fprintf('incomplete cases after imputation:   %d/%d\t%.1f%%\n', sum(any(strcmp(tnms_imputed,''),2)), size(tnms_imputed,1), 100*sum(any(strcmp(tnms_imputed,''),2))/size(tnms_imputed,1))
    fprintf('T, N, M, stage imputation total:                 %s\n', num2str(sum(tnms_imputed_codes>=1,1)));
    fprintf('T, N, M, stage imputation logic:                 %s\n', num2str(sum(tnms_imputed_codes==fImputationCodes('cell empty_agrees conclusive'),1)));
    fprintf('T, N, M, stage imputation logic-probabilistic:   %s\n', num2str(sum(tnms_imputed_codes==fImputationCodes('cell empty_agrees probabilistic'),1)));
end
end



%% local functions
function [tnms_imputed, tnms_imputed_codes] = fTnmsImputation(tnms, tnms_prob_ref, tnms_library, verbose_bool)
% This function does the actual imputation. % You can select logic-only
% imputation or logic followed by probabilistic imputation. You activate logic-only by not adding a reference cell 'tnms_prob_ref'.
% You activate logic and probabilistic imputation by including a reference cell 'tnms_prob_ref' which will be matched for complete case patients*.
%
% The cell to impute is separated from the cell used as a reference for the probabilistic imputation (to allow for imputation of a validation set based on a
% training set). This cell used as reference, 'tnms_prob_ref', is only used during the probabilistic imputation after tnm-logic imputation.
%
% *Best to call this function twice, first without probabilistic imputation and only tnm-logic based, then use the result as reference input for this function with
% probabilistic imputation. This ensures you have the maximum number of complete case patients available for the probabilistic imputation.



% determine if probability imputation is requested based on whether a reference cell has been supplied (empty->no prob impute, present->prob impute)
probability_imputation_bool = ~isempty(tnms_prob_ref);


% prepare output
tnms_imputed = tnms;
tnms_imputed_codes = zeros(size(tnms_imputed));

% loop over the rows of the input cell
for i_row = 1:size(tnms,1)
    % get current row
    tnms_cur = tnms(i_row, :);
    missing_values_idx = strcmp(tnms_cur, '');
    
    % check for missing values in this row
    if ~any(missing_values_idx)
        % no missing values in this row, only check if tnm-logic is violated
        
        % filter the tnms-library cell with the values of the current row
        [~, nr_matches] = fFilterCellByRow(tnms_library, tnms_cur);
        
        % check if we have a unique match or that logic is violated
        if nr_matches == 0
            % logic violated, insert imputation code
            tnms_imputed_codes(i_row, ~missing_values_idx) = fImputationCodes('all cells filled_violates');
            if verbose_bool
                fprintf('row %d:  tnms_pre: %-13s                                complete case with violating logic\n', i_row, strjoin(tnms_cur));
            end
        elseif nr_matches > 1
            error('weird stuff, nr_matches>1 for complete case, row: %d', i_row);
        end
    elseif sum(missing_values_idx) == 4
        % only missing values, can't logic impute, can't probability, return empty and imputation code
        tnms_imputed(i_row, :) = tnms(i_row,:); % unnecessary because it was already preallocated
        tnms_imputed_codes(i_row, :) = fImputationCodes('all cells empty');
    elseif sum(missing_values_idx) > 0 && sum(missing_values_idx) < 4
        % missing values in this row, continue with imputation
        
        % filter the tnms-library cell with the values of the current row
        [tnms_library_matched, nr_matches] = fFilterCellByRow(tnms_library, tnms_cur);
        
        % continue if we have matches
        if nr_matches == 0
            % no match based on logic
            
            % save the imputation code
            tnms_imputed_codes(i_row, missing_values_idx) = fImputationCodes('cell empty_violates');
            
            % print info
            if verbose_bool
                fprintf('row %d:  tnms_pre: %-13s                                no matches based on logic\n', i_row, strjoin(tnms_cur));
            end
        elseif nr_matches == 1
            % unique match based on logic
            
            % save the tnms_imputed labels and imputation code
            tnms_imputed(i_row, missing_values_idx) = tnms_library_matched(missing_values_idx);
            tnms_imputed_codes(i_row, missing_values_idx) = fImputationCodes('cell empty_agrees conclusive');
            
            % print info
            if verbose_bool
                fprintf('row %d:  tnms_pre: %-13s  tnms_imputed: %-14s  unique match based on logic\n', i_row, strjoin(tnms_cur), strjoin(tnms_imputed(i_row,:)));
            end
        elseif nr_matches > 1
            % inconclusive match based on logic, probability impute based on distribution of matching patients
            if probability_imputation_bool % this if-statement misses an else-statement where an imputation code is returned in tnms_imputed_codes for the case when logic is inconclusive but probabibilistic imputation is not requested
                % loop over the allowed tnms-library-combinations (these are complete cases) of current patient to count the number of occurences in the reference cell
                tnms_library_matched_nr_matches = zeros(size(tnms_library_matched, 1), 1);
                for j_row = 1:size(tnms_library_matched, 1)
                    % current tnm-library combination
                    j_tnms_cur = tnms_library_matched(j_row, :);
                    
                    % filter the complete patients tnms-prob-ref-cell with the current tnms-row of the tnm-library
                    [~, nr_matches] = fFilterCellByRow(tnms_prob_ref, j_tnms_cur);
                    tnms_library_matched_nr_matches(j_row) = nr_matches;
                end
                
                % calc the probabilities if any hits
                if sum(tnms_library_matched_nr_matches) > 0
                    tnms_library_matched_nr_hits_prob = tnms_library_matched_nr_matches ./ sum(tnms_library_matched_nr_matches);
                    
                    % generate random sample based on the probability distribution
                    randomvalue = randsample(size(tnms_library_matched,1), 1, true, tnms_library_matched_nr_hits_prob);
                    
                    % save the tnms_imputed labels and imputation code
                    impute_values = tnms_library_matched(randomvalue, :);
                    tnms_imputed(i_row, missing_values_idx) = impute_values(missing_values_idx);
                    tnms_imputed_codes(i_row, missing_values_idx) = fImputationCodes('cell empty_agrees probabilistic');
                else
                    % probability imputation failed since no matching patients are present imputation code
                    tnms_imputed_codes(i_row, missing_values_idx) = fImputationCodes('cell empty_agrees probabilistic failed');
                end
                % print info
                if verbose_bool
                    fprintf('row %d:  tnms_pre: %-13s  tnms_imputed: %-14s  inconclusive match based on logic, probability imputation based on matching complete case patients\n', i_row, strjoin(tnms_cur), strjoin(tnms_imputed(i_row,:)));
                end
            end
        else
            % nr_matches is not in range [0-inf]
            error('row %d:  tnms_pre: %-13s   weird stuff (nr_matches=%d)\n', i_row, strjoin(tnms_cur), nr_matches);
        end
    end
end
end


function nr_out = fImputationCodes(string_in)
% map imputation strings into codes
% positive indicates imputation performed
imputation_codes = {-7, 'all cells filled_violates';...
    -8, 'all cells empty';...
    0, 'cell filled_agrees';...
    -9, 'cell empty_no edition';...
    -1, 'cell empty_violates';...
    1, 'cell empty_agrees conclusive';...
    2, 'cell empty_agrees probabilistic';...
    -2, 'cell empty_agrees probabilistic failed'};

% find idx and convert to number
idx = strcmp(string_in, imputation_codes(:, 2));
if any(idx)
    nr_out = imputation_codes{idx, 1};
else
    error('imputation code string (''%s'') not found in fImputationCodes() mapping matrix', string_in);
end
end


function [matched_cell, nr_matches] = fFilterCellByRow(ref_cell, row_cell)
% filter a mxn ref cell of strings by a 1-n cell of strings (e.g. pt to the tnm-library, tnm-libary entry to all patients)

% prepare output
matched_cell = ref_cell;

% check if all entries of the row_cell that is used to filter the ref_cell are empty
if all(strcmp(row_cell, ''))
    error('fFilterCellByRow: asked to match ref cell fully empty row cell. ');
end

for i_col = 1:size(row_cell, 2)
    % get current label
    cur_label = row_cell{i_col};
    
    % filter the ref cell if non-empty label
    if ~strcmp(cur_label, '')
        % for current column, find indices that match the current label
        col_matched_idx = strcmp(cur_label, matched_cell(:, i_col));
        
        % filter the output cell by the matched indices of the current column
        matched_cell = matched_cell(col_matched_idx, :);
    end
    nr_matches = size(matched_cell, 1);
end
end


function cell_out = csv_labels_to_ontology_labels(tnms)
% hardced mapping cell for going from csv labels to ontology labels
map_labels_cell = {'T0','T0 Stage Finding';...
    'Tis','Tis Stage Finding';...
    'Tx','TX Stage Finding';...
    'T1','T1 Stage Finding';...
    'T1mi','T1mi Stage Finding';...
    'T1a','T1a Stage Finding';...
    'T1b','T1b Stage Finding';...
    'T1c','T1c Stage Finding';...
    'T2','T2 Stage Finding';...
    'T2a','T2a Stage Finding';...
    'T2b','T2b Stage Finding';...
    'T3','T3 Stage Finding';...
    'T4','T4 Stage Finding';...
    'Nx','NX Stage Finding';...
    'N0','N0 Stage Finding';...
    'N1','N1 Stage Finding';...
    'N2','N2 Stage Finding';...
    'N3','N3 Stage Finding';...
    'Mx','MX Stage Finding';...
    'M0','M0 Stage Finding';...
    'M1','M1 Stage Finding';...
    'M1a','M1a Stage Finding';...
    'M1b','M1b Stage Finding';...
    'M1c','M1c Stage Finding';...
    '0','Stage 0';...
    'Occult','Occult Stage';...
    'I','Stage I';...
    'IA','Stage IA';...
    'IA1','Stage IA1';...
    'IA2','Stage IA2';...
    'IA3','Stage IA3';...
    'IB','Stage IB';...
    'II','Stage II';...
    'IIA','Stage IIA';...
    'IIB','Stage IIB';...
    'III','Stage III';...
    'IIIA','Stage IIIA';...
    'IIIB','Stage IIIB';...
    'IIIC','Stage IIIC';...
    'IV','Stage IV';...
    'IVA','Stage IVA';...
    'IVB','Stage IVB'};

cell_out = fMapLabels(tnms, map_labels_cell);
end


function cell_out = fMapLabels(tnms, subgroups_to_change)

% prepare output
cell_out = tnms;

% replace labels (exact matches)
for i_entry = 1:size(subgroups_to_change,1)
    old_str = subgroups_to_change{i_entry,1};
    new_str = subgroups_to_change{i_entry,2};
    
    % find and replace strings (exact matches)
    indices_to_replace = strcmp(cell_out, old_str);
    cell_out(indices_to_replace) = {new_str};
end
end


function tnms_library = fTnmsLibraryFromEdition(edition, labelstyle)
% tnms libraries. Generated using 'fImpute20kChallenge_tnmsDefinitionsReadScript.m' and manually
% copy-pasting the contents of the variable 'tnms_library' in this function below at the correct 'case' statement
%
% with labelstyle you can switch the library from csv-labels (20k data model) to ontology labels (NCI thesaurus)

switch edition
    case 1
        tnms_library = {'Tx','N0','M0','Occult';'Tis','N0','M0','I';'T1','N0','M0','I';'T1','N1','M0','I';'T2','N0','M0','I';'T2','N1','M0','II';'T3','N0','Mx','III';'T3','N1','Mx','III';'T3','N2','Mx','III';'T3','N0','M0','III';'T3','N1','M0','III';'T3','N2','M0','III';'T3','N0','M1','III';'T3','N1','M1','III';'T3','N2','M1','III';'Tx','N2','Mx','III';'Tis','N2','Mx','III';'T0','N2','Mx','III';'T1','N2','Mx','III';'T2','N2','Mx','III';'Tx','N2','M0','III';'Tis','N2','M0','III';'T0','N2','M0','III';'T1','N2','M0','III';'T2','N2','M0','III';'Tx','N2','M1','III';'Tis','N2','M1','III';'T0','N2','M1','III';'T1','N2','M1','III';'T2','N2','M1','III';'Tx','N0','M1','III';'Tis','N0','M1','III';'T0','N0','M1','III';'T1','N0','M1','III';'T2','N0','M1','III';'Tx','N1','M1','III';'Tis','N1','M1','III';'T0','N1','M1','III';'T1','N1','M1','III';'T2','N1','M1','III'};
    case 2
        tnms_library = {'Tx','N0','M0','Occult';'Tis','N0','M0','I';'T1','N0','M0','I';'T2','N0','M0','I';'Tx','N1','M0','I';'T0','N1','M0','I';'T2','N1','M0','II';'T3','Nx','Mx','III';'T3','N0','Mx','III';'T3','N1','Mx','III';'T3','N2','Mx','III';'T3','Nx','M0','III';'T3','N0','M0','III';'T3','N1','M0','III';'T3','N2','M0','III';'T3','Nx','M1','III';'T3','N0','M1','III';'T3','N1','M1','III';'T3','N2','M1','III';'Tx','N2','Mx','III';'Tis','N2','Mx','III';'T0','N2','Mx','III';'T1','N2','Mx','III';'T2','N2','Mx','III';'Tx','N2','M0','III';'Tis','N2','M0','III';'T0','N2','M0','III';'T1','N2','M0','III';'T2','N2','M0','III';'Tx','N2','M1','III';'Tis','N2','M1','III';'T0','N2','M1','III';'T1','N2','M1','III';'T2','N2','M1','III';'Tx','Nx','M1','III';'Tis','Nx','M1','III';'T0','Nx','M1','III';'T1','Nx','M1','III';'T2','Nx','M1','III';'Tx','N0','M1','III';'Tis','N0','M1','III';'T0','N0','M1','III';'T1','N0','M1','III';'T2','N0','M1','III';'Tx','N1','M1','III';'Tis','N1','M1','III';'T0','N1','M1','III';'T1','N1','M1','III';'T2','N1','M1','III'};
    case {3,4}
        tnms_library = {'Tx','N0','M0','Occult';'Tis','N0','M0','0';'T1','N0','M0','I';'T2','N0','M0','I';'T1','N1','M0','II';'T2','N1','M0','II';'T1','N2','M0','IIIA';'T2','N2','M0','IIIA';'T3','N0','M0','IIIA';'T3','N1','M0','IIIA';'T3','N2','M0','IIIA';'Tx','N3','M0','IIIB';'Tis','N3','M0','IIIB';'T0','N3','M0','IIIB';'T1','N3','M0','IIIB';'T2','N3','M0','IIIB';'T3','N3','M0','IIIB';'T4','N3','M0','IIIB';'T4','Nx','M0','IIIB';'T4','N0','M0','IIIB';'T4','N1','M0','IIIB';'T4','N2','M0','IIIB';'Tx','Nx','M1','IV';'Tis','Nx','M1','IV';'T0','Nx','M1','IV';'T1','Nx','M1','IV';'T2','Nx','M1','IV';'T3','Nx','M1','IV';'T4','Nx','M1','IV';'Tx','N0','M1','IV';'Tis','N0','M1','IV';'T0','N0','M1','IV';'T1','N0','M1','IV';'T2','N0','M1','IV';'T3','N0','M1','IV';'T4','N0','M1','IV';'Tx','N1','M1','IV';'Tis','N1','M1','IV';'T0','N1','M1','IV';'T1','N1','M1','IV';'T2','N1','M1','IV';'T3','N1','M1','IV';'T4','N1','M1','IV';'Tx','N2','M1','IV';'Tis','N2','M1','IV';'T0','N2','M1','IV';'T1','N2','M1','IV';'T2','N2','M1','IV';'T3','N2','M1','IV';'T4','N2','M1','IV';'Tx','N3','M1','IV';'Tis','N3','M1','IV';'T0','N3','M1','IV';'T1','N3','M1','IV';'T2','N3','M1','IV';'T3','N3','M1','IV';'T4','N3','M1','IV'};
    case {5,6}
        tnms_library = {'Tx','N0','M0','Occult';'Tis','N0','M0','0';'T1','N0','M0','IA';'T2','N0','M0','IB';'T1','N1','M0','IIA';'T2','N1','M0','IIB';'T3','N0','M0','IIB';'T1','N2','M0','IIIA';'T2','N2','M0','IIIA';'T3','N1','M0','IIIA';'T3','N2','M0','IIIA';'Tx','N3','M0','IIIB';'Tis','N3','M0','IIIB';'T0','N3','M0','IIIB';'T1','N3','M0','IIIB';'T2','N3','M0','IIIB';'T3','N3','M0','IIIB';'T4','N3','M0','IIIB';'T4','Nx','M0','IIIB';'T4','N0','M0','IIIB';'T4','N1','M0','IIIB';'T4','N2','M0','IIIB';'Tx','Nx','M1','IV';'Tis','Nx','M1','IV';'T0','Nx','M1','IV';'T1','Nx','M1','IV';'T2','Nx','M1','IV';'T3','Nx','M1','IV';'T4','Nx','M1','IV';'Tx','N0','M1','IV';'Tis','N0','M1','IV';'T0','N0','M1','IV';'T1','N0','M1','IV';'T2','N0','M1','IV';'T3','N0','M1','IV';'T4','N0','M1','IV';'Tx','N1','M1','IV';'Tis','N1','M1','IV';'T0','N1','M1','IV';'T1','N1','M1','IV';'T2','N1','M1','IV';'T3','N1','M1','IV';'T4','N1','M1','IV';'Tx','N2','M1','IV';'Tis','N2','M1','IV';'T0','N2','M1','IV';'T1','N2','M1','IV';'T2','N2','M1','IV';'T3','N2','M1','IV';'T4','N2','M1','IV';'Tx','N3','M1','IV';'Tis','N3','M1','IV';'T0','N3','M1','IV';'T1','N3','M1','IV';'T2','N3','M1','IV';'T3','N3','M1','IV';'T4','N3','M1','IV'};
    case 7
        tnms_library = {'Tx','N0','M0','Occult';'Tis','N0','M0','0';'T1a','N0','M0','IA';'T1b','N0','M0','IA';'T2a','N0','M0','IB';'T2b','N0','M0','IIA';'T1a','N1','M0','IIA';'T1b','N1','M0','IIA';'T2a','N1','M0','IIA';'T2b','N1','M0','IIB';'T3','N0','M0','IIB';'T1a','N2','M0','IIIA';'T1b','N2','M0','IIIA';'T2a','N2','M0','IIIA';'T2b','N2','M0','IIIA';'T3','N1','M0','IIIA';'T3','N2','M0','IIIA';'T4','N0','M0','IIIA';'T4','N1','M0','IIIA';'T1a','N3','M0','IIIB';'T1b','N3','M0','IIIB';'T2a','N3','M0','IIIB';'T2b','N3','M0','IIIB';'T3','N3','M0','IIIB';'T4','N2','M0','IIIB';'T4','N3','M0','IIIB';'Tx','Nx','M1a','IV';'Tis','Nx','M1a','IV';'T0','Nx','M1a','IV';'T1a','Nx','M1a','IV';'T1b','Nx','M1a','IV';'T2a','Nx','M1a','IV';'T2b','Nx','M1a','IV';'T3','Nx','M1a','IV';'T4','Nx','M1a','IV';'Tx','N0','M1a','IV';'Tis','N0','M1a','IV';'T0','N0','M1a','IV';'T1a','N0','M1a','IV';'T1b','N0','M1a','IV';'T2a','N0','M1a','IV';'T2b','N0','M1a','IV';'T3','N0','M1a','IV';'T4','N0','M1a','IV';'Tx','N1','M1a','IV';'Tis','N1','M1a','IV';'T0','N1','M1a','IV';'T1a','N1','M1a','IV';'T1b','N1','M1a','IV';'T2a','N1','M1a','IV';'T2b','N1','M1a','IV';'T3','N1','M1a','IV';'T4','N1','M1a','IV';'Tx','N2','M1a','IV';'Tis','N2','M1a','IV';'T0','N2','M1a','IV';'T1a','N2','M1a','IV';'T1b','N2','M1a','IV';'T2a','N2','M1a','IV';'T2b','N2','M1a','IV';'T3','N2','M1a','IV';'T4','N2','M1a','IV';'Tx','N3','M1a','IV';'Tis','N3','M1a','IV';'T0','N3','M1a','IV';'T1a','N3','M1a','IV';'T1b','N3','M1a','IV';'T2a','N3','M1a','IV';'T2b','N3','M1a','IV';'T3','N3','M1a','IV';'T4','N3','M1a','IV';'Tx','Nx','M1b','IV';'Tis','Nx','M1b','IV';'T0','Nx','M1b','IV';'T1a','Nx','M1b','IV';'T1b','Nx','M1b','IV';'T2a','Nx','M1b','IV';'T2b','Nx','M1b','IV';'T3','Nx','M1b','IV';'T4','Nx','M1b','IV';'Tx','N0','M1b','IV';'Tis','N0','M1b','IV';'T0','N0','M1b','IV';'T1a','N0','M1b','IV';'T1b','N0','M1b','IV';'T2a','N0','M1b','IV';'T2b','N0','M1b','IV';'T3','N0','M1b','IV';'T4','N0','M1b','IV';'Tx','N1','M1b','IV';'Tis','N1','M1b','IV';'T0','N1','M1b','IV';'T1a','N1','M1b','IV';'T1b','N1','M1b','IV';'T2a','N1','M1b','IV';'T2b','N1','M1b','IV';'T3','N1','M1b','IV';'T4','N1','M1b','IV';'Tx','N2','M1b','IV';'Tis','N2','M1b','IV';'T0','N2','M1b','IV';'T1a','N2','M1b','IV';'T1b','N2','M1b','IV';'T2a','N2','M1b','IV';'T2b','N2','M1b','IV';'T3','N2','M1b','IV';'T4','N2','M1b','IV';'Tx','N3','M1b','IV';'Tis','N3','M1b','IV';'T0','N3','M1b','IV';'T1a','N3','M1b','IV';'T1b','N3','M1b','IV';'T2a','N3','M1b','IV';'T2b','N3','M1b','IV';'T3','N3','M1b','IV';'T4','N3','M1b','IV'};
    case 8
        tnms_library = {'Tx','N0','M0','Occult';'Tis','N0','M0','0';'T1mi','N0','M0','IA1';'T1a','N0','M0','IA1';'T1a','N1','M0','IIB';'T1a','N2','M0','IIIA';'T1a','N3','M0','IIIB';'T1b','N0','M0','IA2';'T1b','N1','M0','IIB';'T1b','N2','M0','IIIA';'T1b','N3','M0','IIIB';'T1c','N0','M0','IA3';'T1c','N1','M0','IIB';'T1c','N2','M0','IIIA';'T1c','N3','M0','IIIB';'T2a','N0','M0','IB';'T2a','N1','M0','IIB';'T2a','N2','M0','IIIA';'T2a','N3','M0','IIIB';'T2b','N0','M0','IIA';'T2b','N1','M0','IIB';'T2b','N2','M0','IIIA';'T2b','N3','M0','IIIB';'T3','N0','M0','IIB';'T3','N1','M0','IIIA';'T3','N2','M0','IIIB';'T3','N3','M0','IIIC';'T4','N0','M0','IIIA';'T4','N1','M0','IIIA';'T4','N2','M0','IIIB';'T4','N3','M0','IIIC';'Tx','Nx','M1','IV';'Tis','Nx','M1','IV';'T0','Nx','M1','IV';'T1mi','Nx','M1','IV';'T1a','Nx','M1','IV';'T1b','Nx','M1','IV';'T1c','Nx','M1','IV';'T2a','Nx','M1','IV';'T2b','Nx','M1','IV';'T3','Nx','M1','IV';'T4','Nx','M1','IV';'Tx','N0','M1','IV';'Tis','N0','M1','IV';'T0','N0','M1','IV';'T1mi','N0','M1','IV';'T1a','N0','M1','IV';'T1b','N0','M1','IV';'T1c','N0','M1','IV';'T2a','N0','M1','IV';'T2b','N0','M1','IV';'T3','N0','M1','IV';'T4','N0','M1','IV';'Tx','N1','M1','IV';'Tis','N1','M1','IV';'T0','N1','M1','IV';'T1mi','N1','M1','IV';'T1a','N1','M1','IV';'T1b','N1','M1','IV';'T1c','N1','M1','IV';'T2a','N1','M1','IV';'T2b','N1','M1','IV';'T3','N1','M1','IV';'T4','N1','M1','IV';'Tx','N2','M1','IV';'Tis','N2','M1','IV';'T0','N2','M1','IV';'T1mi','N2','M1','IV';'T1a','N2','M1','IV';'T1b','N2','M1','IV';'T1c','N2','M1','IV';'T2a','N2','M1','IV';'T2b','N2','M1','IV';'T3','N2','M1','IV';'T4','N2','M1','IV';'Tx','N3','M1','IV';'Tis','N3','M1','IV';'T0','N3','M1','IV';'T1mi','N3','M1','IV';'T1a','N3','M1','IV';'T1b','N3','M1','IV';'T1c','N3','M1','IV';'T2a','N3','M1','IV';'T2b','N3','M1','IV';'T3','N3','M1','IV';'T4','N3','M1','IV';'Tx','Nx','M1a','IVA';'Tis','Nx','M1a','IVA';'T0','Nx','M1a','IVA';'T1mi','Nx','M1a','IVA';'T1a','Nx','M1a','IVA';'T1b','Nx','M1a','IVA';'T1c','Nx','M1a','IVA';'T2a','Nx','M1a','IVA';'T2b','Nx','M1a','IVA';'T3','Nx','M1a','IVA';'T4','Nx','M1a','IVA';'Tx','N0','M1a','IVA';'Tis','N0','M1a','IVA';'T0','N0','M1a','IVA';'T1mi','N0','M1a','IVA';'T1a','N0','M1a','IVA';'T1b','N0','M1a','IVA';'T1c','N0','M1a','IVA';'T2a','N0','M1a','IVA';'T2b','N0','M1a','IVA';'T3','N0','M1a','IVA';'T4','N0','M1a','IVA';'Tx','N1','M1a','IVA';'Tis','N1','M1a','IVA';'T0','N1','M1a','IVA';'T1mi','N1','M1a','IVA';'T1a','N1','M1a','IVA';'T1b','N1','M1a','IVA';'T1c','N1','M1a','IVA';'T2a','N1','M1a','IVA';'T2b','N1','M1a','IVA';'T3','N1','M1a','IVA';'T4','N1','M1a','IVA';'Tx','N2','M1a','IVA';'Tis','N2','M1a','IVA';'T0','N2','M1a','IVA';'T1mi','N2','M1a','IVA';'T1a','N2','M1a','IVA';'T1b','N2','M1a','IVA';'T1c','N2','M1a','IVA';'T2a','N2','M1a','IVA';'T2b','N2','M1a','IVA';'T3','N2','M1a','IVA';'T4','N2','M1a','IVA';'Tx','N3','M1a','IVA';'Tis','N3','M1a','IVA';'T0','N3','M1a','IVA';'T1mi','N3','M1a','IVA';'T1a','N3','M1a','IVA';'T1b','N3','M1a','IVA';'T1c','N3','M1a','IVA';'T2a','N3','M1a','IVA';'T2b','N3','M1a','IVA';'T3','N3','M1a','IVA';'T4','N3','M1a','IVA';'Tx','Nx','M1b','IVA';'Tis','Nx','M1b','IVA';'T0','Nx','M1b','IVA';'T1mi','Nx','M1b','IVA';'T1a','Nx','M1b','IVA';'T1b','Nx','M1b','IVA';'T1c','Nx','M1b','IVA';'T2a','Nx','M1b','IVA';'T2b','Nx','M1b','IVA';'T3','Nx','M1b','IVA';'T4','Nx','M1b','IVA';'Tx','N0','M1b','IVA';'Tis','N0','M1b','IVA';'T0','N0','M1b','IVA';'T1mi','N0','M1b','IVA';'T1a','N0','M1b','IVA';'T1b','N0','M1b','IVA';'T1c','N0','M1b','IVA';'T2a','N0','M1b','IVA';'T2b','N0','M1b','IVA';'T3','N0','M1b','IVA';'T4','N0','M1b','IVA';'Tx','N1','M1b','IVA';'Tis','N1','M1b','IVA';'T0','N1','M1b','IVA';'T1mi','N1','M1b','IVA';'T1a','N1','M1b','IVA';'T1b','N1','M1b','IVA';'T1c','N1','M1b','IVA';'T2a','N1','M1b','IVA';'T2b','N1','M1b','IVA';'T3','N1','M1b','IVA';'T4','N1','M1b','IVA';'Tx','N2','M1b','IVA';'Tis','N2','M1b','IVA';'T0','N2','M1b','IVA';'T1mi','N2','M1b','IVA';'T1a','N2','M1b','IVA';'T1b','N2','M1b','IVA';'T1c','N2','M1b','IVA';'T2a','N2','M1b','IVA';'T2b','N2','M1b','IVA';'T3','N2','M1b','IVA';'T4','N2','M1b','IVA';'Tx','N3','M1b','IVA';'Tis','N3','M1b','IVA';'T0','N3','M1b','IVA';'T1mi','N3','M1b','IVA';'T1a','N3','M1b','IVA';'T1b','N3','M1b','IVA';'T1c','N3','M1b','IVA';'T2a','N3','M1b','IVA';'T2b','N3','M1b','IVA';'T3','N3','M1b','IVA';'T4','N3','M1b','IVA';'Tx','Nx','M1c','IVB';'Tis','Nx','M1c','IVB';'T0','Nx','M1c','IVB';'T1mi','Nx','M1c','IVB';'T1a','Nx','M1c','IVB';'T1b','Nx','M1c','IVB';'T1c','Nx','M1c','IVB';'T2a','Nx','M1c','IVB';'T2b','Nx','M1c','IVB';'T3','Nx','M1c','IVB';'T4','Nx','M1c','IVB';'Tx','N0','M1c','IVB';'Tis','N0','M1c','IVB';'T0','N0','M1c','IVB';'T1mi','N0','M1c','IVB';'T1a','N0','M1c','IVB';'T1b','N0','M1c','IVB';'T1c','N0','M1c','IVB';'T2a','N0','M1c','IVB';'T2b','N0','M1c','IVB';'T3','N0','M1c','IVB';'T4','N0','M1c','IVB';'Tx','N1','M1c','IVB';'Tis','N1','M1c','IVB';'T0','N1','M1c','IVB';'T1mi','N1','M1c','IVB';'T1a','N1','M1c','IVB';'T1b','N1','M1c','IVB';'T1c','N1','M1c','IVB';'T2a','N1','M1c','IVB';'T2b','N1','M1c','IVB';'T3','N1','M1c','IVB';'T4','N1','M1c','IVB';'Tx','N2','M1c','IVB';'Tis','N2','M1c','IVB';'T0','N2','M1c','IVB';'T1mi','N2','M1c','IVB';'T1a','N2','M1c','IVB';'T1b','N2','M1c','IVB';'T1c','N2','M1c','IVB';'T2a','N2','M1c','IVB';'T2b','N2','M1c','IVB';'T3','N2','M1c','IVB';'T4','N2','M1c','IVB';'Tx','N3','M1c','IVB';'Tis','N3','M1c','IVB';'T0','N3','M1c','IVB';'T1mi','N3','M1c','IVB';'T1a','N3','M1c','IVB';'T1b','N3','M1c','IVB';'T1c','N3','M1c','IVB';'T2a','N3','M1c','IVB';'T2b','N3','M1c','IVB';'T3','N3','M1c','IVB';'T4','N3','M1c','IVB'};
    otherwise
        error(['tnm ' num2str(edition) 'th edition not loaded'])
end

if strcmp(labelstyle, 'ontology')
    tnms_library = csv_labels_to_ontology_labels(tnms_library);
end
end