%This demo computes N proMPs given a set of recorded trajectories containing the demonstrations for the N types of movements. 
%It plots the results.

% by Oriane Dermy 07/09/2016
% For any problem / remark / improvement, contact me:
% oriane.dermy@gmail.com with subject [proMPs_toolbox]

close all;
clearvars;
warning('off','MATLAB:colon:nonIntegerIndex')
%%%%%%%%%%%%%%%VARIABLES, please refer you to the readme
%nameDataTrajectories = 'Data/traj1';
list = {'x[m]'};
%nbKindOfTraj =1;
z=100;
nbInput(1) = 1; %number of input used during the inference (here cartesian position)

nbFunctions(1) = 5; %number of basis functions

%variable tuned to achieve the trajectory correctly
expNoise = 0.00001;

for typeReco=1:2 %2%1:3
    switch typeReco
        case 1
            typeR = 'ML';
        case 2 
            typeR = 'DI';
        case 3 
            typeR = 'MO';
    end
    typeR
        
    for actTest=1:8
        actTest
        procentData = 10*actTest; %number of data max with what you try to find the correct movement

        %%%%%%%%%%%%%% END VARIABLE CHOICE

        %some variable computation to create basis function, you might have to
        %change them
        nbTotFunctions = 0; 
        for i=1:size(nbFunctions,2)
            nbTotFunctions = nbTotFunctions + nbFunctions(i)*nbInput(i);
        end
        center_gaussian(1) = 1 / (nbFunctions(1));
        h(1) = center_gaussian(1)/(nbFunctions(1)); %bandwidth of the gaussians

        %recover the data saved in the Data/trajX/recordY.txt files
        load('Data/toy_1DOF.mat');
        %plot recoverData
        %drawRecoverData(t{1}, list);
        
        [train1, test1] = partitionTrajectory(t{1},90);

        %compute the distribution for each kind of trajectories.
        %we define var and TotalTime in this function
        %here we need to define the bandwith of the gaussians h
        %computeDistributions_withCrossOver;
        promp{1} = computeDistribution(train1, nbFunctions, z,center_gaussian,h);

        %plot distribution
        drawDistribution(promp, list,z);

%%
        data.Errortype{typeReco}(actTest) = 0;
        for trial=1:test1.nbTraj

            %creation of a trajectory test
            test.traj = test1.y{trial};
            test.trajM = test1.yMat{trial};
            test.totTime =  test1.totTime(trial);
            test.alpha = z / test.totTime;
            test.partialTraj = [];
            nbData = round((test.totTime*procentData)/100);
            test.partialTrajM = test.trajM(1:nbData,:);
            test.nbData = nbData;
            for i=1:test1.nbInput(1)
                test.partialTraj = [test.partialTraj; test1.yMat{trial}(1:nbData,i)];
            end

            % %%%test alpha computation from nbData
            % w = computeAlpha(nbData,t);
            % %[promp{1}.w_alpha] = computeAlpha(nbData,t1);
            % promp{1}.w_alpha = w{1};
            % promp{2}.w_alpha = w{2};

            %Recognition of the movement
            [alphaTraj,type, x] = inferenceAlpha(promp,test,nbFunctions,z,center_gaussian,h,nbData, expNoise, typeR);
            infTraj = inference(promp, test, nbFunctions, z, center_gaussian, h, nbData, expNoise, alphaTraj);


            drawInference(promp,infTraj, test,z)
            if(type~=1) % Error number of trajectory type recognition
                data.Errortype{typeReco}(actTest) = data.Errortype{typeReco}(actTest) + 1;
            else
                %%%compute distance error
                psi_inf_tot = computeBasisFunction(z,nbFunctions, nbInput, alphaTraj, (z/alphaTraj), center_gaussian, h, (z/alphaTraj));
                minSize= min(size(psi_inf_tot,1), size(test.traj,1));
                tmp = psi_inf_tot*infTraj.mu_w;
                display(['difference entre les courbes for ', num2str(nbData), 'data']);
                data.DiffCourbs{typeReco}(actTest, trial-data.Errortype{typeReco}(actTest) ) = sum(abs(test.traj(1:minSize,:) -tmp(1:minSize,:)));

                %%%compute alphaTimeError
                data.errAlpha{typeReco}(actTest, trial-data.Errortype{typeReco}(actTest) ) = abs(alphaTraj- test.alpha);
            end
        end
    end
end
%alphaTraj = promp{1}.mu_alpha

%  infTraj = inference(promp, test, nbFunctions, z, center_gaussian, h, nbData, expNoise, alphaTraj);
% % %%
% % %draw the infered movement
%  drawInference(promp,infTraj, test,z)
% 

