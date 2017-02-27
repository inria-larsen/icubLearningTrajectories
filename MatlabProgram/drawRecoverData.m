list = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};

set(0,'DefaultLineLinewidth',1);
set(0,'DefaultAxesFontSize',12);

%Here we plot the cartesian position
for k =1:nbKindOfTraj
    fig22 = figure;
    for l=1:nbDof(1)%nbDofTot  
        subplot(nbDof(1),1,l)%size(nbDof,2),l);
        for i=1:var(k)      
            fig22 = visualisation(y{k}{i},nbDofTot,totalTime(k,i), l, ':b',fig22,realTime{k}{i});hold on;
        end
        %fig22=visualisation(y_trial{k}, nbDofTot,nbData,l, '.b',fig22);hold on;
         %fig22=visualisation(y_trial_Tot{k}, nbDofTot, totalTimeTrial(k),l, 'b',fig22,realTimeTrial{k});hold on;
         ylabel(list{l}, 'fontsize', 24);
         %if(l==1)    
            % title(['trajecories type ', num2str(k)], 'fontsize', 30);
         if(l==nbDof(1))
              xlabel('Time [s]', 'fontsize', 24);
         end
    end
end

%Here we plot the forces
for k =1:nbKindOfTraj
    fig22 = figure;
    for l=nbDof(1)+1:6  
        subplot(3,1,l-nbDof(1));%size(nbDof,2),l);
        for i=1:var(k)      
            fig22 = visualisation(y{k}{i},nbDofTot,totalTime(k,i), l, ':b',fig22,realTime{k}{i});hold on;
        end
        %fig22=visualisation(y_trial{k}, nbDofTot,nbData,l, '.b',fig22);hold on;
         %fig22=visualisation(y_trial_Tot{k}, nbDofTot, totalTimeTrial(k),l, 'b',fig22,realTimeTrial{k});hold on;
         ylabel(list{l}, 'fontsize', 24);
         %if(l==1)    
            % title(['trajecories type ', num2str(k)], 'fontsize', 30);
         if(l==6)
              xlabel('Time [s]', 'fontsize', 24);
         end
    end
end

%Here we plot the moments
for k =1:nbKindOfTraj
    fig22 = figure;
    for l= 7:9  
        subplot(3,1,l-6);%size(nbDof,2),l);
        for i=1:var(k)      
            fig22 = visualisation(y{k}{i},nbDofTot,totalTime(k,i), l, ':b',fig22,realTime{k}{i});hold on;
        end
        %fig22=visualisation(y_trial{k}, nbDofTot,nbData,l, '.b',fig22);hold on;
         %fig22=visualisation(y_trial_Tot{k}, nbDofTot, totalTimeTrial(k),l, 'b',fig22,realTimeTrial{k});hold on;
         ylabel(list{l}, 'fontsize', 24);
         %if(l==1)    
            % title(['trajecories type ', num2str(k)], 'fontsize', 30);
         if(l==9)
              xlabel('Time [s]', 'fontsize', 24);
         end
    end
end

%Here we plot the forces and moments
for k =1:nbKindOfTraj
    fig22 = figure;
    for l=nbDof(1)+1:nbDofTot  
        subplot(nbDof(2),1,l-nbDof(1));%size(nbDof,2),l);
        for i=1:var(k)      
            fig22 = visualisation(y{k}{i},nbDofTot,totalTime(k,i), l, ':b',fig22,realTime{k}{i});hold on;
        end
        %fig22=visualisation(y_trial{k}, nbDofTot,nbData,l, '.b',fig22);hold on;
         %fig22=visualisation(y_trial_Tot{k}, nbDofTot, totalTimeTrial(k),l, 'b',fig22,realTimeTrial{k});hold on;
         ylabel(list{l}, 'fontsize', 24);
         %if(l==1)    
            % title(['trajecories type ', num2str(k)], 'fontsize', 30);
         if(l==nbDofTot)
              xlabel('Time [s]', 'fontsize', 24);
         end
    end
end
