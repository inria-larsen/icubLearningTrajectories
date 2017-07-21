function [value,bestproba, xest] = computeBestAlpha(ProMP, obsTraj, expNoise, nbInputs, M, nbData,refTime,c,h, type)
%computeBestAlpha computes the best alpha in one kind of trajectory in the set of observed alphas during learing.
%
%INPUTS:
%ProMP: the actual treated trajectory
%newTraj: the observed trajectory we want to infer
%expNoise: the expected noise in the data observed
%nbInputs : the number of inputs we use for the recognition
%nbFunctions: the number of functions we use for modelize the trajectories
%nbData : the number of observed trajectories
%refTime : reference modulation time
%center of gaussian/h : parameters for the RBF of the model
%
%OUTPUTS:
% value: alpha's value that maximize the loglikelihood
% proba: value of the corresponding loglikelihood
% xest: observed trajectory with the offset (for debug/ plot)
    
    %we retrieve the learned distribution trajectory of the input used for
    %inference (example: cartesian position)
    mu_w_reco = ProMP.mu_w(1:nbInputs(1)*M(1));
    sigma_w_reco = ProMP.sigma_w(1:nbInputs(1)*M(1),1:nbInputs(1)*M(1));
    
    %initialization
    bestproba = -Inf;
    proba = zeros(length(ProMP.traj.alpha),2);
    cpt=1;
    value = NaN;%alpha's value that maximize the log
    xest = NaN;% observed trajectory with offset (to be centered on each distribution)
    
%%%Plot for debugging purpose:
%fig= figure;hold on;

     if(type == 'MO')%Model: we compute THE alpha that correspond to the learned alpha model.
        
        %computes the expected alpha using the model
        variation = abs(obsTraj.yMat(nbData,1:nbInputs(1))  - obsTraj.yMat(1,1:nbInputs(1)));
        basis = AlphaBasis(variation);
        value  = basis*ProMP.w_alpha;
        if(floor(refTime / value )<nbData) %if the model found a too short alpha phasis, we force the trajectory to spend as least nbData sample times
            value = refTime /nbData;
        end
        
        %computes the maximum likelihood that this alpha with this ProMP corresponds to the observed trajectory 
        PHI_reco = computeBasisFunction(refTime,M(1), nbInputs(1), value , round(refTime/value), c(1), h(1), nbData);
        umax = PHI_reco*mu_w_reco;
        sigmax = expNoise*eye(size(umax,1));
        [bestproba,x] = mesureDiff('ML', umax, sigmax, obsTraj.partialTraj, nbData, nbInputs(1)); %mesure of the error using Maximum Likelihood
        xest=x; %keep offset information used.
     else

        for i=1:length(ProMP.traj.alpha) % for each alpha observed during learning step
            if(floor(refTime/ProMP.traj.alpha(i)) < nbData) % we look if the alpha phasis is not too short (expected trajectory length < nbData)
                display(['Cannot take into account', num2str(i), 'th trajectory (not enougth data)']);
            else
                PHI_reco{i} = computeBasisFunction(refTime,M(1), nbInputs(1), ProMP.traj.alpha(i), floor(refTime/ProMP.traj.alpha(i)), c(1), h(1), nbData,c);    
                traj_mean = PHI_reco{i}*mu_w_reco;
                %sig = PHI_reco{i}*1.96*sqrt(diag(sigma_w_reco));
                % from a Probabilistic Approach to Robot Trajectory Generation + book pattern reco:
                traj_var = expNoise*eye(size(traj_mean,1));
                [proba(i,1),x] = mesureDiff(type, traj_mean, traj_var, obsTraj.partialTraj, nbData, nbInputs(1));%mesure of the error using the type "type"
                proba(i,2)=ProMP.traj.alpha(i); %save alpha value information
                if(proba(i,1) > bestproba)
                    bestproba = proba(i,1);
                    value = proba(i,2);
                    xest = x;
                    cpt = cpt+1;
                    
%%%Plot for debugging purpose:
%             subplot(1,3,1);hold on;
%             fig(length(fig)+1) = plot(u(1:nbData),':k');
%             subplot(1,3,2);hold on;
%             fig(length(fig)+1) = plot(u(nbData+1:nbData*2),':k');
%             subplot(1,3,3);hold on;
%             fig(length(fig)+1) = plot(u(nbData*2+1:nbData*3),':k');
%             oth= length(fig);hold on;
                end
            end
        end
     end
%      figure;
%      scatter(proba(:,2), proba(:,1));
%      hold on;
%      vline(obsTraj.alpha)
     
%%Plot for debugging purpose:  
%  subplot(1,3,1);
%   hold on;
% 
% fig(length(fig)+1) =  plot(umax(1:nbData),'g');
% visualisationShared(umax, sigmax, nbInput(1), nbData,  1, 'g', fig);
% 
% subplot(1,3,2);
%   hold on;
% 
% fig(length(fig)+1) =  plot(umax(nbData+1:nbData*2),'g');
% visualisationShared(umax, sigmax, nbInput(1), nbData,  2, 'g', fig);
% subplot(1,3,3);
%    hold on;
% 
% fig(length(fig)+1) =  plot(umax(nbData*2+1:nbData*3),'g');
% visualisationShared(umax, sigmax, nbInput(1), nbData,  3, 'g', fig);
%  best = length(fig);
%   
%     
% subplot(1,3,1);
% fig(length(fig)+1) = plot(newTraj.partialTraj(1:nbData), 'b'); 
% fig(length(fig)+1) = plot(x(1:nbData), 'm'); 
% subplot(1,3,2);
% fig(length(fig)+1) = plot(newTraj.partialTraj(nbData+1:nbData*2), 'b'); hold on;
% fig(length(fig)+1) = plot(x(nbData+1:nbData*2), 'm'); 
% title('max_\alpha(likelihood)');
% xlabel('Known samples');
% subplot(1,3,3);
% 
% fig(length(fig)+1) = plot(newTraj.partialTraj(nbData*2+1:nbData*3), 'b'); hold on;
% real = length(fig);
% fig(length(fig)+1) = plot(x(nbData*2+1:nbData*3), 'm'); 
% offst= length(fig);   
% if(type == 'MO')
% legend(fig([best, real, offst]),'Infered \alpha',  'Real trajectory ', 'Trajectory with offset');
% else
% legend(fig([best,oth, real, offst]),'Best \alpha', 'Other \alpha', 'Real trajectory ', 'Trajectory with offset');
% end
%    
    
end