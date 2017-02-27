%DRAWDISTRIBUTION 
%draw the distribution learned

list = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};
   	

set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)
for i=1:nbKindOfTraj
    fig = figure%(i+nbDof(1));
 
    for vff=1:nbDof(1)%nbDofTot
            subplot(nbDof(1),1,vff);%size(nbDof,2),vff);
%             a = PSI_z*mu_w{i};
%             b = PSI_z*1.96*sqrt(diag(sigma_w{i}));% a +
%             plot(a(1+100*(vff-1):100*(vff)),'g');hold on;
%              plot(a(1+100*(vff-1):100*(vff)) - b(1+100*(vff-1):100*(vff)), '.-g');hold on;
%              plot(a(1+100*(vff-1):100*(vff)) + b(1+100*(vff-1):100*(vff)), '.-g');hold on;
            %fig(size(fig,2) + 1) =

            
            for j = 1 : var(i)
                %a = w{i}(j,:)*PSI_z';
                %plot(a((vff-1)*100 + 1:(vff)*100) , ':k');hold on;
              fig(size(fig,2) + 1) =  plot(y{i}{j}(1 + totalTime(i,j)*(vff-1) : totalTime(i,j)/100 : totalTime(i,j)*vff), ':b','linewidth',2);hold on;
            end
            datG = size(fig,2);
            
            fig = visualisationShared(PSI_z*mu_w{i}, PSI_z*1.96*sqrt(diag(sigma_w{i} )), nbDofTot, z,  vff, 'r', fig);
            fig = visualisation(PSI_z*mu_w{i}, nbDofTot, z,  vff, 'r', fig);
            set(gca, 'fontsize', 10);
            disG = size(fig,2);
            
            %un des tests
            %plot(y_trial_Tot{i}(totalTimeTrial(i)*(vff-1) + 1 : (totalTimeTrial(i)/100): totalTimeTrial(i)*vff),'+g');hold on;
        %visualisationShared(a((vff-1)*100 + 1:(vff)*100) , b((vff-1)*100 + 1:(vff)*100 ), 100, 1, z, 1, fig);hold on;
       % plot(b((vff-1)*100 + 1:(vff)*100) ,'--', 'Color', [i/nbKindOfTraj, 0, 0]);hold on;
       % b = a - PSI_z*1.96*sqrt(diag(sigma_w{i}));
       % plot(b((vff-1)*100 + 1:(vff)*100) ,'--', 'Color', [i/nbKindOfTraj, 0, 0]);hold on;
         ylabel(list{vff}, 'fontsize', 24);
         if(vff==nbDof(1))
              xlabel('iterations', 'fontsize', 24);
         end
    end
        legend(fig([disG,datG]), 'distribution learnt (mean & standart deviation)','observed data');
end