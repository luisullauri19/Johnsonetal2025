% Script for getting the attachment position from Simulation (100 nm sep dist) based on Experimental position. 
    clc;clear;close all;
    filePath = matlab.desktop.editor.getActiveFilename;
    dir = strrep(filePath,"\a5_data_extraction_Sim_100nm.m",'\');
    disp(filePath)
    disp(dir)  
% Load AML or CML for Fav or Unfav conditions from experimental data
    predefined_name = 'CML';
    sep_criterion(1) = 7;
    thresh(1) = 0.02;  
% Load AML or CML-Sim geometry 
    load(strcat(dir,'Sim','_sub_geo_',predefined_name,'.mat'));
% Load the Excel file with the 200 nm summary results from Fav or UnFav conditions
    % Fav: fav_data_200nm
    % Unfav: unfav_data_200nm
    if strcmp(predefined_name, 'AML')
        excelFile = 'fav_data_200nm.xlsx';
        disp('Favorable (AML) conditions simulation file has been loaded');
            % Load the .mat files that contains the complete data from simulation at 200 nm  
        condition_name = 'Fav';   
        % Comparable simulation values to experimental
            % Field of view (5th section)
            dleft(2)=5800; % adjustment for the 5th of the field of view to obtain the same FOV as experiments
            % Number of attached colloids (experimentally ~ 214 colloids)
            tolerance = inf; % tolerance =  37;  % Define a tolerance value for the simulation attached location relative to the experimental.  
    elseif strcmp(predefined_name, 'CML')
        excelFile = 'unfav_data_200nm.xlsx';
        disp('Unfavorable (CML) conditions simulation file has been loaded');
            % Load the .mat files that contains the complete data from simulation at 200 nm  
        condition_name = 'Unfav';
        % Comparable simulation values to experimental
            % Number of attached colloids (experimentally ~ 214 colloids)
            tolerance = inf; % tolerance = 20; % Define a tolerance value for the simulation attached location relative to the experimental.  
    end
% Read the first sheet of the Excel file and explicitly handle headers
    Sim_rawData = readcell(excelFile); 
% Headers from the first row for each column 
    Sim_headers = Sim_rawData(1, :);
    Sim_headers = cellstr(Sim_headers);
% Extract numerical values from the 2nd row to the end
    Sim_data = Sim_rawData(2:end, :);
% Save the data from 100 nm Sim into a table with the header names
    Sim_dataTable = cell2table(Sim_data);
    Sim_dataTable.Properties.VariableNames = matlab.lang.makeValidName(Sim_headers); 
% Convert the table to an array
    Sim_dataArray = table2array(Sim_dataTable);
    % Variable to use from the loaded .mat file
    Sim_data_extract_x= Sim_dataArray(:,1);
    Sim_data_extract_y= Sim_dataArray(:,2);
    % load mat. files that contain x,y coordinates to ensure that the whole
    % trajectory is within the Field of view
    x_data = load(sprintf("%s-tr_x_att.mat", condition_name));
    y_data = load(sprintf("%s-tr_y_att.mat", condition_name));
    % Load the data files dynamically based on condition_name
    time_data = load(sprintf("%s-tr_time_att.mat", condition_name));
    h_data = load(sprintf("%s-tr_h_att.mat", condition_name));
    % Get variable names for each file
        time_100nm = fieldnames(time_data);
        x_100nm = fieldnames(x_data);
        y_100nm = fieldnames(y_data);
        h_100nm = fieldnames(h_data);
    % Ensure that the data is within the FOV limits
k = 0;
r = 0;
for i = 1:length(Sim_data_extract_y)
    % Check X and Y conditions
    x_in = Sim_data_extract_x(i,1) > dleft(1) && Sim_data_extract_x(i,1) < dright(1);
    y_in = Sim_data_extract_y(i,1) > dleft(2) && Sim_data_extract_y(i,1) < uright(2);   
    % Check both conditions
    if x_in && y_in
        k = k + 1;
        Sim_data_x_in(k,1) = Sim_data_extract_x(i,1);
        Sim_data_y_in(k,1) = Sim_data_extract_y(i,1);
        Sim_data_Idx(k,1)=i;
    % Load data of x,y coordinates to ensure that the whole trajectory is within the Field of view 
        % For tr_x_att
        specific_100nm_x = x_data.(x_100nm{1})(Sim_data_Idx(k,1), :); 
        tr_x_100nm = specific_100nm_x';
        min_values_x=min(tr_x_100nm);
        max_values_x=max(tr_x_100nm);
        % For tr_y_att
        specific_100nm_y = y_data.(y_100nm{1})(Sim_data_Idx(k,1), :); 
        tr_y_100nm = specific_100nm_y';
        min_values_y=min(tr_y_100nm);
        max_values_y=max(tr_y_100nm);
        % Check X and Y trajectory within FOV
        x_traj_in = min_values_x > dleft(1) && max_values_x < dright(1);
        y_traj_in= min_values_y> dleft(2) && max_values_y < uright(2);   
        % Check both conditions
        if x_traj_in && y_traj_in
            r = r + 1;
            Sim_data_x_in_traj(r,1) = Sim_data_extract_x(i,1);
            Sim_data_y_in_traj(r,1) = Sim_data_extract_y(i,1);
            Sim_data_Idx_traj(r,1)=i;
        end
            fprintf('Point %d added: X = %.2f, Y = %.2f\n', i, ...
            Sim_data_extract_x(i,1), Sim_data_extract_y(i,1));
    end
end

% Load the experimental array to compare with
    % File name
    predefined_name2 = 'Exp';
    exp_file=sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-new_Complete', ...
    predefined_name2, predefined_name, sep_criterion(1), thresh(1));
    % Load the .mat file
    Exp_data=load(strcat(dir,exp_file,'.mat')); 
    disp(strcat(exp_file, '.mat has been loaded'));
    Exp_data_variables = fieldnames(Exp_data);
    % Variable to use from the loaded .mat file
    Exp_data_extract= Exp_data.x_int_max_sep(:,1,1);
    % Extract data with no zeros
    Exp_data_extract = Exp_data_extract(Exp_data_extract ~= 0);
