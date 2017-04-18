function [train, test] = partitionTrajectory(t, procent, procentData, refTime)
%PARTITIONTRAJECTORY allows to partition the trajectories sample for training and
%test
%INPUT:
%t: trajectories object
%procent: number of procent of the training data set; 
%or if procent==1: only one test

if(procent==1)%want only one test 
    ind = ceil(rand(1)*t.nbTraj)
    test{1}.y = t.y{ind}
    test{1}.yMat = t.yMat{ind};
    test{1}.totTime = t.totTime(ind);
    test{1}.alpha = refTime / test{1}.totTime;
    test{1}.partialTraj = [];
    test{1}.nbData = ceil((procentData/100)*t.totTime(ind));
    for i=1:t.nbInput(1)
       test{1}.partialTraj = [test{1}.partialTraj; t.yMat{ind}(1:test{1}.nbData,i)];
    end
    train.nbTraj = t.nbTraj -1;
    train.nbInput = t.nbInput;
    train.label = t.label;
    for i=1:ind-1
            train.alpha(i) = t.alpha(i);
            train.y{i} =  t.y{i};
            train.yMat{i} = t.yMat{i};
            train.totTime(i) = t.totTime(i);
            train.realTime{i} = t.realTime{i};
    end
    for i=ind+1:t.nbTraj
            train.alpha(i-1) = t.alpha(i);
            train.y{i-1} =  t.y{i};
            train.yMat{i-1} = t.yMat{i};
            train.totTime(i-1) = t.totTime(i);
            train.realTime{i-1} = t.realTime{i};
    end
    
else
     nbTrain = ceil((procent/100)*t.nbTraj)
     nbTest = t.nbTraj - nbTrain;
     test.nbTraj = nbTest;
     train.nbTraj = nbTrain;
     train.nbInput = t.nbInput;
     test.nbInput = t.nbInput;
     test.label = t.label;
     train.label = t.label;
     list = zeros(nbTest,1);
    test = cell(nbTest,1);
    for i=1:nbTest
        ind = ceil(nbTrain*rand(1));
        while(ismember(ind, list))
            ind = nbTrain*rand(1);
        end
        list(i) = ind;
        test{i}.y = t.y{ind};
        test{i}.yMat = t.yMat{ind};
        test{i}.totTime = t.totTime(ind);
        test{i}.alpha = t.alpha(ind);
        test{i}.realTime = t.realTime(ind);
        test{i}.nbData = ceil((procentData/100)*t.totTime(ind));
        test{i}.partialTraj = [];
        for j=1:t.nbInput(1)
            test{i}.partialTraj = [test{i}.partialTraj; t.yMat{ind}(1:test{i}.nbData,j)];
        end
    end
    cpt=1;
    for i=1:t.nbTraj
        if(~ismember(i,list))
            train.y{cpt} = t.y{i};
            train.yMat{cpt} = t.yMat{i};
            train.totTime(cpt) = t.totTime(i);
            train.alpha(cpt) = t.alpha(i);
            train.realTime(cpt) = t.realTime(i);
            cpt = cpt+1;
        end
    end
end
     
end