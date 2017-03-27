function [proba,x] = mesureDiff(type, mu, S, x, nbData,nbInput)
    if(strcmp(type, 'ML'))
        offset =zeros(nbInput,1);
        for i=1:nbInput
            offset(i) = mu((i-1)*nbData +1) - x((i-1)*nbData +1);
            x((i-1)*nbData +1:i*nbData) = x((i-1)*nbData +1:i*nbData) + offset(i); 
        end
       
       [Sigma, p] = chol(S);
       if(p ~=0) 
           error('Error in the cholesky decomposition');
       end
       logdetSigma = sum(log(diag(Sigma))); % logdetSigma
       Mat = (x-mu)'*(S\(x-mu));
       
       proba = -(nbInput*nbData/2)*log(2*pi) -(nbData/2)*logdetSigma -0.5*sum((x-mu)'*(S\(x-mu)));  

    elseif(strcmp(type, 'DI')) %distance
        offset =zeros(nbInput,1);
        for i=1:nbInput
            offset(i) = mu((i-1)*nbData +1) - x((i-1)*nbData +1);
            x((i-1)*nbData +1:i*nbData) = x((i-1)*nbData +1:i*nbData) + offset(i); 
        end
        proba = - mean(abs(mu - x));
    elseif(strcmp(type,'LA'))%last data
        %offset
%         offset =zeros(nbInput,1);
%         for i=1:nbInput
%             offset(i) = mu((i-1)*nbData +1) - x((i-1)*nbData +1);
%             x((i-1)*nbData +1:i*nbData) = x((i-1)*nbData +1:i*nbData) + offset(i); 
%         end


                proba = - mean(abs(mu(nbData*2+1:nbData*3) - x(nbData*2+1:nbData*3) ));

    else
       display('error non recognized');
       proba = NaN;
    end
end