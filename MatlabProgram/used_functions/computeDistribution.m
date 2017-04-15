function promp = computeDistribution(traj, nbFunctions, z,center_gaussian,h)
%COMPUTEDISTRIBUTION
%This function computes the distribution for each kind of trajectory.
  
    promp.traj = traj;
   %for each trajectory
    for j = 1:traj.nbTraj 
        %we compute the corresponding PSI matrix
         promp.PSI{j} = computeBasisFunction (z,nbFunctions, promp.traj.nbInput, promp.traj.alpha(j), promp.traj.totTime(j), center_gaussian, h, promp.traj.totTime(j));
    end
    promp.mu_alpha = mean(promp.traj.alpha);
    promp.sigma_alpha = cov(promp.traj.alpha);

    promp.PSI_z = computeBasisFunction (z,nbFunctions,promp.traj.nbInput, 1, z,center_gaussian,h, z);

%     val = 0;
%     for cpt =1:size(promp.traj.nbInput,2)
%         val = val + promp.traj.nbInput(cpt)*nbFunctions(cpt);
%     end
    %w computation for each trials
    for j = 1 : promp.traj.nbTraj
        %resolve a little bug
        sizeY  = size(promp.traj.y{j},1);
        if(sizeY ~= size(promp.PSI{j},1))
            prom.traj.y{j} = prom.traj.y{j}(1:sizeY-(sum(promp.traj.nbInput)));
            prom.traj.totTime(j) = prom.traj.totTime(j) -sum(promp.traj.nbInput);
            prom.traj.alpha(j) = z /prom.traj.totTime(j);
        end
       sizeNoise = size(promp.PSI{j}'*promp.PSI{j});
       %Least square
        w(j,:) = (promp.PSI{j}'*promp.PSI{j}+1e-12*eye(sizeNoise)) \ promp.PSI{j}' * promp.traj.y{j};        
        listw(j,:) =w(j,:); 

    end
    
    %computation of the w distribution     
    promp.mu_w = mean(listw)';
    promp.sigma_w = cov(listw); %sometimes have < 0 for forces as it is not
    promp.sigma_w = nearestSPD(promp.sigma_w);
    promp.meanTimes= mean(promp.traj.totTime);
end
   
   