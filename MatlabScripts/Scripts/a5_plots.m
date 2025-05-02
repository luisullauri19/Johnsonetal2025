% Script for plotting
clc; clear; close all;
filePath = matlab.desktop.editor.getActiveFilename; %get script  path
% change path to locate data directory
dir = strrep(filePath,"\a5_plots.m",'\');
disp(filePath)
disp(dir)
% Call for AML or CML depending on Fav or Unfav conditions, respectively.
% Call for Sim or Exp depending on Simulation or Experiment, respectively.
flag_data=3; % choose the type of data to load 
    % 1 for loading AML (Favorable) from simulations
    % 2 for loading AML (Favorable) from experiments
    % 3 for loading CML (Unfavorable) from simulations
    % 4 for loading CML (Unfavorable) from experiments
%
% Plots to display, flag_plot = 1 to display or = 0 to do not display
flag_plot_1 = 0; % figure (1)% trajectory (1), vel nom. (2) and sep dist. (3) vs x-distance (µm)
flag_plot_2 = 0; % figure (2) % Colloid trajectory (1), vel_norm/sep_dist vs distance (2), vel_norm/sep_dist vs time (3)
flag_plot_3 = 1; % figure(3) % Translation number (1), Interception order (2) vs mean x-distance (µm)
%
% Trajectories to be plotted, select the trajectory. Check the total number of trajectories by using disp(npart) in the command window
% For figure (1) (flag_plot_1=1), there should be a single trajectory (ini_traj=end_traj)
% For figure (2) (flag_plot_2=1), there can be multiple trajectories (ini_traj<end_traj)
% For figure (3) (flag_plot_3=1), there can be multiple trajectories (ini_traj<end_traj)
    ini_traj=1; % Assign value of first trajectory to be analyzed
    end_traj=31; % Assign value of last trajectory to be analyzed
%
% Set criteria to be analyzed in Figure (1)
    % Set 1 for Sim (sep. dist=100nm) or Exp (sep. dist=7µm). Set 2 for Sim (sep. dist=7µm)
        j_sep_crit_idx=1; % select 1 or 2
    % Set 1,2,3 norm. vel. thresh. [0.015 0.020 0.025] for Sim and Exp (sep. dist=7µm). Set 1 norm. vel. thresh. of 1 for Sim (sep. dist=100nm)
        j_thresh_idx=2;  % select 1, 2 or 3
%
% Load the .mat file based on flag_data (check line 10)
    if flag_data == 1
        predefined_name='AML'; % Call for AML on Fav conditions
        predefined_name2='Sim'; % Call for Sim on Simulation 
        j_end=2;
    elseif flag_data == 2
        predefined_name='AML'; % Call for AML on Fav conditions
        predefined_name2='Exp'; % Call for Exp on Experiment
        j_end=1;
    elseif flag_data == 3
        predefined_name='CML'; % Call for CML on Unfav conditions
        predefined_name2='Sim'; % Call for Sim on Simulation 
        j_end=2;
    elseif flag_data == 4
        predefined_name='CML'; % Call for CML on Unfav conditions
        predefined_name2='Exp'; % Call for Exp on Experiment
        j_end=1;
    end
% 
% Set criteria for 
if predefined_name2=='Sim'
    if j==1 % When j = 1, interceptions identified by sep. distance criterion 
        sep_criterion(1) = 0.1; % discriminate via this separation distance (µm)
        thresh_check = 1;
    else % When j = 2, interceptions identified by velocity threshold criterion
        sep_criterion(2) = 7; %dist_resolution; % use all separation distances < dist_resolution 
        thresh_check =[0.015 0.02 0.025]; % Normalized velocity thresholds for AML and CML
    end
elseif predefined_name2=='Exp'
    % When j = 1, interceptions identified by velocity threshold criterion
    thresh_check = [0.015 0.02 0.025]; % discriminate via this norm. vel. threshold criterion (-)
    % Normalized velocity thresholds to be evaluated
    sep_criterion(1) = 7; %dist_resolution; % use all separation distances < dist_resolution 
end
%
% Font sizes for plots
number_size=20;
    fontsize_x_axis_title=number_size; % x_axis title
    fontsize_axis_number=number_size; % x_axis number
    fontsize_legend_figure=number_size; % legend at the top of the figure
    fontsize_y_axis_title=number_size; % y_axis title
    fonsize_symbol=number_size; % symbol size
%
% Generate a sequence of colors for plotting figure (2) and figure (3)
    % Load a file to load npart from the loaded file
        color_file = string(sprintf('%s-SepDist_Velocity-complete-%s.mat', predefined_name2, predefined_name));
        file_contents = load(color_file, 'npart'); % Load only the 'npart' variable
        nColors = file_contents.npart; % Extract the value of npart
    % Define the desired hues for the transition
        if predefined_name == 'AML'    
            hue_sequence = [0, 0.67, 0.67, 0.08, 0.75, 0.13, 0.83, 0.15, 0.5, 0.27, 0.92, 0.3, 0.58]; % Red, Blue, Orange, Indigo, Gold, Magenta, Yellow, Cyan, Lime, Pink, Green, Turquoise
        elseif predefined_name =='CML'
            hue_sequence = [0, 0.58, 0.08, 0.67, 0.15, 0, 0.75, 0.27, 0.5, 0.83, 0.3, 0.13, 0.92]; % Red, Turquoise, Orange, Blue, Gold, Indigo, Lime, Cyan, Magenta, Green, Yellow, Pink
        end
    % Preallocate matrix for colors
        colors1 = zeros(nColors, 3);
    % Generate colors using the defined sequence
    for i = 1:nColors
        % Cycle through the hue_sequence
        hue = hue_sequence(mod(i - 1, length(hue_sequence)) + 1);
        saturation = 0.9; % Keep saturation high for vivid colors
        value = 0.8; % Keep value high for visibility
        if predefined_name == 'AML'    
            if i==14
                value = 0;
            elseif i==20
                value = 0;
            end
        elseif predefined_name == 'CML'    
            if i==17
                value = 0;
            elseif i==26
                value = 0.6;
            end
        end
        % Convert HSV to RGB
        colors1(i, :) = hsv2rgb([hue, saturation, value]);
    end
%
% Colloid trajectory (1), vel_norm/sep_dist vs distance (2), vel_norm/sep_dist vs time (3)
if flag_plot_1 ==1 % For simulations or experiments
n = 30; %set number of points for unit circle (use to represent pillars)
a =linspace(0,2*pi,n); % geneate a unit circle
xu = cos(a); % x-coordinates to plot a unit circle
yu = sin(a); % y-coordinates to plot a unit circle
for f=1:length(thresh_check(j_thresh_idx))
% Load files with defined sep. dist. (line 30) and norm. vel. criterion (line 32)
name(f) = string(sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete_subset',predefined_name2, predefined_name, sep_criterion(j_sep_crit_idx), thresh_check(j_thresh_idx)));
load(name(f)); % Load the files saved for each norm. vel. criterion
%
for i=ini_traj:end_traj
figure (1)% trajectory (1), vel nom. (2) and sep dist. (3) vs x-distance (µm)
   subplot (3,1,1); % colloid trajectory and collector interceptions
    for j=j_end:j_end
            hold on; % Allow adding more elements
            set(gca, 'Color', [0.9, 0.95, 1]); % Set the axes background to a light blue color
            % draw pillars
            for z=1:npFOV
                fill(xu*Csub(z,3)+Csub(z,1),yu*Csub(z,3)+Csub(z,2), [0.8, 0.8, 0.8], 'EdgeColor', 'none')
            end
            hold on
            for k=1:max(max(numint))
                scatter(x_bulk(:,i), y_bulk(:,i), 25, 'k', '.');
                hold on;
                scatter(x_int(:,i), y_int(:,i), 150, 'r', '.');
                hold on
                set(gca, 'XTickLabel', []);
                ylabel('Y (µm)', 'FontSize', fontsize_y_axis_title)
                xlim([0 5300])
                ylim([5500 6500])
                set(gca, 'FontSize', fontsize_axis_number); % Changes the font size of both X and Y axis numbers
                set(gca, 'TickDir', 'out'); % Change tick direction to outward
                set(gca, 'XColor', 'k', 'YColor', 'k'); % set axis color
                set(gca, 'FontName', 'Calibri'); % set font type
            end
    end
    subplot (3,1,2); % colloid trajectory and collector interceptions
    for j=1:j_end
            for k=1:max(max(numint))
                scatter(x_bulk(:,i), velnorm_bulk(:,i),'k','.','LineWidth',0.5);
                hold on;
                scatter(x_int(:,i), velnorm_int(:,i),'k','.','LineWidth',0.5); 
                hold on
                % xlabel('X (µm)')
                set(gca, 'XTickLabel', []);
                ylabel('Norm. Vel.', 'FontSize', fontsize_y_axis_title)
                xlim([0 5300])
            % Set only the minimum value
                currentYLim = get(gca, 'YLim'); % Get current Y-axis limits
                ylim([0.001, currentYLim(2)]); % Set minimum to 0, keep the current maximum
                set(gca, 'YScale', 'log');
                set(gca, 'YTick', [10^-3, 10^-2, 10^-1, 10^0]); % Show all ticks explicitly
                set(gca, 'FontSize', fontsize_axis_number); % Changes the font size of both X and Y axis numbers
                set(gca, 'TickDir', 'out'); % Change tick direction to outward
                set(gca, 'XColor', 'k', 'YColor', 'k'); % set axis color
                set(gca, 'FontName', 'Calibri'); % set font type
            end
    end
    subplot (3,1,3); % colloid trajectory and collector interceptions
    for j=1:j_end
            for k=1:max(max(numint))
                scatter(x_bulk(:,i), sepdist_bulk(:,i),'k','.','LineWidth',0.5);
                hold on;
                scatter(x_int(:,i), sepdist_int(:,i),'k','.','LineWidth',0.5); 
                hold on
                xlabel('X (µm)', 'FontSize', fontsize_x_axis_title)
                ylabel('Sep. dist. (µm)', 'FontSize', fontsize_y_axis_title)
                xlim([0 5300])
            % Set only the minimum value
                currentYLim = get(gca, 'YLim'); % Get current Y-axis limits
                ylim([0.001, currentYLim(2)]); % Set minimum to 0, keep the current maximum
                set(gca, 'YScale', 'log');
                set(gca, 'YTick', [10^-3, 10^-2, 10^-1, 10^0, 10^1, 10^2]); % Show all ticks explicitly
                set(gca, 'FontSize', fontsize_axis_number); % Changes the font size of both X and Y axis numbers
                set(gca, 'TickDir', 'out'); % Change tick direction to outward
                set(gca, 'XColor', 'k', 'YColor', 'k'); % set axis color
                set(gca, 'FontName', 'Calibri'); % set font type
            end
    end
    % Resize the subplots manually at the end
    h1 = subplot(3, 1, 1); % Select the first subplot
    set(h1, 'Position', [0.1, 0.75, 0.8, 0.2]); % Adjust position [x, y, width, height]
    h2 = subplot(3, 1, 2); % Select the second subplot
    set(h2, 'Position', [0.1, 0.45, 0.8, 0.25]); % Adjust position [x, y, width, height]
    h3 = subplot(3, 1, 3); % Select the third subplot
    set(h3, 'Position', [0.1, 0.15, 0.8, 0.25]); % Adjust position [x, y, width, height]
end
    % Save each figure with a unique name
        % saveas(gcf, strcat('Trajectory_', num2str(i), '-', predefined_name, '-sep_', num2str(sep_criterion(1)), 'µm-normvel_', num2str(thresh(1)), '.jpg'));
        % close(gcf); % Close the figure to free up memory
end % f=1:length(thresh_check(j_thresh_idx))
end % end flag_plot
%
%%
if predefined_name2 == 'Sim'
if flag_plot_2==1
for f=1:length(thresh_check)
name(f) = string(sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete_subset',predefined_name2, predefined_name, sep_criterion(j_sep_crit_idx), thresh_check(j_thresh_idx))); % name of files with different norm. vel. criterion
load(name(f)); % Load the files saved for each norm. vel. criterion
figure (2) % Colloid trajectory (1), vel_norm/sep_dist vs distance (2), vel_norm/sep_dist vs time (3)
    %
    subplot(2,1,1); % vs x-distance
    for j=1:j_end
        for i=1:npart
            if j==1
                plot(x_int(:,i,j), sepdist_int(:,i,j), 'o-','MarkerSize',fonsize_symbol, 'Color', colors1(i,:)); % circles for sep. dist. criterion
                hold on
            elseif j==2
                plot(x_int(:,i,j), velnorm_int(:,i,j), '^-','MarkerSize',fonsize_symbol, 'Color', colors1(i,:)); % triangles for norm. vel. criterion
                hold on
            end
            xlim([0 5500])
        end
    end
    set(gca, 'FontSize', fontsize_axis_number); % assign font to the number on the axis
    xlabel('x-distance (µm)','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
    %
    subplot(2,1,2); % vs time
    for j=1:j_end
        for i=1:npart
            if j==1
                plot(time_int(:,i,j), sepdist_int(:,i,j),'o-','MarkerSize',fonsize_symbol,'Color', colors1(i,:)); % circles for sep. dist. criterion
                hold on
            elseif j==2
                plot(time_int(:,i,j), velnorm_int(:,i,j),'^-','MarkerSize',fonsize_symbol,'Color', colors1(i,:)); % triangles for norm. vel. criterion
                hold on
            end
        end
    end
    set(gca, 'FontSize', fontsize_axis_number); % assign font to the number on the axis
    header1=sprintf('%.3f µm separation distance criterion', sep_criterion(1));
    header2=sprintf('%.3f norm. vel criterion', thresh(2));
    xlabel('time (s)','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
    % ylabel('norm. vel. (-) or sep. dist. (µm)','FontSize',fontsize_axis_title); % increases the fontsize of axis
    savefig(gcf, strcat('Fig1-',predefined_name,'sep_',num2str(sep_criterion(j_sep_crit_idx)),'µm-normvel_',num2str(thresh(j_thresh_idx)),'.fig'));
    % Add a single Y-axis label for the whole figure
    han = axes(gcf, 'visible', 'off'); % Create an invisible axis
    han.YLabel.Visible = 'on'; % Make only the Y-axis label visible
    ylabel(han, 'norm. vel. (-) or sep. dist. (\mum)','FontSize',fontsize_y_axis_title); % Add the unique Y-axis label
    % Offset the Y-axis label to the left
    han.YLabel.Position(1) = han.YLabel.Position(1); % Move it left by adjusting X position
    %
    % Create dummy plots for the legend
    hold on; % Ensure the plot remains active
    h1 = plot(NaN, NaN, 'o', 'MarkerSize', 10,'Color','k'); % Circle marker
    h2 = plot(NaN, NaN, '^', 'MarkerSize', 10,'Color','k'); % Triangle marker
    % Create legend text
    legend_text = {['= ', header1], ['= ', header2]};
    % Add the legend
    lgd = legend([h1, h2], legend_text, 'FontSize', fontsize_legend_figure);
    lgd.Orientation = 'horizontal';
    lgd.Position = [0.5, 0.95, 0.01, 0.01]; % [X, Y, width, height] in normalized coordinates
    hold off;
end
end
%
%%
if flag_plot_3==1
figure(3) % Translation number (1), Interception order (2), Interception difference (3) vs mean x-distance (µm)
%
% Definir posiciones personalizadas para los subplots
symbols = ['^', 'o','+','x','>','v','d']; % Symbols for each normalized velocity
symbols2 = {'-.^', '-.o','-.+','-.x','-.>','-.v','-.d'}; % Symbols and dotted lines for each normalized velocity
name = strings(1, length(thresh_check)); % Record names of the .mat files
legend_handles1 = zeros(1, length(thresh_check) + 1); % Initialize handles for legend
legend_name1 = strings(1, length(thresh_check) + 1); % Initialize names for legend entries
legend_handles2 = zeros(1, length(thresh_check)+1); % Initialize handles for legend
legend_name2 = strings(1, length(thresh_check)+1); % Initialize names for legend entries
%
% rearrange plotting arrays to place k in first position of each array and
% superimpose with :
    % When j = 1, interceptions identified by sep. distance criterion 
    sep_criterion(1) = 0.1; % discriminate via this separation distance (µm)
    % When j = 2, interceptions identified by velocity threshold criterion
    sep_criterion(2) = 7; %dist_resolution; % use all separation distances < dist_resolution 
for f=1:length(thresh_check)
    name(f) = string(sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete_subset',predefined_name2, predefined_name, sep_criterion(2), thresh_check(f))); % name of files with different norm. vel. criterion
    load(name(f)); % Load the files saved for each norm. vel. criterion
for j=1:j_end
    for i=1:npart
        for k=1:numint(j,i)
            x_int_mean_sep2(k,i,j) = x_int_mean_sep(i, j, k);
            inv_k = numint(j,i) - k + 1; % Inverted index
            ntrans_int2(k, i,j) = ntrans_int(i,j, k);
            y_int_order2(inv_k, i, j) = y_int_order(i, j, k);
        end
    end
end
%
y_int_order2(y_int_order2 == 0) = NaN;
%
    % Generate the name for the .mat file and load it
    name(f) = string(sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete_subset',predefined_name2, predefined_name, sep_criterion(2), thresh_check(f))); % name of files with different norm. vel. criterion
    load(name(f)); % Load the file dynamically
    for j = 1:j_end % j=1, separation criterion; j=2, norm. vel. criterion
        for i = 1:npart % Loop over the number of trajectories
            subplot (3,1,1) % Number of translations
            if j == 1 % Scatter for sep. dist. criterion
               plot(x_int_mean_sep2(:,i,j), ntrans_int2(:,i,j), '-.o','MarkerSize',5, 'Color', colors1(i, :),'MarkerFaceColor', colors1(i, :)); 
               hold on;
            elseif j == 2 % Scatter for norm. vel. criterion
               plot(x_int_mean_sep2(:,i,j), ntrans_int2(:,i,j), symbols2{f}, 'MarkerSize',(8+(1*f)),'Color', colors1(i, :));
               hold on;
            end
            set(gca, 'FontSize', fontsize_axis_number); % assign font to the number on the axis
            set(gca, 'FontName', 'Calibri');
            set(gca, 'Box', 'off');
            set(gca, 'TickDir', 'out'); 
            set(gca, 'XAxisLocation', 'bottom'); 
            set(gca, 'YAxisLocation', 'left'); 
            set(gca, 'XTickLabel', []); % delete the x-axis values for the 1st subplot 
            xlim([0 5500])
            ylim([1 2000])
            yticks([1 100 1000]);
            % xlabel('Interception x-distance (µm)','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            ylabel('# of translations','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            set(gca, 'YScale', 'log');
            hold on
            %
            subplot (3,1,2) % All interceptions for each npart
            if j == 1 % Scatter for sep. dist. criterion
                plot(x_int_mean_sep2(:,i,j), y_int_order2(:,i,j),'-.o','MarkerSize',5, 'Color', colors1(i, :),'MarkerFaceColor', colors1(i, :)); 
                hold on;
            elseif j == 2 % Scatter for norm. vel. criterion
                plot(x_int_mean_sep2(:,i,j), y_int_order2(:,i,j),symbols2{f}, 'MarkerSize',(8+(2*f)),'Color', colors1(i, :));
                hold on;
            end
            % set(gca, 'Position', [0.1, 0.4, 0.8, 0.25]); % adjust 2nd subplot position
            set(gca, 'FontSize', fontsize_axis_number); % assign font to the number on the axis
            set(gca, 'FontName', 'Calibri');
            set(gca, 'Box', 'off');
            set(gca, 'TickDir', 'out'); 
            set(gca, 'XAxisLocation', 'bottom'); 
            set(gca, 'YAxisLocation', 'left'); 
            xlim([0 5500])
            xlabel('Interception x-distance  (µm)','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            ylabel('Int. order','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            if predefined_name == 'AML'
                ylim([1 3])
                yticks(1:1:3); 
            elseif predefined_name == 'CML'
                ylim([1 5])
                yticks(1:1:5); 
            end
            hold on    
            %
            subplot (3,1,3) % Interception difference for each npart
            max_values = min(x_int_mean_sep,[],2); % get the max values of each column 
            max_values = squeeze(max(max_values, [], 3)); % get the max values of each block and delete extra dimensions
            scatter(max_values(i)',int_diff(i), (160-(20*f)), colors1(i, :), symbols(f));
            hold on;
            % set(gca, 'Position', [0.1, 0.1, 0.8, 0.25]); % adjust 3rd subplot position
            set(gca, 'FontSize', fontsize_axis_number); % assign font to the number on the axis
            set(gca, 'FontName', 'Calibri');
            xlim([0 5500])
            xlabel('Attachment x-distance (µm)','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            ylabel('Int. difference','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            if predefined_name == 'AML'
                ylim([-2 2])
                yticks(-2:1:2); 
            elseif predefined_name == 'CML'
                ylim([-2 2])
                yticks(-2:1:2); 
            end
            hold on
            set(gca, 'TickDir', 'out');
        end % end of npart (i loop)
    end % end of criterion (j loop)
% Add dummy scatter point for legend with the correct symbol and color
legend_handles1(f) = plot(NaN, NaN, symbols(f),'Markersize',10,'Color','k', 'LineWidth', 1.5); % Dummy scatter for legend
legend_name1(f) = sprintf('norm. vel.: %.3f', thresh_check(f)); % Legend entry for norm. vel.
% Add a legend entry for sep. dist.
    if predefined_name2=='Sim'
    sep_criterion(1)=0.1;
    final_leg=length(thresh_check)+1;
    legend_handles1(final_leg) = plot(NaN, NaN, 'o','Markersize',6,'Color','k','MarkerFaceColor', 'k'); % Dummy scatter for sep. dist.
    legend_name1(final_leg) = sprintf('sep. dist.: %.3f µm', sep_criterion(1)); % Legend entry for sep. dist.
    end
end
%
% Resize the subplots manually at the end
h1 = subplot(3, 1, 1); % Select the first subplot
set(h1, 'Position', [0.1, 0.65, 0.5, 0.25]); % Adjust position [x, y, width, height]
h2 = subplot(3, 1, 2); % Select the second subplot
set(h2, 'Position', [0.1, 0.40, 0.5, 0.20]); % Adjust position [x, y, width, height]
h3 = subplot(3, 1, 3); % Select the third subplot
set(h3, 'Position', [0.1, 0.12, 0.5, 0.15]); % Adjust position [x, y, width, height]
% Add legends to the plot
lgd = legend(legend_handles1, legend_name1, 'FontSize', fontsize_legend_figure);
lgd.Orientation = 'horizontal'; % legend orientation
lgd.Position = [0.4, 0.95, 0.01, 0.01]; % [X, Y, width, height] in normalized coordinates
legend_icons = findobj(lgd, 'Type', 'Patch'); % find legend elements
set(legend_icons, 'MarkerSize', 10); % adjust the markersize manually
end % end flag_plot
end % end simulation conditions
%%
%
if predefined_name2=='Exp'
if flag_plot_2==1
thresh_check=0.02;
for f=1:length(thresh_check)
name(f) = string(sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete_subset',predefined_name2, predefined_name, sep_criterion(1), thresh_check(f))); % name of files with different norm. vel. criterion
load(name(f)); % Load the files saved for each norm. vel. criterion
figure (2) % Colloid trajectory (1), vel_norm/sep_dist vs distance (2), vel_norm/sep_dist vs time (3)
    %
    subplot(2,1,1); % vs x-distance
    for j=1:j_end
        for i=1:npart
            if j==1
                plot(x_int(:,i,j), sepdist_int(:,i,j), 'o-','MarkerSize',fonsize_symbol, 'Color', colors1(i,:)); % circles for sep. dist. criterion
                hold on
            elseif j==2
                plot(x_int(:,i,j), velnorm_int(:,i,j), '^-','MarkerSize',fonsize_symbol, 'Color', colors1(i,:)); % triangles for norm. vel. criterion
                hold on
            end
            xlim([0 5500])
        end
    end
    set(gca, 'FontSize', fontsize_axis_number); % assign font to the number on the axis
    xlabel('x-distance (µm)','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
    %
    subplot(2,1,2); % vs time
    for j=1:j_end
        for i=1:npart
            if j==1
                plot(time_int(:,i,j), sepdist_int(:,i,j),'o-','MarkerSize',fonsize_symbol,'Color', colors1(i,:)); % circles for sep. dist. criterion
                hold on
            elseif j==2
                plot(time_int(:,i,j), velnorm_int(:,i,j),'^-','MarkerSize',fonsize_symbol,'Color', colors1(i,:)); % triangles for norm. vel. criterion
                hold on
            end
        end
    end
    set(gca, 'FontSize', fontsize_axis_number); % assign font to the number on the axis
    header1=sprintf('%.3f µm separation distance criterion', sep_criterion(1));
    header2=sprintf('%.3f norm. vel criterion', thresh(2));
    xlabel('time (s)','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
    % ylabel('norm. vel. (-) or sep. dist. (µm)','FontSize',fontsize_axis_title); % increases the fontsize of axis
    savefig(gcf, strcat('Fig1-',predefined_name,'sep_',num2str(sep_criterion(1)),'µm-normvel_',num2str(thresh(2)),'.fig'));
    % Add a single Y-axis label for the whole figure
    han = axes(gcf, 'visible', 'off'); % Create an invisible axis
    han.YLabel.Visible = 'on'; % Make only the Y-axis label visible
    ylabel(han, 'norm. vel. (-) or sep. dist. (\mum)','FontSize',fontsize_y_axis_title); % Add the unique Y-axis label
    % Offset the Y-axis label to the left
    han.YLabel.Position(1) = han.YLabel.Position(1); % Move it left by adjusting X position
    %
    % Create dummy plots for the legend
    hold on; % Ensure the plot remains active
    h1 = plot(NaN, NaN, 'o', 'MarkerSize', 10,'Color','k'); % Circle marker
    h2 = plot(NaN, NaN, '^', 'MarkerSize', 10,'Color','k'); % Triangle marker
    % Create legend text
    legend_text = {['= ', header1], ['= ', header2]};
    % Add the legend
    lgd = legend([h1, h2], legend_text, 'FontSize', fontsize_legend_figure);
    lgd.Orientation = 'horizontal';
    lgd.Position = [0.5, 0.95, 0.01, 0.01]; % [X, Y, width, height] in normalized coordinates
    hold off;
end
end
%
%%
if flag_plot_3==1
    %
% for f=1:length(thresh_check)
%     name(f) = string(sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-new_subset_Complete',predefined_name2, predefined_name, sep_criterion(2), thresh_check(f))); % name of files with different norm. vel. criterion
%     load(name(f)); % Load the files saved for each norm. vel. criterion
% end
%%
figure(3) % Translation number (1), Interception order (2), Interception difference (3) vs mean x-distance (µm)
%
% Definir posiciones personalizadas para los subplots
symbols = ['^', 'o','+','x','>','v','d']; % Symbols for each normalized velocity
symbols2 = {'-.^', '-.o','-.+','-.x','-.>','-.v','-.d'}; % Symbols and dotted lines for each normalized velocity
name = strings(1, length(thresh_check)); % Record names of the .mat files
legend_handles1 = zeros(1, length(thresh_check)); % Initialize handles for legend
legend_name1 = strings(1, length(thresh_check) + 1); % Initialize names for legend entries
legend_handles2 = zeros(1, length(thresh_check)+1); % Initialize handles for legend
legend_name2 = strings(1, length(thresh_check)+1); % Initialize names for legend entries
%
% rearrange plotting arrays to place k in first position of each array and
% superimpose with :
for f=1:length(thresh_check)
    name(f) = string(sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete_subset',predefined_name2, predefined_name, sep_criterion(1), thresh_check(f))); % name of files with different norm. vel. criterion
    load(name(f)); % Load the files saved for each norm. vel. criterion
for j=1:j_end
    for i=1:npart
        if isnan(numint(j,i))
            continue
        else
            for k=1:numint(j,i)
                x_int_mean_sep2(k,i,j)=x_int_mean_sep(i, j, k);
                ntrans_int2(k,j,i)=ntrans_int(i,j,k);
                inv_k = numint(j,i) - k + 1; % Inverted index
                y_int_order2(inv_k, i, j) = y_int_order(i, j, k);
            end
        end
    end
end
%
y_int_order2(y_int_order2 == 0) = NaN;
    % % Generate the name for the .mat file and load it
    name(f) = string(sprintf('%s-%s-Sepdist_%.2fµm-Norm_vel_%.3f-all_Complete_subset',predefined_name2, predefined_name, sep_criterion(1), thresh_check(f))); % name of files with different norm. vel. criterion
    load(name(f)); % Load the file dynamically
    for j = 1:j_end % j=1, separation criterion; j=2, norm. vel. criterion
        for i = 1:npart % Loop over the number of trajectories
            subplot (2,1,1) % Number of translations
            if j == 1 % Scatter for sep. dist. criterion
               plot(x_int_mean_sep2(:,i,j), ntrans_int2(:,j,i), symbols2{f}, 'MarkerSize',(8+(1*f)),'Color', colors1(i, :));
               hold on;
            elseif j == 2 % Scatter for norm. vel. criterion
               plot(x_int_mean_sep2(:,i,j), ntrans_int2(:,j,i), symbols2{f}, 'MarkerSize',(8+(1*f)),'Color', colors1(i, :));
               hold on;
            end
            set(gca, 'FontSize', fontsize_axis_number); % assign font to the number on the axis
            set(gca, 'FontName', 'Calibri');
            set(gca, 'Box', 'off');
            set(gca, 'TickDir', 'out'); 
            set(gca, 'XAxisLocation', 'bottom'); 
            set(gca, 'YAxisLocation', 'left'); 
            set(gca, 'XTickLabel', []); % delete the x-axis values for the 1st subplot 
            xlim([0 5500])
            ylim([1 200])
            % xlabel('Interception x-distance (µm)','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            ylabel('# of translations','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            set(gca, 'YScale', 'log');
            hold on
            %
            subplot (2,1,2) % All interceptions for each npart
            if j == 1 % Scatter for sep. dist. criterion
                plot(x_int_mean_sep2(:,i,j), y_int_order2(:,i,j),symbols2{f}, 'MarkerSize',(8+(2*f)),'Color', colors1(i, :));
                hold on;
            elseif j == 2 % Scatter for norm. vel. criterion
                plot(x_int_mean_sep2(:,i,j), y_int_order2(:,i,j),symbols2{f}, 'MarkerSize',(8+(2*f)),'Color', colors1(i, :));
                hold on;
            end
            % set(gca, 'Position', [0.1, 0.4, 0.8, 0.25]); % adjust 2nd subplot position
            set(gca, 'FontSize', fontsize_axis_number); % assign font to the number on the axis
            set(gca, 'FontName', 'Calibri');
            set(gca, 'Box', 'off');
            set(gca, 'TickDir', 'out'); 
            set(gca, 'XAxisLocation', 'bottom'); 
            set(gca, 'YAxisLocation', 'left'); 
            xlim([0 5500])
            xlabel('Interception x-distance  (µm)','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            ylabel('Int. order','FontSize',fontsize_x_axis_title); % increases the fontsize of axis
            if predefined_name == 'AML'
                ylim([1 2])
                yticks(1:1:2); 
            elseif predefined_name == 'CML'
                ylim([1 3])
                yticks(1:1:3); 
            end
            hold on    
            %
            hold on
        end % end of npart (i loop)
    end % end of criterion (j loop)
% Add dummy scatter point for legend with the correct symbol and color
legend_handles1(f) = plot(NaN, NaN, symbols(f),'Markersize',10,'Color','k', 'LineWidth', 1.5); % Dummy scatter for legend
legend_name1(f) = sprintf('norm. vel.: %.3f', thresh_check(f)); % Legend entry for norm. vel.
% Add a legend entry for sep. dist.
sep_criterion(1)=7;
final_leg=length(thresh_check)+1;
% legend_handles1(final_leg) = plot(NaN, NaN, 'o','Markersize',6,'Color','k','MarkerFaceColor', 'k'); % Dummy scatter for sep. dist.
legend_name1(final_leg) = sprintf('sep. dist.: %.3f µm', sep_criterion(1)); % Legend entry for sep. dist.
end
%
% Resize the subplots manually at the end
h1 = subplot(2, 1, 1); % Select the first subplot
set(h1, 'Position', [0.1, 0.6, 0.5, 0.3]); % Adjust position [x, y, width, height]
h2 = subplot(2, 1, 2); % Select the second subplot
set(h2, 'Position', [0.1, 0.2, 0.5, 0.3]); % Adjust position [x, y, width, height]
% Add legends to the plot
lgd = legend(legend_handles1, legend_name1, 'FontSize', fontsize_legend_figure);
lgd.Orientation = 'horizontal'; % legend orientation
lgd.Position = [0.5, 0.95, 0.01, 0.01]; % [X, Y, width, height] in normalized coordinates
legend_icons = findobj(lgd, 'Type', 'Patch'); % find legend elements
set(legend_icons, 'MarkerSize', 15); % adjust the markersize manually
end % end flag_plot
end % end experimental conditions
% %