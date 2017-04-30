function promp = computeDistribution(traj, M, s_ref,c,h)
%COMPUTEDISTRIBUTION
%This function computes the distribution for each kind of trajectory.
  
    promp.traj = traj;
   %for each trajectory
    for j = 1:traj.nbTraj 
        %we compute the corresponding PHI matrix
         promp.PHI{j} = computeBasisFunction (s_ref,M, promp.traj.nbInput, promp.traj.alpha(j), promp.traj.totTime(j), c, h, promp.traj.totTime(j));
    end
    promp.mu_alpha = mean(promp.traj.alpha);
    promp.sigma_alpha = cov(promp.traj.alpha);

    promp.PHI_norm = computeBasisFunction (s_ref,M,promp.traj.nbInput, 1, s_ref,c,h, s_ref);
    promp.PHI_mean = computeBasisFunction (s_ref,M,promp.traj.nbInput, promp.mu_alpha, s_ref*promp.mu_alpha,c,h, s_ref*promp.mu_alpha);

%     val = 0;
%     for cpt =1:size(promp.traj.nbInput,2)
%         val = val + promp.traj.nbInput(cpt)*nbFunctions(cpt);
%     end
    %w computation for each trials
    for j = 1 : promp.traj.nbTraj
        %resolve a little bug
        sizeY  = size(promp.traj.y{j},1);
        if(sizeY ~= size(promp.PHI{j},1))
            promp.traj.y{j} = promp.traj.y{j}(1:sizeY-(sum(promp.traj.nbInput)));
            promp.traj.totTime(j) = promp.traj.totTime(j) -sum(promp.traj.nbInput);
            promp.traj.alpha(j) = s_ref /promp.traj.totTime(j);
        end
       sizeNoise = size(promp.PHI{j}'*promp.PHI{j});
       %Least square
        w(j,:) = (promp.PHI{j}'*promp.PHI{j}+1e-12*eye(sizeNoise)) \ promp.PHI{j}' * promp.traj.y{j};        
        listw(j,:) =w(j,:); 
      %  promp.traj.interval(j) = promp.traj.interval(j)  + promp.traj.realTime{j}(promp.traj.totTime);

    end
    
    %computation of the w distribution     
    promp.mu_w = mean(listw)';
    promp.sigma_w = cov(listw); %sometimes have < 0 for forces as it is not
    promp.sigma_w = nearestSPD(promp.sigma_w);
    promp.meanTimes= length(promp.PHI_mean);%mean(promp.traj.totTime);
    promp.meanInterval = mean(promp.traj.interval);
end
   
   