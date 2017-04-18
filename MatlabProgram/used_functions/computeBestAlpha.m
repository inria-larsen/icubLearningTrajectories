function [value,bestproba, xest] = computeBestAlpha(ProMP, newTraj, expNoise, nbInput, nbFunctions, nbData,refTime,center_gaussian,h, type)
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
   
    proba = zeros(length(ProMP.traj.alpha),2);
 %   fig= figure;
 %   hold on;
    cpt=1;
    
    %initialization of the alpha's value thatmaximize the log
    value = NaN;
    xest = NaN;
    
 if(type == 'MO')%Model: we don't tes all the alpha i
    variation = abs(newTraj.trajM(nbData,1:nbInput(1))  - newTraj.trajM(1,1:nbInput(1)));
    basis = AlphaBasis(variation);
    value  = basis*ProMP.w_alpha;
    mu_w_coord = ProMP.mu_w(1:nbInput(1)*nbFunctions(1));
%    sigma_w_coord = ProMP.sigma_w(1:nbInput(1)*nbFunctions(1),1:nbInput(1)*nbFunctions(1));
    if(floor(refTime/value )<nbData) %the model found a too long trajectory, we force the trajectory to spend as least nbData sample times
        value = refTime /nbData;
    end
        
        PSI_coor = computeBasisFunction(refTime,nbFunctions(1), nbInput(1), value , floor(refTime/value ), center_gaussian(1), h(1), nbData,center_gaussian);
        umax = PSI_coor*mu_w_coord;
        sigmax = expNoise*eye(size(umax,1));
        [bestproba,x] = mesureDiff('ML', umax, sigmax, newTraj.partialTraj, nbData, nbInput(1));
        xest=x;
 else
 
    for i=1:length(ProMP.traj.alpha)
        if(floor(refTime/ProMP.traj.alpha(i)) < nbData)
            display(['Cannot take into account', num2str(i), 'th trajectory (not enougth data)']);
            %continue;
        else
            PSI_coor{i} = computeBasisFunction(refTime,nbFunctions(1), nbInput(1), ProMP.traj.alpha(i), floor(refTime/ProMP.traj.alpha(i)), center_gaussian(1), h(1), nbData,center_gaussian);
            %we compute the learned distribution trajectory of cartesian position
    %         for t=1:nbData
    %         u{t} = PSI_coor{i}{t}*mu_w_coord;
    %         clear tmp;
    %         tmp = PSI_coor{i}{t}*sigma_w_coord*PSI_coor{i}{t}';
    %         sigma{t} = tmp + expNoise*eye(size(tmp));
    %         end     


    %%PROMP alexandros
            u = PSI_coor{i}*mu_w_coord;
            sig = PSI_coor{i}*1.96*sqrt(diag(sigma_w_coord));
            %clear tmp;
            %tmp = PSI_coor{i}*sigma_w_coord*PSI_coor{i}';
            %sigma = tmp + expNoise*eye(size(tmp));
    %%% A Probabilistic Approach to Robot Trajectory Generation + book pattern reco
            sigma = expNoise*eye(size(u,1));


            [proba(i,1),x] = mesureDiff(type, u, sigma, newTraj.partialTraj, nbData, nbInput(1));
            proba(i,2)=ProMP.traj.alpha(i);

            if(proba(i,1) > bestproba)
     %          umax = u;
     %          sigmax = sig;
                bestproba = proba(i,1);
                value = proba(i,2);
                xest = x;
               cpt = cpt+1;

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
%              subplot(1,3,1);
%               hold on;
% 
%             fig(length(fig)+1) =  plot(umax(1:nbData),'g');
%             visualisationShared(umax, sigmax, nbInput(1), nbData,  1, 'g', fig);
%             
%             subplot(1,3,2);
%               hold on;
% 
%             fig(length(fig)+1) =  plot(umax(nbData+1:nbData*2),'g');
%             visualisationShared(umax, sigmax, nbInput(1), nbData,  2, 'g', fig);
%             subplot(1,3,3);
%                hold on;
% 
%             fig(length(fig)+1) =  plot(umax(nbData*2+1:nbData*3),'g');
%             visualisationShared(umax, sigmax, nbInput(1), nbData,  3, 'g', fig);
%              best = length(fig);
%   
%     
%     subplot(1,3,1);
%     fig(length(fig)+1) = plot(newTraj.partialTraj(1:nbData), 'b'); 
%     fig(length(fig)+1) = plot(x(1:nbData), 'm'); 
%     subplot(1,3,2);
%     fig(length(fig)+1) = plot(newTraj.partialTraj(nbData+1:nbData*2), 'b'); hold on;
%     fig(length(fig)+1) = plot(x(nbData+1:nbData*2), 'm'); 
%     title('max_\alpha(likelihood)');
%     xlabel('Known samples');
%     subplot(1,3,3);
% 
%     fig(length(fig)+1) = plot(newTraj.partialTraj(nbData*2+1:nbData*3), 'b'); hold on;
%     real = length(fig);
%     fig(length(fig)+1) = plot(x(nbData*2+1:nbData*3), 'm'); 
%   offst= length(fig);   
% if(type == 'MO')
%     legend(fig([best, real, offst]),'Infered \alpha',  'Real trajectory ', 'Trajectory with offset');
% else
%   legend(fig([best,oth, real, offst]),'Best \alpha', 'Other \alpha', 'Real trajectory ', 'Trajectory with offset');
% end
   
    
end