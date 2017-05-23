function [maxAlpha,typet, x] = inferenceAlpha(promps,obsTraj,M,s_ref,c,h,nbData, expNoise, typeReco)
%INFERENCEALPHA finds the alpha that correspond the best to the given
%trajectory for all the trajectories.

nbTrajType = length(promps); %number of trajectory types

% we compute for each learned distribution and for each alpha, the loglikelihood that this
% movement correspond to the distribution
bestAlpha = zeros(nbTrajType,1);
xs = cell(nbTrajType);
proba = -Inf*ones(nbTrajType,1);
for i=1:nbTrajType
  [bestAlpha(i), proba(i), xs{i}] = computeBestAlpha(promps{i}, obsTraj, expNoise, promps{1}.traj.nbInput, M, nbData,s_ref,c,h, typeReco);
end

[~, typet] = max(proba);
maxAlpha = bestAlpha(typet); 
x =xs{typet}; %used for debbuging purpose: observed trajectories with "offset" (when we compute the best alpha, we put the initiated trajectory on the mean distribution).

