% Script to read _geo_.mat file created on a1_readdata and create a
% distribution of pillar across the selected Field of view
clc; clear; close all;
%get script path
filePath = matlab.desktop.editor.getActiveFilename;
% change path to locate data directory
dir = strrep(filePath,"\a2_subset_geo.m",'\');
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
%
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
% load workspace
load(strcat(predefined_name2,'_geo_','',predefined_name,'.mat'));
% define subset geometry based on boundaries provided
% extract geometry matrix xcenter ycenter radii all in um
p = C{:,1:3};
% number of pillars
num_pillars = length(p);

%extract boundaries in um
uleft  = [C{1,6},C{1,7}]; % up-left corner
dleft   = [C{2,6},C{2,7}]; % down-left corner
uright = [C{3,6},C{3,7}]; % up-right corner
dright  = [C{4,6},C{4,7}]; % down-right corner

% FOV vectors
xFOV = [dleft(1) dright(1) uright(1) uleft(1) dleft(1)];
yFOV = [dleft(2) dright(2) uright(2) uleft(2) dleft(2)];

% discriminate pillars located inside or partially inside FOV
Csub = NaN(num_pillars,3); % prealocate empty matrix 
%count pillars
k=0;
for i=1:num_pillars
    xd = p(i,1)+p(i,3)>dleft(1)&&p(i,1)-p(i,3)<dright(1); % Determine which pillars are in FOV (X-axis)
    yd = p(i,2)+p(i,3)>dleft(2)&&p(i,2)-p(i,3)<uleft(2); % Determine which pillars are in FOV (Y-axis)
    if xd+yd==2 % both conditions (xd && yd) should meet
        k=k+1;
        % save X-y coordinates and radii (µm) in subset
        Csub(k,1) = p(i,1)+1; % X coordinate: offset 1 µm to match Bashar's geometry
        Csub(k,2) = p(i,2)+1; % Y coordinate: offset 1 µm to match Bashar's geometry
        Csub(k,3) = p(i,3); % radii
    end
end
% delete extra rows in Csub
if k<num_pillars
    Csub(k+1:num_pillars,:)=[];
end
% save workspace
save(strcat(dir,predefined_name2,'_sub_geo_',predefined_name,'.mat'))

% geneate a unit circle
n = 20;
a =linspace(0,2*pi,n);
xu = cos(a);
yu = sin(a);

%plot 
figure(1)
plot(xFOV,yFOV,'.-r','LineWidth',2)
tol = 100; % dimension tolerance
maxd =max([max(xFOV),max(yFOV)])+tol; % axis maximum dimensions
axis ([-tol maxd -tol maxd])% axis dimensions
axis square
hold on

% draw pillars
for i=1:k
    fill(xu*Csub(i,3)+Csub(i,1),yu*Csub(i,3)+Csub(i,2),'g')
end
% % save FOV figures 
% saveas(gcf, strcat(predefined_name2,'_FOV_',predefined_name,'.png'));
% savefig(gcf, strcat(predefined_name2,'_FOV_',predefined_name,'.fig'));