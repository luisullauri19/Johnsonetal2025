% Script to create a subset based on AML, CML, Sim and Exp data. 
clc; clear; close all;
filePath = matlab.desktop.editor.getActiveFilename;
dir = strrep(filePath, "\b1_rows_2_extract.m", '\');
disp(filePath);
disp(dir);

% Preallocation of matrix to store number of trajectories for each condition
x_new = NaN(35, 4); 
% Initialization of counters
j = 1; % counter of x_max_sep_dist
z = 1; % counter for index location. 
%
% Define the conditions to extract the data from experimental and
% simulation .mat files (this is just for loading the final locations of
% the colloids), any other norm. vel. can be applied
for k = 1:2 % Conditions to load from simulations or experiments
    if k == 1 
        predefined_name2 = 'Sim';
        sep_criterion(1) = 0.1;
        thresh(1) = 1;
    elseif k == 2 
        predefined_name2 = 'Exp';
        sep_criterion(1) = 7;
        thresh(1) = 0.02;
    end
    
    for r = 1:2 % Conditions to load from AML or CML
        if r == 1
            predefined_name = 'AML';
        elseif r == 2
            predefined_name = 'CML';
        end
        file_to_load = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete', ...
            predefined_name2, predefined_name, sep_criterion(1), thresh(1));
        %
        % Load the .mat file with the conditions (defined by k and r values)
        Exp_data = load(strcat(file_to_load, '.mat'));
        disp(strcat(file_to_load, '.mat has been loaded'));
        
        % Extract variables dynamically for all mat. files (AML, CML, Sim, and Exp)
        Exp_data_variables = fieldnames(Exp_data);
        for i = 1:numel(Exp_data_variables)
            current_variable_name = Exp_data_variables{i}; % Dynamic name
            % Create combined variable name with predefinednames (AML, CML, Sim, and Exp)
            combined_name = sprintf('%s_%s_%s', predefined_name2, predefined_name, current_variable_name);
            eval(sprintf('%s = Exp_data.%s;', combined_name, current_variable_name));
            current_data = eval(combined_name); % save data for each variable, it will be updated every loop
            % Extract first column from each array
            if isnumeric(current_data)
                current_data = current_data(:, 1); 
            end
            % Remove invalid or empty entries
            if isnumeric(current_data)
                current_data = current_data(current_data ~= 0); % Remove zeros for numeric data
            end
            % Save back to dynamically named variable with combined name
            eval(sprintf('%s_clean = current_data;', combined_name));
        end
        % Dynamically determine the name of the reference variable
        x_ref = sprintf('%s_%s_x_int_max_sep_clean', predefined_name2, predefined_name);
        %
        if exist(x_ref, 'var')
            % Evaluate the dynamically named variable
            x_ref = eval(x_ref);   
            % Compare values that are evenly spaced across x-distance
            spacing_crit = 500; % Spacing criteria for use in the field of view (Creates 10 bins)
            spacing_xFOV_name = sprintf('%s_%s_xFOV', predefined_name2, predefined_name);
            spacing_xFOV = eval(spacing_xFOV_name); % Extract the xFOV data
            % Calculate the number of data points evenly spaced in the xFOV range
            num_data_in_xFOV = floor((spacing_xFOV(2) - spacing_xFOV(1)) / spacing_crit) + 1; % (Creates 11 bins)
            ref_data_x = linspace(spacing_xFOV(1), spacing_xFOV(2), num_data_in_xFOV); % Generate evenly spaced x-coordinates
            
            % Define tolerance for comparison
            tolerance_x = 40; 
            % Initialize a cell array to store indices for each reference point
            Idx_Sim_All = cell(length(ref_data_x), 1);
            for i = 1:length(ref_data_x)
                % Compute absolute differences between reference_data and current ref_data_x point
                differences = abs(x_ref - ref_data_x(i));
                % Sort differences and get the indices of the smallest values
                [~, sorted_indices] = sort(differences);
                % Determine the number of points based on the bin index
                if i < 10 % 1st to 9th bin (3 values)
                    num_points = min(3, length(sorted_indices)); % Use up to 3 points for the first bins
                else % 10th to 11th bin (2 values)
                    num_points = min(2, length(sorted_indices)); % Use up to 2 points for last 2 bins
                end
                % Select the required indices
                selected_indices = sorted_indices(1:num_points);
                % Collect indices for this bin
                Idx_Sim_All{i} = selected_indices(:); % Ensure selected indices are column vectors
            end

            % Ensure all cells have consistent dimensions before concatenation
            Idx_Sim_All = Idx_Sim_All(~cellfun('isempty', Idx_Sim_All)); % Remove empty cells
            Idx_Sim = unique(vertcat(Idx_Sim_All{:})); % Concatenate all arrays vertically and remove duplicates
            % Dynamically handle size mismatch in x_new
            num_indices = length(Idx_Sim);
            if num_indices > size(x_new, 1)
                % Resize x_new to accommodate more rows
                x_new = [x_new; NaN(num_indices - size(x_new, 1), size(x_new, 2))];
            end
            % Assign the extracted the x-coordinate data to x_new saved in
            % diffenret columns
            x_new(1:num_indices, j) = x_ref(Idx_Sim);
            j = j + 1; % Move to the next column
        end 
        % Dynamically determine the name of the secondary reference variable
        x_max_ref_name = sprintf('%s_%s_x_int_max_sep', predefined_name2, predefined_name);
        if exist(x_max_ref_name, 'var')
            % Evaluate the secondary reference variable
            x_max_ref = eval(x_max_ref_name);
            % Ensure x_max_ref is a column vector
            x_max_ref = x_max_ref(:);
            % Find indices of x_new values in x_max_ref
            [is_member, idx] = ismember(x_new(:, j-1), x_max_ref); % Use the last filled column of x_new
            % Extract the indices (row positions) in x_max_ref
            x_idx_array(:, z) = idx(is_member);
        end
        z=z+1;
    end
end

% Define bin edges
bin_edges = 0:500:5500; % Define bin edges (adjust as needed)
bin_centers = bin_edges(1:end-1) + diff(bin_edges) / 2; % Calculate bin centers

% Initialize a matrix to store histogram counts for all columns
all_counts = zeros(length(bin_centers), size(x_new, 2));

% Open a new figure
figure(1);
hold on;

% Loop through the columns of x_new
for z = 1:size(x_new,2)
    % Extract non-NaN values for the current column
    current_data = x_new(:,z); % Remove NaN values

    % Compute histogram counts for the current column
    bin_counts = histcounts(current_data, bin_edges);
    all_counts(:, z) = bin_counts; % Store counts for later

% Plot with filled markers
plot(bin_centers, bin_counts, 'o-', 'MarkerFaceColor', 'auto', ...
    'DisplayName', sprintf('"n" data value: %d', z));
end

% Add labels, legend, and grid for better visualization
xlabel('x-distance (µm)');
ylabel('Number of trajectories');
legend('Location', 'best'); % Show legend
hold off;
% Save file
file_name = sprintf('Sim_Exp_subset_new_arrays');
save(strcat(file_name, '.mat'));
