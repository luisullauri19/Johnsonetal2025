% Script to get the min and max x-coordinate and corresponding times and number of translations 
% for each interception under each condition (AML, CML, Sim or Exp)
clc; clear; close all;
filePath = matlab.desktop.editor.getActiveFilename;
dir = strrep(filePath, "a7_min_max_x_t_ntrans_data.m", filesep); % Ensure cross-platform compatibility
disp(" Working directory: " + dir);

% Output Excel files
output_files = {...
    fullfile('output_all_x_int_min_x.xlsx'),...
    fullfile('output_all_x_int_max_x.xlsx'),...
    fullfile('output_all_x_int_min_t.xlsx'),...
    fullfile('output_all_x_int_max_t.xlsx'),...
    fullfile('output_all_ntrans_int.xlsx')};

% Arrays to process
array_names = {'x_int_minimum_x', 'x_int_maximum_x', 'x_int_minimum_t', 'x_int_maximum_t', 'ntrans_int'};

tic;

% Iterate over all dataset types
for ii = 1:4
    flag_data = ii;
    if flag_data == 1
        predefined_name = 'AML';
        predefined_name2 = 'Sim';
        j_end = 2;
        sep_criterion = [0.1, 7];
    elseif flag_data == 2
        predefined_name = 'AML';
        predefined_name2 = 'Exp';
        j_end = 1;
        sep_criterion = [7];
    elseif flag_data == 3
        predefined_name = 'CML';
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
            filename = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete.mat',...
                predefined_name2, predefined_name, sep_criterion(j), thresh_new(f));
            
            file_path = fullfile(filename);
            disp("Processing file: " + file_path);
            
            if exist(file_path, 'file')
                disp("File found, loading...");
                data = load(file_path);
                
                exp_type = predefined_name2;
                method = predefined_name;
                normvel = sprintf('%.3f', thresh_new(f));
                
                for arr_idx = 1:length(array_names)
                    array_name = array_names{arr_idx};
                    output_file = output_files{arr_idx};
                    
                    if isfield(data, array_name)
                        array_data = data.(array_name);
                    else
                        warning("'%s' not found in %s. Skipping.", array_name, filename);
                        continue;
                    end
                    
                    % Extract entire matrix properly without compression
                    extracted_matrix = reshape(array_data(:, j, :), size(array_data, 1), size(array_data, 3));
                    
                    sheet_name = sprintf('%s-%s-%s-j%d', exp_type, method, normvel, j);
                    extracted_table = array2table(extracted_matrix);
                    
                    writetable(extracted_table, output_file, 'Sheet', sheet_name, 'WriteVariableNames', false);
                    fprintf('Saved: %s to sheet %s\n', filename, sheet_name);
                end
            else
                warning("File NOT found: " + file_path);
            end
        end
    end
end

elapsed_time = toc;
fprintf('Process completed in %.2f seconds!\n', elapsed_time);
