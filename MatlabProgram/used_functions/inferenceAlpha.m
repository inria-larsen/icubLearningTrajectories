function [maxAlpha,typet, x] = inferenceAlpha(promps,newTraj,nbFunctions,z,center_gaussian,h,nbData, expNoise, typeR)
%INFERENCEALPHA finds the alpha that correspond the best to the given
%trajectory for all the trajectories.

nbTrajType = length(promps); %number of trajectory type

% we compute for each learned distribution and for each data, the loglikelihood that this
% movement correspond to the distribution
bestAlpha = zeros(nbTrajType,1);
xs = cell(nbTrajType);
proba = -Inf*ones(nbTrajType,1);
for i=1:nbTrajType
  [bestAlpha(i), proba(i), xs{i}] = computeBestAlpha(promps{i}, newTraj, expNoise, promps{1}.traj.nbInput, nbFunctions, nbData,z,center_gaussian,h, typeR);
end

[~, typet] = max(proba);
maxAlpha = bestAlpha(typet); 
x =xs{typet}; %used for debbuging purpose: observed trajectories with "offset" (when we compute the best alpha, we put the initiated trajectory on the mean distribution).

