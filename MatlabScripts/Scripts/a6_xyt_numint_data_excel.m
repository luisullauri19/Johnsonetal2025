% Script for extracting histogram data of number of interceptions and 
% attachment x-coordinate in Excel spreadsheet files. 
clc; clear; close all;

% Get file path and directory
filePath = matlab.desktop.editor.getActiveFilename;
dir = strrep(filePath, "\a6_xyt_numint_data_excel.m", '\');
disp(filePath);
disp(dir);

% Separation distance and normalized velocity from [Sim Exp]
sep_dist = [0.1, 7]; % Define both values for sep_criterion [Sim Exp] (µm)
thresh_norm_vel = [1, 0.02];   % Define both values for thresh [Sim Exp] (-)
%
%% Load files
sep_criterion =sep_dist; % separation distance criterion [Sim Exp]
thresh = thresh_norm_vel; % normalized velocity criterion [Sim Exp]
% Load AML for Fav conditions from simulation and experimental data
% Favorable conditions
predefined_name = 'AML';
    % Load data from Simulation
    predefined_name2 = 'Sim';
    file_name = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete', ...
        predefined_name2, predefined_name, sep_criterion(1), thresh(1));
    load(strcat(file_name, '.mat'));
    disp([file_name, ' has been loaded.']);
    % Define the name for the new array
    arrays_name = sprintf('%s-%s-array', predefined_name, predefined_name2);
    % Check if required variables exist before proceeding
    if exist('x_int_max_sep', 'var') && exist('y_int_max_sep', 'var') && ...
       exist('numint', 'var') && exist('time_plot_max', 'var')
        % Preallocate array
        array_ntrans = sum(x_int_max_sep(:, 1, 1) ~= 0); % Sum for non-zero elements
        % Initialize the array within a structure using the dynamic name
        arrays_name = matlab.lang.makeValidName(arrays_name); % Ensure valid field name
        data_struct1.(arrays_name) = NaN(array_ntrans, 4); % Preallocate array
        % Populate the new array directly
        data_struct1.(arrays_name)(:, 1) = x_int_max_sep(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        data_struct1.(arrays_name)(:, 2) = y_int_max_sep(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        data_struct1.(arrays_name)(:, 3) = numint(1, x_int_max_sep(:, 1, 1) ~= 0);
        data_struct1.(arrays_name)(:, 4) = time_plot_max(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        % Display confirmation
        disp([file_name, ' has been processed and saved as ', arrays_name]);
    end
    % Load data from Experiments
    predefined_name2 = 'Exp';
    sep_criterion =sep_dist; % separation distance criterion [Sim Exp]
    thresh = thresh_norm_vel; % normalized velocity criterion [Sim Exp]
    file_name = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete', ...
        predefined_name2, predefined_name, sep_criterion(2), thresh(2));
    load(strcat(file_name, '.mat'));
    disp([file_name, ' has been loaded.']);
    % Define the name for the new array
    arrays_name = sprintf('%s-%s-array', predefined_name, predefined_name2);
    % Check if required variables exist before proceeding
    if exist('x_int_max_sep', 'var') && exist('y_int_max_sep', 'var') && ...
       exist('numint', 'var') && exist('time_plot_max', 'var')
        % Preallocate array
        array_ntrans = sum(x_int_max_sep(:, 1, 1) ~= 0); % Sum for non-zero elements
        % Initialize the array within a structure using the dynamic name
        arrays_name = matlab.lang.makeValidName(arrays_name); % Ensure valid field name
        data_struct2.(arrays_name) = NaN(array_ntrans, 4); % Preallocate array
        % Populate the new array directly
        data_struct2.(arrays_name)(:, 1) = x_int_max_sep(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        data_struct2.(arrays_name)(:, 2) = y_int_max_sep(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        data_struct2.(arrays_name)(:, 3) = numint(1, x_int_max_sep(:, 1, 1) ~= 0);
        data_struct2.(arrays_name)(:, 4) = time_plot_max(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        % Display confirmation
        disp([file_name, ' has been processed and saved as ', arrays_name]);
    end
%%
% Load CML for Unfav conditions from simulation and experimental data
sep_criterion =sep_dist; % separation distance criterion [Sim Exp]
thresh = thresh_norm_vel; % normalized velocity criterion [Sim Exp]
% Unfavorable conditions
predefined_name = 'CML';
    %
    % Load data from Simulation
    predefined_name2 = 'Sim';
    file_name = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete', ...
        predefined_name2, predefined_name, sep_criterion(1), thresh(1));
    load(strcat(file_name, '.mat'));
    disp([file_name, ' has been loaded.']);
    % Define the name for the new array
    arrays_name = sprintf('%s-%s-array', predefined_name, predefined_name2);
    % Check if required variables exist before proceeding
    if exist('x_int_max_sep', 'var') && exist('y_int_max_sep', 'var') && ...
       exist('numint', 'var') && exist('time_plot_max', 'var')
        % Preallocate array
        array_ntrans = sum(x_int_max_sep(:, 1, 1) ~= 0); % Sum for non-zero elements
        % Initialize the array within a structure using the dynamic name
        arrays_name = matlab.lang.makeValidName(arrays_name); % Ensure valid field name
        data_struct3.(arrays_name) = NaN(array_ntrans, 4); % Preallocate array
        % Populate the new array directly
        data_struct3.(arrays_name)(:, 1) = x_int_max_sep(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        data_struct3.(arrays_name)(:, 2) = y_int_max_sep(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        data_struct3.(arrays_name)(:, 3) = numint(1, x_int_max_sep(:, 1, 1) ~= 0);
        data_struct3.(arrays_name)(:, 4) = time_plot_max(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        % Display confirmation
        disp([file_name, ' has been processed and saved as ', arrays_name]);
    end
    %
    % Load data from Experiments
    predefined_name2 = 'Exp';
    sep_criterion =sep_dist; % separation distance criterion [Sim Exp]
    thresh = thresh_norm_vel; % normalized velocity criterion [Sim Exp]
    file_name = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete', ...
        predefined_name2, predefined_name, sep_criterion(2), thresh(2));
    load(strcat(file_name, '.mat'));
    disp([file_name, ' has been loaded.']);
    % Define the name for the new array
    arrays_name = sprintf('%s-%s-array', predefined_name, predefined_name2);
    % Check if required variables exist before proceeding
    if exist('x_int_max_sep', 'var') && exist('y_int_max_sep', 'var') && ...
       exist('numint', 'var') && exist('time_plot_max', 'var')
        % Preallocate array
        array_ntrans = sum(x_int_max_sep(:, 1, 1) ~= 0); % Sum for non-zero elements
        % Initialize the array within a structure using the dynamic name
        arrays_name = matlab.lang.makeValidName(arrays_name); % Ensure valid field name
        data_struct4.(arrays_name) = NaN(array_ntrans, 4); % Preallocate array
        % Populate the new array directly
        data_struct4.(arrays_name)(:, 1) = x_int_max_sep(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        data_struct4.(arrays_name)(:, 2) = y_int_max_sep(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        data_struct4.(arrays_name)(:, 3) = numint(1, x_int_max_sep(:, 1, 1) ~= 0);
        data_struct4.(arrays_name)(:, 4) = time_plot_max(x_int_max_sep(:, 1, 1) ~= 0, 1, 1);
        % Display confirmation
        disp([file_name, ' has been processed and saved as ', arrays_name]);
    end
%
%%
% Export matrix as Excel file
excel_filename = 'output_subset_data_Sim_Exp-histogram(numint_vs_x-coord)_7µm_0.02_normvel.xlsx';
% Define the column headers
column_headers = {'x-coordinate att.', 'y-coordinate att.', 'int. order', 'elapsed time (s)'};
    % Export data_struct1: Sim-AML
        field_names1 = fieldnames(data_struct1);
        for i = 1:numel(field_names1)
            writecell(column_headers, excel_filename, 'Sheet', field_names1{i}, 'Range', 'A1');
            writematrix(data_struct1.(field_names1{i}), excel_filename, 'Sheet', field_names1{i}, 'Range', 'A2');
        end
    % Export data_struct2: Exp-AML
        field_names2 = fieldnames(data_struct2);
        for i = 1:numel(field_names2)
            writecell(column_headers, excel_filename, 'Sheet', field_names2{i}, 'Range', 'A1');
            writematrix(data_struct2.(field_names2{i}), excel_filename, 'Sheet', field_names2{i}, 'Range', 'A2');
        end
    % Export data_struct3: Sim-CML
        field_names3 = fieldnames(data_struct3);
        for i = 1:numel(field_names3)
            writecell(column_headers, excel_filename, 'Sheet', field_names3{i}, 'Range', 'A1');
            writematrix(data_struct3.(field_names3{i}), excel_filename, 'Sheet', field_names3{i}, 'Range', 'A2');
        end
    % Export data_struct4: Exp-CML
        field_names4 = fieldnames(data_struct4);
        for i = 1:numel(field_names4)            
            writecell(column_headers, excel_filename, 'Sheet', field_names4{i}, 'Range', 'A1');
            writematrix(data_struct4.(field_names4{i}), excel_filename, 'Sheet', field_names4{i}, 'Range', 'A2');
        end
disp(['Matrices saved on:  ', excel_filename]); 
