function drawDistribution(promp, list,z, varargin)
%DRAWDISTRIBUTION draws the learned distribution

set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

if(~isempty(varargin))
    interval=varargin{1};
    nbInputs = length(interval);
else
    nbInputs = sum(promp{1}.traj.nbInput);
    interval = [1:nbInputs];
end
    
 for i=1:length(promp)
    fig =figure;
    for j=interval
           subplot(ceil(nbInputs/2),2,j);
            for k = 1 : promp{i}.traj.nbTraj
              fig(size(fig,2) + 1) =  plot(promp{i}.traj.y{k}(1 + promp{i}.traj.totTime(k)*(j-1) : promp{i}.traj.totTime(k)/z : promp{i}.traj.totTime(k)*j), ':b','linewidth',2);hold on;
            end
            datG = size(fig,2);
            
            fig = visualisationShared(promp{i}.PSI_z*promp{i}.mu_w, promp{i}.PSI_z*1.96*sqrt(diag(promp{i}.sigma_w )), sum(promp{i}.traj.nbInput), z,  j, 'g', fig);
            fig = visualisation(promp{i}.PSI_z*promp{i}.mu_w, sum(promp{i}.traj.nbInput), z,  j, 'g', fig);
            set(gca, 'fontsize', 20);
            disG = size(fig,2);
            
         ylabel(list{j}, 'fontsize', 24);
         if(j==promp{i}.traj.nbInput(1))
              xlabel('Samples', 'fontsize', 24);
         end
         set(gca, 'fontsize', 20);
    end
        legend(fig([disG,datG]), 'Learned distribution','Observed data');
        title(['Distribution trajectory ', promp{i}.traj.label]);
 end
end