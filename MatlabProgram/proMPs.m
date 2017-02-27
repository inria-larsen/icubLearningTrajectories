%This toolbox allow (1) to learn the distribution of any kind of trajectories (i.e. data input that evolved in time) 
% (2) to infer the end of an initiate trajectory, thanks to the learned distribution.
% (3) If you learnt cartesian position of the icub robot, youcan replay
% them. 

% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]
close all;
clearvars;

%%%%%%%%%%%%%%%VARIABLES, please refer you to the readme
nbKindOfTraj =1;
z=100;
nbDof(1) = 3; %number of degree of freedom
nbDof(2) = 6; %number of forces and moments

nbFunctions(1) = 5;%5 %51; %number of basis functions
nbFunctions(2) = 5; %21; %number of basis functions for forces
nbTotFunctions = 0;

for i=1:size(nbFunctions,2)
    nbTotFunctions = nbTotFunctions + nbFunctions(i)*nbDof(i);
end
center_gaussian(1) = 1.0 / (nbFunctions(1));
center_gaussian(2) = 1.0 / (nbFunctions(2));
h(1) = center_gaussian(1)/5%0.02%center_gaussian(1)*(1/z); %0.006; %bandwidth of the gaussians
h(2) = center_gaussian(1)/5;%center_gaussian(1)*6*(1/z)/100;%0.003;
%variable tuned to achieve the trajectory correctly
accuracy = 0.000000001;
%%%%%%%%%%%%%% END VARIABLE CHOICE


%Launch that initConnection, only if you want to test it onto gazebo

%information: 
%port open: port(/matlab/write)
%bottle b to write, c to read

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
initConnection;
    
nbData = 30 %floor(z /3); %number of data max with what you try to find the correct movement

%recover the data saved in the Data/trajX/recordY.txt files
recoverData;

%plot recoverData
%drawRecoverData

%compute the distribution for each kind of trajectories.
%we define var and TotalTime in this function
%here we need to define the bandwith of the gaussians h
%computeDistributions_withCrossOver;
computeDistributions

%plot distribution
drawDistribution

%This function replays the trajectory into gazebo.
replay;

%Recognition of the movement
inference;

%draw the infered movement
drawInferedMovement

%replay the movement into gazebo
replayRecognition;

%close the port and the program replay.
closeConnection;



