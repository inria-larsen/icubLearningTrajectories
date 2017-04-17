function drawRecoverData(traj, list)

set(0,'DefaultLineLinewidth',1);
set(0,'DefaultAxesFontSize',12);

%TODO mieux
if(length(traj) ==2) %2traj
    fig22 = figure;
    
    display('plot many traj');
    
    totInput = sum(traj{1}.nbInput) 
%Here we plot all data
    
    for l=1:totInput
        subplot(ceil(totInput/2),2,l);%size(nbDof,2),l);
        for i=1:traj{1}.nbTraj  
            fig22 = visualisation(traj{1}.y{i},sum(traj{1}.nbInput),traj{1}.totTime(i), l, ':k',fig22,traj{1}.realTime{i});hold on;
        end

         ylabel(list{l}, 'fontsize', 24);
         if(l==sum(traj{1}.nbInput))
              xlabel('Time [s]', 'fontsize', 24);
         end
      set(gca, 'fontsize', 20)
    end
    lab1 = length(fig22);
    totInput = sum(traj{2}.nbInput) 
    %Here we plot all data
    
    for l=1:totInput
        subplot(ceil(totInput/2),2,l);%size(nbDof,2),l);
        for i=1:traj{2}.nbTraj  
            fig22 = visualisation(traj{2}.y{i},sum(traj{2}.nbInput),traj{2}.totTime(i), l, ':r',fig22,traj{2}.realTime{i});hold on;
        end

         ylabel(list{l}, 'fontsize', 24);
         if(l==sum(traj{2}.nbInput))
              xlabel('Time [s]', 'fontsize', 24);
         end
      set(gca, 'fontsize', 20)
      lab2 = length(fig22);
    end 
    
    legend(fig22([lab1 lab2]), traj{1}.label, traj{2}.label);
    
  
else    
totInput = sum(traj.nbInput) 
% %Here we plot all data
%     fig22 = figure;
%     for l=1:totInput
%         subplot(ceil(totInput/2),2,l);%size(nbDof,2),l);
%         for i=1:traj.nbTraj  
%             fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, ':b',fig22,traj.realTime{i});hold on;
%         end
% 
%          ylabel(list{l}, 'fontsize', 24);
%          if(l==sum(traj.nbInput))
%               xlabel('Time [s]', 'fontsize', 24);
%          end
%       set(gca, 'fontsize', 20)
%     end
        %Here we plot the cartesian position
        fig22 = figure;
        for l=1:traj.nbInput(1)%nbDofTot  
            subplot(traj.nbInput(1),1,l)%size(nbDof,2),l);
            for i=1:traj.nbTraj     
                fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, ':b',fig22,traj.realTime{i});hold on;
            end
            
             ylabel(list{l}, 'fontsize', 24);
    
             if(l==traj.nbInput(1))
                  xlabel('Time [s]', 'fontsize', 24);
             end
        end
              
        %Here we plot the cartesian position
        fig22 = figure;
        for l=traj.nbInput(1)+1:totInput  
            subplot(nbDofTot - traj.nbInput(1),1,l)
            for i=1:traj.nbTraj     
                fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, ':b',fig22,traj.realTime{i});hold on;
            end
            
             ylabel(list{l}, 'fontsize', 24);
    
             if(l==traj.nbInput(1))
                  xlabel('Time [s]', 'fontsize', 24);
             end
        end

%     %Here we plot the forces
%         fig22 = figure;
%     
%         for l=traj.nbInput(1)+1:6  
%             subplot(3,1,l-traj.nbInput(1));%size(nbDof,2),l);
%             for i=1:traj.nbTraj     
%                 i
%                 fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, ':b',fig22,traj.realTime{i});hold on;
%             end
%     
%              ylabel(list{l}, 'fontsize', 24);
%              if(l==4)
%                      title(traj.label, 'fontsize', 24);
%              end
%              if(l==6)
%                   xlabel('Time [s]', 'fontsize', 24);
%              end
%              set(gca, 'fontsize', 20)
%         end
%     
%     %Here we plot the moments
%         fig22 = figure;
%         for l= 7:9  
%             subplot(3,1,l-6);%size(nbDof,2),l);
%             for i=1:traj.nbTraj     
%                 fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, ':b',fig22,traj.realTime{i});hold on;
%             end
%     
%              ylabel(list{l}, 'fontsize', 24);
%              if(l==9)
%                   xlabel('Time [s]', 'fontsize', 24);
%              end
%              set(gca, 'fontsize', 20)
%         end


    %Here we plot the forces and moments
    %     fig22 = figure;
    %     for l=traj.nbInput(1)+1:sum(traj.nbInput) 
    %         subplot(traj.nbInput(2),1,l-traj.nbInput(1));%size(nbDof,2),l);
    %         for i=1:traj.nbTraj  
    %             fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, ':b',fig22,traj.realTime{i});hold on;
    %         end
    % 
    %          ylabel(list{l}, 'fontsize', 24);
    %          if(l==sum(traj.nbInput))
    %               xlabel('Time [s]', 'fontsize', 24);
    %          end
    %       set(gca, 'fontsize', 20)
    %     end
    % end
    
    
    
end

end

