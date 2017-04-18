function [train, test] = partitionTrajectory(t, procent)
%PARTITIONTRAJECTORY allows to partition the trajectories sample for training and
%test
%INPUT:
%t: trajectories object
%procent: number of procent of the training data set
 nbTrain = ceil((procent/100)*t.nbTraj);
 nbTest = t.nbTraj - nbTrain;
 test.nbTraj = nbTest;
 train.nbTraj = nbTrain;
 train.nbInput = t.nbInput;
 test.nbInput = t.nbInput;
 test.label = t.label;
 train.label = t.label;
 list = zeros(nbTest,1);

    for i=1:nbTest
        ind = ceil(nbTrain*rand(1));
        while(ismember(ind, list))
            ind = nbTrain*rand(1);
        end
        list(i) = ind;
        test.y{i} = t.y{ind};
        test.yMat{i} = t.yMat{ind};
        test.totTime(i) = t.totTime(ind);
        test.alpha(i) = t.alpha(ind);
        test.realTime(i) = t.realTime(ind);
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