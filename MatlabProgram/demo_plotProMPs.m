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
DataPath = 'Data/traj1';
inputName = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};
s_bar=100;
nbInput(1) = 3; %number of input used during the inference (here cartesian position)
nbInput(2) = 6; %other inputs (here forces and wrenches)

M(1) = 5; %number of basis functions for the first type of input
M(2) = 5; %number of basis functions for the second type of input

%variable tuned to achieve the trajectory correctly
expNoise = 0.00001;
procentData = 35; %number of data max with what you try to find the correct movement

%%%%%%%%%%%%%% END VARIABLE CHOICE

%some variable computation to create basis function, you might have to
%change them
dimRBF = 0; 
for i=1:size(M,2)
    dimRBF = dimRBF + M(i)*nbInput(i);
end
c(1) = 1.0 / (M(1));%center of gaussians
c(2) = 1.0 / (M(2));
h(1) = c(1)/M(1); %bandwidth of gaussians
h(2) = c(2)/M(2);

%recover the data saved in the Data/trajX/recordY.txt files
t{1} = loadTrajectory(DataPath, 'top', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');

%take one of the trajectory randomly to do test, the others are stocked in
%train1.
t{1} = loadTrajectory('Data/bas', 'bottom', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');
t{2} = loadTrajectory('Data/haut', 'top', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');
t{3} = loadTrajectory('Data/milieu', 'front', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');

%plot recoverData
drawRecoverData(t{1}, inputName, 'Specific');

[train{1},test{1}] = partitionTrajectory(t{1},1,procentData,s_bar);
[train{2},test{2}] = partitionTrajectory(t{2},1,procentData,s_bar);
[train{3},test{3}] = partitionTrajectory(t{3},1,procentData,s_bar);

%Compute the distribution for each kind of trajectories.
promp{1} = computeDistribution(train{1}, M, s_bar,c,h);
promp{2} = computeDistribution(train{2}, M, s_bar,c,h);
promp{3} = computeDistribution(train{3}, M, s_bar,c,h);

%plot distribution
drawDistribution(promp{1}, inputName,s_bar,3);
drawDistribution(promp{2}, inputName,s_bar,3);
drawDistribution(promp{3}, inputName,s_bar,3);

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
[alphaTraj,type, x] = inferenceAlpha(promp,test{1},M,s_bar,c,h,test{1}.nbData, expNoise, 'ML');
infTraj = inference(promp, test{1}, M, s_bar, c, h, test{1}.nbData, expNoise, alphaTraj);

%draw the infered movement
drawInferenceRescaled(promp,infTraj, test{1},s_bar)

