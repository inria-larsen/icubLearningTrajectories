function [error,obsTraj] = mesureDiff(type, meanTraj, varTraj, obsTraj, nbData,nbInputs)
%MESUREDIFF computes the error of the expected trajectory.
%
%INPUTS:
%type: type of error computation. Can be:
%%% "ML" for maximum likelihood;
%%% 'DI' for distance error (sqrt(|expectedTraj - realTraj|^2)
%%% 'LA' last data distance error (not correct yet).
%meanTraj: expected trajectory retrieve from models.
%varTraj: variance of the expected trajectory retrieve from models.
%obsTraj: observed trajectory
%nbData: number of observed data 
%nbInputs: number of inputs that define the trajectory
%
%OUTPUT:
%error: the error in between the expected trajectory and the real one.
%obsTraj: the observed trajectory with offset at the begining to replace
%the observed trajectory in the center of the expected ProMP

    if(strcmp(type, 'ML')) %Maximum likelihood type
        
        %add an offset on the observed trajectory
        offset =zeros(nbInputs,1);
        for i=1:nbInputs
            offset(i) = meanTraj((i-1)*nbData +1) - obsTraj((i-1)*nbData +1);
            obsTraj((i-1)*nbData +1:i*nbData) = obsTraj((i-1)*nbData +1:i*nbData) + offset(i); 
        end
       
       %compute ML
       [Sigma, p] = chol(varTraj);
       if(p ~=0) 
           error('Error in the cholesky decomposition');
       end
       logdetSigma = sum(log(diag(Sigma))); % logdetSigma
       Mat = (obsTraj-meanTraj)'*(varTraj\(obsTraj-meanTraj));
       error = -(nbInputs*nbData/2)*log(2*pi) -(nbData/2)*logdetSigma -0.5*sum((obsTraj-meanTraj)'*(varTraj\(obsTraj-meanTraj)));  

    elseif(strcmp(type, 'DI')) %distance type
        %add an offset on the observed trajectory
        offset =zeros(nbInputs,1);
        for i=1:nbInputs
            offset(i) = meanTraj((i-1)*nbData +1) - obsTraj((i-1)*nbData +1);
            obsTraj((i-1)*nbData +1:i*nbData) = obsTraj((i-1)*nbData +1:i*nbData) + offset(i); 
        end
        
        %compute distance
        error = - mean(abs(meanTraj - obsTraj));
        
    %TODO: verify this function: not currently good.    
%     elseif(strcmp(type,'LA'))%last data: not accurate and used yet 
%         %in this case we don't use offset trajectory.
%         
%         error = - mean(abs(meanTraj(nbData*2+1:nbData*3) - obsTraj(nbData*2+1:nbData*3) ));
    else %we don't recognize the typ of error computation
       display('error, the asked type of error computation is not recognized');
       error = NaN;
    end
end