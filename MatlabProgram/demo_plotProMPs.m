%This demo computes N proMPs given a set of recorded trajectories containing the demonstrations for the N types of movements. 
%It plots the results.

% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]

close all;
clearvars;
warning('off','MATLAB:colon:nonIntegerIndex')
addpath('used_functions'); %add some fonctions we use.

%%%%%%%%%%%%%%%VARIABLES, please refer you to the readme
inputName = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};
s_bar=100;
nbInput(1) = 3; %number of input used during the inference (here cartesian position)
nbInput(2) = 6; %other inputs (here forces and wrenches)

M(1) = 5; %number of basis functions for the first type of input
M(2) = 5; %number of basis functions for the second type of input

%variable tuned to achieve the trajectory correctly
expNoise = 0.00001;
percentData = 48; %number of data max with what you try to find the correct movement

%%%%%%%%%%%%%% END VARIABLE CHOICE

%some variable computation to create basis function, you might have to
%change them
dimRBF = 0; 
for i=1:size(M,2)
    dimRBF = dimRBF + M(i)*nbInput(i);
    c(i) = 1.0 / (M(i));%center of gaussians
    h(i) = c(i)/M(i); %bandwidth of gaussians
end

%WITH WORLD3HEIGHTS
t{1} = loadTrajectory('Data/heights/bottom', 'bottom', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');
t{2} = loadTrajectory('Data/heights/top', 'top', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');
t{3} = loadTrajectory('Data/heights/middle', 'front', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');

% WITH WORLDPROMPS
% t{1} = loadTrajectory('Data/FLT/front', 'bottom', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');
% t{2} = loadTrajectory('Data/FLT/left', 'top', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');
% t{3} = loadTrajectory('Data/FLT/top', 'front', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');


%plot recoverData
drawRecoverData(t{1}, inputName, 'Specolor','b','namFig', 1);
drawRecoverData(t{1}, inputName, 'Interval', [4 7 5 8 6 9], 'Specolor','b','namFig',2);
drawRecoverData(t{2}, inputName, 'Specolor','r','namFig',1);
drawRecoverData(t{2}, inputName, 'Interval', [4 7 5 8 6 9], 'Specolor','r','namFig',2);
drawRecoverData(t{3}, inputName, 'Specolor','g','namFig',1);
drawRecoverData(t{3}, inputName, 'Interval', [4 7 5 8 6 9], 'Specolor','g','namFig',2);

%take one of the trajectory randomly to do test, the others are stocked in
%train.
[train{1},test{1}] = partitionTrajectory(t{1},1,percentData,s_bar);
[train{2},test{2}] = partitionTrajectory(t{2},1,percentData,s_bar);
[train{3},test{3}] = partitionTrajectory(t{3},1,percentData,s_bar);

%Compute the distribution for each kind of trajectories.
promp{1} = computeDistribution(train{1}, M, s_bar,c,h);
promp{2} = computeDistribution(train{2}, M, s_bar,c,h);
promp{3} = computeDistribution(train{3}, M, s_bar,c,h);

%plot distribution
drawDistribution(promp{1}, inputName,s_bar,[1:3], 'col', 'b');
drawDistribution(promp{2}, inputName,s_bar,[1:3], 'col', 'r');
drawDistribution(promp{3}, inputName,s_bar,[1:3], 'col', 'g');

trial = length(promp)+1;
while (trial > length(promp) || trial < 1)
    trial = input(['Give the trajectory you want to test (between 1 and ', num2str(length(promp)),')']);
end
disp(['We try the number ', num2str(trial)]);

test = test{trial};
w = computeAlpha(test{1}.nbData,t, nbInput);
promp{1}.w_alpha= w{1};
promp{2}.w_alpha= w{2};
promp{3}.w_alpha= w{3};

%Recognition of the movement
[alphaTraj,type, x] = inferenceAlpha(promp,test{1},M,s_bar,c,h,test{1}.nbData, expNoise, 'MO');
infTraj = inference(promp, test{1}, M, s_bar, c, h, test{1}.nbData, expNoise, alphaTraj, nbInput);

%draw the infered movement
drawInferenceRescaled(promp,inputName ,infTraj, test{1},s_bar)
drawInference(promp,inputName,infTraj, test{1},s_bar)

