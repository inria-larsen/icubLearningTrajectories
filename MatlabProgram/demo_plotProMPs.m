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
nameDataTrajectories = 'Data/traj1';
list = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};
%nbKindOfTraj =1;
refTime=100;
nbInput(1) = 3; %number of input used during the inference (here cartesian position)
nbInput(2) = 6; %other inputs (here forces and wrenches)

nbFunctions(1) = 5; %number of basis functions for the first type of input
nbFunctions(2) = 5; %number of basis functions for the second type of input

%variable tuned to achieve the trajectory correctly
expNoise = 0.00001;
procentData = 35; %number of data max with what you try to find the correct movement

%%%%%%%%%%%%%% END VARIABLE CHOICE

%some variable computation to create basis function, you might have to
%change them
nbTotFunctions = 0; 
for i=1:size(nbFunctions,2)
    nbTotFunctions = nbTotFunctions + nbFunctions(i)*nbInput(i);
end
center_gaussian(1) = 1.0 / (nbFunctions(1));
center_gaussian(2) = 1.0 / (nbFunctions(2));
h(1) = center_gaussian(1)/nbFunctions(1); %bandwidth of the gaussians
h(2) = center_gaussian(2)/nbFunctions(2);

%recover the data saved in the Data/trajX/recordY.txt files
t1 = loadTrajectory(nameDataTrajectories, 'top', 'referenceNumber', refTime, 'nbInput',nbInput, 'Specific', 'FromGeom');

%take one of the trajectory randomly to do test, the others are stocked in
%train1.
[train1,test1] = partitionTrajectory(t1,1,procentData,refTime);

%plot recoverData
drawRecoverData(t1, list, 'Specific');

%Compute the distribution for each kind of trajectories.
promp{1} = computeDistribution(train1, nbFunctions, refTime,center_gaussian,h);

%plot distribution
drawDistribution(promp, list,refTime);

trial = size(promp,1)+1;
while (trial > size(promp,1) || trial < 1)
    trial = input(['Give the trajectory you want to test (between 1 and ', num2str(size(promp,1)),')']);
end
disp(['We try the number ', num2str(trial)]);

test = test1;
t{1} = t1;
w = computeAlpha(test{1}.nbData,t, nbInput);
promp{1}.w_alpha= w{1};

%Recognition of the movement
[alphaTraj,type, x] = inferenceAlpha(promp,test{1},nbFunctions,refTime,center_gaussian,h,test{1}.nbData, expNoise, 'MO');
infTraj = inference(promp, test{1}, nbFunctions, refTime, center_gaussian, h, test{1}.nbData, expNoise, alphaTraj);

%draw the infered movement
drawInference(promp,infTraj, test{1},refTime)


