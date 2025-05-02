% This script uses an Excel file to produce the matrix Trajs 
clc; clear; close all;
filePath = matlab.desktop.editor.getActiveFilename;
dir = strrep(filePath,"\a3_b_sepdist_vel.m",'\');
disp(filePath)
disp(dir)
%
% Call for AML or CML depending on Fav or Unfav conditions, respectively.
% Call for Sim or Exp depending on Simulation or Experiment, respectively.
flag_data=3; % choose the type of data to load 
% 1 for loading AML (Favorable) from simulations
% 2 for loading AML (Favorable) from experiments
% 3 for loading CML (Unfavorable) from simulations
% 4 for loading CML (Unfavorable) from experiments
    % Load the .mat file
    if flag_data == 1
        predefined_name='AML'; % Call for AML on Fav conditions
        predefined_name2='Sim'; % Call for Sim on Simulation 
    elseif flag_data == 2
        predefined_name='AML'; % Call for AML on Fav conditions
        predefined_name2='Exp'; % Call for Exp on Experiment
    elseif flag_data == 3
        predefined_name='CML'; % Call for CML on Unfav conditions
        predefined_name2='Sim'; % Call for Sim on Simulation 
    elseif flag_data == 4
        predefined_name='CML'; % Call for CML on Unfav conditions
        predefined_name2='Exp'; % Call for Exp on Experiment
    end
%
if predefined_name=='AML'
    if predefined_name2 == 'Sim' 
        load(strcat(predefined_name2,'_sub_geo_',predefined_name,'.mat')); % Load Sim-AML geometry
        ap=0.95/2; % colloid radius in Favorable conditions simulations (µm) 
    elseif predefined_name2 == 'Exp'
        load(strcat(predefined_name2,'_sub_geo_',predefined_name,'.mat')); % Load Exp-AML geometry
        disp(['Select the ', predefined_name2,'_',predefined_name,'_trajectories file']); % select the file (Exp_AML) with trajectories 
        [fileTraj]  = uigetfile('*.xlsx', dir); % load the excel file (Exp_AML) 
        ap=1/2; % colloid radius in Favorable conditions experiments (µm)
    end
elseif predefined_name=='CML'
    if predefined_name2 == 'Sim'
        load(strcat(predefined_name2,'_sub_geo_',predefined_name,'.mat')); % Load Sim-CML geometry
        ap=0.95/2; % colloid radius in Unfavorable conditions simulations (µm) 
    elseif predefined_name2 == 'Exp'
        load(strcat(predefined_name2,'_sub_geo_',predefined_name,'.mat')); % Load CML-Exp geometry
        disp(['Select the ', predefined_name2,'_',predefined_name,'_trajectories file']); % select the file (Exp_CML) with trajectories 
        [fileTraj]  = uigetfile('*.xlsx', dir); % load the excel file (Exp_CML)
        ap=0.95/2; % colloid radius in Unfavorable conditions experiments (µm)
    end
end
%%
if predefined_name2=='Sim'
    % Read in New_Array3(1:ntrans_i(i),:,i), where rows (translations),
    % 4 columns (described below) for npart trajectories:
        % 1st column: x-coordinate (µm)
        % 2nd column: y-coordinate (µm)
        % 3rd column: time (s)
        % 4th column: sep. dist. to the nearest grain (µm)
        load(strcat(predefined_name2,'_New_Array3_File_',predefined_name,'.mat')); % Load AML or CML Sim data
elseif predefined_name2=='Exp' % For experiments read Excel for array lengths
    sheets = sheetnames(fileTraj); % get sheets names
    aux = size(sheets); % get sheets length
    npart = aux(1); % get number of trajectories
    for i=1:npart
        T = readtable(fileTraj,'Sheet',sheets(i)); % read the data of each sheet
        nrows = height(T); % number of translations 
        ntrans_i(i)=nrows; % number of translations
    end
end
%
% Preallocate colloid trajectories data with array length ntrans_i both Exp and Sim
    if predefined_name2=='Sim' 
        Trajs = NaN(max(ntrans_i),11,npart);  
    elseif predefined_name2=='Exp' 
        Trajs = NaN(max(ntrans_i)+10,11,npart);  
    end
    % Simulations -> array_data are declared in '200nm_Fav_Sim' or '200nm_Unfav_Sim'
    % Trajs columns:
        % 2nd column: x(um) -> (1) array_data 
        % 3rd column: y(um)-> (2) array_data 
        % 9th column: time (s) -> (3) array_data 
        % 11th column: sep. dist. to the nearest grain -> (4) array_data 
    % Experimental
    % Trajs columns:
        % 1st, 2nd and 3rd columns are: time step (frame), x(µm) and y(µm).
        % 4th column: sep. dist. to the nearest collector
        % 5th, 6th and 7th are: nearest pillar x(µm)-y(µm) center and radius (µm)
        % 8th: pillar index refered as the row in Csub
        % 9th column: time (s).
        % 10th column: inst. velocity.
% Preallocate vel., sep. dist. and norm vel. calculations
    if predefined_name2=='Sim' 
        Trajsadj = NaN(max(ntrans_i),5,npart);  
    elseif predefined_name2=='Exp' 
        Trajsadj = NaN(max(ntrans_i)+10,5,npart);    
    end
    % Simulations and Experimental
    % Trajsadj columns:
        % 1st column: adjusted minimum sep. dist. to equal zero
        % 2nd column: the velocity
        % 3rd column: normalized separation distance
        % 4th column: normalized velocity.
        % 5th column: sum of normalized distance and velocity
% Preallocate max, min and range values for sep. dist. and vel.
    % Separation distance
        Max_values_sep=NaN(1,npart); % prealocate array for maximum separation
        Min_values_sep=NaN(1,npart); % prealocate array for minimum separation
        Range_values_sep=NaN(1,npart); % prealocate array for separation range
    % Velocities and normalized velocities
        Max_values_vel=NaN(1,npart); % prealocate array for maximum velocities
        Min_values_vel=NaN(1,npart); % prealocate array for minimum velocities
        Range_values_vel=NaN(1,npart); % prealocate array for velocities range
        % velocities
        if predefined_name2=='Sim' 
            vel_norm=NaN(max(ntrans_i),npart); % prealocate array for normalized velocities
        elseif predefined_name2=='Exp' 
            vel_norm=NaN(max(ntrans_i)+10,npart); % prealocate array for normalized velocities
        end      
%
if predefined_name2=='Sim'
    for i=1:npart % trajectory loop
        for ic=1:ntrans_i(i) % translations loop
            % save to Trajs matrix
            Trajs(:,2,i) = New_Array3(:,1,i); % x-coodrinate (µm) from 200 nm simulations.
            Trajs(:,3,i) = New_Array3(:,2,i); % y-coordinate (µm) from 200 nm simulations.
            Trajs(:,9,i) = New_Array3(:,3,i); % cumulative time (s) from 200 nm simulations.
            Trajs(:,11,i) = New_Array3(:,4,i); % sep. dist. (µm) from 200 nm simulations.
        end % end translation loop
    end % end trajectory loop
%
% Load experimental data from spreadsheet
elseif predefined_name2=='Exp'
    for i=1:npart % trajectory loop
        T = readtable(fileTraj,'Sheet',sheets(i));
        colToExtract = [1, 4, 5]; % columns in T that contain time step (frame), x, y
        % save in array
        Trajs(1:ntrans_i(i),1:3,i)=T{1:ntrans_i(i),colToExtract}; % time step (frame), x, y 
        for ic=1:10
            Trajs(ntrans_i(i)+ic,1:3,i)=T{ntrans_i(i),colToExtract}; % repeat last row 10 times for attachment
        end
        ntrans_i(i)=ntrans_i(i)+10; % increase ntrans_i by 10 
        %
        % Time conversion from frame
        time_index= Trajs(1:ntrans_i(i), 1, i); % time step (frames)
        time_conver=0.064; % conversion factor (s/frame)
        time=time_index*time_conver; % time (s)
        Trajs(1:ntrans_i(i), 9, i) = time;  % Store time (s) in 9th column 
    end 
end
% evaluate all trajectory points to find minimum separation distance
npFOV = length(Csub); % npillars in FOV
for i=1:npart % trajectory loop
    for ic=1:ntrans_i(i) % translations loop
        % calculate distance to each collector and find the closest
        % collector to the location of the colloid at each time step.
        hmin = 100; % dummy hminimum value
        for r=1:npFOV
            x = Trajs(ic,2,i); % colloid x-coordinate
            y = Trajs(ic,3,i); % colloid y-coordinate
            xc = Csub(r,1); % collector x-coordinate
            yc = Csub(r,2); % collector y-coordinate
            rc = Csub(r,3); % collector radius
            h = (((xc-x)*(xc-x)+(yc-y)*(yc-y))^0.5)-rc-ap; % colloid-collector distance
            if h<hmin
                hmin = h; % minimum separation distance to nearest grain
                xcmin = xc; % nearest collector x-coordinate (µm)
                ycmin = yc; % nearest collector y-coordinate (µm)
                rcmin = rc; % nearest collector radius (µm)
                icmin = r; % nearest collector index (µm)
            end
        end
        % save to Trajs matrix the sep. dist. to the closest grain
        Trajs(ic,4,i) = hmin; % minimum separation distance to nearest grain
        Trajs(ic,5,i) = xcmin; % nearest collector x-coordinate (µm)
        Trajs(ic,6,i) = ycmin; % nearest collector y-coordinate (µm)
        Trajs(ic,7,i) = rcmin; % nearest collector radius (µm)
        Trajs(ic,8,i) = icmin; % nearest collector index (µm)
    end
end
%
% Calculate velocity for each particle and store in the matrix
for i=1:npart % trajectory loop
    % Extract x-y colloid coordinates 
        x = Trajs(1:ntrans_i(i), 2, i); % x-coordinate (µm)
        y = Trajs(1:ntrans_i(i), 3, i); % y-coordinate (µm)
    % Delta calculation between translations
    for ic = 1:ntrans_i(i)-1 
        delta_t = Trajs(ic+1,9,i) - Trajs(ic,9,i);
        delta_x = x(ic+1) - x(ic);
        delta_y = y(ic+1) - y(ic);
        if delta_t> 0
            vel = sqrt(delta_x*delta_x + delta_y*delta_y) / delta_t;
            Trajs(ic, 10, i) = vel; %store velocity in the 10th column
        else
            Trajs(ic, 10, i) = 0; % Handle cases where delta_t is 0 or negative
        end
    end
         % Adjust separation distance to the minimum value
         % Find min of separation distance
        Min_values_sep (i)= min(Trajs(:,4,i)); % minimum value
            % Add the min to the separation distance if it's negative
            if Min_values_sep(i) < 0 % adjusting sep. dists. with negative minimum values               
               Trajsadj(:, 1, i) = Trajs(:, 4, i) - Min_values_sep(i); % 1st column adjusted sep. dist. to minimum zero.
            elseif Min_values_sep(i) > 0 % adjusting sep. dists. with positive minimum values               
               Trajsadj(:, 1, i) = Trajs(:, 4, i) - Min_values_sep(i); % 1st column adjusted sep. dist. to minimum zero.
            else % adjusting sep. dists. with values that equal zero             
               Trajsadj(:, 1, i) = Trajs(:, 4, i); % retain sep. dists. with minimum values equal to zero.
            end
        Min_values_sep (i)= min(Trajsadj(:,1,i)); % sep. dist. minimum value
        Max_values_sep (i) =max(Trajsadj(:,1,i)); % sep. dist. maximum value
        Range_values_sep (i) = Max_values_sep(i) - Min_values_sep(i); % range sep. distance       
        %
        % Adjust velocity to the minimum value
        Trajsadj(:,2,i) = Trajs(:, 10, i); % velocity (µm/s)
        Min_values_vel (i)= min(Trajsadj(:,2,i)); % velocity minimum value
        % Add the min to the velocity if it's negative
            if Min_values_vel(i) < 0 % adjusting velocities with negative minimum values               
               Trajsadj(:, 2, i) = Trajsadj(:, 2, i) - Min_values_vel(i); % 1st column adjusted velocities to minimum zero.
            elseif Min_values_vel(i) > 0 % adjusting velocities with positive minimum values               
               Trajsadj(:, 2, i) = Trajsadj(:, 2, i) - Min_values_vel(i); % 1st column adjusted velocities to minimum zero.
            else % adjusting velocities with values that equal zero             
               Trajsadj(:, 2, i) = Trajsadj(:, 2, i); % retain velocities with minimum values equal to zero.
            end
        % Find max and min of velocity
        Min_values_vel(i)= min(Trajsadj(:,2,i)); % minimum value
        Max_values_vel (i)= max(Trajsadj(:,2,i)); % maximum value
        Range_values_vel (i)= Max_values_vel(i) - Min_values_vel(i); % range velocity        

        % Normalization
            Trajsadj(:,3,i) = Trajsadj(:, 1, i)./Range_values_sep(i); % adjusted separation distance normalized
            Trajsadj(:,4,i) = Trajsadj(:, 2, i)./Range_values_vel(i); % adjusted velocity normalized
end
% Comparison between sep. distance from simulations and calculated
if predefined_name2 == 'Sim'
    for i=1:npart
        for ic=1:ntrans_i(i)
            diff(ic,i) = (Trajs(ic,11,i) - Trajs(ic,4,i));
        end
    end
end
%%
% Save workspace
save(strcat(predefined_name2,'-SepDist_Velocity-all-complete-',predefined_name,'.mat'))
%