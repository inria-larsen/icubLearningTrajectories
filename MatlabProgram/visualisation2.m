% Function that plot the matrix with the color col1. x is the line of the
% matrix, y the number of colonnes
%take into account the alpha
function y = visualisation2(matrix, x,y, z, col1, alpha, nameFig)
tall = size(nameFig,2);

for i=1:x
    for j=1:y
        val(i,j) = matrix(y*(i-1)+j);
    end
end

if(isa(col1, 'char'))
  %  for i=1:x
    i=z;     
    if(size(val,2) < size([alpha : alpha : 100],2))
      nameFig(tall + 1) =  plot([alpha : alpha : size(val,2)*alpha], val(i,:), col1); hold on;
    else
    nameFig(tall + 1) =  plot([alpha : alpha : 100], val(i,:), col1,'linewidth',2); hold on;
    end
else
   % for i=1:x 
    i=z;
      nameFig(tall + (2*1) - 1) =   plot([alpha : alpha : 100], val(i,:), col1); hold on;
      nameFig(tall + 2*1) =  plot(tmp, val(i,:), 'Color', col1,'linewidth',2); hold on;
   % end
end
    y = nameFig;

end
