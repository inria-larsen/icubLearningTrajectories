function RBF = AlphaBasis(x)
%AlphaBasis is not finish yet, will allow to compute Basis functions 
%to model the alpha value according to the input variation.
%INPUT:
%x: all the variation inputs for each trajectory
%OUTPUT:
%RBF the RBF of the alpha model.

    RBF = [];
    Phi = cell(size(x,2));
    for traj=1:size(x,2) %for each trajectory
        Phi{traj}= zeros(size(x,1),5);
        for t=1:size(x,1) %nbData 
            %TODO the RBF as parameter
            for i=1:5 %5 RBF from -0.5 to 0.5 in 3D
                c =  0.012*(i-1);
                if(isnan(x(t)))
                    Phi{traj}(t,i) = 0;
                else
                    Phi{traj}(t,i) = exp(-power(x(t,traj)' - c,2) /sqrt(0.2));            
                end
            end
                sumBI = sum(Phi{traj}(t,:));
                Phi{traj}(t,:) = Phi{traj}(t,:)/sumBI;
        end
            RBF = [RBF,Phi{traj}];
    end
end