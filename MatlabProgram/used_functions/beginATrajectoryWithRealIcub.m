function [test] = beginATrajectoryWithRealIcub(connexion)
    finish=0;
    disp('You can begin a movement. Maintain the robot left arm and move it till the end of the movement.');

    while(finish==0)
       threshold = 20;
        ok=0;
        %wait for skin contact
        while(ok==0)
            display('waiting skin contact');
            skinContact;%(30);
        end

        %todo : mettre cette fonction avec reelle trajectoire du iCUb
        cpt=1;
        val = 0;
        threshold = 15;
        tic;
        clear num num3;
        while(ok==1)  
            connexion.state.clear(); 
            connexion.portState.read(connexion.state); 
            num3 = str2num(connexion.state)
            num(cpt,:) = num3';
            cpt=cpt+1;
            %verify contact
            skinContact;%(15);
        end
        timeEl = toc;

        if(length(num) <10)
            display('error, it is not a real trajectory (too short)');
        else 
            finish = 1;
        end
    end
    
    disp('End of the early-observations');
    test.interval = timeEl /length(num);
    test.nbData =length(num); 
    test.yMat = num;
    test.y = [num(:,1) ; num(:,2) ; num(:,3) ; num(:,4) ; num(:,5);num(:,6);num(:,7)];
    test.partialTraj = test.y; %y_trial_nbData;% [num(:,1) ; num(:,2) ; num(:,3) ];
end