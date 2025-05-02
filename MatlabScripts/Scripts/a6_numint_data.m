% This script dynamically generates file names, loads them, and processes data

clc; clear; close all;
filePath = matlab.desktop.editor.getActiveFilename;
dir = strrep(filePath, "a6_numint_data.m", filesep); % Ensure cross-platform compatibility
disp("Working directory: " + dir);

% Output Excel file
output_file = fullfile(dir, 'Output-subset_complete_numint.xlsx');

% Start timer for performance tracking
tic;

% Iterate over all dataset types
for ii = 1:4
    flag_data = ii;
    if flag_data == 1
        predefined_name = 'AML'; % Favorable AML
        predefined_name2 = 'Sim'; % Simulation
        j_end = 2;
        sep_criterion = [0.1, 7];
    elseif flag_data == 2
        predefined_name = 'AML';
        predefined_name2 = 'Exp';
        j_end = 1;
        sep_criterion = [7]; % Ensure it's always an array
    elseif flag_data == 3
        predefined_name = 'CML'; % Unfavorable CML
        predefined_name2 = 'Sim';
        j_end = 2;
        sep_criterion = [0.1, 7];
    elseif flag_data == 4
        predefined_name = 'CML';
        predefined_name2 = 'Exp';
        j_end = 1;
        sep_criterion = [7];
    end

    for j = 1:j_end
        if j == 1 && (flag_data == 1 || flag_data == 3)
            thresh_new = [1];
        else
            thresh_new = [0.015, 0.02, 0.025];
        end

        for f = 1:length(thresh_new)
            % Generate filename
            filename = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete_subset.mat',...
                predefined_name2, predefined_name, sep_criterion(j), thresh_new(f));
            
            % Full file path
            file_path = fullfile(dir, filename);
            disp("Processing file: " + file_path);

            % Check if file exists
            if exist(file_path, 'file')
                disp("File found, loading...");
                data = load(file_path); % Load the file into a struct
                
                % Check if the required variable exists
                if isfield(data, 'numint')
                    numint = data.numint;
                else
                    warning("Variable 'ntrans_int' not found in %s. Skipping.", filename);
                    continue;
                end
                
                % Extract metadata from filename
                exp_type = predefined_name2; % 'Sim' or 'Exp'
                method = predefined_name; % 'AML' or 'CML'
                normvel = sprintf('%.3f', thresh_new(f)); % Extract norm. velocity

                % Process ntrans_int
                for j_idx = 1:size(numint, 1)
                    if strcmp(exp_type, 'Sim')
                        if thresh_new(f) == 1 && j_idx > 1
                            continue; % Only evaluate j=1 once when thresh == 1
                        elseif thresh_new(f) ~= 1 && j_idx == 1
                            continue; % Skip j=1 when thresh is different from 1
                        end
                    elseif strcmp(exp_type, 'Exp') && j_idx > 1
                        continue; % Only j=1 for Exp datasets
                    end

                    sheet_name = sprintf('%s-%s-%s-j%d', exp_type, method, normvel, j_idx);
                    extracted_matrix = squeeze(numint(j_idx, :, :));

                    % Convert to table for better Excel structure
                    extracted_table = array2table(extracted_matrix);
                    
                    % Save data to Excel
                    writetable(extracted_table, output_file, 'Sheet', sheet_name, 'WriteVariableNames', false);

                    fprintf('Saved: %s to sheet %s\n', filename, sheet_name);
                end
            else
                warning("File NOT found: " + file_path);
            end
        end
    end
end

% End timer
elapsed_time = toc;
fprintf('Process completed in %.2f seconds!\n', elapsed_time);