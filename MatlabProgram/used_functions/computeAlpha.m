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
        else
            mask{typeTraj}(traj) = 1;
            t{typeTraj}.velVar(cpt,1:nbInput(1)) = abs(t{typeTraj}.yMat{traj}(size(t{typeTraj}.yMat{traj},1),1:nbInput(1)) - t{typeTraj}.yMat{traj}(1,1:nbInput(1)));
            cpt = cpt+1; 
        end
    end
    
    %computes the RBF for the alpha model
    RBF{typeTraj} = AlphaBasis(t{typeTraj}.velVar);
    sizeNoise{typeTraj} = size(RBF{typeTraj}'*RBF{typeTraj});
    %computes the w parameter of the model
    w_alpha{typeTraj} =  (RBF{typeTraj}'*RBF{typeTraj}+1e-12*eye(sizeNoise{typeTraj})) \ (RBF{typeTraj})' *t{typeTraj}.alpha(logical(mask{typeTraj}))';        
        
end 

% %%%FOR DEBUGGING PURPOSE:

%%%%%%%%figure learning alphas model
%  set(0,'DefaultAxesFontSize',18);
%  set(groot,'defaultLineLineWidth',4)
% fig  = figure(200);
% subplot(3,1,1);
% hold on;
% plot(t{1}.alpha,t{1}.velVar(:,1),'+b');
% plot(t{1}.alpha,t{1}.velVar(:,2),'+r');
% plot(t{1}.alpha,t{1}.velVar(:,3),'+g');
% %plot(t{1}.alpha,(t{1}.velVar(:,1)+t{1}.velVar(:,2)+t{1}.velVar(:,3)) /3, '-k');
% %title('Variation des entrées en fonction du temps de modulation \alpha', 'fontsize', 24);
% xlabel('\alpha', 'fontsize', 24);
% ylabel({'Position variation', '(X_{nbData} - X_1)'}, 'fontsize', 24);
% legend('x_{nbData} - x_1','y_{nbData} - y(1)','z_{nbData} - z_1');
% 
% subplot(3,1,2);
% plot([t{1}.alpha, t{2}.alpha, t{3}.alpha],'+g');hold on;
% plot([RBF{1}*w_alpha{1};RBF{2}*w_alpha{2};RBF{3}*w_alpha{3}],'+-m');
% title('\alpha learning according to the cartesian position', 'fontsize', 24);
% xlabel('# Samples', 'fontsize', 24);
% ylabel('\alpha', 'fontsize', 24);
% legend('Real \alpha','Infered \alpha');
% subplot(3,1,3);
% error =[abs(RBF{1}*w_alpha{1}- t{1}.alpha');abs(RBF{2}*w_alpha{2}- t{2}.alpha');abs(RBF{2}*w_alpha{2}- t{2}.alpha')]; 
% plot(error,'+k');hold on;
% plot(mean(error)*ones(length(error),1));
% xlabel('# Samples', 'fontsize', 24);
% title('Error computation of the \alpha', 'fontsize', 24);
% legend('Error per samples','mean error');
end
