clear  all
close all

referenceNumber = 100;


%Retrieve data
nameFolder ={'../Data/expFrontier/front/';'../Data/expFrontier/right/'} 
for j=1:2
    
    
    %add skin information
    
    PATH=[ nameFolder{j}, 'skinContact/' ]
    listtmp = dir(PATH);
    listtmp2 = find(vertcat(listtmp.isdir));
    liste = listtmp(listtmp2);
    for parc=3:length(liste)
        PATH2 = [PATH, liste(parc).name];
        if (~exist([PATH2,'/data.log']))
            display('error no files with this name');
            display([PATH2,'/data.log']);
            cont=0;
        end
        
        fid = fopen('../Data/expFrontier/front/skinContact/skinContacts/data.log','r');
        firstLine = split(fgetl(fid), ' ');
        initTime = str2num(firstLine{2})
        ok=1;
        while(ok)
            tline = fgetl(fid);
            if (~ischar(tline)) 
                break;
            end
            clear splitLine
            splitLine = split(tline, ' ');
            if(size(splitLine,1) > 3)
                val = split(splitLine{size(splitLine,1)}, ')')
                if(str2num(val{1}) >20)
                   timeContact(j,parc-2) = str2num(splitLine{2}) - initTime
                   break;
                end
            end
            
        end
    end
        %%%END SKIN INFO
    
    
    
    
    t{j}.nbInput(1) = 3;
    t{j}.nbInput(2) = 4; % x y z ax ay az theta
    t{j}.label = nameFolder{j};
    %retrieve position information
    PATH=[ nameFolder{j}, 'state/']
    listtmp = dir(PATH);
    listtmp2 = find(vertcat(listtmp.isdir));
    liste = listtmp(listtmp2);
    for parc=3:length(liste)
        cont=1;
        PATH2 = [PATH, liste(parc).name];
        if (~exist([PATH2,'/data.log']))
            display('error no files with this name');
            display([PATH2,'/data.log']);
            cont=0;
        end
        data_tot{parc-2} = load([PATH2,'/data.log']);
        
        %when skin contact
        clear tmp_val
        tmp_val= data_tot{parc-2}(:,2) -ones(length(data_tot{parc-2}(:,2)),1)*data_tot{parc-2}(1,2);
        for testi=1:length(tmp_val)
           if(tmp_val(testi) >= timeContact(j,parc-2))
               beginTrajInd= testi;
               break;
           end
        end