% 
% Extract data from 100 nm simulations
    Exp_data_extract = Exp_data_extract(:)'; % Arrange Exp_data_extract as a row vector
    differences = abs(Sim_data_x_in_traj - Exp_data_extract); % Absolute differences between the sim and exp values
    % Initialize a cell array to store all indices within the tolerance for each column
    Idx_Sim_All = cell(1, size(differences, 2));
        for col = 1:size(differences, 2)
            % Find indices where the difference is within the tolerance
            Id_within_tolerance = find(differences(:, col) <= tolerance);
            % Store these indices in the cell array
            Idx_Sim_All{col} = Id_within_tolerance;
        end
    Idx_Sim = unique(cell2mat(Idx_Sim_All')); % Cell array into a single list of unique indices
    Idx_Sim = Sim_data_Idx_traj(~isnan(Idx_Sim)); % remove NaN values, just in case
    disp(['Number of matched trajectories with tolerance: ', num2str(length(Idx_Sim))]); % Display the final number of matched trajectories
    %
% Load the data from the complete 100nm-simulation data set 
    % Define the specific rows you want to extract
        n_rows=Idx_Sim;
% Save the selected trajectories in an array "Array_name"
    % For x_100nm
        specific_100nm_x = x_data.(x_100nm{1})(n_rows, :); 
        tr_x_100nm = specific_100nm_x';
    % For y_100nm
        specific_100nm_y = y_data.(y_100nm{1})(n_rows, :); 
        tr_y_100nm = specific_100nm_y';
    % For tr_time_att
        specific_100nm_time = time_data.(time_100nm{1})(n_rows, :);
        tr_time_100nm = specific_100nm_time';
    % For tr_h_att
        specific_100nm_h = h_data.(h_100nm{1})(n_rows, :) * 1e6; % Convert to µm
        tr_h_100nm = specific_100nm_h';
% Assuming the transposed tables are already loaded as variables
    % Define the number of rows and files
        transp_nrows = size(tr_time_100nm, 1); % Number of rows
        num_files = 4; % Number of files or criteria (x, y, time, h_distance)
        npart=size(tr_time_100nm,2);
    % Preallocate New_Array
        if predefined_name=='AML'
            New_Array_name = 'Fav_100nm_complete_Array'; % New_Array_name = 'Fav_100nm_Array';
        elseif predefined_name=='CML'
            New_Array_name = 'Unfav_100nm_complete_Array';% New_Array_name = 'Unfav_100nm_Array'; 
        end
    % Preallocate the array with the dynamic name
    eval([New_Array_name ' = NaN(transp_nrows, num_files, npart);']);

    % Populate the 3D array with each column from each criterion
    for j = 1:npart
        eval([New_Array_name '(:, 1, j) = tr_x_100nm(:, j);']);
        eval([New_Array_name '(:, 2, j) = tr_y_100nm(:, j);']);
        eval([New_Array_name '(:, 3, j) = tr_time_100nm(:, j);']);
        eval([New_Array_name '(:, 4, j) = tr_h_100nm(:, j);']);
    end
% Save New_Array to a .mat file
eval(['save(''' New_Array_name '.mat'', ''' New_Array_name ''');']);