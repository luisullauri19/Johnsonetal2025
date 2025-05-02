% Script to extract subset data from simulations(100 nm sep dist) and experiments
clc; clear; close all;
% Get the current file path and set the directory
filePath = matlab.desktop.editor.getActiveFilename;
dir = strrep(filePath, "\b2_data_ext_subset.m", '\');
disp(filePath)
disp(dir)
%
% Load the mat. file with the number of rows to extract for Experiments and
% simulations for Favorable and Unfavorable conditions.
subset_array_file = strcat('Sim_Exp_subset_new_arrays.mat'); % File with subset arrays
load(subset_array_file, 'x_idx_array'); % Load only the specific array
% Load AML or CML for Fav or Unfav conditions from experimental data
sep_criterion(1) = 7; % Separation criterion
thresh(1) = 0.02; % Threshold value
% Load AML or CML arrays from Simulations to load data
for k=1:4
    if k==1
        predefined_name2='Sim';
        % Favorable
        load(strcat(predefined_name2,'_sub_geo_AML','.mat')); % Load AML-Sim geometry 
        load(strcat('Sim_New_Array3_Array_AML.mat'))
        Fav_100nm_complete_Array_subset=New_Array3(:,:,x_idx_array(:,1));
        % Save the subset to a new .mat file
        file_name = 'Fav_100nm_complete_Array_subset';
        save(strcat(file_name, '.mat'));
    elseif k==2
        predefined_name2='Sim';
        % Unfavorable
        load(strcat(predefined_name2,'_sub_geo_CML','.mat')); % Load CML-Sim geometry 
        load(strcat('Sim_New_Array3_Array_CML.mat'))
        Unfav_100nm_complete_Array_subset=New_Array3(:,:,x_idx_array(:,2));
        % Save the subset to a new .mat file
        file_name = 'Unfav_100nm_complete_Array_subset';
        save(strcat(file_name, '.mat'));
    elseif k==3
        predefined_name2 = 'Exp'; % Load AML or CML arrays from Experiments to load data
        % Favorable
        predefined_name = 'AML'; % Specify geometry for AML
        load(strcat(predefined_name2, '_sub_geo_', predefined_name, '.mat')); % Load AML-Exp geometry
        aml_file = fullfile('Exp_AML_trajectories.xlsx');
        % Open an Excel server
        excel = actxserver('Excel.Application');
        % Open the original Excel file
        originalWorkbook = excel.Workbooks.Open(aml_file); % Open the specified file
        
        % Create a new Excel file
        newWorkbook = excel.Workbooks.Add;
        
        while newWorkbook.Sheets.Count > 1 % Remove default blank sheets 
            newWorkbook.Sheets.Item(1).Delete;
        end
        
        % Names (indices) of the sheets you want to copy
        sheetIndices = x_idx_array(:,3); % Extract the third column containing sheet indices
        
        % Iterate over the sheet indices you want to copy
        for i = 1:length(sheetIndices)
            % Get the index of the current sheet
            sheetIndex = sheetIndices(i);
            
            % Access the sheet in the original workbook using its index
            sheet = originalWorkbook.Sheets.Item(sheetIndex);
            
            % Copy the sheet to the new workbook
            sheet.Copy(newWorkbook.Sheets.Item(i));
        end
        
        % After the loop, check if any extra default sheets still exist
        if newWorkbook.Sheets.Count > length(sheetIndices)
            for k = length(sheetIndices) + 1:newWorkbook.Sheets.Count
                newWorkbook.Sheets.Item(k).Delete;
            end
        end
        
        % Close original workbook AFTER copying the sheets
        originalWorkbook.Close(false);
        
        % Save and close the new workbook
        newWorkbook.SaveAs(fullfile('Exp_AML_trajectories_subset.xlsx'));
        newWorkbook.Close;
        
        % Quit Excel application
        excel.Quit;
        delete(excel);
    elseif k==4
        predefined_name2 = 'Exp'; % Load AML or CML arrays from Experiments to load data
        % Unfavorable
        predefined_name = 'CML'; % Specify geometry for AML
        load(strcat(predefined_name2, '_sub_geo_', predefined_name, '.mat')); % Load AML-Exp geometry
        cml_file = fullfile('Exp_CML_trajectories.xlsx');
        % Open an Excel server
        excel = actxserver('Excel.Application');
        % Open the original Excel file
        originalWorkbook = excel.Workbooks.Open(cml_file); % Open the specified file
        
        % Create a new Excel file
        newWorkbook = excel.Workbooks.Add;
        
        while newWorkbook.Sheets.Count > 1 % Remove default blank sheets 
            newWorkbook.Sheets.Item(1).Delete;
        end
        
        % Names (indices) of the sheets you want to copy
        sheetIndices = x_idx_array(:,4); % Extract the third column containing sheet indices
        
        % Iterate over the sheet indices you want to copy
        for i = 1:length(sheetIndices)
            % Get the index of the current sheet
            sheetIndex = sheetIndices(i);
            
            % Access the sheet in the original workbook using its index
            sheet = originalWorkbook.Sheets.Item(sheetIndex);
            
            % Copy the sheet to the new workbook
            sheet.Copy(newWorkbook.Sheets.Item(i));
        end
        
        % After the loop, check if any extra default sheets still exist
        if newWorkbook.Sheets.Count > length(sheetIndices)
            for k = length(sheetIndices) + 1:newWorkbook.Sheets.Count
                newWorkbook.Sheets.Item(k).Delete;
            end
        end
        
        % Close original workbook AFTER copying the sheets
        originalWorkbook.Close(false);
        
        % Save and close the new workbook
        newWorkbook.SaveAs(fullfile('Exp_CML_trajectories_subset.xlsx'));
        newWorkbook.Close;
        
        % Quit Excel application
        excel.Quit;
        delete(excel);
    end
end


