clear all
close all

referenceNumber = 100;


%Retrieve data
nameFolder ={'Data/realIcub/front_to_left/';'Data/realIcub/base_to_left_goal/';'Data/realIcub/base_to_front_goal/'} 
for j=1:3
    t{j}.nbInput(1) = 3;
    t{j}.nbInput(2) = 6; % x y z ax ay az theta fx fy fz wx wy wz
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
        tmp_yMat{parc-2} = [data_tot{parc-2}(:,3:5)]; 
        t{j}.realTime{parc-2} = data_tot{parc-2}(:,2) -ones(length(data_tot{parc-2}(:,2)),1)*data_tot{parc-2}(1,2);
    end
    t{j}.nbTraj = length(liste) -2;
    t{j}.nbTraj
    clear data_tot;
    PATH=[ nameFolder{j}, 'cartesianEndEffectorWrench/' ]
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
        data_tot{parc-2} = load([PATH2,'/data.log']);
        %todo on peut faire mieux ici
        minimum = min(length(tmp_yMat{parc-2}), length(data_tot{parc-2}));
        if(minimum~= length(tmp_yMat{parc-2}))
            t{j}.realTime{parc-2} = data_tot{parc-2}(:,2) - ones(length(data_tot{parc-2}(:,2)),1)*data_tot{parc-2}(1,2);
        end
        t{j}.yMat{parc-2} = [tmp_yMat{parc-2}(1:minimum,:),data_tot{parc-2}(1:minimum,3:8)]; 
        t{j}.totTime(parc-2) = minimum;
        t{j}.interval(parc-2) = (t{j}.realTime{parc-2}(t{j}.totTime(parc-2)) - t{j}.realTime{parc-2}(1)) /t{j}.totTime(parc-2); %time inteval between sample
        t{j}.y{parc-2} = [];
        for i=1:sum(t{j}.nbInput)
            t{j}.y{parc-2} = [t{j}.y{parc-2}; t{j}.yMat{parc-2}(1:minimum,i)];
        end
    end    
   
        
    if(referenceNumber ~= -1)%compute the modulation time of the t{j}.
        for val=1:t{j}.nbTraj
            t{j}.alpha(val) = referenceNumber / t{j}.totTime(val);
        end 
    end
end    

%suppr bad samples
t{1}.realTime(10)= [];
t{1}.nbTraj = t{1}.nbTraj-1;
t{1}.yMat(10) = [];
t{1}.totTime(10) = [];
t{1}.interval(10) = [];
t{1}.y(10) = [];
t{1}.alpha(10) = [];

t{2}.realTime(1)= [];
t{2}.nbTraj = t{2}.nbTraj-1;
t{2}.yMat(1) = [];
t{2}.totTime(1) = [];
t{2}.interval(1) = [];
t{2}.y(1) = [];
t{2}.alpha(1) = [];

t{2}.realTime(1)= [];
t{2}.nbTraj = t{2}.nbTraj-1;
t{2}.yMat(1) = [];
t{2}.totTime(1) = [];
t{2}.interval(1) = [];
t{2}.y(1) = [];
t{2}.alpha(1) = [];

t{2}.realTime(1)= [];
t{2}.nbTraj = t{2}.nbTraj-1;
t{2}.yMat(1) = [];
t{2}.totTime(1) = [];
t{2}.interval(1) = [];
t{2}.y(1) = [];
t{2}.alpha(1) = [];
    

%filtre forces & wrenches
for type=1:3
    figure;
    for ind=1:t{type}.nbTraj 
        for indInput=t{type}.nbInput(1)+1:t{type}.nbInput(1)+3
            clear traj;
            subplot(t{type}.nbInput(2)/2,2, indInput-t{type}.nbInput(1));
            hold on;
            plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'b');
        
            [envHigh, envLow] = envelope(t{type}.yMat{ind}(:,indInput));
            t{type}.yMat{ind}(:,indInput) = (envHigh+envLow)/2;
            plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'r');
            
%             [b a] = butter(1, 0.01);
%             traj = filter(b,a,t{type}.yMat{ind}(:,indInput));
%             t{type}.yMat{ind}(:,indInput) = traj;
%             plot(t{type}.realTime{ind},traj,'r');
        end
        for indInput=t{type}.nbInput(1)+4:t{type}.nbInput(1)+6
            clear traj;
            subplot(t{type}.nbInput(2)/2,2, indInput-t{type}.nbInput(1));
            hold on;
            plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'b');
            [envHigh, envLow] = envelope(t{type}.yMat{ind}(:,indInput));
            t{type}.yMat{ind}(:,indInput) = (envHigh+envLow)/2;           
%             plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'b');
%             [b a] = butter(1, 0.01);
%             traj = filter(b,a,t{type}.yMat{ind}(:,indInput));
%            t{type}.yMat{ind}(:,indInput) = traj;
            plot(t{type}.realTime{ind},t{type}.yMat{ind}(:,indInput),'r');
        end
    end
end


%plot results
col = ['r';'g';'b'];
figure;
for j=1:3
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
legend(labplot, 'frontToLeft','baseToLeft','baseToFront');
 figure;
for j=1:3
    set(findall(gcf,'-property','FontSize'),'FontSize',18)
    for i=1:t{j}.nbTraj
        subplot(3,2,1);hold on;
        title('cartesianEndEffectoWrench:o');
        plot(t{j}.realTime{i} , t{j}.yMat{i}(:,4), col(j));
        ylabel('Fx');
        subplot(3,2,3);hold on;
        plot(t{j}.realTime{i} , t{j}.yMat{i}(:,5), col(j));
        ylabel('Fy');
        subplot(3,2,5);hold on;
        plot(t{j}.realTime{i} , t{j}.yMat{i}(:,6), col(j));
        ylabel('Fz');
        subplot(3,2,2);hold on;
        plot(t{j}.realTime{i} , t{j}.yMat{i}(:,7), col(j));
        ylabel('wx');
        subplot(3,2,4);hold on;
        plot(t{j}.realTime{i} , t{j}.yMat{i}(:,8), col(j));
        ylabel('wy');
        subplot(3,2,6);hold on;
        labplot(j) = plot(t{j}.realTime{i}, t{j}.yMat{i}(:,9), col(j));
        ylabel('wz');
     end      
end
legend(labplot, 'frontToLeft','baseToLeft','baseToFront');
