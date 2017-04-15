function drawInference(promp, infTraj, test,z)
list = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};

nbInput = promp{1}.traj.nbInput;
set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

%Plot the total trial and the data we have
nameFig = figure;

for vff=1:nbInput(1)
    subplot(nbInput(1),1,vff);
    nameFig = visualisation2(test.traj,sum(nbInput), test.totTime,vff, ':m', z / test.totTime, nameFig);hold on;
    dtG = size(nameFig,2);
    nameFig(size(nameFig,2) + 1) = plot(test.partialTraj(1+ test.nbData*(vff-1):(infTraj.timeInf/z):test.nbData + test.nbData*(vff-1)),'om','linewidth',2);
    dnG = size(nameFig,2);

    i = infTraj.reco;%reco{1};
    visualisationShared(promp{i}.PSI_z*promp{i}.mu_w, promp{i}.PSI_z*1.96*sqrt(diag(promp{i}.sigma_w )), sum(nbInput), z,  vff, 'b', nameFig);
    nameFig = visualisation(promp{i}.PSI_z*promp{i}.mu_w, sum(nbInput), z, vff, 'b', nameFig);
    prevG = size(nameFig,2);
    visualisationShared(promp{i}.PSI_z*infTraj.mu_w, promp{i}.PSI_z*1.96*sqrt(diag(infTraj.sigma_w)), sum(nbInput), z,  vff, 'g', nameFig);
    nameFig = visualisation(promp{i}.PSI_z*infTraj.mu_w, sum(nbInput), z, vff,'g', nameFig);
    newG = size(nameFig,2);
           ylabel(list{vff}, 'fontsize', 24);
         
%            switch vff
%                case 1: axis([-0.35 -0.25 0 100]);
%                case 2: asis([-0.1 0 0 100]);
%                case 3: axis([-0.1 0.2]);
%            end
           if(vff==nbInput(1))
              xlabel('Samples', 'fontsize', 24);
         end
         set(gca, 'fontsize', 20)
         
end
legend(nameFig(1,[dtG, dnG, prevG, newG]),'real trajectory', 'observations','prior proMP', 'prediction' );
end