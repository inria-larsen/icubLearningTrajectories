%This demo computes N proMPs given a set of recorded trajectories containing the demonstrations for the N types of movements. 
%It plots the results.

% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]

close all;
clearvars;
warning('off','MATLAB:colon:nonIntegerIndex')
%%%%%%%%%%%%%%%VARIABLES, please refer you to the readme
nameDataTrajectories = 'Data/traj1';
list = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};
%nbKindOfTraj =1;
refTime=100;
nbInput(1) = 3; %number of input used during the inference (here cartesian position)
nbInput(2) = 6; %other inputs (here forces and wrenches)

nbFunctions(1) = 5; %number of basis functions
nbFunctions(2) = 5; %number of basis functions for the second type of input (could require over forces).

%variable tuned to achieve the trajectory correctly
expNoise = 0.00001;

for typeReco=1%:3
    switch typeReco
        case 1
            typeR = 'ML';
        case 2 
            typeR = 'MO';
        case 3 
            typeR = 'DI';
    end
    typeR
        
for actTest=4%:10

procentData = 10*actTest; %number of data max with what you try to find the correct movement

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
t{1} = loadTrajectory('Data/Test_WBD/trajG1', 'Left', 'z', refTime, 'nbInput',nbInput);
t{2} = loadTrajectory('Data/Test_WBD/trajG2', 'Left', 'z', refTime, 'nbInput',nbInput);

%plot recoverData
 drawRecoverData(t{1}, list);
 drawRecoverData(t{2}, list);

%partition data between training and tests
[train1,test1] = partitionTrajectory(t{1},1,procentData,refTime);
[train2,test2] = partitionTrajectory(t{2},1,procentData,refTime);

 
%compute the distribution for each kind of trajectories.
%we define var and TotalTime in this function
%here we need to define the bandwith of the gaussians h
%computeDistributions_withCrossOver;
promp{1} = computeDistribution(t{1}, nbFunctions, refTime,center_gaussian,h);
promp{2} = computeDistribution(t{2}, nbFunctions, refTime,center_gaussian,h);

%plot distribution
drawDistribution(promp{1}, list,refTime,[1:3]);
drawDistribution(promp{2}, list,refTime,[1:3]);


trial = 1;%size(promp,2)+1;
while (trial > size(promp,2) || trial < 1)
    trial = input(['Give the trajectory you want to test (between 1 and ', num2str(size(promp,2)),')']);
end
disp(['We try the number ', num2str(trial)]);

if(trial==1)
    test=test1{1};
else
    test = test2{1};
end

%%%test alpha computation from nbData
w = computeAlpha(test.nbData,t, nbInput);
promp{1}.w_alpha = w{1};
promp{2}.w_alpha = w{2}

%Recognition of the movement
[alphaTraj,type, x] = inferenceAlpha(promp,test,nbFunctions,refTime,center_gaussian,h,test.nbData, expNoise, typeR);
data.typeTot(typeReco, actTest) = type;
data.errAlpha(typeReco, actTest) = abs(alphaTraj- test.alpha);
end
end
%alphaTraj = promp{1}.mu_alpha

%  infTraj = inference(promp, test, nbFunctions, refTime, center_gaussian, h, test.nbData, expNoise, alphaTraj);
% % %%
% % %draw the infered movement
%  drawInference(promp,infTraj, test,refTime)
% 

