function PSI = computeBasisFunction(refTime,nbFunctions, nbInput, alpha, totalTime, center_gaussian, h, nbData)
%COMPUTEBASISFUNCTION creates the basis function matrix. 
%tall: [nbInput*nbData]x[nbFunctions*nbData]
%Inputs:
% refTime: time reference used to compute promp independently to the
% trajectory phases.
% nbFunctions: number of RBF we want to model the trajectory
% alpha: phasis of the trajectory
% totalTime: the total number of samples to finish the trajectory
% center_gaussian: where the functions will be placed.
% h: bandwith of the RBF
% nbData: normally = totalTime. But if you want a subpart of the matrix,
% you can specify this number.

    for k=1:size(nbFunctions,2)
        for i = 1 : nbFunctions(k) 
            c(k,i) = center_gaussian(k)*(i-1); 
        end

        for t=1:totalTime
            %creating a basis functions model (time*nbFunctions)
            for i = 1 : nbFunctions(k)
                val{k} = -(alpha*t*(1/refTime)-c(k,i))*(alpha*t*(1/refTime)-c(k,i))/(h(k));
                basis{k}(t,i) = exp(val{k});
            end

            %normalization of the RBF
            sumBI = sum(basis{k}(t,:));
            for i = 1 : nbFunctions(k)
                phi{k}(t,i) = basis{k}(t,i) / sumBI;
            end
        end
    end    

    %Creation of the diagonal matrix of all the basis functions
    for i=1:size(nbFunctions,2)
        for j =1:nbInput(i)
           if and(i==1,j==1)
               PSI = phi{i}(1:nbData,:);
           else
               PSI = blkdiag(PSI, phi{i}(1:nbData,:));
           end
        end
    end
end
