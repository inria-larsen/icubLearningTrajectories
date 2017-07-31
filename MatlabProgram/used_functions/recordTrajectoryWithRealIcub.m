function t = recordTrajectoryWithRealIcub(connexion, typeName, nbInput, s_bar)

    continueRecording=20;
    t.nbTraj = 0;
    t.label = typeName;
    t.nbInput = nbInput;

    while(continueRecording)
        a = input('Go to home position');
        ok=0;
        disp('You can begin a movement. Maintain the robot left arm and move it till the end of the movement.');

        display('waiting skin contact');
        %wait for skin contact
        while(ok==0)
            skinContact;
        end
        display('Contact detected. Recording the trajectory');
        
        cpt=1;
        val = 0;
        tic;
        while(ok==1)  
            connexion.state.clear(); 
            connexion.portState.read(connexion.state); 
            num3 = str2num(connexion.state);   
            num(cpt,:) = num3';
            cpt=cpt+1;
                %verify contact
                skinContact;
        end
        display('end of the trajectory');
        timeEl = toc;
        length(num)
        if(length(num) >10)
            disp('End of the observation');
            t.nbTraj = t.nbTraj+1;
            t.interval(t.nbTraj) = timeEl /length(num);

            t.totTime(t.nbTraj) =length(num); 
            t.yMat{t.nbTraj} = num;
            t.y{t.nbTraj} = [num(:,1) ; num(:,2) ; num(:,3) ; num(:,4) ; num(:,5);num(:,6);num(:,7)];
            t.alpha(t.nbTraj) = s_bar / length(num);
        end
        clear num;
        continueRecording = continueRecording -1;
    end
end