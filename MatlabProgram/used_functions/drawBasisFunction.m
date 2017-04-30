function drawBasisFunction(PHI,nbFunctions) 
% drawBasisFunction draws the basis function
%INPUT: 
%PSI: is the basis function. the promp's basis function are stocked in 
%your object promp: promp.PSI_z. 
% If you want to see basis function rescaled to a specific trajectory "i",
% you can put: promp.PSI{i}
        figure;
        for k=1:size(nbFunctions,2)
             for i=1:nbFunctions(k)
                plot(PHI(:,i), 'b');hold on;
             end
        end
                 set(gca, 'fontsize', 20);

        %title([ num2str(nbFunctions(1)) ' functions'],'fontsize', 24);
        xlabel('normalized # samples','fontsize', 24)
        ylabel('normalized RBF','fontsize', 24)
end