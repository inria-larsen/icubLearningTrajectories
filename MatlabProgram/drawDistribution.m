function drawDistribution(promp, list,z)
%DRAWDISTRIBUTION 
%draw the distribution learned   	

set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

    fig = figure;
 
    for vff=1:promp{1}.traj.nbInput(1)%nbDofTot
           subplot(promp{1}.traj.nbInput(1),1,vff);%size(nbDof,2),vff);
%             a = PSI_z*promp{1}.mu_w;
%             b = PSI_z*1.96*sqrt(diag(promp{1}.sigma_w));% a +
%             plot(a(1+100*(vff-1):100*(vff)),'g');hold on;
%              plot(a(1+100*(vff-1):100*(vff)) - b(1+100*(vff-1):100*(vff)), '.-g');hold on;
%              plot(a(1+100*(vff-1):100*(vff)) + b(1+100*(vff-1):100*(vff)), '.-g');hold on;
            %fig(size(fig,2) + 1) =

            
            for j = 1 : promp{1}.traj.nbTraj
                %a = w{i}(j,:)*promp{1}.PSI_z';
                %plot(a((vff-1)*100 + 1:(vff)*100) , ':k');hold on;
              fig(size(fig,2) + 1) =  plot(promp{1}.traj.y{j}(1 + promp{1}.traj.totTime(j)*(vff-1) : promp{1}.traj.totTime(j)/100 : promp{1}.traj.totTime(j)*vff), ':b','linewidth',2);hold on;
            end
            datG = size(fig,2);
            
            fig = visualisationShared(promp{1}.PSI_z*promp{1}.mu_w, promp{1}.PSI_z*1.96*sqrt(diag(promp{1}.sigma_w )), sum(promp{1}.traj.nbInput), z,  vff, 'r', fig);
            fig = visualisation(promp{1}.PSI_z*promp{1}.mu_w, sum(promp{1}.traj.nbInput), z,  vff, 'r', fig);
            set(gca, 'fontsize', 20);
            disG = size(fig,2);
            
            %un des tests
            %plot(y_trial_Tot{i}(totalTimeTrial(i)*(vff-1) + 1 : (totalTimeTrial(i)/100): totalTimeTrial(i)*vff),'+g');hold on;
        %visualisationShared(a((vff-1)*100 + 1:(vff)*100) , b((vff-1)*100 + 1:(vff)*100 ), 100, 1, z, 1, fig);hold on;
       % plot(b((vff-1)*100 + 1:(vff)*100) ,'--', 'Color', [i/nbKindOfpromp{1}.traj, 0, 0]);hold on;
       % b = a - promp{1}.PSI_z*1.96*sqrt(diag(promp{1}.sigma_w));
       % plot(b((vff-1)*100 + 1:(vff)*100) ,'--', 'Color', [i/nbKindOfpromp{1}.traj, 0, 0]);hold on;
         ylabel(list{vff}, 'fontsize', 24);
         if(vff==promp{1}.traj.nbInput(1))
              xlabel('iterations', 'fontsize', 24);
         end
         set(gca, 'fontsize', 20);
    end
        legend(fig([disG,datG]), 'distribution learnt (mean & standart deviation)','observed data');
end