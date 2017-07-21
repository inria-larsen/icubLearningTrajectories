% Function that plot the matrix with the color col1. x is the line of the
% matrix, y the number of colonnes
%take into account the alpha
function y = visualisation2(matrix, x,y, z, col1, alpha, nameFig)
tall = size(nameFig,2);

if(isa(col1, 'char'))
    
    if(size(matrix,1) < size([alpha : alpha : 100],2))
      nameFig(tall + 1) =  plot([alpha : alpha : size(matrix,1) *alpha], matrix(:,z), col1,'linewidth',2); hold on;
    else
        nameFig(tall + 1) =  plot([alpha : alpha : 100], matrix(:,z), col1,'linewidth',2); hold on;
    end
else
      nameFig(tall + (2*1) - 1) =   plot([alpha : alpha : 100],  matrix(:,z), col1,'linewidth',2); hold on;
      nameFig(tall + 2*1) =  plot(tmp,  matrix(:,z), 'Color', col1,'linewidth',2); hold on;
end
    y = nameFig;

end