%         ok=0
%         i=1;
%         while(~ok)
%             if(data_tot{parc-2}(i,2) -ones(length(data_tot{parc-2}(:,2)),1)*data_tot{parc-2}(1,2)
%                 i++
%         end
        t{j}.realTime{parc-2} = data_tot{parc-2}(beginTrajInd:length(tmp_val),2) -ones(length(data_tot{parc-2}(beginTrajInd:length(tmp_val),2)),1)*data_tot{parc-2}(beginTrajInd,2);
        
        
        
       t{j}.yMat{parc-2} = [data_tot{parc-2}(beginTrajInd:length(tmp_val),3:9)]; 
        %         t{j}.yMat{parc-2} = [tmp_yMat{parc-2}(1:minimum,:),data_tot{parc-2}(beginTrajInd:minimum+beginTrajInd-1,3:8)]; 
         t{j}.totTime(parc-2) = length(t{j}.yMat{parc-2});
         t{j}.interval(parc-2) = (t{j}.realTime{parc-2}(t{j}.totTime(parc-2)) - t{j}.realTime{parc-2}(1)) /t{j}.totTime(parc-2); %time inteval between sample
         t{j}.y{parc-2} = [];
         for i=1:sum(t{j}.nbInput)
             t{j}.y{parc-2} = [t{j}.y{parc-2}; t{j}.yMat{parc-2}(1:t{j}.totTime(parc-2),i)];
         end
        
    end
    t{j}.nbTraj = length(liste) -2;
    t{j}.nbTraj
%     clear data_tot;
%     PATH=[ nameFolder{j}, 'cartesianEndEffectorWrench/' ]
%     listtmp = dir(PATH);
%     listtmp2 = find(vertcat(listtmp.isdir));
%     liste = listtmp(listtmp2);
%     for parc=3:length(liste)
%         PATH2 = [PATH, liste(parc).name];
%         if (~exist([PATH2,'/data.log']))
%             display('error no files with this name');
%             display([PATH2,'/data.log']);
%             cont=0;
%         end
%         data_tot{parc-2} = load([PATH2,'/data.log']);
%         
%         
%                 %when skin contact
%         clear tmp_val
%         tmp_val= data_tot{parc-2}(:,2) -ones(length(data_tot{parc-2}(:,2)),1)*data_tot{parc-2}(1,2);
%         for testi=1:length(tmp_val)
%            if(tmp_val(testi) >= initTime)
%                beginTrajInd= testi;
%                break;
%            end
%         end
%         
%         
%         %todo on peut faire mieux ici
%         minimum = min(length(tmp_yMat{parc-2}), length(tmp_val) - beginTrajInd);
%         if(minimum~= length(tmp_yMat{parc-2}))
%             t{j}.realTime{parc-2} = data_tot{parc-2}(beginTrajInd:length(tmp_val),2) - ones(length(data_tot{parc-2}(beginTrajInd:length(tmp_val),2)),1)*data_tot{parc-2}(beginTrajInd,2);
%         end
%         t{j}.yMat{parc-2} = [tmp_yMat{parc-2}(1:minimum,:),data_tot{parc-2}(beginTrajInd:minimum+beginTrajInd-1,3:8)]; 
%         t{j}.totTime(parc-2) = minimum;
%         t{j}.interval(parc-2) = (t{j}.realTime{parc-2}(t{j}.totTime(parc-2)) - t{j}.realTime{parc-2}(1)) /t{j}.totTime(parc-2); %time inteval between sample
%         t{j}.y{parc-2} = [];
%         for i=1:sum(t{j}.nbInput)
%             t{j}.y{parc-2} = [t{j}.y{parc-2}; t{j}.yMat{parc-2}(1:minimum,i)];
%         end
%     end
    

        
    if(referenceNumber ~= -1)%compute the modulation time of the t{j}.
        for val=1:t{j}.nbTraj
            t{j}.alpha(val) = referenceNumber / t{j}.totTime(val);
        end 
    end
end    
%% 
% %suppr bad samples
 t{1}.realTime(9)= [];
 t{1}.nbTraj = t{1}.nbTraj-1;
 t{1}.yMat(9) = [];
 t{1}.totTime(9) = [];
 t{1}.interval(9) = [];
 t{1}.y(9) = [];
 t{1}.alpha(9) = [];
% 
% t{2}.realTime(1)= [];
% t{2}.nbTraj = t{2}.nbTraj-1;
% t{2}.yMat(1) = [];
% t{2}.totTime(1) = [];
% t{2}.interval(1) = [];
% t{2}.y(1) = [];
% t{2}.alpha(1) = [];
% 
% t{2}.realTime(1)= [];
% t{2}.nbTraj = t{2}.nbTraj-1;
% t{2}.yMat(1) = [];
% t{2}.totTime(1) = [];
% t{2}.interval(1) = [];
% t{2}.y(1) = [];
% t{2}.alpha(1) = [];
% 
% t{2}.realTime(1)= [];
% t{2}.nbTraj = t{2}.nbTraj-1;
% t{2}.yMat(1) = [];
% t{2}.totTime(1) = [];
% t{2}.interval(1) = [];
% t{2}.y(1) = [];
% t{2}.alpha(1) = [];
%     
% 
% %filtre forces & wrenches
% for type=1:2
%     figure;
%     for ind=1:t{type}.nbTraj 
%         for indInput=t{type}.nbInput(1)+1:t{type}.nbInput(1)+3
%             clear traj;
%             subplot(t{type}.nbInput(2)/2,2, indInput-t{type}.nbInput(1));
%             hold on;
%             plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'b');
%         
%             [envHigh, envLow] = envelope(t{type}.yMat{ind}(:,indInput));
%             t{type}.yMat{ind}(:,indInput) = (envHigh+envLow)/2;
%             plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'r');
%             
% %             [b a] = butter(1, 0.01);
% %             traj = filter(b,a,t{type}.yMat{ind}(:,indInput));
% %             t{type}.yMat{ind}(:,indInput) = traj;
% %             plot(t{type}.realTime{ind},traj,'r');
%         end
%         for indInput=t{type}.nbInput(1)+4:t{type}.nbInput(1)+6
%             clear traj;
%             subplot(t{type}.nbInput(2)/2,2, indInput-t{type}.nbInput(1));
%             hold on;
%             plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'b');
%             [envHigh, envLow] = envelope(t{type}.yMat{ind}(:,indInput));
%             t{type}.yMat{ind}(:,indInput) = (envHigh+envLow)/2;           
% %             plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'b');
% %             [b a] = butter(1, 0.01);
% %             traj = filter(b,a,t{type}.yMat{ind}(:,indInput));
% %            t{type}.yMat{ind}(:,indInput) = traj;
%             plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'r');
%         end
%     end
% end


