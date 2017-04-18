function w = computeAlpha(nbData,t,nbInput)
%computeAlpha is not finish yet.
%It will allow to compute the link between the variation in the first
%nbData and the alpha value.

for tallT=1:length(t) % for all type of trajectories

cpt=1;
mask{tallT} = zeros(length(t{tallT}.yMat),1);
for i=1:length(t{tallT}.yMat) %for all trajectory of type tallT
    if(size(t{tallT}.yMat{i},1)>=nbData)
        mask{tallT}(i) = 1;
        t{tallT}.velVar(cpt,1:nbInput(1)) = abs(t{tallT}.yMat{i}(nbData,1:nbInput(1)) - t{tallT}.yMat{i}(1,1:nbInput(1))) ; 
        cpt = cpt+1;
    end
end
% cpt=1;
% mask2 = zeros(length(t2.yMat),1);
% for i=1:length(t2.yMat)
%     if(size(t2.yMat{i},1)>=nbData) 
%         mask2(i) = 1;
%         t2.velVar(cpt,:) = abs(t2.yMat{i}(nbData,1:3) - t2.yMat{i}(1,1:3)) ;  
%         cpt = cpt+1;
%     end
% end
% cpt=1;
% mask3 = zeros(length(t3.yMat),1);
% for i=1:length(t3.yMat)
%     if(size(t3.yMat{i},1)>=nbData) 
%         mask3(i) = 1;
%         t3.velVar(cpt,:) = abs(t3.yMat{i}(nbData,1:3) - t3.yMat{i}(1,1:3)) ;  
%         cpt = cpt+1;
%     end
% end

% min(t1.velVar)
% min(t2.velVar)
% min(t3.velVar)
% 
% 
% max(t1.velVar)
% max(t2.velVar)
% max(t3.velVar)


basis{tallT} = AlphaBasis(t{tallT}.velVar);
% basis2 = AlphaBasis(t2.velVar);
% basis3 = AlphaBasis(t3.velVar);

sizeNoise{tallT} = size(basis{tallT}'*basis{tallT});
% sizeNoise2 = size(basis2'*basis2);
% sizeNoise3 = size(basis3'*basis3);

w{tallT} = (basis{tallT}'*basis{tallT}+1e-12*eye(sizeNoise{tallT})) \ (basis{tallT})' *t{tallT}.alpha(logical(mask{tallT}))';        
% w2 = (basis2'*basis2+1e-12*eye(sizeNoise2)) \ (basis2)' *t2.alpha(logical(mask2))';        
% w3 = (basis3'*basis3+1e-12*eye(sizeNoise3)) \ (basis3)' *t3.alpha(logical(mask3))';        
end 
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
