%This demo computes N proMPs given a set of recorded trajectories containing the demonstrations for the N types of movements. 
%It plots the results.

% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]

close all;
clearvars;
warning('off','MATLAB:colon:nonIntegerIndex');
addpath('used_functions');


%%%%%%%%%%%%%%%VARIABLES, please refer you to the readme
matlabDataToRecover= 'Data/traj1_1DOF.mat';

nameInput = {'z[m]'};
%nbKindOfTraj =1;
referenceTime=100;
nbInput(1) = 1; %number of input used during the inference (here cartesian position)

nbFunctions(1) = 5; %number of basis functions

%variable tuned to achieve the trajectory correctly
expNoise = 0.00001;
nbData = 10; %number of data max with what you try to find the correct movement

%%%%%%%%%%%%%% END VARIABLE CHOICE



%some variable computation to create basis function, you might have to
%change them
nbTotFunctions = 0; 
for i=1:size(nbFunctions,2)
    nbTotFunctions = nbTotFunctions + nbFunctions(i)*nbInput(i);
end
center_gaussian(1) = 1.0 / (nbFunctions(1));
h(1) = center_gaussian(1)/nbFunctions(1); %bandwidth of the gaussians

%recover the data saved in the Data/trajX/recordY.txt files
%t1 = loadTrajectory('Data/traj1', 'top', 'z', z, 'nbInput',nbInput);
load(matlabDataToRecover);

%plot recoverData
drawRecoverData(t1, nameInput);

%compute the distribution for each kind of trajectories.
%we define var and TotalTime in this function
%here we need to define the bandwith of the gaussians h
%computeDistributions_withCrossOver;
promp{1} = computeDistribution(t1, nbFunctions, referenceTime,center_gaussian,h);

%plot distribution
drawDistribution(promp, nameInput,referenceTime);

%creation of a trajectory test
test.traj = promp{1}.traj.y{3};
test.trajM = promp{1}.traj.yMat{3};
test.totTime = promp{1}.traj.totTime(3);
test.alpha = referenceTime / test.totTime;
test.partialTraj = [];
test.nbData = nbData;
for i=1:sum(promp{1}.traj.nbInput)
    test.partialTraj = [test.partialTraj; promp{1}.traj.yMat{3}(1:nbData,i)];
end

%Recognition of the movement
infTraj = inference(promp, test, nbFunctions, referenceTime, center_gaussian, h, nbData, expNoise);

%draw the infered movement
drawInference(promp,infTraj, test,referenceTime)