%plot results
col = ['r';'g';'b'];
figure;
for j=1:2
    set(findall(gcf,'-property','FontSize'),'FontSize',18)

    for i=1:t{j}.nbTraj
        subplot(3,1,1);hold on;
        title('cartesianController/left\_arm/state:o');
        plot(t{j}.realTime{i} , t{j}.yMat{i}(:,1), col(j));
        ylabel('x');
        subplot(3,1,2);hold on;
        plot(t{j}.realTime{i} , t{j}.yMat{i}(:,2), col(j));
        ylabel('y');
        subplot(3,1,3);hold on;
        labplot(j) =plot(t{j}.realTime{i} , t{j}.yMat{i}(:,3), col(j));
        ylabel('z');
    end
end    
legend(labplot, 'front','right');


% 
% %%
%  figure;
% for j=1:2
%     set(findall(gcf,'-property','FontSize'),'FontSize',18)
%     for i=1:t{j}.nbTraj
%         subplot(3,2,1);hold on;
%         title('cartesianEndEffectoWrench:o');
%         plot(t{j}.realTime{i} , t{j}.yMat{i}(:,4), col(j));
%         ylabel('Fx');
%         subplot(3,2,3);hold on;
%         plot(t{j}.realTime{i} , t{j}.yMat{i}(:,5), col(j));
%         ylabel('Fy');
%         subplot(3,2,5);hold on;
%         plot(t{j}.realTime{i} , t{j}.yMat{i}(:,6), col(j));
%         ylabel('Fz');
%         subplot(3,2,2);hold on;
%         plot(t{j}.realTime{i} , t{j}.yMat{i}(:,7), col(j));
%         ylabel('wx');
%         subplot(3,2,4);hold on;
%         plot(t{j}.realTime{i} , t{j}.yMat{i}(:,8), col(j));
%         ylabel('wy');
%         subplot(3,2,6);hold on;
%         labplot(j) = plot(t{j}.realTime{i}, t{j}.yMat{i}(:,9), col(j));
%         ylabel('wz');
%      end      
% end
% legend(labplot, 'front','right');


%plot results
col = ['r';'g';'b'];
figure;
for j=1:2
    set(findall(gcf,'-property','FontSize'),'FontSize',18)

    for i=1:t{j}.nbTraj
        subplot(4,1,1);hold on;
        title('angles');
        plot(t{j}.realTime{i} , t{j}.yMat{i}(:,4), col(j));
        ylabel('a1');
        subplot(4,1,2);hold on;
        plot(t{j}.realTime{i} , t{j}.yMat{i}(:,5), col(j));
        ylabel('a2');
        subplot(4,1,3);hold on;
        labplot(j) =plot(t{j}.realTime{i} , t{j}.yMat{i}(:,6), col(j));
        ylabel('a3');
        subplot(4,1,4);hold on;
        labplot(j) =plot(t{j}.realTime{i} , t{j}.yMat{i}(:,7), col(j));
        ylabel('a4');
    end
end    
legend(labplot, 'front','right');