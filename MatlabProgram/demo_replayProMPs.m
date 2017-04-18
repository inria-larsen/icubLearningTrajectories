%This toolbox allows (1) to learn the distribution of any kind of trajectories (i.e. data input that evolved in time) 
% (2) to infer the end of an initiate trajectory, thanks to the learned distribution.
% (3) to replay the end of the trajectory on the Gazebo simulation.

% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]
close all;
clearvars;
addpath('used_functions');

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
procentData = 30; %number of data with what you try to find the correct movement
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

%information: 
%port open: port(/matlab/write)
%bottle b to write, c to read
connection = initializeConnection    

%You have to launch:
%1. yarpserver
%2. gazebo with worldPROMPS
%4. Create another terminal and launch:  iKinCartesianSolver --robot icubGazeboSim --part left_arm
%5. Launch: simCartesianControl --robot icubGazeboSim in this terminal
%6. Then, launch the program. It will show you the learned distribution.
%Then, it will wait for a connection. Do it by:
%7. ./Cpp/build/bin/replay 
%8 connect the port /matlab/write and /replay/read in the two sens.
%9 On matlab, give the number of the trajectory to replay and watch/


%recover the data saved in the Data/trajX/recordY.txt files
t{1} = loadTrajectory(nameDataTrajectories, 'top', 'referenceNumber', refTime, 'nbInput',nbInput, 'Specific', 'FromGeom');

%take one of the trajectory randomly to do test, the others are stocked in
%train1.
[train1,test1] = partitionTrajectory(t1,1,procentData,refTime);

%Compute the distribution for each kind of trajectories.
promp{1} = computeDistribution(train1, nbFunctions, refTime,center_gaussian,h);

i = size(promp,1)+1;
while (i > size(promp,1) || i < 1)
    i = input(['Give the trajectory you want to replay (between 1 and ' num2str(size(promp,1)), ')']);
end
%This function replays the trajectory into gazebo.
replayProMP(i, promp{1}, connection,refTime);

trial = size(promp,1)+1;
while (trial > size(promp,1) || trial < 1)
    trial = input(['Give the trajectory you want to test (between 1 and ', num2str(size(promp,1)),')']);
end
disp(['We try the number ', num2str(trial)]);

test = test1;
w = computeAlpha(test{1}.nbData,t, nbInput);
promp{1}.w_alpha= w{1};

%begin to play the first nbFirstData
replayObservedData(test,connection);

%Recognition of the movement
[alphaTraj,type, x] = inferenceAlpha(promp,test{1},nbFunctions,refTime,center_gaussian,h,test{1}.nbData, expNoise, 'MO');
infTraj = inference(promp, test{1}, nbFunctions, refTime, center_gaussian, h, test{1}.nbData, expNoise, alphaTraj);

%replay the movement into gazebo
continueMovement(infTraj,connection, test.nbData,refTime, promp{1}.PSI_z,list);

%close the port and the program replay.
closeConnection(connection);
