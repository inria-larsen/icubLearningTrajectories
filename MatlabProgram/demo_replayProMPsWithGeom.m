%In this demo, you can replay learned movement; then you can begin a movement with the geomagic on iCubGazeboSim. To that, you will use a Cpp program that records your movement as long as you press a Geomagic button. Then, this script retrieve these early observation, and infer the movement end. It replays it on the icubGazeboSim. 


% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]
close all;
clearvars;
addpath('used_functions');
warning('off','MATLAB:colon:nonIntegerIndex')

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
procentData = 40; %number of data with what you try to find the correct movement
%%%%%%%%%%%%%% END VARIABLE CHOICE

%some variable computation to create basis function, you might have to
%change them
dimRBF = 0; 
for i=1:size(M,2)
    dimRBF = dimRBF + M(i)*nbInput(i);
    c(i) = 1.0 / (M(i));%center of gaussians
    h(i) = c(1)/M(i); %bandwidth of gaussians
end

%information: 
%port open: port(/matlab/write)
%bottle b to write, c to read
connection = initializeConnection    

%You have to launch:
%1. yarpserver
%2. gazebo with WORLD2HEIGHTS
%4. Create another terminal and launch:  iKinCartesianSolver --robot icubGazeboSim --part left_arm
%5. Launch: simCartesianControl --robot icubGazeboSim in this terminal
%6. Then, launch the program. It will show you the learned distribution.
%Then, it will wait for a connection. Do it by:
%7. ./Cpp/build/bin/replay 
%8 connect the port /matlab/write and /replay/read in the two sens.
%9 On matlab, give the number of the trajectory to replay and watch.


%recover the data 
t{1} = loadTrajectory('Data/heights/bottom', 'bottom', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');
t{2} = loadTrajectory('Data/heights/top', 'top', 'refNb', s_bar, 'nbInput',nbInput, 'Specific', 'FromGeom');

%take one of the trajectory randomly to do test{1}, the others are stocked in
%train.
[train{1},test{1}] = partitionTrajectory(t{1},1,procentData,s_bar,3);
[train{2},test{2}] = partitionTrajectory(t{2},1,procentData,s_bar,3);

%Compute the distribution for each kind of trajectories.
promp{1} = computeDistribution(train{1}, M, s_bar,c,h);
promp{2} = computeDistribution(train{2}, M, s_bar,c,h);

% drawDistribution(promp{2}, inputName,s_bar,1:3);
% drawDistribution(promp{1}, inputName,s_bar,1:3);

cont=1;
while( cont==1)
    i = length(promp)+1;
    while (i > length(promp) || i < 1)
        i = input(['Give the trajectory you want to replay (between 1 and ' num2str(length(promp)), ')']);
    end
    
    %This function replays the trajectory into gazebo.
    replayProMP(i, promp{i}, connection,s_bar);
    cont = input('Do you want to replay? (yes=1, no=0)');
end


cont=1;
while( cont==1)
    
    test = beginATrajectory(connection);

    w = computeAlpha(test.nbData,t, nbInput);
    promp{1}.w_alpha= w{1};
    promp{2}.w_alpha= w{2};

    %Recognition of the movement
    [alphaTraj,type, x] = inferenceAlpha(promp,test,M,s_bar,c,h,test.nbData, expNoise, 'MO');
    [infTraj, Treco] = inference(promp, test, M, s_bar, c, h, test.nbData, expNoise, alphaTraj, connection);
    
    %to ask icub to say the label of the recognize trajectory
    sayType(promp{Treco}.traj.label, connection);
    
    %replay the movement into gazebo
    continueMovement(infTraj,connection, test.nbData,s_bar, promp{type}.PHI_norm,inputName);
    cont = input('Do you want to infer again? (yes=1, no=0)');
end

%draw the infered movement
%drawInference(promp,inputName,infTraj, test,s_bar)

%close the port and the program replay.
closeConnection(connection);
