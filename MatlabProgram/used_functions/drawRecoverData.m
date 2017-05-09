function drawRecoverData(traj, list, varargin)

%set(0,'DefaultLineLinewidth',0.1);
set(0,'DefaultAxesFontSize',18);

specific = 0;
col = 'm';
if(~isempty(varargin))
    for index = 1:length(varargin)
        if(varargin{index}=='Specific')%If you want to plot position/forces/moment separately
            specific =1;
        elseif(varargin{index}=='Specolor')
            index = index+1
             col = varargin{index};   
        end
    end
end

if(specific==1)%If you want to plot position/forces/moment separately
        
        %Here we plot the forces
            fig22 = figure;
            set(gca, 'fontsize', 24);
            for l=traj.nbInput(1)+1:6  
                subplot(3,1,l-traj.nbInput(1));%size(nbDof,2),l);
                for i=1:traj.nbTraj     
                    fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, col,fig22,traj.realTime{i});hold on;
                end

                 ylabel(list{l}, 'fontsize', 24);
                 if(l==6)
                      xlabel('Time [s]', 'fontsize', 24);
                 end
                 set(gca, 'fontsize', 20)
            end

        %Here we plot the moments
            fig22 = figure;
                        set(gca, 'fontsize', 18);

            for l= 7:9  
                subplot(3,1,l-6);%size(nbDof,2),l);
                for i=1:traj.nbTraj     
                    fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, col,fig22,traj.realTime{i});hold on;
                end

                 ylabel(list{l}, 'fontsize', 24);
                 if(l==9)
                      xlabel('Time [s]', 'fontsize', 24);
                 end
                 set(gca, 'fontsize', 20)
            end
        
        
        %Here we plot the cartesian position
            fig22 = figure(100);
            set(gca, 'fontsize', 18);

            for l=1:traj.nbInput(1)
                subplot(traj.nbInput(1),1,l)
                for i=1:traj.nbTraj     
                    fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, col,fig22,traj.realTime{i});hold on;
                end

                 ylabel(list{l}, 'fontsize', 24);

                 if(l==traj.nbInput(1))
                      xlabel('Time [s]', 'fontsize', 24);
                 end
            end



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
else

    fig22 = figure;
    set(gca, 'fontsize', 18);

    for l=1:traj.nbInput(1)  
        subplot(traj.nbInput(1),1,l)
        for i=1:traj.nbTraj     
            fig22 = visualisation(traj.y{i},sum(traj.nbInput),traj.totTime(i), l, col,fig22,traj.realTime{i});hold on;
        end

         ylabel(list{l}, 'fontsize', 24);

         if(l==traj.nbInput(1))
              xlabel('Time [s]', 'fontsize', 24);
         end
    end
end
end



