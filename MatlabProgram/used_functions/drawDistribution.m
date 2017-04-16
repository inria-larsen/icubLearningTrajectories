function drawDistribution(promp, list,z)
%DRAWDISTRIBUTION 
%draw the distribution learned   	

set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

    fig = figure;
 
    for i=1:promp{1}.traj.nbInput(1)%nbDofTot
           subplot(promp{1}.traj.nbInput(1),1,i);
            for j = 1 : promp{1}.traj.nbTraj
              fig(size(fig,2) + 1) =  plot(promp{1}.traj.y{j}(1 + promp{1}.traj.totTime(j)*(i-1) : promp{1}.traj.totTime(j)/100 : promp{1}.traj.totTime(j)*i), ':b','linewidth',2);hold on;
            end
            datG = size(fig,2);
            
            fig = visualisationShared(promp{1}.PSI_z*promp{1}.mu_w, promp{1}.PSI_z*1.96*sqrt(diag(promp{1}.sigma_w )), sum(promp{1}.traj.nbInput), z,  i, 'g', fig);
            fig = visualisation(promp{1}.PSI_z*promp{1}.mu_w, sum(promp{1}.traj.nbInput), z,  i, 'g', fig);
            set(gca, 'fontsize', 20);
            disG = size(fig,2);
            ylabel(list{i}, 'fontsize', 24);
         if(i==promp{1}.traj.nbInput(1))
              xlabel('Normalized #samples', 'fontsize', 24);
         end
         set(gca, 'fontsize', 20);
    end
        legend(fig([disG,datG]), 'distribution learned','observed data');
end