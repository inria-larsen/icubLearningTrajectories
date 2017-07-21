function [test] = beginATrajectoryWithRealIcub(connection)


    ok=0;
    disp('You can begin a movement. Maintain the robot left arm and move it till the end of the movement.');

    %wait for skin contact
    while(ok==0)
        display('waiting skin contact');
        skinContact;
    end

    %todo : mettre cette fonction avec reelle trajectoire du iCUb
    t=1
    while(ok==1)  
        
        disp('on est dans la boucle');
        %modify this part: should retrieve information
        connection.wrenches.clear(); 
        connection.port4.read(connection.wrenches); 
        disp('We have received wrenches'); 
        disp(connection.wrenches); 
        num2 = str2num(connection.wrenches);   
        connection.state.clear(); 
        connection.port5.read(connection.state); 
        disp('We have received cartesian state'); 
        disp(connection.state); 
        num3 = str2num(connection.wrenches);   
        
        num(t,:) = [num3(1:3)'; num2'];
        t=t+1;
                
        %verify contact
        skinContact;
    end
    y_trial_nbData = [num(:,1) ; num(:,2) ; num(:,3) ; num(:,4) ; num(:,5);num(:,6);num(:,7);num(:,8);num(:,9)]; 
    test.y = y_trial_nbData;
    test.partialTraj = [num(:,1) ; num(:,2) ; num(:,3) ];
    test.yMat = [num(:,1) , num(:,2) , num(:,3) , num(:,4) , num(:,5),num(:,6),num(:,7),num(:,8),num(:,9)] ;
    test.nbData = size(test.yMat,1);
end