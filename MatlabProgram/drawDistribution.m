function drawDistribution(promp, list,z)
%DRAWDISTRIBUTION 
%draw the distribution learned   	

set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

    
 for i=1:length(promp)
     
     fig =figure;%('PaperPositionMode', 'auto');
    for vff=1:6%promp{i}.traj.nbInput(1)%nbDofTot
           subplot(promp{i}.traj.nbInput(1),2,vff);%size(nbDof,2),vff);
%             a = PSI_z*promp{i}.mu_w;
%             b = PSI_z*1.96*sqrt(diag(promp{i}.sigma_w));% a +
%             plot(a(1+100*(vff-1):100*(vff)),'g');hold on;
%              plot(a(1+100*(vff-1):100*(vff)) - b(1+100*(vff-1):100*(vff)), '.-g');hold on;
%              plot(a(1+100*(vff-1):100*(vff)) + b(1+100*(vff-1):100*(vff)), '.-g');hold on;
            %fig(size(fig,2) + 1) =

            
            for j = 1 : promp{i}.traj.nbTraj
                %a = w{i}(j,:)*promp{i}.PSI_z';
                %plot(a((vff-1)*100 + 1:(vff)*100) , ':k');hold on;
              fig(size(fig,2) + 1) =  plot(promp{i}.traj.y{j}(1 + promp{i}.traj.totTime(j)*(vff-1) : promp{i}.traj.totTime(j)/100 : promp{i}.traj.totTime(j)*vff), ':b','linewidth',2);hold on;
            end
            datG = size(fig,2);
            
            fig = visualisationShared(promp{i}.PSI_z*promp{i}.mu_w, promp{i}.PSI_z*1.96*sqrt(diag(promp{i}.sigma_w )), sum(promp{i}.traj.nbInput), z,  vff, 'g', fig);
            fig = visualisation(promp{i}.PSI_z*promp{i}.mu_w, sum(promp{i}.traj.nbInput), z,  vff, 'g', fig);
            set(gca, 'fontsize', 20);
            disG = size(fig,2);
            
            %un des tests
            %plot(y_trial_Tot{i}(totalTimeTrial(i)*(vff-1) + 1 : (totalTimeTrial(i)/100): totalTimeTrial(i)*vff),'+g');hold on;
        %visualisationShared(a((vff-1)*100 + 1:(vff)*100) , b((vff-1)*100 + 1:(vff)*100 ), 100, 1, z, 1, fig);hold on;
       % plot(b((vff-1)*100 + 1:(vff)*100) ,'--', 'Color', [i/nbKindOfpromp{i}.traj, 0, 0]);hold on;
       % b = a - promp{i}.PSI_z*1.96*sqrt(diag(promp{i}.sigma_w));
       % plot(b((vff-1)*100 + 1:(vff)*100) ,'--', 'Color', [i/nbKindOfpromp{i}.traj, 0, 0]);hold on;
         ylabel(list{vff}, 'fontsize', 24);
         if(vff==promp{i}.traj.nbInput(1))
              xlabel('Samples', 'fontsize', 24);
         end
         set(gca, 'fontsize', 20);
    end
        legend(fig([disG,datG]), 'Learned distribution','observed data');
        title(['Distribution trajectory', promp{i}.traj.label]);
        print(gcf, '-dpdf', 'test.pdf');
 end
end