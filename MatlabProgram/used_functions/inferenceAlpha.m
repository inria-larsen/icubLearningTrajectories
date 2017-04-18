function [maxAlpha,typet, x] = inferenceAlpha(promps,newTraj,nbFunctions,z,center_gaussian,h,nbData, expNoise, typeR)
%inferenceAllAlpha
%in this function, we find the good trajectory and the good alpha

nbKindOfTraj = length(promps);

nbInput= promps{1}.traj.nbInput;

% we compute for each learned distribution the loglikelihood that this
% movement correspond to the distribution
reco = {0 , -Inf };
bestAlpha = zeros(nbKindOfTraj,1);
proba = zeros(nbKindOfTraj,1);
xs = cell(nbKindOfTraj);
proba = -Inf;
maxAlpha = -NaN;
typet=-1;
for i=1:nbKindOfTraj
  [bestAlpha(i), proba(i), xs{i}] = computeBestAlpha(promps{i}, newTraj, expNoise, nbInput, nbFunctions, nbData,z,center_gaussian,h, typeR);
%     
%     velValr = abs(newTraj.partialTrajM(nbData,1:3)  - newTraj.partialTrajM(1,1:3));
%     basis{i} = AlphaBasis(velValr);
%     bestAlpha(i)  = basis{i}*promps{i}.w_alpha;
%     mu_w_coord = promps{i}.mu_w(1:nbInput(1)*nbFunctions(1));
%     sigma_w_coord = promps{i}.sigma_w(1:nbInput(1)*nbFunctions(1),1:nbInput(1)*nbFunctions(1));
%     PSI_coor{i} = computeBasisFunction(z,nbFunctions(1), nbInput(1), bestAlpha(i) , floor(z/bestAlpha(i) ), center_gaussian(1), h(1), nbData,center_gaussian);
%     u = PSI_coor{i}*mu_w_coord;
%     sigma = expNoise*eye(size(u,1));
%     [probaN,x] = mesureDiff('ML', u, sigma, newTraj.partialTraj, nbData, nbInput(1));
%     if(probaN > proba)
%         typet=i
%         proba = probaN;
%         maxAlpha = bestAlpha(i)
%     end
end

[maximum, typet] = max(proba);
maxAlpha = bestAlpha(typet); 
x =xs{typet}; %used to debug: observed trajectory with offset
