% Function that plot the matrix with the color col1. x is the line of the
% matrix, y the number of colonnes

function y = visualisationShared(matrix, matrix2, x,y, z, col1, nameFig)

%tall = size(nameFig,2);
for i=1:x
    for j=1:y
        meanV(i,j) = matrix(y*(i-1)+j);
        stdV(i,j) = matrix2(y*(i-1)+j);
    end
end


if(isa(col1, 'char'))
    %for i=1:x
     i=z;
       shadedErrorBar([1:1:size(meanV(i,:),2)],meanV(i,:),stdV(i,:),col1, 0.01); hold on;

else
    %for i=1:x 
     i=z;
     shadedErrorBar([1:1:size(meanV(i,:),2)],meanV(i,:),stdV(i,:), 'Color', col1, 0.01); hold on;
      
    %end
end
 y = nameFig;
end