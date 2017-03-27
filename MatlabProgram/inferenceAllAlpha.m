function [maxAlpha,typet, x] = inferenceAllAlpha(promps,newTraj,nbFunctions,z,center_gaussian,h,nbData, expNoise)
%inferenceAllAlpha
%in this function, we find the good trajectory and the good alpha

nbKindOfTraj = length(promps);
nbInput(1)= promps{1}.traj.nbInput(1);
nbInput(2) = promps{1}.traj.nbInput(2);

% we compute for each learned distribution the loglikelihood that this
% movement correspond to the distribution
reco = {0 , -Inf };
bestAlpha = zeros(nbKindOfTraj,1);
proba = zeros(nbKindOfTraj,1);
xs = cell(nbKindOfTraj);
for i=1:nbKindOfTraj
    [bestAlpha(i), proba(i), xs{i}] = computeBestAlpha(promps{i}, newTraj, expNoise, nbInput, nbFunctions, nbData,z,center_gaussian,h);
end

[maximum, typet] = max(proba);
maxAlpha = bestAlpha(typet); 
x =xs{typet}; %used to debug: observed trajectory with offset
