%In this demo, you can replay learned movement; then you can begin a movement with the geomagic on iCubGazeboSim. To that, you will use a Cpp program that records your movement as long as you press a Geomagic button. Then, this script retrieve these early observation, and infer the movement end. It replays it on the icubGazeboSim. 


% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]
close all;
clearvars;
addpath('used_functions');
warning('off','MATLAB:colon:nonIntegerIndex')

%%%%%%%%%%%%%%%VARIABLES, please refer you to the readme
inputName = {'x[m]','y[m]','z[m]', 'a_1','a_2','a_3', 'a_4'};
s_bar=100;
nbInput = 7%[3 4];%9 %number of input used during the inference (here cartesian position)

M(1) = 5; %number of basis functions for the first type of input
%M(2) = 5; %number of basis functions for the second type of input

%variable tuned to achieve the trajectory correctly
expNoise = 0.00001;
percentData = 40; %number of data with what you try to find the correct movement
%%%%%%%%%%%%%% END VARIABLE CHOICE

%some variable computation to create basis function, you might have to
%change them
dimRBF = 0; 
for i=1:size(M,2)
    dimRBF = dimRBF + M(i)*nbInput(i);
    c(i) = 1.0 / (M(i));%center of gaussians
    h(i) = c(1)/M(i); %bandwidth of gaussians
end

connexion = initializeConnectionRealIcub    
%%
 closeEndOrder = 'left close_hand';
 connexion.grasp.clear();
 connexion.grasp.fromString(closeEndOrder);
 connexion.portGrasp.write(connexion.grasp);
 a = input('Press enter when the robot has closed its hand');
 connexion.portGrasp.close;
%retrieve trajectories done with the real iCub
load('Data/icub_frontiersWithMatlab.mat');
for i=1:length(t)
    t{i}.nbInput = nbInput;
end

% 
% % %take one of the trajectory randomly to do test{1}, the others are stocked in
% % %train.
% [train{1},test{1}] = partitionTrajectory(t{1},1,percentData,s_bar);
% [train{2},test{2}] = partitionTrajectory(t{2},1,percentData,s_bar);
% clear test;
%Compute the distribution for each kind of trajectories.
promp{1} = computeDistribution(t{1}, M, s_bar,c,h);
promp{2} = computeDistribution(t{2}, M, s_bar,c,h);

%cont=1;
%while( cont==1)
%%     
    test{1} = beginATrajectoryWithRealIcub(connexion);
    connexion.portSkin.close;
    connexion.portState.close;
    
    w = computeAlpha(test{1}.nbData,t, nbInput);
    promp{1}.w_alpha= w{1};
    promp{2}.w_alpha= w{2};
    %Recognition of the movement
    [alphaTraj,type, x] = inferenceAlpha(promp,test{1},M,s_bar,c,h,test{1}.nbData, expNoise, 'MO');
    recoPromp{1} =promp{type}; % we keep only the inferred ProMP
    [infTraj,typeReco] = inference(promp, test{1}, M, s_bar, c, h, test{1}.nbData, expNoise, alphaTraj, connexion);

    recoPromp{1}
    typeReco
    %to ask icub to say the label of the recognize trajectory
    %sayType(promp{typeReco}.traj.label, connexion);
    drawInference(promp,inputName,infTraj, test{1},s_bar)

    continueMovementiCubGui(infTraj,connexion, test{1}.nbData,s_bar, promp{type}.PHI_norm,inputName);
    %replay the movement into gazebo
    %connexion.portIG.close;
        
    a = input('press "y" if you want to replay on icub or "n" ');
    while(strcmp(a, 'y')==0)
        a = input(' press "y" when ready'); 
        if(strcmp(a, 'n') ==1)
            break;
        end
    end
    
    
    if(strcmp(a,'y') ==1)
        continueMovement(infTraj,connexion, test{1}.nbData,s_bar, promp{type}.PHI_norm,inputName);
    end
    pause(3);  
     connexion.portGrasp.open('/matlab/grasp:o');
     system('yarp connect /matlab/grasp:o /grasper/rpc:i');
     closeEndOrder = 'left open_hand';
     connexion.grasp.clear();
     connexion.grasp.fromString(closeEndOrder);
     connexion.portGrasp.write(connexion.grasp);
    %cont = input('Do you want to infer again? (yes=1, no=0)');
%end

%close the port and the program replay.
closeConnectionRealIcub(connexion);
