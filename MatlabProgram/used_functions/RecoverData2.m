function RecoverData2(traj, list)



set(0,'DefaultLineLinewidth',1);
set(0,'DefaultAxesFontSize',12);

%Here we plot the cartesian position

    fig22 = figure;
    for l=1:nbDof(1)%nbDofTot  
        subplot(traj.nbInput(1),1,l)%size(nbDof,2),l);
        for i=1:traj.nbTraj     
            fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, ':b',fig22,traj.totTime{i});hold on;
        end
        
         ylabel(list{l}, 'fontsize', 24);

         if(l==nbDof(1))
              xlabel('Time [s]', 'fontsize', 24);
         end
    end
end

%Here we plot the forces
    fig22 = figure;
    for l=traj.nbInput(1)+1:6  
        subplot(3,1,l-traj.nbInput(1));%size(nbDof,2),l);
        for i=1:traj.nbTraj     
            fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, ':b',fig22,tot.realTime{i});hold on;
        end

         ylabel(list{l}, 'fontsize', 24);
         if(l==6)
              xlabel('Time [s]', 'fontsize', 24);
         end
    end

%Here we plot the moments
    fig22 = figure;
    for l= 7:9  
        subplot(3,1,l-6);%size(nbDof,2),l);
        for i=1:traj.nbTraj     
            fig22 = visualisation(traj.y{i},sum(traj.nbInput,traj.totTime(i), l, ':b',fig22,traj.realTime{i});hold on;
        end

         ylabel(list{l}, 'fontsize', 24);
         if(l==9)
              xlabel('Time [s]', 'fontsize', 24);
         end
    end
end

%Here we plot the forces and moments
for k =1:nbKindOfTraj
    fig22 = figure;
    for l=traj.nbInput(1)+1:sum(traj.nbInput) 
        subplot(traj.nbInput(2),1,l-traj.nbInput(1));%size(nbDof,2),l);
        for i=1:traj.nbTraj  
            fig22 = visualisation(traj.y{k},sum(traj.nbInput),traj.totTime(i), l, ':b',fig22,traj.realTime{i});hold on;
        end

         ylabel(list{l}, 'fontsize', 24);
         if(l==sum(traj.nbInput))
              xlabel('Time [s]', 'fontsize', 24);
         end
    end
end
