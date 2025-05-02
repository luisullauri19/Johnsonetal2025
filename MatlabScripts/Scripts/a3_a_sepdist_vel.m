% This script uses an mat. files to produce the matrix New_Array3 
clc; clear; close all;
filePath = matlab.desktop.editor.getActiveFilename;
dir = strrep(filePath,"\a3_a_sepdist_vel.m",'\');
disp(filePath)
disp(dir)
%
% Call for AML or CML depending on Fav or Unfav conditions, respectively.
% Call for Simulation
flag_data=1; % choose the type of data to load 
% 1 for loading AML (Favorable) from simulations
% 3 for loading CML (Unfavorable) from simulations
    % Load the .mat file
    if flag_data == 1
        predefined_name='AML'; % Call for AML on Fav conditions
        predefined_name2='Sim'; % Call for Sim on Simulation 
    elseif flag_data == 3
        predefined_name='CML'; % Call for CML on Unfav conditions
        predefined_name2='Sim'; % Call for Sim on Simulation 
    end
%
if predefined_name=='AML'
    if predefined_name2 == 'Sim' 
        load(strcat('Fav_100nm_complete_Array.mat')); %load(strcat(dir,'Fav_100nm_Array.mat')); % Load Sim-AML workbook with worksheet New_Array
        ap=0.95/2; % colloid radius in Favorable conditions simulations (µm) 
    end
elseif predefined_name=='CML'
    if predefined_name2 == 'Sim'
        load(strcat('Unfav_100nm_complete_Array.mat')); % load(strcat(dir,'Unfav_100nm_Array.mat')); % Load Sim-CML workbook with worksheet New_Array
        ap=0.95/2; % colloid radius in Unfavorable conditions simulations (µm) 
    end
end
%%
if predefined_name2=='Sim'
    % Simulation input 3D matrix: New_Array
    % 40000 rows (translations), 4 columns (described below) for npart trajectories:
        % 1st column: x-coordinate (µm)
        % 2nd column: y-coordinate (µm)
        % 3rd column: time (s)
        % 4th column: sep. dist. to the nearest grain (µm)
    % 
    % Check for attachment (x and y coordinates unchanging) and note row 
    % number in order to delete subsequent rows and shorten array
        if predefined_name=='AML'
            New_Array=Fav_100nm_complete_Array;% New_Array=Fav_100nm_Array; 
        elseif predefined_name=='CML'
            New_Array=Unfav_100nm_complete_Array;% New_Array=Unfav_100nm_Array;
        end
        % Get the number of rows, columns, and the third dimension
        ntrans = size(New_Array, 1); % Number of translations for each particle (40000)
        npart = size(New_Array, 3); % Number of particle trajectories 
        ntrans_i = NaN(1,npart);  % Number of translations for each particle
        New_Array2 = NaN(ntrans, size(New_Array, 2), npart);
        %
        for i=1:npart
        Colloid_xy0 = [New_Array(1,1,i) New_Array(1,2,i)]; % Assign initial colloid location
            trans_count = 0; % Assign initial translation count
            attach_flag = 0; % attach_flag equal to zero means non-attached
            for ic = 1:ntrans
                New_Array2(ic,:,i)=New_Array(ic,:,i); % New_Array2 is saving needed rows from New_Array
                % Check whether colloid has immobilized
                Colloid_xy1 = [New_Array(ic,1,i) New_Array(ic,2,i)]; % Assign current colloid location
                Colloid_dist = sqrt((Colloid_xy1(1) - Colloid_xy0(1))^2 + (Colloid_xy1(2) - Colloid_xy0(2))^2); % distance between current and first colloid 
                    if Colloid_dist < 0.001 % check for immobilization based on <1 nm translation over 20 translations
                        trans_count=trans_count+1;
                        if trans_count > 20 % Check if Colloid_dist < 1 nm for 20 consecutive translations
                            attach_flag = 1; % attached_flag 1 = attachment
                        end
                    else
                        Colloid_xy0 = Colloid_xy1; % exchanging current for previous colloid
                        trans_count = 0; % Reset if Colloid_dist > 0.001 µm
                    end
                if attach_flag == 1
                    ntrans_i(i)=ic; 
                    break
                end
            end % loop for translations (ic:ntrans_i)
            New_Array3=NaN(max(ntrans_i(i)),4, npart);
        end % loop for trajectory number (i:npart)
    % Array with valid data from simulation
    for i=1:npart
        New_Array3(1:ntrans_i(i),:, i)=New_Array2(1:ntrans_i(i),:,i); 
    end
    % Save condensed Sim data array 
    save(strcat(predefined_name2,'_New_Array3_Array_',predefined_name,'.mat'), 'New_Array3')
    save(strcat(predefined_name2,'_New_Array3_File_',predefined_name,'.mat'))
end
%