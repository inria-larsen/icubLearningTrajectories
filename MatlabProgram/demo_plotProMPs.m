%This demo computes N proMPs given a set of recorded trajectories containing the demonstrations for the N types of movements. 
%It plots the results.

% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]

close all;
clearvars;
warning('off','MATLAB:colon:nonIntegerIndex')
%%%%%%%%%%%%%%%VARIABLES, please refer you to the readme
list = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};
%nbKindOfTraj =1;
z=100;
nbInput(1) = 3; %number of input used during the inference (here cartesian position)
nbInput(2) = 6; %other inputs (here forces and wrenches)

nbFunctions(1) = 5; %number of basis functions
nbFunctions(2) = 5; %number of basis functions for the second type of input (could require over forces).

%variable tuned to achieve the trajectory correctly
accuracy = 0.00001;
nbData = 30; %number of data max with what you try to find the correct movement

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
t1 = loadTrajectory('Data/traj1', 'top', 'z', z, 'nbInput',nbInput);

%plot recoverData
drawRecoverData(t1, list);

%compute the distribution for each kind of trajectories.
%we define var and TotalTime in this function
%here we need to define the bandwith of the gaussians h
%computeDistributions_withCrossOver;
promp{1} = computeDistribution(t1, nbFunctions, z,center_gaussian,h);

%plot distribution
drawDistribution(promp, list,z);

trial = size(promp,1)+1;
while (trial > size(promp,1) || trial < 1)
    trial = input(['Give the trajectory you want to test (between 1 and ', num2str(size(promp,1)),')']);
end
disp(['We try the number ', num2str(trial)]);

%creation of a trajectory test
test.traj = promp{trial}.traj.y{3};
test.trajM = promp{trial}.traj.yMat{3};
test.totTime = promp{trial}.traj.totTime(3);
test.alpha = z / test.totTime;
test.partialTraj = [];
test.nbData = nbData;
for i=1:sum(promp{trial}.traj.nbInput)
    test.partialTraj = [test.partialTraj; promp{trial}.traj.yMat{3}(1:nbData,i)];
end


%Recognition of the movement
infTraj = inference(promp, test, nbFunctions, z, center_gaussian, h, nbData, accuracy);

%draw the infered movement
drawInference(promp,infTraj, test,z)


