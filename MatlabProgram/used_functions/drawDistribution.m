function drawDistribution(promp, list,z, varargin)
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
    
    fig =figure;
    for j=interval
           subplot(ceil(nbInputs/2),2,j);
            for k = 1 : promp.traj.nbTraj
              fig(size(fig,2) + 1) =  plot(promp.traj.y{k}(1 + promp.traj.totTime(k)*(j-1) : promp.traj.totTime(k)/z : promp.traj.totTime(k)*j), ':b','linewidth',2);hold on;
            end
            datG = size(fig,2);
            
            fig = visualisationShared(promp.PSI_z*promp.mu_w, promp.PSI_z*1.96*sqrt(diag(promp.sigma_w )), sum(promp.traj.nbInput), z,  j, 'g', fig);
            fig = visualisation(promp.PSI_z*promp.mu_w, sum(promp.traj.nbInput), z,  j, 'g', fig);
            set(gca, 'fontsize', 20);
            disG = size(fig,2);
            
         ylabel(list{j}, 'fontsize', 24);
         if(j==promp.traj.nbInput(1))
              xlabel('Samples', 'fontsize', 24);
         end
         set(gca, 'fontsize', 20);
    end
        legend(fig([disG,datG]), 'Learned distribution','Observed data');
        title(['Distribution trajectory ', promp.traj.label]);
end