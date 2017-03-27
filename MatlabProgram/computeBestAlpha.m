function [value,bestproba, xest] = computeBestAlpha(ProMP, newTraj, expNoise, nbInput, nbFunctions, nbData,z,center_gaussian,h)
%COmpute the best alpha in one kind of trajectory in the set of observed
%alphas during learing.
%INPUTS:
%ProMP: the actual treated trajectory
%newTraj: the observed trajectory we want to infer
%expNoise: the expected noise in the data observed
%nbInput : the number of inputs we use for the recognition
%nbFunction: the number of functions we use for modelize the trajectories
%nbData : the number of observed trajectories
% z : reference modulation time
% center of gaussian/h : parameters for the RBF of the model
%OUTPUT:
% value: alpha's value that maximize the loglikelihood
% proba: value of the corresponding loglikelihood
% xest: observed trajectory with the offset (for debug/ plot)

    mu_w_coord = ProMP.mu_w(1:nbInput(1)*nbFunctions(1));
    sigma_w_coord = ProMP.sigma_w(1:nbInput(1)*nbFunctions(1),1:nbInput(1)*nbFunctions(1));
    %we compute the learned distribution trajectory of cartesian position
    
    bestproba = -Inf; %mesureDiff('ML', u, sigma, newTraj, nbData, nbInput(1));
    %bestAlpha.value = ProMP.traj.alpha(1);
   % proba = zeros(length(ProMP.traj.alpha),2);
  fig= figure
     cpt=1;
v = zeros(nbData,1);
    for i=1:length(ProMP.traj.alpha)
        PSI_coor{i} = computeBasisFunction(z,nbFunctions(1), nbInput(1), ProMP.traj.alpha(i), floor(z/ProMP.traj.alpha(i)), center_gaussian(1), h(1), nbData,center_gaussian);
        %we compute the learned distribution trajectory of cartesian position
%         for t=1:nbData
%         u{t} = PSI_coor{i}{t}*mu_w_coord;
%         clear tmp;
%         tmp = PSI_coor{i}{t}*sigma_w_coord*PSI_coor{i}{t}';
%         sigma{t} = tmp + expNoise*eye(size(tmp));
%         end     
 

%%PROMP alexandros
        u = PSI_coor{i}*mu_w_coord;
        clear tmp;
        tmp = PSI_coor{i}*sigma_w_coord*PSI_coor{i}';
        sigma = tmp + expNoise*eye(size(tmp));
%%% A Probabilistic Approach to Robot Trajectory Generation + book pattern reco
        sigma = expNoise*eye(size(tmp));
        
        
        [proba(i,1),x] = mesureDiff('LA', u, sigma, newTraj.partialTraj, nbData, nbInput(1));
        proba(i,2)=ProMP.traj.alpha(i);
        
        if(proba(i,1) > bestproba)
            i
            bestproba = proba(i,1);
            value = proba(i,2);
            xest = x;
            cpt = cpt+1;
            if(v(1)~=0)
            subplot(1,3,1);
            fig(length(fig)+1) = plot(v(1:nbData),'k');
            subplot(1,3,2);
            fig(length(fig)+1) = plot(v(nbData+1:nbData*2),'k');
            subplot(1,3,3);
            fig(length(fig)+1) = plot(v(nbData*2+1:nbData*3),'k');
            end
            subplot(1,3,1);
              hold on;

            fig(length(fig)+1) =  plot(u(1:nbData),'g');
            subplot(1,3,2);
              hold on;

            fig(length(fig)+1) =  plot(u(nbData+1:nbData*2),'g');
            subplot(1,3,3);
              hold on;

            fig(length(fig)+1) =  plot(u(nbData*2+1:nbData*3),'g');
            v=u;
        end
    end
    subplot(1,3,1);
    fig(length(fig)+1) = plot(newTraj.partialTraj(1:nbData), 'b'); 
    fig(length(fig)+1) = plot(x(1:nbData), 'm'); 
    subplot(1,3,2);
    fig(length(fig)+1) = plot(newTraj.partialTraj(nbData+1:nbData*2), 'b'); hold on;
    fig(length(fig)+1) = plot(x(nbData+1:nbData*2), 'm'); 
    title('max_\alpha(likelihood)');
    xlabel('Known samples');
    subplot(1,3,3);
    fig(length(fig)+1) = plot(newTraj.partialTraj(nbData*2+1:nbData*3), 'b'); hold on;
    fig(length(fig)+1) = plot(x(nbData*2+1:nbData*3), 'm'); 
    
    legend(fig([2,5, length(fig)-1, length(fig)]),'Best \alpha', 'Other \alpha', 'Real trajectory ', 'Trajectory with offset');

    
    
end