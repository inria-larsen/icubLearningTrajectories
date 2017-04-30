function drawDistribution(promp, list,s_ref, varargin)
%DRAWDISTRIBUTION draws the learned distribution

set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

if(~isempty(varargin))
    interval=varargin{1};
    nbInputs = length(interval);
else
    nbInputs = sum(promp.traj.nbInput);
    interval = [1:nbInputs];
end
    fig = figure;

if(nbInputs >3) 
    subplotInfo=  ceil(nbInputs/2);
    subplotInfo2 = 2;
else
    subplotInfo=  nbInputs;
    subplotInfo2 = 1;
end

    cpt=1;
    for i=interval
           subplot(subplotInfo,subplotInfo2,cpt);
           
            meanTraj =promp.PHI_norm*promp.mu_w;
            fig = visualisationShared(meanTraj, promp.PHI_norm*1.96*sqrt(diag(promp.sigma_w )), sum(promp.traj.nbInput), s_ref,  i, 'b', fig);
          %  fig = visualisation(promp.PHI_norm*promp.mu_w, sum(promp.traj.nbInput), s_ref,  i, 'g', fig);
            
             for j = 1 : promp.traj.nbTraj
              fig(size(fig,2) + 1) =  plot(promp.traj.y{j}(1 + promp.traj.totTime(j)*(i-1) : promp.traj.totTime(j)/100 : promp.traj.totTime(j)*i), 'm','linewidth',0.5);hold on;
            end
            datG = size(fig,2);
            fig(size(fig,2) + 1) =  plot(meanTraj(1 + s_ref*(i-1):s_ref*i), 'b','linewidth', 2);
            set(gca, 'fontsize', 20);
            disG = size(fig,2);
            ylabel(list{i}, 'fontsize', 24);
         if(i==promp.traj.nbInput(1))
              xlabel('Normalized #samples', 'fontsize', 24);
         end
         set(gca, 'fontsize', 20);
         cpt = cpt+1;
    end
        legend(fig([disG,datG]), 'Distribution learned','Observed data', 'Location', 'Northwest');
end