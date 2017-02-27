%In this function, we create basis function matrix corresponding to the
%number of input information we have and the number of basis function we
%have defined with their bandwith h.

function PSI = computeBasisFunction(z,nbFunctions, nbDof, alpha, totalTime, center_gaussian, h, nbData)
    %creating the center of basis function model
    
for k=1:size(nbFunctions,2)
    for i = 1 : nbFunctions(k) 
        c(k,i) = center_gaussian(k)*(i-1); 
    end
%     for k=1:size(nbFu

    for t=1:totalTime %z / alpha
        %creating a basis functions model (time*nbFunctions)
        for i = 1 : nbFunctions(k)
            val{k} = -(alpha*t*0.01-c(k,i))*(alpha*t*0.01-c(k,i))/(h(k));
            basis{k}(t,i) = exp(val{k});
        end
 
        sumBI = sum(basis{k}(t,:));
        for i = 1 : nbFunctions(k)
            phi{k}(t,i) = basis{k}(t,i) / sumBI;
        end
    end
    
    
end    

for i=1:size(nbFunctions,2)
    for j =1:nbDof(i)
       if and(i==1,j==1)
           PSI = phi{i}(1:nbData,:);
       else
           PSI = blkdiag(PSI, phi{i}(1:nbData,:));
       end
    end
end

%      %draw the basis function
%     figure;
%     for k=1:size(nbFunctions,2)
%          for i=1:nbFunctions(k)
%            % plot(phi{k}(:,i), 'color', [0, k/size(nbFunctions,2), 0]); hold on;
%             plot(basis{k}(:,i), 'color', [0, k/size(nbFunctions,2), 0]);hold on;
%          end
%     end
%     title('representation of the basis function used for each type of data')
%     xlabel('time')
%     ylabel('basis normalized')
%     yaxis([0 2])
    %TODO ameliorate here to pu as much as we have trajectories!
    %CREATING THE MATRIX BLOCK FOR ALL DOF

end
