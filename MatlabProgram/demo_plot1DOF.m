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
%Can be either ".mat" or ".txt". To use the recorded ".txt" file samples, put: 'Data/traj1'
DataPath= 'Data/traj1_1DOF.mat';
typeRecover= '.mat'; %or .txt, it depends on your choice of data file.

inputName = {'z[m]'};%label of your inputs
s_ref=100; %reference number of samples
nbInput(1) = 1; %number of inputs used during the inference (here Cartesian position)
M(1) = 50; %number of basis functions to represent nbInput(1)

%This variable is the expected data noise, you can tune this parameter to achieve the trajectory correctly
expNoise = 0.00001;
percentData = 50; %percent of observed data during the inference
%type of cost function used to infer the modulation time
%('MO':model/'ML'maximum likelihood/ 'ME' average/'DI' distance).
choice = 'MO' ;
%%%%%%%%%%%%%% END VARIABLE CHOICE

%some variable computation to create basis function, you might have to
%change them
dimRBF = 0; 
for i=1:size(M,2)
    dimRBF = dimRBF + M(i)*nbInput(i);
end
c(1) = 1.0 / (M(1)); %center of gaussians
h(1) = c(1)/(M(1)); %bandwidth of the gaussians

if(strcmp(typeRecover,'.mat')==1)
    load(DataPath);
else
    %recover the data saved in the Data/trajX/recordY.txt files
    t{1} = loadTrajectory('Data/traj1', 'top', 'refNb', s_ref, 'nbInput',nbInput);
end
[train, test] =  partitionTrajectory(t{1}, 1, percentData, s_ref);

%plot recoverData
drawRecoverData(t{1}, inputName, 'Specolor','m','namFig', 1);

%compute the distribution for each kind of trajectories.
promp{1} = computeDistribution(train, M, s_ref,c,h);

%plot distribution
drawDistribution(promp{1}, inputName,s_ref);

%plot RBF
%drawBasisFunction(promp{1}.PHI_norm, M);

if (strcmp(choice,'ME')==1)
        expAlpha = promp{1}.mu_alpha;
else
    if(strcmp(choice,'MO')==1)
        %alpha model
        w = computeAlpha(test{1}.nbData,t, nbInput);
        promp{1}.w_alpha = w{1};
    end
        [expAlpha,type, x] = inferenceAlpha(promp,test{1},M,s_ref,c,h,test{1}.nbData, expNoise, choice);
end
display(['expAlpha= ', num2str(expAlpha), ' real alpha= ', num2str(test{1}.alpha)]);

%Recognition of the movement
infTraj = inference(promp, test{1}, M, s_ref, c, h, test{1}.nbData, expNoise, expAlpha);

%draw the infered movement
drawInference(promp,inputName,infTraj, test{1},s_ref);