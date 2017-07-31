function [test] = beginATrajectory(connection)

    connection.b.clear();
    connection.b.addDouble(-2.0);
    connection.port.write(connection.b);
    ok=1;
    t=1
    while(ok==1)  
        disp('You can begin a movement. Maintain the dark geomagic button pressed and realase it when you want it finish it.');
        connection.c.clear(); 
        connection.port.read(connection.c); 
        disp('we have received data'); 
        disp(connection.c); 
        
        num2 = str2num(connection.c);   
        if(num2(1) ==-2.0)
            ok=0;
        else
            num(t,:) = num2;
            t=t+1;
        end
    end
    y_trial_nbData = [num(:,10) ; num(:,11) ; num(:,12) ; num(:,4) ; num(:,5);num(:,6);num(:,7);num(:,8);num(:,9)]; 
    test.y = y_trial_nbData;
    test.partialTraj = [num(:,10) ; num(:,11) ; num(:,12) ];
    test.yMat = [num(:,10) , num(:,11) , num(:,12) , num(:,4) , num(:,5),num(:,6),num(:,7),num(:,8),num(:,9)] ;
    test.nbData = size(test.yMat,1);
end
