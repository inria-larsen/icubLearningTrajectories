function drawDistribution(promp, list,s_ref, varargin)
%DRAWDISTRIBUTION draws the learned distribution

set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)


nbInputs = sum(promp.traj.nbInput);
interval = [1:nbInputs];
col1='b';
col2='m';
if(~isempty(varargin))
    for i=1:length(varargin)
        if(isnumeric(varargin{i}))
            interval=varargin{i};
            nbInputs = length(interval);
        elseif(strcmp(varargin{i},'col')==1)
            i=i+1;
            col1 = varargin{i};
            col2 = varargin{i};
            fig = figure(10);
            hold on;

        end
    end
end
if(~exist('fig'))
    fig = figure;hold on;
end
if(size(interval)==[3,3]) 
    subplotInfo=  size(interval,1);%ceil(nbInputs/2);
    subplotInfo2 = size(interval,2);
elseif(nbInputs >3)
    subplotInfo=  ceil(nbInputs/2);
    subplotInfo2 = 2;
else
    subplotInfo=  nbInputs;
    subplotInfo2 = 1;
end

    cpt=1;
    for i=reshape(interval',1,[])
           subplot(subplotInfo,subplotInfo2,cpt);
            meanTraj =promp.PHI_norm*promp.mu_w;
            fig = visualisationShared(meanTraj, promp.PHI_norm*1.96*sqrt(diag(promp.sigma_w )), sum(promp.traj.nbInput), s_ref,  i, col1, fig);
          %  fig = visualisation(promp.PHI_norm*promp.mu_w, sum(promp.traj.nbInput), s_ref,  i, 'g', fig);
            
             for j = 1 : promp.traj.nbTraj
              fig(size(fig,2) + 1) =  plot(promp.traj.y{j}(1 + promp.traj.totTime(j)*(i-1) : promp.traj.totTime(j)/100 : promp.traj.totTime(j)*i), col2,'linewidth',0.5);hold on;
            end
            datG = size(fig,2);
            fig(size(fig,2) + 1) =  plot(meanTraj(1 + s_ref*(i-1):s_ref*i), col1,'linewidth', 2);
            set(gca, 'fontsize', 20);
            disG = size(fig,2);
            ylabel(list{i}, 'fontsize', 24);
         if(i==promp.traj.nbInput(1))
              xlabel('Normalized #samples', 'fontsize', 24);
         end
         set(gca, 'fontsize', 20);
         cpt = cpt+1;
    end
    %    legend(fig([disG,datG]), 'Distribution learned','Observed data', 'Location', 'Northwest');
end