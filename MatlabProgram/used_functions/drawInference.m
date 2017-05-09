function drawInference(promp, infTraj, test,s_ref, varargin)
list = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'};

nbInput = promp{1}.traj.nbInput;
set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

%Plot the total trial and the data we have
nameFig = figure;

for vff=1:nbInput(1)
    subplot(nbInput(1),1,vff);

    interval = test.realTime(test.totTime) / test.totTime;
    RTInf = infTraj.timeInf*0.01;
    intervalInf = RTInf / infTraj.timeInf;
    i = infTraj.reco;%reco{1};
    visualisationShared(infTraj.PHI*promp{i}.mu_w, infTraj.PHI*1.96*sqrt(diag(promp{i}.sigma_w )), sum(nbInput), infTraj.timeInf,  vff, 'b', nameFig, 'vecX',[intervalInf:intervalInf:RTInf]);
    nameFig = visualisation(infTraj.PHI*promp{i}.mu_w, sum(nbInput), infTraj.timeInf, vff, 'b', nameFig,[intervalInf:intervalInf:RTInf]);
    prevG = size(nameFig,2);
    visualisationShared(infTraj.PHI*infTraj.mu_w, infTraj.PHI*1.96*sqrt(diag(infTraj.sigma_w)), sum(nbInput), infTraj.timeInf,  vff,'r', nameFig,'vecX', [intervalInf:intervalInf:RTInf]);


    nameFig = visualisation(infTraj.PHI*infTraj.mu_w, sum(nbInput), infTraj.timeInf, vff, 'r', nameFig,[intervalInf:intervalInf:RTInf]);
    newG = size(nameFig,2);
    nameFig(size(nameFig,2) + 1) = plot( [test.realTime(1):interval: test.realTime(test.totTime)],test.yMat(:,vff), ':k', 'linewidth', 2);
    %visualisation2(test.yMat,sum(nbInput), test.totTime,vff, ':k', 1, nameFig);hold on;
    dtG = size(nameFig,2);
    nameFig(size(nameFig,2) + 1) = plot([intervalInf:intervalInf:test.nbData*intervalInf],test.partialTraj(1+ test.nbData*(vff-1):test.nbData + test.nbData*(vff-1)),'ok','linewidth',3);
    dnG = size(nameFig,2);
    
    ylabel(list{vff}, 'fontsize', 24);
         
%            switch vff
%                case 1: axis([-0.35 -0.25 0 100]);
%                case 2: asis([-0.1 0 0 100]);
%                case 3: axis([-0.1 0.2]);
%            end
           if(vff==nbInput(1))
              xlabel('Time [s]', 'fontsize', 24);
         end
         set(gca, 'fontsize', 20)
         
end
legend(nameFig(1,[dtG, dnG, prevG, newG]),'real trajectory', 'observations','prior proMP', 'prediction', 'Location', 'southeast');

if (~isempty(varargin))
    if(varargin{1} == 'Name')
        title(varargin{2}, 'fontsize', 24)
    end
end
end
% lim = axis
% maxVal = max(infTraj.alpha*s_ref,test.totTime);
% meanTimeSample = test.realTime(test.totTime) / test.totTime;
% finalVal = meanTimeSample*(infTraj.alpha*s_ref);
% axis(test.realTime(1), finalVal, lim(3), lim(4));