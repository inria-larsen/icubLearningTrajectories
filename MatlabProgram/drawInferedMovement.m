list = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};

set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

%Plot the total trial and the data we have
%nameFig = figure;

%if you want to plot on the same plot than the learnt distribution.
nameFig = figure%(trial + nbDof(1));

for vff=1:nbDof(1)
    subplot(nbDof(1),1,vff);
    nameFig = visualisation2(y_trial_Tot{trial},sum(nbDof), totalTimeTrial(trial),reco{1}, ':m', realAlpha, nameFig);hold on;
    dtG = size(nameFig,2);
    nameFig(size(nameFig,2) + 1) = plot(y_trial{trial}(1:timeInf/z:nbData),'om','linewidth',2);
    dnG = size(nameFig,2);

    i = reco{1};
    visualisationShared(PSI_z*mu_w{i}, PSI_z*1.96*sqrt(diag(sigma_w{i} )), sum(nbDof), z,  i, 'b', nameFig);
    nameFig = visualisation(PSI_z*mu_w{i}, sum(nbDof), z, i, 'b', nameFig);
    prevG = size(nameFig,2);
    visualisationShared(PSI_z*mu_new, PSI_z*1.96*sqrt(diag(sigma_new)), sum(nbDof), z,  i, 'g', nameFig);
    nameFig = visualisation(PSI_z*mu_new, sum(nbDof), z, i,'g', nameFig);
    newG = size(nameFig,2);
           ylabel(list{vff}, 'fontsize', 24);
         if(vff==nbDof(1))
              xlabel('iterations', 'fontsize', 24);
         end
end
legend(nameFig(1,[dtG, dnG, prevG, newG]),'desired trajectory', 'data known','learnt distribution', 'new distribution' );
