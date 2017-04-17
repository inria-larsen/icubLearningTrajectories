function [infTraj] = inference(promps,newTraj,nbFunctions,z,center_gaussian,h,nbData, expNoise, alphacomp)
%INFERENCE
%in this function, we recongize a movement from some initial data
%and we complete it. We recognize and modify only the position information 
%In this inference version, we do the hypothesis that the phasis of the movement is the mean of the
%phasis used during the learning.


nbKindOfTraj = length(promps);
nbInput= promps{1}.traj.nbInput;

% %TODO triche avec bon alpha:
% for i=1:nbKindOfTraj
%     promps{1}.mu_alpha = newTraj.alpha;
% end

%computation of the loglikelihood for each trajectory using only cartesian
%coordinates

%we cut the mu_w variables to correspond only to the cartesian position
%informaiton (without forces and wrench that are not used for the
%inference)
for i=1:nbKindOfTraj
    mu_w_coord{i} = promps{i}.mu_w(1:nbInput(1)*nbFunctions(1));
%    mu_w_f{i} = mu_w{i}(nbDof(1)*nbFunctions(1)+1:nbDof(1)*nbFunctions(1)+nbDof(2)*nbFunctions(2));
    sigma_w_coord{i} = promps{i}.sigma_w(1:nbInput(1)*nbFunctions(1),1:nbInput(1)*nbFunctions(1));
end

% we compute for each learned distribution the loglikelihood that this
% movement correspond to the distribution
reco = {0 , -Inf };
for i=1:nbKindOfTraj
    %matrix of cartesian basis functions that correspond to the first nbData 
    PSI_coor{i} = computeBasisFunction(z,nbFunctions(1), nbInput(1), alphacomp, floor(z/alphacomp), center_gaussian(1), h(1), nbData);
    %matrix of forces basis functions that correspond to the first nbData
    %PSI_forces{i} = computeBasisFunction(z,nbFunctions(2), promps{i}.traj.nbInput(2),promps{i}.mu_alpha, floor(z/promps{i}.mu_alpha), center_gaussian(2), h(2), nbData);%computeBasisForces(z,nbFunctions(2),mu_alpha(i), floor(z/mu_alpha(i)), h, nbData);
    
    %matrix of basis functions for all data that correspond to the first
    %nbData with phasis alpha_mean
    PSI{i} =  computeBasisFunction(z,nbFunctions, nbInput, alphacomp, floor(z/alphacomp), center_gaussian, h, floor(z/alphacomp));%blkdiag(PSI_coor{i},PSI_forces{i}); %PSI_coor{i};
    
    %we compute the learned distribution trajectory of cartesian position
    u{i} = PSI_coor{i}*mu_w_coord{i};
    sigma{i} = PSI_coor{i}*sigma_w_coord{i}*PSI_coor{i}' + expNoise*eye(size(PSI_coor{i}*sigma_w_coord{i}*PSI_coor{i}'));
    
    %TODO change this part: from the initial movement it is more correct to
    %compare the distance than le likelihood 
    %we compute the probability it correspond to the actual trial
    prob{i}= - mean(abs(newTraj.partialTraj(1:nbInput(1)*nbData,:) -u{i}));     
    
    %we record the max of probability to know wich distribution we
    %recognize
    if(prob{i} > reco{2})
        reco{2} = prob{i};
        reco{1} = i;
    end
end

disp(['The recognize trajectory is the number ', num2str(reco{1})])

%we retrieve the computed distribution that correspond to the recognized
%trajectory
mu_new = promps{reco{1}}.mu_w;
sigma_new = promps{reco{1}}.sigma_w;

%we aren't suppose to know "realData",  here it is only used to draw the real
%trajectory of the sample if we continue it to the end
display(['The real phasis is ', num2str(newTraj.alpha), ' with total time : ', num2str(newTraj.totTime) ])
display(['The supposed phasis is ', num2str(alphacomp), ' with total time : ', num2str(z / alphacomp) ])

%%Creation of the basis function with mean phasis & nbData iterations
 
infTraj.alpha =  alphacomp;
infTraj.timeInf = z / infTraj.alpha ;
infTraj.PSI = PSI{reco{1}};
ma = ones(1,nbData);
mb = zeros(1,round(z /infTraj.alpha)- nbData); 
mc = zeros(1, round(z /infTraj.alpha));
ma = [ma, mb]; % 1 for data we know 0 for the others
mk = []; % C/C the mask for other data
for vv = 1:nbInput
    mk = [mk, ma]; 
end 
mask = logical(mk);

%creation  of the basis function matrix
PSI_update = infTraj.PSI(mask,:);

%distribution update
K = sigma_new*PSI_update' * inv(expNoise*eye(size(PSI_update*sigma_new*PSI_update')) + PSI_update*sigma_new*PSI_update');
mu_new = mu_new + K* (newTraj.partialTraj(1:nbData*nbInput(1),:) - PSI_update*mu_new);
sigma_new = sigma_new - K*(PSI_update*sigma_new);

infTraj.mu_w = mu_new;
infTraj.sigma_w = sigma_new;
infTraj.reco = reco{1}; 

% %to compute error function
% psi_inf_tot = computeBasisFunction(z,nbFunctions, nbDof, alphacomp, (z/alphacomp), center_gaussian, h, (z/alphacomp));
% minSize= min(size(psi_inf_tot,1), size(newTraj.traj,1));
% tmp = psi_inf_tot*mu_new;
% display(['difference entre les courbes for ', num2str(nbData), 'data']);
% sum(abs(newTraj.traj(1:minSize,:) -tmp(1:minSize,:)))
end