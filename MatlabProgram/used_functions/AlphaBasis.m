function vall = AlphaBasis(x)
%AlphaBasis is not finish yet, will allow to compute Basis function 
%to modelize the alpha value according to the position variation of the
%data

    vall = [];
    for j=1:size(x,2)
        val{j}= zeros(size(x,1),5);
    %valy= zeros(size(x,1),5);
    %valz= zeros(size(x,1),5);
        for n=1:size(x,1) %nbData 
            for i=1:5 %5 rbf from -0.5 to 0.5 in 3D
                c =  0.012*(i-1);
                if(isnan(x(n)))
                    val{j}(n,i) = 0;
                   % valy(n,i) = 0;
                   % valz(n,i) = 0;
                else
                    val{j}(n,i) = exp(-power(x(n,j)' - c,2) /sqrt(0.2));            
                   % valy(n,i) = exp(-power(x(n,2)' - c,2) /sqrt(0.2));
                   % valz(n,i) = exp(-power(x(n,3)' - c,2) /sqrt(0.2));
                end
            end
                sumBI = sum(val{j}(n,:));
                val{j}(n,:) = val{j}(n,:)/sumBI;
%                 sumBI = sum(valy(n,:));
%                 valy(n,:) = valy(n,:)/sumBI;
%                 sumBI = sum(valz(n,:));
%                 valz(n,:) = valz(n,:)/sumBI;
        end
            vall = [vall,val{j}];
    end
end