% Script for read the Excel file (.xlsx) for each loaded geometry 
% SIMULATION:
    % Favorable: Sim_PM_Geometry-AML_1µm_FavCond-(IS_2mM-pH_4)_porosity_37
    % Unfavorable: Sim_PM_Geometry-CML(0.95µm)_UnfavCond(IS_6mM-pH_6.5) _porosity_37
% EXPERIMENTAL:
    % Favorable: Exp_PM_Geometry-AML_1µm_FavCond-(IS_2mM-pH_4)_porosity_37
    % Unfavorable: Exp_PM_Geometry-CML(0.95µm)_UnfavCond(IS_6mM-pH_6.5) _porosity_37
clc; clear; close all;
%%
% get script path for AML geometry
filePath = matlab.desktop.editor.getActiveFilename;
% change path to locate data directory for AML geometry (x-y coordinates
% and radii of each pillar)
dir = strrep(filePath,"\a1_readdata.m",'\');
disp(filePath)
disp(dir)

% Call for AML or CML depending on Fav or Unfav conditions, respectively.
% Call for Sim or Exp depending on Simulation or Experiment, respectively.
flag_data=1; % choose the type of data to load 
% 1 for loading AML (Favorable) from simulations
% 2 for loading AML (Favorable) from experiments
% 3 for loading CML (Unfavorable) from simulations
% 4 for loading CML (Unfavorable) from experiments

% Load the .mat file
if flag_data == 1
    predefined_name='AML'; % Call for AML on Fav conditions
    predefined_name2='Sim'; % Call for Sim on Simulation
    file_geo_name='Sim_PM_Geometry-AML_1µm_FavCond-(IS_2mM-pH_4)_porosity_37';
elseif flag_data == 2
    predefined_name='AML'; % Call for AML on Fav conditions
    predefined_name2='Exp'; % Call for Exp on Experiment
    file_geo_name='Exp_PM_Geometry-AML_1µm_FavCond-(IS_2mM-pH_4)_porosity_37';
elseif flag_data == 3
    predefined_name='CML'; % Call for CML on Unfav conditions
    predefined_name2='Sim'; % Call for Sim on Simulation 
    file_geo_name='Sim_PM_Geometry-CML(0.95µm)_UnfavCond(IS_6mM-pH_6.5) _porosity_37';
elseif flag_data == 4
    predefined_name='CML'; % Call for CML on Unfav conditions
    predefined_name2='Exp'; % Call for Exp on Experiment
    file_geo_name='Exp_PM_Geometry-CML(0.95µm)_UnfavCond(IS_6mM-pH_6.5) _porosity_37';
end
%  Message for choosing file with the defined geometry
disp(['Select the ', predefined_name2,'-',predefined_name,' geometry file']);
disp(file_geo_name);
% get the file
[fileGeo, pathGeo] = uigetfile('*.xlsx', dir);
C = readtable(fileGeo);
% save workspace
save(strcat(predefined_name2,'_geo_','',predefined_name,'.mat'));