%This demo computes N proMPs given a set of recorded trajectories containing the demonstrations for the N types of movements. 
%It plots the results.

% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]

close all;
clearvars;
warning('off','MATLAB:colon:nonIntegerIndex');
addpath('./used_functions');


%%%%%%%%%%%%%%%VARIABLES, please look at the README
%Can be either ".mat" or ".txt". To use the recorded ".txt" file sample, put: 'Data/traj1'
DataPath= 'Data/traj1_1DOF.mat';
typeRecover= '.mat' %if it is txt file with all data, write '.txt'

inputName = {'z[m]'};%label of your inputs
s_ref=100; %reference number of samples
nbInput(1) = 1; %number of input used during the inference (here cartesian position)
%nbInput(2) = 2;%if you had some input that are not use to recognize the trajectory type
M(1) = 5; %number of basis functions to represent nbInput(1)
%M(2) = 10; %number of basis functions to represent nbInput(2)

%variable that you can tune to achieve the trajectory correctly: correspond to the expected data noise
expNoise = 0.00001;
procentData = 20; %procent of observed data during the inference

%%%%%%%%%%%%%% END VARIABLE CHOICE

%some variable computation to create basis function, you might have to
%change them
dimRBF = 0; 
for i=1:size(M,2)
    dimRBF = dimRBF + M(i)*nbInput(i);
end
c(1) = 1.0 / (M(1)); %center of gaussians
h(1) = c(1)/M(1) %bandwidth of the gaussians

if(strcmp(typeRecover,'.mat')==1)
    load(DataPath);
else
    %recover the data saved in the Data/trajX/recordY.txt files
    t{1} = loadTrajectory('Data/traj1', 'top', 'refNb', s_ref, 'nbInput',nbInput);
end
[train, test] =  partitionTrajectory(t{1}, 1, procentData, s_ref);

%plot recoverData
drawRecoverData(t{1}, inputName);

%compute the distribution for each kind of trajectories.
%we define var and TotalTime in this function
%here we need to define the bandwith of the gaussians h
%computeDistributions_withCrossOver;
promp{1} = computeDistribution(train, M, s_ref,c,h);

%plot distribution
drawDistribution(promp, inputName,s_ref);

%%%test w_alpha model
w = computeAlpha(test{1}.nbData,t, nbInput);
promp{1}.w_alpha = w{1};

[expAlpha,type, x] = inferenceAlpha(promp,test{1},M,s_ref,c,h,test{1}.nbData, expNoise, 'MO');
%Recognition of the movement
infTraj = inference(promp, test{1}, M, s_ref, c, h, test{1}.nbData, expNoise, expAlpha);

%draw the infered movement
drawInference(promp,infTraj, test{1},s_ref)


