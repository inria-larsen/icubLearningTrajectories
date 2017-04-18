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
DataPath= 'Data/traj1_1DOF.mat'; %for the recorded txt file sample: 'Data/traj1'
typeRecover= '.mat' %if it is txt file with all data, write '.txt'

inputName = {'z[m]'};
refNbIteration=100;
nbInput(1) = 1; %number of input used during the inference (here cartesian position)
%nbInput(2) = 2;%if you had some input that are not use to recognize the
%trajectory type
nbFunctions(1) = 5; %number of basis functions to represent nbInput(1)
%nbFunctions(2) = 10; %number of basis functions to represent nbInput(2)

%variable that you can tune to achieve the trajectory correctly: correspond
%to the expected data noise
expNoise = 0.00001;
nbData = 40; %number of observed data during the inference

%%%%%%%%%%%%%% END VARIABLE CHOICE

%some variable computation to create basis function, you might have to
%change them
nbTotFunctions = 0; 
for i=1:size(nbFunctions,2)
    nbTotFunctions = nbTotFunctions + nbFunctions(i)*nbInput(i);
end
center_gaussian(1) = 1.0 / (nbFunctions(1));
h(1) = center_gaussian(1)/nbFunctions(1) %bandwidth of the gaussians


if(strcmp(typeRecover,'.mat')==1)
    load(DataPath);
    t{1} = t1;
else
    %recover the data saved in the Data/trajX/recordY.txt files
    t{1} = loadTrajectory('Data/traj1', 'top', 'z', refNbIteration, 'nbInput',nbInput);
end
[train1, test] =  partitionTrajectory(t{1}, 1, nbData, refNbIteration);

%plot recoverData
drawRecoverData(t{1}, inputName);

%compute the distribution for each kind of trajectories.
%we define var and TotalTime in this function
%here we need to define the bandwith of the gaussians h
%computeDistributions_withCrossOver;
promp{1} = computeDistribution(t{1}, nbFunctions, refNbIteration,center_gaussian,h);

%plot distribution
drawDistribution(promp, inputName,refNbIteration);

%%%test w_alpha model
w = computeAlpha(test{1}.nbData,t, nbInput);
promp{1}.w_alpha = w{1};

[alphaTraj,type, x] = inferenceAlpha(promp,test{1},nbFunctions,refNbIteration,center_gaussian,h,test{1}.nbData, expNoise, 'MO');
%Recognition of the movement
infTraj = inference(promp, test{1}, nbFunctions, refNbIteration, center_gaussian, h, test{1}.nbData, expNoise, alphaTraj);

%draw the infered movement
drawInference(promp,infTraj, test{1},refNbIteration)


