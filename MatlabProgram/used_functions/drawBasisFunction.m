function drawBasisFunction(PSI,nbFunctions) 
% drawBasisFunction draws the basis function
%INPUT: 
%PSI: is the basis function. the promp's basis function are stocked in 
%your object promp: promp.PSI_z. 
% If you want to see basis function rescaled to a specific trajectory "i",
% you can put: promp.PSI{i}
        figure;
        for k=1:size(nbFunctions,2)
             for i=1:nbFunctions(k)
                plot(PSI(:,i), 'color', [0, k/size(nbFunctions,2), 0]);hold on;
             end
        end
        title('representation of the basis function used for each type of data')
        xlabel('time')
        ylabel('basis normalized')
end