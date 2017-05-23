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
DataPath = 'Data/FLT/left';
inputName = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};

refTime=100;
nbInput(1) = 3; %number of input used during the inference (here cartesian position)
nbInput(2) = 6; %other inputs (here forces and wrenches)

M(1) = 5; %number of basis functions for the first type of input
M(2) = 5; %number of basis functions for the second type of input

%variable tuned to achieve the trajectory correctly
expNoise = 0.00001;
procentData = 30; %number of data max with what you try to find the correct movement

%%%%%%%%%%%%%% END VARIABLE CHOICE

%some variable computation to create basis function, you might have to
%change them
dimRBF = 0; 
for i=1:size(M,2)
    dimRBF = dimRBF + M(i)*nbInput(i);
end
c(1) = 1.0 / (M(1)); %center of gaussians
c(2) = 1.0 / (M(2));
h(1) = c(1)/M(1); %bandwidth of gaussians
h(2) = c(2)/M(2);

%recover the data saved in the Data/trajX/recordY.txt files
t{1} = loadTrajectory(DataPath, 'Test_WBD', 'refNb', refTime, 'nbInput',nbInput, 'Specific', 'FromGeom');

%take one of the trajectory randomly to do test, the others are stocked in
%train1.
[train1,test{1}] = partitionTrajectory(t{1},1,procentData,refTime);

%plot recoverData
drawRecoverData(t{1}, inputName, 'Specolor','m','namFig', 1);
drawRecoverData(t{1}, inputName, 'Interval', [4 7 5 8 6 9], 'Specolor','b','namFig',2);

%Compute the distribution for each kind of trajectories.
promp{1} = computeDistribution(train1, M, refTime,c,h);

%plot distribution
drawDistribution(promp{1}, inputName,refTime, 1:3);

trial = 1%size(promp,1)+1;
while (trial > size(promp,1) || trial < 1)
    trial = input(['Give the trajectory you want to test (between 1 and ', num2str(size(promp,1)),')']);
end
disp(['We try the number ', num2str(trial)]);

test = test{1};
w = computeAlpha(test{1}.nbData,t, nbInput);
promp{1}.w_alpha= w{1};

%Recognition of the movement
[alphaTraj,type, x] = inferenceAlpha(promp,test{1},M,refTime,c,h,test{1}.nbData, expNoise, 'MO');
display(['Error MO= ', num2str(abs(alphaTraj - test{1}.alpha))]); 
infTrajMO = inference(promp, test{1}, M, refTime, c, h, test{1}.nbData, expNoise, alphaTraj);

display(['Error MEAN= ', num2str(abs(promp{1}.mu_alpha - test{1}.alpha))]); 
infTrajME = inference(promp, test{1}, M, refTime, c, h, test{1}.nbData, expNoise, alphaTraj);
% 
% [alphaTraj,type, x] = inferenceAlpha(promp,test{1},M,refTime,c,h,test{1}.nbData, expNoise, 'ML');
% display(['Error ML= ', num2str(abs(alphaTraj - test{1}.alpha))]); 
% infTrajML = inference(promp, test{1}, M, refTime, c, h, test{1}.nbData, expNoise, alphaTraj);
% 
% [alphaTraj,type, x] = inferenceAlpha(promp,test{1},M,refTime,c,h,test{1}.nbData, expNoise, 'DI');
% display(['Error DI= ', num2str(abs(alphaTraj - test{1}.alpha))]); 
% %alphaTraj =   promp{1}.mu_alpha ;
% infTrajDI = inference(promp, test{1}, M, refTime, c, h, test{1}.nbData, expNoise, alphaTraj);

%draw the infered movement
% drawInference(promp,infTrajMO, test{1},refTime, 'Name', 'Model');
% drawInference(promp,infTrajML, test{1},refTime, 'Name', 'Maximum likelihood');
% drawInference(promp,infTrajDI, test{1},refTime, 'Name', 'Distance');
drawInference(promp,inputName,infTrajME, test{1},refTime, 'Name', 'Mean');


