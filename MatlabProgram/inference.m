%INFERENCE
%in this function, we recongize a movement from some initial data
%and we complete it. We recognize and modify only the position information 

%In this inference version, we do the hypothesis that the phasis of the movement is the mean of the
%phasis used during the learning.


%accuracy that we want : choose randomly
trial = input(['Give the test you want to do (between 1 and ', num2str(nbKindOfTraj),')']);
%disp(['we try the number ', num2str(trial)])

%begin to play the first nbFirstData
replayRecognitionNbData;

%computation of the loglikelihood for each trajectory using only cartesian
%coordinates

%we cut the mu_w variables to correspond only to the cartesian position
%informaiton (without forces and wrench that are not used for the
%inference)
for i=1:nbKindOfTraj
    mu_w_coord{i} = mu_w{i}(1:nbDof(1)*nbFunctions(1));
%    mu_w_f{i} = mu_w{i}(nbDof(1)*nbFunctions(1)+1:nbDof(1)*nbFunctions(1)+nbDof(2)*nbFunctions(2));
    sigma_w_coord{i} = sigma_w{i}(1:nbDof(1)*nbFunctions(1),1:nbDof(1)*nbFunctions(1));
end

% we compute for each learned distribution the loglikelihood that this
% movement correspond to the distribution
reco = {0 , -Inf };
for i=1:nbKindOfTraj
    %matrix of cartesian basis functions that correspond to the first nbData 
    PSI_coor{i} = computeBasisFunction(z,nbFunctions(1), nbDof(1), mu_alpha(i), floor(z/mu_alpha(i)), center_gaussian(1), h, nbData);
    %matrix of forces basis functions that correspond to the first nbData
    %PSI_forces{i} = computeBasisFunction(z,nbFunctions(2), nbDof(2), mu_alpha(i), floor(z/mu_alpha(i)), center_gaussian(2), h(2), nbData);%computeBasisForces(z,nbFunctions(2),mu_alpha(i), floor(z/mu_alpha(i)), h, nbData);
    
    %matrix of basis functions for all data that correspond to the first
    %nbData with phasis alpha_mean
   PSI_mean{i} =  computeBasisFunction(z,nbFunctions, nbDof, mu_alpha(i), floor(z/mu_alpha(i)), center_gaussian, h, floor(z/mu_alpha(i)));%blkdiag(PSI_coor{i},PSI_forces{i}); %PSI_coor{i};
    
   %we compute the learned distribution trajectory of cartesian position
    u{i} = PSI_coor{i}*mu_w_coord{i};
    sigma{i} = PSI_coor{i}*sigma_w_coord{i}*PSI_coor{i}' + accuracy*eye(size(PSI_coor{i}*sigma_w_coord{i}*PSI_coor{i}'));
    
    %TODO change this part: from the initial movement it is more correct to
    %compare the distance than le likelihood 
    %we compute the probability it correspond to the actual trial
    prob{i}= - mean(abs(y_trial{trial}(1:nbDof(1)*nbData,:) -u{i}));     
    
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
mu_new = mu_w{reco{1}};
sigma_new = sigma_w{reco{1}}; 


%we aren't suppose to know "realData",  here it is only used to draw the real
%trajectory of the sample if we continue it to the end
realAlpha = z /totalTimeTrial(trial);
timeInf = z / mu_alpha(reco{1});
display(['The real phasis is ', num2str(realAlpha), ' with total time : ', num2str(totalTimeTrial(reco{1})) ])
display(['The supposed phasis is ', num2str(mu_alpha(reco{1})), ' with total time : ', num2str(z / mu_alpha(reco{1})) ])

%%Creation of the basis function with mean phasis & nbData iterations
PSI_inf = PSI_mean{reco{1}};
ma = ones(1,nbData);
mb = zeros(1,round(z / mu_alpha(reco{1}))- nbData); 
mc = zeros(1, round(z / mu_alpha(reco{1})));
ma = [ma, mb]; % 1 for data we know 0 for the others
mk = []; % C/C the mask for other data
for vv = 1:nbDof
    mk = [mk, ma]; 
end 
mask = logical(mk);

%creation  of the basis function matrix
PSI_update = PSI_inf(mask,:);

%distribution update
K = sigma_new*PSI_update' * inv(accuracy*eye(size(PSI_update*sigma_new*PSI_update')) + PSI_update*sigma_new*PSI_update');
mu_new = mu_new + K* (y_trial{trial}(1:nbData*nbDof(1),:) - PSI_update*mu_new);
sigma_new = sigma_new - K*(PSI_update*sigma_new);

% %to compute error function
% psi_inf_tot = computeBasisFunction(z,nbFunctions, nbDof, mu_alpha(i), (z/mu_alpha(i)), center_gaussian, h, (z/mu_alpha(i)));
% minSize= min(size(psi_inf_tot,1), size(y_trial_Tot{trial},1));
% tmp = psi_inf_tot*mu_new;
% display(['difference entre les courbes for ', num2str(nbData), 'data']);
% sum(abs(y_trial_Tot{trial}(1:minSize,:) -tmp(1:minSize,:)))
