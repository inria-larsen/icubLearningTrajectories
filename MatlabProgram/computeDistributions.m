%COMPUTEDISTRIBUTION
%This function computes the distribution for each kind of trajectory.

for i=1:nbKindOfTraj
   
    for j = 1:var(i)
        %we compute the phasis
        alpha2{i}(j) = z / totalTime(i,j);
        %we compute the corresponding PSI matrix
        PSI{i}{j} = computeBasisFunction (z,nbFunctions, nbDof, alpha2{i}(j), totalTime(i,j), center_gaussian, h, totalTime(i,j));
    end
    mu_alpha(i) = mean(alpha2{i});
    sigma_alpha(i) = cov(alpha2{i});
    min_alpha_i(i) = min(alpha2{i});
    max_alpha_i(i) = max(alpha2{i});
end
min_alpha = min(min_alpha_i(i));
max_alpha = max(max_alpha_i(i));
PSI_z = computeBasisFunction (z,nbFunctions,nbDof, 1, z,center_gaussian,h, z);
%w computation for each trials
for i = 1 : nbKindOfTraj
    val = 0;
    clear test;
    for cpt =1:size(nbDof,2)
        val = val + nbDof(cpt)*nbFunctions(cpt);
    end
    for j = 1 : var(i)
        %resolve a little bug
        sizeY  = size(y{i}{j},1);
        if(sizeY ~= size(PSI{i}{j},1))
            y{i}{j} = y{i}{j}(1:sizeY-(nbDofTot));
            totalTime(i,j) = totalTime(i,j) -nbDofTot;
            alpha2{i}(j) = z /totalTime(i,j);
        end
       
        w{i}(j,:) = (PSI{i}{j}'*PSI{i}{j}+1e-12*eye(val)) \ PSI{i}{j}' * y{i}{j};        
        test(j,:) =w{i}(j,:); 

    end
    %computation of the w distribution     
    mu_w{i} = mean(test)';
    sigma_w{i} = cov(test); %sometimes have < 0 for forces as it is not
    sigma_w{i} = nearestSPD(sigma_w{i});
    
end
   % clear i j test w PSI min_alpha_i max_alpha_i cpt nf3D sizeY type val;

   
   