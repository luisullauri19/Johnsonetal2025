% This script uses the matrix Trajs from a3_c_sepdist_vel.m to produce the matrix intercept
clc; clear; close all;
filePath = matlab.desktop.editor.getActiveFilename;
% change path to locate data directory
dir = strrep(filePath,"\a4_intercepts.m",'\');
disp(filePath)
disp(dir)
%
% Call for AML or CML depending on Fav or Unfav conditions, respectively.
% Call for Sim or Exp depending on Simulation or Experiment, respectively.
flag_data=4; % choose the type of data to load 
    % 1 for loading AML (Favorable) from simulations
    % 2 for loading AML (Favorable) from experiments
    % 3 for loading CML (Unfavorable) from simulations
    % 4 for loading CML (Unfavorable) from experiments
%
% Load the .mat file based on flag_data
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
% Load the .mat file created in a3_c_sepdist_vel
    load(strcat(predefined_name2,'-SepDist_Velocity-all-complete-',predefined_name,'.mat')); % load(strcat(dir,predefined_name2,'-SepDist_Velocity-complete-',predefined_name,'.mat'))
    plot_traj_flag = 1; % flag to plot pillars and trajectories
    traj_data_flag = 1; % flag to calculate sep. dis. and norm. vel. data
%
% Set criteria for experiments (j=1) and simulations (j=1 & j=2)
if predefined_name2=='Exp'; % Call for Exp on Experiment
    % When j = 1, interceptions identified by velocity threshold criterion
        sep_criterion(1) = 7; %dist_resolution; % use all separation distances < dist_resolution 
        thresh(1) = 0.015; % discriminate via this norm. vel. threshold criterion (-)
elseif predefined_name2=='Sim'; % Call for Exp on Experiment
    % When j = 1, interceptions identified by sep. distance criterion 
        sep_criterion(1) = 0.1; % discriminate via this separation distance (µm)
        thresh(1) = 1; % no discrimination on norm. vel. 
    % When j = 2, interceptions identified by velocity threshold criterion
        sep_criterion(2) = 7; %dist_resolution; % use all separation distances < dist_resolution 
        thresh(2) = 0.020; % discriminate via this norm. vel. threshold criterion (-)
end
% Preallocate matrix that save values from Trajs
    x=NaN(max(ntrans_i),npart); % x-coordinate
    y=NaN(max(ntrans_i),npart); % y-coordinate
    time_plot=NaN(max(ntrans_i),npart); % time
    vel_norm=NaN(max(ntrans_i),npart); % normalized velocity
    sep_dist_abs=NaN(max(ntrans_i),npart); % absolute separation distance
    int_diff = NaN(1,npart); % interception difference by 2 criteria (Simulation only)
    intercept= NaN(max(ntrans_i),7,npart,2); % array to record according to each column
        % intercept column 1 records x-value
        % intercept column 2 records elapsed time 
        % intercept column 3 records interception order
        % intercept column 4 records y-value
        % intercept column 5 records norm. vel. 
        % intercept column 6 records sep. dist. 
        % inteception indicator = 1 in NS and = 0 in bulk
%
% Define the limit for j loop (j=1 in Exp and j=2 in Sim)
    if predefined_name2 == 'Sim'
        j_end=2;
    elseif predefined_name2 == 'Exp'
        j_end=1;
    end
%
% Identify colloids sep_dist_abs > sep_criterion(1) from pillar
% Initialization of number of interceptions
for i = 1:npart
    if predefined_name2=='Sim'; 
        numint(1:2,i) = 0; % last sep. dist. < 100 nm
    end
    if predefined_name2=='Exp'; 
        if Trajs(ntrans_i(i), 4, i) > sep_criterion(1)
            numint(1:2,i) = NaN; % last sep. dist. > 7 µm
        else
            numint(1:2,i) = 0; % last sep. dist. < 7 µm
        end
    end
end
%
for j=1:j_end % Discrimination loop. j=1 discriminates on separation distance, j=2 discriminates on norm. velocity
    % Simulations
        % When j=1, norm. vel. thresh=1 (no discrim. via norm. vel.), sep. dist. < 100 nm used to discriminate 
        % When j=2, sep. dist. criterion < 7 µm, norm. vel. thresh used to discriminate.
    % Experiments
        % When j=1, sep. dist. criterion < 7 µm, norm. vel. thresh used to discriminate.
    %
    for i = 1:npart % particle trajectory loop 
        tol_dist = min(Csub(:,3)); % minimum radius of collectors
        % Extract data for each particle trajectory (i)
            x(1:ntrans_i(i), i) = Trajs(1:ntrans_i(i), 2, i); % colloid x-coord in Col. 2 in Trajs
            y(1:ntrans_i(i), i) = Trajs(1:ntrans_i(i), 3, i); % colloid y-coord in Col. 3 in Trajs
            sep_dist_abs(1:ntrans_i(i), i) = Trajs(1:ntrans_i(i), 4, i); % sep. dist. in Col. 4 in Trajs
            Collector = Trajs(1:ntrans_i(i), 5:7, i); % collector x-y coord in Col. 5-6 in Trajs, and radius in Col. 7 in Trajs
            time_plot(1:ntrans_i(i),i)= Trajs(1:ntrans_i(i),9,i); % elapsed time in Col. 9 in Trajs
            vel_norm(1:ntrans_i(i),i)=Trajsadj(1:ntrans_i(i), 4, i); % normalized velocity in Col. 4 in Trajsadj
        % Set counters to condense array within NS and bulk fluid domain for each particle trajectory
            int_NS_count=1; % initialize counter for NS
            int_bulk_count=1; % initialize counter for bulk
        %
        if Trajs(ntrans_i(i), 4, i) <= sep_criterion(1) % required attachment separation distance < 100 nm (Sim), 7 µm (Exp)
            for ic=ntrans_i(i):-1:1 % backwards (from attachment location to entry to the FOV)
                if sep_dist_abs(ic,i) < sep_criterion(j) && vel_norm(ic,i) < thresh(j) % enter if sep. dist. and norm. vel. critera met  
                    if numint(j,i)==0 % check whether still has 0 interception (from initialization)
                        numint(j,i)=1; % record for 1st interception (backwards)
                        k=numint(j,i); % record numint as a scalar
                        Coll_xy0 = Collector(ic, 1:2); % Assign initial (attached) collector xy
                        Coll_xy0_r = Collector(ic,3); % Assign initial collector r
                        Coll_x_int(i,j,k)=Collector(ic,1); % save Collector x-coordinate at 1st interception
                        Coll_y_int(i,j,k)=Collector(ic,2); % save Collector y-coordinate at 1st interception
                        Coll_r_int(i,j,k)=Collector(ic,3); % save Collector radius at 1st interception
                        idx_end(i,j,k)=ic;
                    end
                    % Record all values in NS and bulk in intercept, 
                    % just intercept(ic,7,i,j) == 1 within NS
                        intercept(ic,1,i,j) = x(ic,i); % intercept column 1 records x-value
                        intercept(ic,2,i,j) = time_plot(ic,i); % intercept column 2 records elapsed time 
                        intercept(ic,3,i,j) = numint(j,i); % intercept column 3 records interception order
                        intercept(ic,4,i,j) = y(ic,i); % intercept column 4 records y-value
                        intercept(ic,5,i,j) = vel_norm(ic,i); % intercept column 5 records norm. vel. 
                        intercept(ic,6,i,j) = sep_dist_abs(ic,i); % intercept column 6 records sep. dist. 
                        intercept(ic,7,i,j) = 1; % inteception indicator = 1 in NS
                    % Record only for NS for the current particle trajectory loop (i)
                        intercept_NS(int_NS_count,1) = x(ic,i); % intercept column 1 records x-value
                        intercept_NS(int_NS_count,2) = time_plot(ic,i); % intercept column 2 records elapsed time 
                        intercept_NS(int_NS_count,3) = numint(j,i); % intercept column 3 records interception order
                        intercept_NS(int_NS_count,4) = y(ic,i); % intercept column 4 records y-value
                        intercept_NS(int_NS_count,5) = vel_norm(ic,i); % intercept column 5 records norm. vel. 
                        intercept_NS(int_NS_count,6) = sep_dist_abs(ic,i); % intercept column 6 records sep. dist. 
                        intercept_NS(int_NS_count,7) = 1; % inteception indicator = 1 in NS
                        intercept_NS(int_NS_count,8) = ic; % record ic for connection to intercept
                        if k==1 % when interception order equals 1
                            % check if the latest translation for k==1 occurs in the same collector
                            if intercept(idx_end(i,j,k),1,i,j)-intercept(ic,1,i,j)<2*Coll_r_int(i,j,k)
                                int_NS_count=int_NS_count+1; % counter for NS array
                            end
                        else % for k>=2
                            int_NS_count=int_NS_count+1; % counter for NS array
                        end
                    % Identifying a new interception
                    Coll_xy1 = Collector(ic,1:2); % Assign current collector xy
                    Coll_xy1_r = Collector(ic,3); % Assign current collector r
                    Coll_dist = sqrt((Coll_xy1(1) - Coll_xy0(1))^2 + (Coll_xy1(2) - Coll_xy0(2))^2); % distance between current and first collector
                    Coll_sep_dist=Coll_dist-Coll_xy1_r- Coll_xy0_r;
                    if Coll_dist > tol_dist % check for new collector (new interception)
                        passed_count=0; % initialize counter for a minimum of translations required to be considered a real interception
                        for ii=ic:-1:max(ic-9, 1) % 3 consecutive translations out of 9 translations
                            if sep_dist_abs(ii,i) < sep_criterion(j) && vel_norm(ii,i) < thresh(j)% check if next translation meets criteria
                                passed_count=passed_count+1; 
                            end
                        end
                        %
                        % Conditional for 3 or more consecutive translation is considered as a new interception
                        if passed_count > 2 
                                if Coll_sep_dist > 2 * sep_criterion(1)  % Avoid oscillating collectors when sep. dist. <= 7 µm in experiments
                                    numint(j,i) = numint(j,i) + 1;  % Update number of interceptions
                                    intercept(ic,3,i,j) = numint(j,i);  % Update interception order
                                    if numint(j,i) == 2
                                        intercept_NS(int_NS_count,3) = numint(j,i);  % Update interception order
                                    else
                                        intercept_NS(int_NS_count-1,3) = numint(j,i);  % Update interception order
                                    end
                                    Coll_xy0 = Coll_xy1; % exchanging current for previous
                                    % Collector coordinates and radius for interceptions > 1
                                        k=numint(j,i); % record numint as a scalar
                                        Coll_x_int(i,j,k)=Collector(ic,1); % save Collector x-coordinate at "n" interceptions
                                        Coll_y_int(i,j,k)=Collector(ic,2); % save Collector y-coordinate at "n" interceptions
                                        Coll_r_int(i,j,k)=Collector(ic,3); % save Collector radius at "n" interceptions
                                        x_int_maximum_x(i,j,k)=intercept(ic,1); % save the maximum x-coordinate at "n" interceptions 
                                        x_int_maximum_t(i,j,k)=intercept(ic,2); % save the maximum time at "n" interceptions 
                                        y_int_order(i,j,k)=k; % save interception order at "n" interceptions
                                        idx_end(i,j,k)=ic;
                                end
                        else % if passed_count <= 2 it is not considered as a new interception. 
                                % Transfer pre-saved intercept_NS values to intercept_bulk before overwriting
                                    % Remove last stored intercept_NS entry
                                        intercept_NS(int_NS_count-1, :) = [];
                                        int_NS_count = int_NS_count - 1;  % Decrement count
                                    % Store new values in intercept_bulk instead of the NS
                                        intercept_bulk(int_bulk_count,1) = x(ic,i);  % x-value
                                        intercept_bulk(int_bulk_count,2) = time_plot(ic,i);  % Elapsed time
                                        intercept_bulk(int_bulk_count,3) = numint(j,i);  % Interception order
                                        intercept_bulk(int_bulk_count,4) = y(ic,i);  % y-value
                                        intercept_bulk(int_bulk_count,5) = vel_norm(ic,i);  % Normalized velocity
                                        intercept_bulk(int_bulk_count,6) = sep_dist_abs(ic,i);  % Separation distance
                                        intercept(ic,7,i,j) = 0;  % Update interception indicator
                                        intercept_bulk(int_bulk_count,7) = 0;  % Mark as bulk interception
                                        int_bulk_count = int_bulk_count + 1;
                        end
                    end % end if Coll_dist>tol_dist
                else % not interception, it's on the bulk fluid domain
                    intercept(ic,1,i,j) = x(ic,i); % intercept column 1 records x-value
                    intercept(ic,2,i,j) = time_plot(ic,i); % intercept column 2 records elapsed time 
                    intercept(ic,3,i,j) = numint(j,i); % intercept column 3 records interception order
                    intercept(ic,4,i,j) = y(ic,i); % intercept column 4 records y-value
                    intercept(ic,5,i,j) = vel_norm(ic,i); % intercept column 5 records norm. vel. 
                    intercept(ic,6,i,j) = sep_dist_abs(ic,i); % intercept column 6 records sep. dist.                         
                    intercept(ic,7,i,j) = 0; % inteception indicator =0 in bulk
                    % Record only bulk values
                    intercept_bulk(int_bulk_count,1) = x(ic,i); % intercept column 1 records x-value
                    intercept_bulk(int_bulk_count,2) = time_plot(ic,i); % intercept column 2 records elapsed time 
                    intercept_bulk(int_bulk_count,3) = numint(j,i); % intercept column 3 records interception order
                    intercept_bulk(int_bulk_count,4) = y(ic,i); % intercept column 4 records y-value
                    intercept_bulk(int_bulk_count,5) = vel_norm(ic,i); % intercept column 5 records norm. vel. 
                    intercept_bulk(int_bulk_count,6) = sep_dist_abs(ic,i); % intercept column 6 records sep. dist.                         
                    intercept_bulk(int_bulk_count,7) = 0; % inteception indicator =0 in bulk
                    intercept_bulk(int_bulk_count,8) = ic; % record ic for connection to intercept
                    int_bulk_count=int_bulk_count+1; % counter for bulk array 
                    % 
                end % if for separation distance criterion end % if for normalized velocity
            end % end of ic (translations) loop
            %
            % Records maximum (first translation within NS going backwards)
            % Records maximum (last translation within NS going backwards)
            for ic=1:int_NS_count-1 % (-1) the counter is counting +1 when it exits the previous ic loop
                %
                if ic == 1 % 1st interception 
                x_int_maximum_x(i,j,1)=intercept_NS(ic,1); % save the maximum x-coordinate at 1st interception 
                y_int_order(i,j,1)=1; % save interception order at 1st interception
                x_int_maximum_t(i,j,1)=intercept_NS(ic,2); % trans_count
                end
                %
                if ic==int_NS_count-1 % ic equals intercept_NS length for last interception 
                    k_min=intercept_NS(ic,3);
                    x_int_minimum_x(i,j,k_min)=intercept_NS(ic-1,1);
                    x_int_minimum_t(i,j,k_min)=intercept_NS(ic-1,2);
                elseif isnan(intercept_NS(ic,8))  % ic equals NaN after last translation 
                    k_min=intercept_NS(ic-1,3);
                    x_int_minimum_x(i,j,k_min)=intercept_NS(ic-1,1);
                    x_int_minimum_t(i,j,k_min)=intercept_NS(ic-1,2);
                elseif intercept_NS(ic,3)<intercept_NS(ic+1,3)&& ic<int_NS_count-1  % check for increased interception order if not at end of file
                    k_min=intercept_NS(ic,3);
                    x_int_minimum_x(i,j,k_min)=intercept_NS(ic,1);
                    x_int_minimum_t(i,j,k_min)=intercept_NS(ic,2);
                    %
                    k_max=intercept_NS(ic+1,3);
                    x_int_maximum_x(i,j,k_max)=intercept_NS(ic+1,1);
                    x_int_maximum_t(i,j,k_max)=intercept_NS(ic+1,2);
                end % intercept_NS(ic,3)<intercept_NS(ic+1,3)
            end % ic equals intercept_NS length for last interception
        end % end for conditional that filter trajectories with sep. dist > 7µm, sep_criterion -> numint(j,i)=NaN  
        %
        % Overwrite with NaNs the interception array for colloids with attached sep. dist > sep_criterion(1) from pillar
        if predefined_name2=='Exp';
            if Trajs(ntrans_i(i), 4, i) > sep_criterion(1) % attached sep. dist. > 7 µm
                for ii=1:6
                    intercept(1:ntrans_i(i),ii,i,j) = NaN; % NaN populates for attached sep. dist. > 7 µm
                end
            end
        end
        %
        % Resets the arrays intercept_NS and intercept_bulk to NaN
        % Resets intercept_NS
        % to avoid trajectory loop filled with NaN (sep. dist. > 7 µm)
            if exist('intercept_NS', 'var') && ~isempty(intercept_NS)
                intercept_NS = NaN(length(intercept_NS), 8);
            end
        % Resets intercept_bulk
        % to avoid trajectory loop filled with NaN (sep. dist. > 7 µm)
            if exist('intercept_bulk', 'var') && ~isempty(intercept_bulk)
                intercept_bulk = NaN(length(intercept_bulk), 8);
            end
        %
    end % i loop ends for particle trajectory loop
end % j=1:j_end. Discrimination loop ends
%
% Preallocate number of translations for each interception
for j=1:j_end
    for i=1:npart
        for k=1:max(max(numint))
            ntrans_int=zeros(i,j,k); 
        end
    end
end
% Preallocation for _int (NS arrays)
    ntrans3=max(max(ntrans_i)); % single maximum translations value for all trajectories
    x_int = NaN(ntrans3,npart,1); % preallocate x-distance for interception
    time_int = NaN(ntrans3,npart,1); % preallocate time for interception
    y_int = NaN(ntrans3,npart,1); % preallocate y-distance for interception
    velnorm_int = NaN(ntrans3,npart,1); % preallocate vel. norm. for interception
    sepdist_int = NaN(ntrans3,npart,1);% preallocate sep. dist. for interception
    int_order = NaN(ntrans3,npart,1);% preallocate the interception order   
% Preallocation for _bulk (Bulk arrays)
    x_bulk = NaN(ntrans3,npart,1); % preallocate x-distance for bulk
    time_bulk = NaN(ntrans3,npart,1); % preallocate time for bulk
    y_bulk = NaN(ntrans3,npart,1); % preallocate y-distance for bulk
    velnorm_bulk = NaN(ntrans3,npart,1); % preallocate vel. norm. for bulk
    sepdist_bulk = NaN(ntrans3,npart,1);% preallocate sep. dist. for interception
%
% Interception only (NS) arrays 
for j=1:j_end % loop for discrimination criteria
    for i=1:npart % loop for particle trajectory
        for ic=ntrans_i(i):-1:1 % loop for translations
            if intercept(ic,7,i,j) == 1 % Conditional for arrays with interceptions and attachment
                x_int(ic,i,j) = intercept(ic,1,i,j); % intercept column 1 records x-value
                time_int(ic,i,j) = intercept(ic,2,i,j); % intercept column 2 records elapsed time 
                int_order(ic,i,j) = intercept(ic,3,i,j); % intercept column 3 records interception order
                y_int(ic,i,j) = intercept(ic,4,i,j); % intercept column 4 records y-value
                velnorm_int(ic,i,j) = intercept(ic,5,i,j); % intercept column 5 records norm. vel. 
                sepdist_int(ic,i,j) = intercept(ic,6,i,j); % intercept column 6 records sep. dist.
                for k=int_order(ic,i,j):-1:1
                    if int_order(ic,i,j) == k 
                        ntrans_int(i,j,k) = ntrans_int(i,j,k)+1; % count of number of translations for each interception
                    end
                end
            elseif intercept(ic,7,i,j) == 0 % Conditional for arrays in bulk fluid domain
                x_bulk(ic,i,j) = intercept(ic,1,i,j); % intercept column 1 records x-value in bulk
                time_bulk(ic,i,j) = intercept(ic,2,i,j); % intercept column 2 records elapsed time in bulk 
                int_order(ic,i,j) = intercept(ic,3,i,j); % intercept column 3 records interception order in bulk
                y_bulk(ic,i,j) = intercept(ic,4,i,j); % intercept column 4 records y-value in bulk 
                velnorm_bulk(ic,i,j) = intercept(ic,5,i,j); % intercept column 5 records norm. vel. in bulk 
                sepdist_bulk(ic,i,j) = intercept(ic,6,i,j); % intercept column 6 records sep. dist. in bulk 
            end
        end % ends ic loop non-interceptions (bulk) and interceptions (NS) arrays
    end % ends i loop non-interceptions (bulk) and interceptions (NS) arrays 
end % end j loop for non-interceptions (bulk) and interceptions (NS) arrays 
%
if predefined_name2=='Sim' % interception count difference respect to sep. dist. criterion (100 nm)
    for i=1:npart
        int_diff(i)=numint(2,i)'-numint(1,i)'; % neg. diff. = undercount by norm. vel.; pos. diff. = overcount by norm. vel. 
    end
end
%
% max x-distance for each trajectory
for j=1:j_end
    for i=1:npart
        if numint(j,i)>0
            for k=1:numint(j,i)
                x_int_max_sep(i,j,k)=max(intercept(:,1,i,j)); % max x-distance for each particle (row) 
                                                              % for j=1,2 (left,right columns)
                                                              % for k=# intercept (blocks)
                y_int_max_sep(i,j,k)=max(intercept(:,4,i,j)); % max x-distance for each particle (row)
                time_plot_max(i,j,k)=max(intercept(:,2,i,j));% max time for each particle (row) 
                                                              % for j=1,2 (left,right columns)
                                                              % for k=# intercept (blocks)   
            end
        end
    end
end
% 
% average separation distance between the x_int_max_x and x_int_min_x
for j=1:j_end
    for i=1:npart
        if ~isnan(numint(j,i))
            for k=1:numint(j,i)
                x_int_mean_sep(i,j,k)=mean([x_int_minimum_x(i,j,k) x_int_maximum_x(i,j,k)]); % mean x-distance for each particle (row) 
                                                              % for j=1,2 (left,right columns)
                                                              % for k=# intercept (blocks)
            end
        end
    end
end 
%
% Save elapsed distance and times within the NS for each intercepted collector
for j=1:j_end
    for i=1:npart
        if ~isnan(numint(j,i))
            for k=1:numint(j,i)
                elapsed_dist(i,j,k)=x_int_maximum_x(i,j,k)-x_int_minimum_x(i,j,k) ;
                dist_warning=elapsed_dist(i,j,k)-2*Coll_r_int(i,j,k);
                if dist_warning > 2*sep_criterion(j) 
                    disp('warning elapsed distance in interception exceeds collector diameter by:')
                    disp(dist_warning);
                end
                elapsed_time(i,j,k)=x_int_maximum_t(i,j,k)-x_int_minimum_t(i,j,k) ;
            end
        end
    end
end 
%%
% Save files 
for j=1:j_end
    %
    if predefined_name2=='Sim'
        if j==1
        % Save data - Construct file name for j = 1
            file_name = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete',predefined_name2, predefined_name, sep_criterion(j), thresh(j));
        elseif j==2
        % Save data - Construct file name for j = 2
            file_name = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete',predefined_name2, predefined_name, sep_criterion(j), thresh(j));
        end
    elseif predefined_name2=='Exp'
        file_name = sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete',predefined_name2, predefined_name, sep_criterion(j), thresh(j));
    end
    % Save the workspace with the dynamically constructed file name
    save(strcat(file_name, '.mat'));
end