function w_alpha = computeAlpha(nbData,t,nbInput)
%computeAlpha is not finish yet.
%computeAlpha allows to compute the link between the variation in the first
%nbData and the alpha value.


%initialization
mask = cell(length(t),1);
RBF = cell(length(t),1);
sizeNoise = cell(length(t),1);
w_alpha = cell(length(t),1);
for typeTraj=1:length(t) % for all type of trajectories
    
    %retrieve trajectories that are long enouth to corrspond to the
    %observed trajectory (length(traj) > nbData).
    cpt=1;
    mask{typeTraj} = zeros(length(t{typeTraj}.yMat),1);
    for traj=1:length(t{typeTraj}.yMat) %for all trajectories of type typeTraj
        % if the trajectory is ok, we compute the variation inputs between input(nbData) and input(1)
        if(size(t{typeTraj}.yMat{traj},1)>=nbData) %if the trajectory is probable for the inference, we use it in the model.
            mask{typeTraj}(traj) = 1;
            t{typeTraj}.velVar(cpt,1:nbInput(1)) = abs(t{typeTraj}.yMat{traj}(nbData,1:nbInput(1)) - t{typeTraj}.yMat{traj}(1,1:nbInput(1)));
            cpt = cpt+1;
        end
    end
    
    %computes the RBF for the alpha model
    RBF{typeTraj} = AlphaBasis(t{typeTraj}.velVar);
    sizeNoise{typeTraj} = size(RBF{typeTraj}'*RBF{typeTraj});
    %computes the w parameter of the model
    w_alpha{typeTraj} =  (RBF{typeTraj}'*RBF{typeTraj}+1e-12*eye(sizeNoise{typeTraj})) \ (RBF{typeTraj})' *t{typeTraj}.alpha(logical(mask{typeTraj}))';        
        
end 

%%%FOR DEBUGGING PURPOSE:
% % %%%draw_results
% %subplot(2,3,1);
% hold on;
% plot(t1.alpha,t1.velVar(:,1),'+b');
% plot(t1.alpha,t1.velVar(:,2),'+r');
% plot(t1.alpha,t1.velVar(:,3),'+g');
% %plot(t1.alpha,(t1.velVar(:,1)+t1.velVar(:,2)+t1.velVar(:,3)) /3, '-k');
% title('Variation des entrées en fonction du temps de modulation \alpha');
% xlabel('\alpha');
% ylabel('Variation des entrées (X(nbData) - X(1))');
% legend('X = x(nbData) - x(1)','Y = y(nbData) - y(1)','Z = z(nbData) - z(1)','(X + Y + Z) / 3');
% 
% subplot(2,3,2);
% hold on;
% for i=1:length(t1.yMat)
%     t2.velVar(i,1:3) = abs(t2.yMat{i}(nbData,1:3) - t2.yMat{i}(1,1:3)) ;  
% end
% plot(t2.alpha,t2.velVar(:,1),'+b');
% plot(t2.alpha,t2.velVar(:,2),'+r');
% plot(t2.alpha,t2.velVar(:,3),'+g');
% plot(t2.alpha,(t2.velVar(:,1)+t2.velVar(:,2)+t2.velVar(:,3)) /3,  '-k');
% title('Variation des entrées en fonction du temps de modulation \alpha');
% xlabel('\alpha');
% ylabel('Variation des entrées (X(nbData) - X(1))');
% legend('X = x(nbData) - x(1)','Y = y(nbData) - y(1)','Z = z(nbData) - z(1)','(X + Y + Z) / 3');
% 
% subplot(2,3,3);
% hold on;
% for i=1:length(t1.yMat)
%     t3.velVar(i,1:3) = abs(t3.yMat{i}(nbData,1:3) - t3.yMat{i}(1,1:3)) ;  
% end
% plot(t3.alpha, t3.velVar(:,1),'+b');
% plot(t3.alpha, t3.velVar(:,2),'+r');
% plot(t3.alpha,t3.velVar(:,3),'+g');
% plot(t3.alpha,(t3.velVar(:,1)+t3.velVar(:,2)+t3.velVar(:,3)) /3, '-k');
% title('Variation des entrées en fonction du temps de modulation \alpha');
% xlabel('\alpha');
% ylabel('Variation des entrées (X(nbData) - X(1))');
% legend('X = x(nbData) - x(1)','Y = y(nbData) - y(1)','Z = z(nbData) - z(1)','(X + Y + Z) / 3');
% 
% %%%%%%%%figure learning alphas
% fig  = figure();
% subplot(2,1,1);
% plot([t1.alpha, t2.alpha, t3.alpha],'+g');hold on;
% plot([basis1*w1;basis2*w2;basis3*w3],'+m');
% title('\alpha learning according to the cartesian position');
% xlabel('Samples');
% ylabel('\alpha');
% legend('Real \alpha','Infered \alpha');
% subplot(2,1,2);
% error =[abs(basis1*w1- t1.alpha');abs(basis2*w2- t2.alpha');abs(basis2*w2- t2.alpha')]; 
% plot(error,'+k');hold on;
% plot(mean(error)*ones(120,1));
% xlabel('Samples');
% ylabel('Error computation of the \alpha');
% legend('Error per samples','mean error');
end
