function drawInference(promp,list, infTraj, test,s_ref, varargin)

nbInput = promp{1}.traj.nbInput;
set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

isInterval=0;
isNamed=0;
if (~isempty(varargin))
        for i=1:length(varargin)
        if(strcmp(varargin{i},'Name'))
            isNamed=1;
            i=i+1;
            Name = varargin{i};
        elseif(strcmp(varargin{i},'Interval')==1)
            isInterval=1;
            i=i+1;
            intervalPlot = reshape(varargin{i}',1,[]);
                subplotInfo=  size(varargin{i},1);%ceil(nbInputs/2);
                 subplotInfo2 = size(varargin{i},2);
        end
    end
end


%Plot the total trial and the data we have
nameFig = figure;

if(isInterval==1)
    cpt=0;
    i = infTraj.reco%reco{1};
    prior = infTraj.PHI*promp{i}.mu_w;
    otherPrior = infTraj.PHI*promp{(3 - i)}.mu_w;
    varOtherPrior = infTraj.PHI*1.96*sqrt(diag(promp{(3-i)}.sigma_w ));

    varPrior = infTraj.PHI*1.96*sqrt(diag(promp{i}.sigma_w ));
    posterior = infTraj.PHI*infTraj.mu_w;
    varPosterior = infTraj.PHI*1.96*sqrt(diag(infTraj.sigma_w));
	for vff=intervalPlot
        cpt=cpt+1;
        subplot(subplotInfo,subplotInfo2,cpt);

        interval = test.realTime(test.totTime) / test.totTime;
        RTInf = infTraj.timeInf*0.01;
        intervalInf = RTInf / infTraj.timeInf;
        visualisationShared(prior, varPrior, sum(nbInput), infTraj.timeInf,  vff, 'b', nameFig, 'vecX',[intervalInf:intervalInf:RTInf]);
        
        
        visualisationShared(otherPrior, varOtherPrior, sum(nbInput), infTraj.timeInf,  vff, 'b', nameFig, 'vecX',[intervalInf:intervalInf:RTInf]);
        nameFig = visualisation(otherPrior, sum(nbInput), infTraj.timeInf, vff, 'g', nameFig,[intervalInf:intervalInf:RTInf]);
        otherP = size(nameFig,2);

        
        nameFig = visualisation(prior, sum(nbInput), infTraj.timeInf, vff, 'b', nameFig,[intervalInf:intervalInf:RTInf]);
        prevG = size(nameFig,2);
        visualisationShared(posterior, varPosterior, sum(nbInput), infTraj.timeInf,  vff,'r', nameFig,'vecX', [intervalInf:intervalInf:RTInf]);

        nameFig = visualisation(posterior, sum(nbInput), infTraj.timeInf, vff, 'r', nameFig,[intervalInf:intervalInf:RTInf]);
        newG = size(nameFig,2);
        nameFig(size(nameFig,2) + 1) = plot( test.realTime,test.yMat(:,vff), ':k', 'linewidth', 2);
        %visualisation2(test.yMat,sum(nbInput), test.totTime,vff, ':k', 1, nameFig);hold on;
        dtG = size(nameFig,2);
        if(vff <= nbInput(1))
            nameFig(size(nameFig,2) + 1) = plot([interval:interval:test.nbData*interval],test.partialTraj(1+ test.nbData*(vff-1):test.nbData*vff),'ok','linewidth',3);
           dnG = size(nameFig,2);
        end

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
            legend(nameFig(1,[dtG,otherP, dnG, prevG, newG]),'real trajectory', 'other prior', 'observations','prior proMP', 'prediction', 'Location', 'southeast');

else
    for vff=1:nbInput(1)
        subplot(nbInput(1),1,vff);
        if(isfield(test, 'totTime') )
            if(isfield(test, 'realTime'))
                interval =  test.realTime(test.totTime) / test.totTime;
            end
        end
        RTInf = infTraj.timeInf*0.01;
        intervalInf = RTInf / infTraj.timeInf;
        i = infTraj.reco%reco{1};
        visualisationShared(infTraj.PHI*promp{i}.mu_w, infTraj.PHI*1.96*sqrt(diag(promp{i}.sigma_w )), sum(nbInput), infTraj.timeInf,  vff, 'b', nameFig, 'vecX',[intervalInf:intervalInf:RTInf]);
        nameFig = visualisation(infTraj.PHI*promp{i}.mu_w, sum(nbInput), infTraj.timeInf, vff, 'b', nameFig,[intervalInf:intervalInf:RTInf]);
        prevG = size(nameFig,2);
        visualisationShared(infTraj.PHI*infTraj.mu_w, infTraj.PHI*1.96*sqrt(diag(infTraj.sigma_w)), sum(nbInput), infTraj.timeInf,  vff,'r', nameFig,'vecX', [intervalInf:intervalInf:RTInf]);
        nameFig = visualisation(infTraj.PHI*infTraj.mu_w, sum(nbInput), infTraj.timeInf, vff, 'r', nameFig,[intervalInf:intervalInf:RTInf]);
        newG = size(nameFig,2);
        varOtherPrior = infTraj.PHI*1.96*sqrt(diag(promp{(3-i)}.sigma_w ));

        otherPrior = infTraj.PHI*promp{(3 - i)}.mu_w;
        visualisationShared(otherPrior, varOtherPrior, sum(nbInput), infTraj.timeInf,  vff, 'g', nameFig, 'vecX',[intervalInf:intervalInf:RTInf]);
        nameFig = visualisation(otherPrior, sum(nbInput), infTraj.timeInf, vff, 'g', nameFig,[intervalInf:intervalInf:RTInf]);
        otherP = size(nameFig,2);

        
        
        if(isfield(test, 'interval'))
            if(isfield(test, 'realTime'))
                nameFig(size(nameFig,2) + 1) = plot( [interval:interval: test.realTime(test.totTime)],test.yMat(:,vff), ':k', 'linewidth', 2);
            end
            %visualisation2(test.yMat,sum(nbInput), test.totTime,vff, ':k', 1, nameFig);hold on;
            dtG = size(nameFig,2);
        end
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
    if(exist('dtG'))
            legend(nameFig(1,[dtG,otherP, dnG, prevG, newG]),'real trajectory', 'other prior', 'observations','prior proMP', 'prediction', 'Location', 'southeast');
    else
            legend(nameFig(1,[otherP, dnG, prevG, newG]), 'other prior', 'observations','prior proMP', 'prediction', 'Location', 'southeast');
    end
end


if (isNamed==1)
        title(Name, 'fontsize', 24)
end


end
% lim = axis
% maxVal = max(infTraj.alpha*s_ref,test.totTime);
% meanTimeSample = test.realTime(test.totTime) / test.totTime;
% finalVal = meanTimeSample*(infTraj.alpha*s_ref);
% axis(test.realTime(1), finalVal, lim(3), lim(4));