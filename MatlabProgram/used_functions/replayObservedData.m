function replayObservedData(newTraj, connection)
%replayObservedData plays the nbData early observations

%data = y_trial_Tot{trial};

for t = 1 : newTraj.nbData
    connection.b.clear();
     for i = 1 : 3 %cartesianPosition of the robot
%         val(t,i) = newTraj.traj. data(totalTimeTrial(trial)*(i-1)+t);
         connection.b.addDouble(newTraj.yMat(t,i));   %val(t,i));
     end
    connection.port.write(connection.b);
    connection.port.read(connection.c);
   % disp(connection.c);
    num = str2num(connection.c);
    disp(['Receiving: f =', num2str(num(1,1)), ' ', num2str(num(1,2)),' ', num2str(num(1,3)), 'm=', num2str(num(1,4)), ' ',num2str(num(1,5)), ' ',num2str(num(1,6)) ]);
end

rep = input('End of the known data. Please press a button to do the inference.\n');
end