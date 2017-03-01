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
list = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};
nbKindOfTraj =1;
z=100;
nbInput(1) = 3; %number of degree of freedom
nbInput(2) = 6; %number of forces and moments

nbFunctions(1) = 5;%5 %51; %number of basis functions
nbFunctions(2) = 5; %21; %number of basis functions for forces
nbTotFunctions = 0;

for i=1:size(nbFunctions,2)
    nbTotFunctions = nbTotFunctions + nbFunctions(i)*nbInput(i);
end
center_gaussian(1) = 1.0 / (nbFunctions(1));
center_gaussian(2) = 1.0 / (nbFunctions(2));
h(1) = center_gaussian(1)/5;%0.02%center_gaussian(1)*(1/z); %0.006; %bandwidth of the gaussians
h(2) = center_gaussian(1)/5;%center_gaussian(1)*6*(1/z)/100;%0.003;
%variable tuned to achieve the trajectory correctly
accuracy = 0.00001;
%%%%%%%%%%%%%% END VARIABLE CHOICE


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
nbData = 30; %floor(z /3); %number of data max with what you try to find the correct movement

%recover the data saved in the Data/trajX/recordY.txt files
t1 = loadTrajectory('Data/traj1', 'top', 'z', z, 'nbInput',nbInput);
%%
%plot recoverData
drawRecoverData2(t1, list);

%compute the distribution for each kind of trajectories.
%we define var and TotalTime in this function
%here we need to define the bandwith of the gaussians h
%computeDistributions_withCrossOver;
promp{1} = computeDistributions2(t1, nbFunctions, z,center_gaussian,h);


%plot distribution
drawDistribution2(promp, list,z);

i = input(['Give the trajectory you want to replay (between 1 and ' num2str(size(promp,1)), ')']);
%This function replays the trajectory into gazebo.
replayProMP(i, promp{1}, connection,z);

trial = input(['Give the trajectory you want to test (between 1 and ', num2str(nbKindOfTraj),')']);
disp(['we try the number ', num2str(trial)])


test.traj = promp{trial}.traj.y{3};
test.trajM = promp{trial}.traj.yMat{3}
test.totTime = promp{trial}.traj.totTime(3);
test.alpha = z / test.totTime;
test.partialTraj = [];
test.nbData = nbData;
for i=1:sum(promp{trial}.traj.nbInput)
    test.partialTraj = [test.partialTraj; promp{trial}.traj.yMat{3}(1:nbData,i)];
end

%begin to play the first nbFirstData
replayObservedData(test,connection);

%Recognition of the movement
infTraj = inferencee(promp, test, nbFunctions, z, center_gaussian, h, nbData, accuracy);

%draw the infered movement
drawInference(promp,infTraj, test,z)

%replay the movement into gazebo
continueMovement(infTraj,connection, test.nbData,z, promp{1}.PSI_z,list);

%close the port and the program replay.
finishConnection(connection);


