
function PSI = computeBasisFunction(z,nbFunctions, nbDof, alpha, totalTime, center_gaussian, h, nbData, varargin)
%computeBasisFunction creates RBF in a matrix that corresponds to the
%number of input information we have and the number of basis function we
%have defined with their bandwith h.

    %creating the center of basis function model
    
	for k=1:size(nbFunctions,2)
	    for i = 1 : nbFunctions(k) 
	        c(k,i) = center_gaussian(k)*(i-1); 
	    end
	
	    for t=1:totalTime
	        %creating a basis functions model (time*nbFunctions)
	        for i = 1 : nbFunctions(k)
	            val{k} = -(alpha*t*(1/z)-c(k,i))*(alpha*t*(1/z)-c(k,i))/(h(k));
	            basis{k}(t,i) = exp(val{k});
	        end
	 
	        sumBI = sum(basis{k}(t,:));
	        for i = 1 : nbFunctions(k)
	            phi{k}(t,i) = basis{k}(t,i) / sumBI;
	        end
	    end
	end
	
	%IF we want the RBF as a matrix matrix    
	if((~isempty(varargin)) && (strcmp(varargin{1},'Mat')))
	    display('matrix!!')
	    
	    for t=1:nbData
	        for i=1:size(nbFunctions,2)
	            for j =1:nbDof(i)
	               if and(i==1,j==1)
	                   PSI{t} = phi{i}(t,:);
	               else
	                   PSI{t} = blkdiag(PSI{t}, phi{i}(t,:)); %TODO to optimize: can be use for inf? (loglikelihood)
	               end
	            end
	        end
	    end
	else
	    for i=1:size(nbFunctions,2)
	        for j =1:nbDof(i)
	           if and(i==1,j==1)
	               PSI = phi{i}(1:nbData,:);
	           else
	               PSI = blkdiag(PSI, phi{i}(1:nbData,:));
	           end
	        end
	    end
	end

end
