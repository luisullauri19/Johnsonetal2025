% Script for extracting velocity data and t-test (p-values) in an Excel spreadsheet file
clc; clear; close all;

% Get file path and directory
filePath = matlab.desktop.editor.getActiveFilename;
dir = strrep(filePath, "\a6_vel_data_excel.m", '\');
disp(filePath);
disp(dir);

% Initialize the Excel filename
excel_filename = 'output_data-Sim_Exp-velocity_analysis.xlsx';

% Initialize cell array for storing velocity means
all_means = {}; % Start with an empty cell array
col_idx = 1; % Independent index for columns in all_means

for k = 1:4
    % Clean previous data for each new spreadsheet
    clear data_struct Idx_npart velocity_data;
    % 
    % Predefined names and criteria for AML and CML in simulation and experiments
    if k == 1
        predefined_name = 'AML'; predefined_name2 = 'Sim';
        sep_criterion(1) = 0.1; thresh(1) = 1;
    elseif k == 2
        predefined_name = 'AML'; predefined_name2 = 'Exp';
        sep_criterion(1) = 7; thresh(1) = 0.02;
    elseif k == 3
        predefined_name = 'CML'; predefined_name2 = 'Sim';
        sep_criterion(1) = 0.1; thresh(1) = 1;
    elseif k == 4
        predefined_name = 'CML'; predefined_name2 = 'Exp';
        sep_criterion(1) = 7; thresh(1) = 0.02;
    end
    % 
    % Load the .mat file created in script a4_intercepts.m
    file_name = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-new_Complete', predefined_name2, predefined_name, sep_criterion(1), thresh(1));
    load(fullfile(dir, file_name));
    disp([file_name, ' has been loaded.']);
    % 
    % Name dinamically assigned depending on the conditions (AML, CML, Sim or Exp)
    arrays_name = sprintf('%s_%s_vel_array', predefined_name, predefined_name2); % Array name
    sheet_name = sprintf('%s_%s_vel', predefined_name, predefined_name2); % Define sheet name
    % 
    % Check if required variables exist before proceeding
    if exist('Trajs', 'var')
        % Preallocate arrays within the structure for the current `k`
        % conditions (AML or CML, and Sim or Exp)
        array_ntrans = sum(Trajs(:, 1, 1) ~= 0); % Sum for non-zero elements
        array_npart = sum(Trajs(1, 1, :) ~= 0); % Sum for non-zero elements
        data_struct{k}.(arrays_name) = NaN(array_ntrans, array_npart); % Preallocate for velocity
        % Analyze and display trajectories
        Idx_npart = find(x_int_max_sep(:, 1, 1) == 0);
        total_zeros = sum(x_int_max_sep(:, 1, 1) == 0);
        disp('The trajectories that can not be saved because never experience an interception or the separation distance is >7µm')
        disp(total_zeros);
        total_remain = length(x_int_max_sep) - total_zeros;
        disp('The trajectories within the separation distance criteria <7µm')
        disp(total_remain);   
        % 
        % Populate the array depending on the conditions (AML, CML, Sim or Exp)
        for i = 1:array_npart
            if ~exist('Idx_npart', 'var') || isempty(Idx_npart) || ~ismember(i, Idx_npart)
                velocity_data = Trajs(Trajs(:, 10, i) ~= 0, 10, i); % Instantaneous velocity data
                data_struct{k}.(arrays_name)(1:length(velocity_data), i) = velocity_data;
            else
                continue;
            end
        end
        % 
        % Calculate the mean velocity of each trajectory-particle
        column_means = mean(data_struct{k}.(arrays_name), 'omitnan'); % Mean ignoring NaN
        % Append the means to the cell array for final export
        all_means{1, col_idx} = sheet_name; % Store the name in the first row
        for row = 1:length(column_means)
            all_means{row + 1, col_idx} = column_means(row); % Append mean values in the corresponding column
        end
        % Increment column index for the next condition
        col_idx = col_idx + 1;
        % Save the full data in the original spreadsheet
        writematrix(data_struct{k}.(arrays_name), excel_filename, 'Sheet', sheet_name, 'Range', 'A1');
        disp(['Data saved to sheet: ', sheet_name, ' in file: ', excel_filename]);
    end
end

% Write all means to a new sheet within the same Excel file
writecell(all_means, excel_filename, 'Sheet', 'Mean_vel', 'Range', 'A1');

% Final confirmation
disp(['Column means saved to a new sheet "Mean_vel" in file: ', excel_filename]);
%%
% Perform t-test analysis and save summary to Excel
disp('Starting t-test analysis and summary generation...');

% Determine the maximum column length in all_means
max_length = 0;
for col = 1:size(all_means, 2)
    % Calculate the number of rows (excluding the header) in each column
    col_data = all_means(2:end, col);
    max_length = max(max_length, numel(col_data));
end

% Create a matrix with consistent column lengths, filling shorter columns with NaN
all_means_numeric = NaN(max_length, size(all_means, 2));
for col = 1:size(all_means, 2)
    % Extract numeric data for this column
    col_data = cell2mat(all_means(2:end, col)); % Skip the header row
    all_means_numeric(1:length(col_data), col) = col_data; % Fill column with data
end

% Extract columns for AML and CML
AML_Sim = all_means_numeric(:, 1); % Column 1 (AML-Sim)
AML_Exp = all_means_numeric(:, 2); % Column 2 (AML-Exp)
CML_Sim = all_means_numeric(:, 3); % Column 3 (CML-Sim)
CML_Exp = all_means_numeric(:, 4); % Column 4 (CML-Exp)

% Remove NaN values before performing the t-tests
AML_Sim = AML_Sim(~isnan(AML_Sim));
AML_Exp = AML_Exp(~isnan(AML_Exp));
CML_Sim = CML_Sim(~isnan(CML_Sim));
CML_Exp = CML_Exp(~isnan(CML_Exp));

% Initialize summary table
summary_table = {
    'Analysis', 'p-value', 'Interpretation';
    'AML-Sim vs. AML-Exp', [], '';
    'CML-Sim vs. CML-Exp', [], '';
    'AML-Sim vs. CML-Sim', [], '';
    'AML-Exp vs. CML-Exp', [], '';
};

% Perform t-tests and populate summary table
[~, p_AML] = ttest2(AML_Sim, AML_Exp, 'Vartype', 'unequal');
summary_table{2, 2} = p_AML;
summary_table{2, 3} = interpret_p_value(p_AML, 'AML-Sim vs. AML-Exp');

[~, p_CML] = ttest2(CML_Sim, CML_Exp, 'Vartype', 'unequal');
summary_table{3, 2} = p_CML;
summary_table{3, 3} = interpret_p_value(p_CML, 'CML-Sim vs. CML-Exp');

[~, p_AML_CML_Sim] = ttest2(AML_Sim, CML_Sim, 'Vartype', 'unequal');
summary_table{4, 2} = p_AML_CML_Sim;
summary_table{4, 3} = interpret_p_value(p_AML_CML_Sim, 'AML-Sim vs. CML-Sim');

[~, p_AML_CML_Exp] = ttest2(AML_Exp, CML_Exp, 'Vartype', 'unequal');
summary_table{5, 2} = p_AML_CML_Exp;
summary_table{5, 3} = interpret_p_value(p_AML_CML_Exp, 'AML-Exp vs. CML-Exp');

% Append summary table to the Excel file in "Mean_vel"
writecell(summary_table, excel_filename, 'Sheet', 'Mean_vel', 'Range', 'F1');

disp(['Summary table saved in the "Mean_vel" sheet of file: ', excel_filename]); % Final confirmation

% Function to interpret p-value
function interpretation = interpret_p_value(p, comparison)
    if p < 0.05
        interpretation = ['Significant difference between ', comparison, ' (p-value<0.05)'];
    else
        interpretation = ['No significant difference between ', comparison, ' (p-value>=0.05)'];
    end
end