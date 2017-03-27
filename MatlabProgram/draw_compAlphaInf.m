set(0,'DefaultLineLinewidth',1)
set(0,'DefaultAxesFontSize',12)

mu_wcoor = promp{1}.mu_w(1:3*5);
sigma_wcoor = promp{1}.sigma_w(1:3*5, 1:3*5);

psiExp_part = computeBasisFunction(z,nbFunctions(1), nbInput(1),  test.alpha, floor(z/ test.alpha), center_gaussian(1), h(1), nbData);
exppart = psiExp_part*promp{1}.mu_w(1:3*5);
sigexpart = psiExp_part*0.1*sqrt(diag(sigma_wcoor));

psiExp_tot = computeBasisFunction(z,nbFunctions(1), nbInput(1),  test.alpha, floor(z/ test.alpha), center_gaussian(1), h(1), floor(z/ test.alpha));
exptot = psiExp_tot*promp{1}.mu_w(1:3*5);
sigextot = psiExp_tot*0.1*sqrt(diag(sigma_wcoor));

psiComp_part = computeBasisFunction(z,nbFunctions(1), nbInput(1),  alphaTraj, floor(z/ alphaTraj), center_gaussian(1), h(1), nbData);
psiComp_tot = computeBasisFunction(z,nbFunctions(1), nbInput(1),  alphaTraj, floor(z/ alphaTraj), center_gaussian(1), h(1), floor(z/ alphaTraj));
comppart = psiComp_part*promp{1}.mu_w(1:3*5);
comptot = psiComp_tot*promp{1}.mu_w(1:3*5);
sigcomppart = psiComp_part*0.1*sqrt(diag(sigma_wcoor));
sigcomptot = psiComp_tot*0.1*sqrt(diag(sigma_wcoor));

psiMu_part = computeBasisFunction(z,nbFunctions(1), nbInput(1),  promp{1}.mu_alpha, floor(z/ promp{1}.mu_alpha), center_gaussian(1), h(1), nbData);
psiMu_tot = computeBasisFunction(z,nbFunctions(1), nbInput(1),  promp{1}.mu_alpha, floor(z/ promp{1}.mu_alpha), center_gaussian(1), h(1), floor(z/ promp{1}.mu_alpha));
mupart = psiMu_part*promp{1}.mu_w(1:3*5);
mutot = psiMu_tot*promp{1}.mu_w(1:3*5);
sigmupart = psiMu_part*0.1*sqrt(diag(sigma_wcoor));
sigmutot = psiMu_part*0.1*sqrt(diag(sigma_wcoor));

fig = figure;
subplot(3,1,3)
plot(test.partialTraj(nbData*2+1:nbData*3),'b');hold on;
plot(comppart(nbData*2+1:nbData*3),'m');
plot(mupart(nbData*2+1:nbData*3),'r');
plot(exppart(nbData*2+1:nbData*3),'g');
plot(x(nbData*2+1:nbData*3),'k');hold on;

% 
plot(exptot(1+floor(z/ test.alpha)*2:floor(z/ test.alpha)*3),':g');
plot(mutot(2*floor(z/ promp{1}.mu_alpha)+1:floor(z/ promp{1}.mu_alpha)*3),':r');
plot(comptot(floor(z/ alphaTraj)*2+1: floor(z/ alphaTraj)*3),':m');
plot(test.traj(test.totTime*2+1:test.totTime*3),':b');

% 
% visualisationShared(exppart, sigexpart, nbInput(1), nbData,  3, 'g', fig);
% visualisationShared(comppart, sigcomppart, nbInput(1), nbData,  3, 'm', fig);
% visualisationShared(mupart, sigmupart, nbInput(1), nbData,  3, 'r', fig);



subplot(3,1,1)

plot(test.partialTraj(1:nbData),'b');hold on;
plot(x(nbData*0+1:nbData*1),'k');hold on;
plot(comppart(1:nbData),'m');hold on;
plot(mupart(nbData*0+1:nbData*1),'r');hold on;

plot(exppart(nbData*0+1:nbData*1),'g');
legend('Real', 'real + offset', 'max(loglikelihood)', 'mean alpha','expected');

% 
plot(exptot(1+floor(z/ test.alpha)*0:floor(z/ test.alpha)*1),':g');
plot(mutot(0*floor(z/ promp{1}.mu_alpha)+1:floor(z/ promp{1}.mu_alpha)*1),':r');
plot(comptot(floor(z/ alphaTraj)*0+1: floor(z/ alphaTraj)*1),':m');
plot(test.traj(test.totTime*0+1:test.totTime*1),':b');



% visualisationShared(exppart, sigexpart, nbInput(1), nbData,  1, 'g', fig);
% visualisationShared(comppart, sigcomppart, nbInput(1), nbData, 1, 'm', fig);
% visualisationShared(mupart, sigmupart, nbInput(1), nbData,  1, 'r', fig);

subplot(3,1,2)
plot(test.partialTraj(nbData*1+1:nbData*2),'b');hold on;
plot(comppart(nbData*1+1:nbData*2),'m');hold on;
plot(mupart(nbData*1+1:nbData*2),'r');hold on;
plot(exppart(nbData*1+1:nbData*2),'g');
plot(x(nbData*1+1:nbData*2),'k');hold on;
% legend('Real', 'max(loglikelihood)', 'mean alpha','expected');
% 
plot(exptot(1+floor(z/ test.alpha)*1:floor(z/ test.alpha)*2),':g');
plot(mutot(2*floor(z/ promp{1}.mu_alpha)+1:floor(z/ promp{1}.mu_alpha)*2),':r');
plot(comptot(floor(z/ alphaTraj)*1+1: floor(z/ alphaTraj)*2),':m');
plot(test.traj(test.totTime*1+1:test.totTime*2),':b');


% 
% visualisationShared(exppart, sigexpart, nbInput(1), nbData,  2, 'g', fig);
% visualisationShared(comppart, sigcomppart, nbInput(1), nbData,  2, 'm', fig);
% visualisationShared(mupart, sigmupart, nbInput(1), nbData,  2, 'r', fig);



