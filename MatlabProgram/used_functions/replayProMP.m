
function replayProMP(i, ProMP, connection,s_bar)
%In this function we will play the trajectory into gazebo.

data = ProMP.PHI_z*ProMP.mu_w;

    for t = 1 : s_bar
        connection.b.clear();
        for i = 1 : ProMP.traj.nbInput %+ nbDof(2)
            val(t,i) = data(s_bar*(i-1)+t);
            connection.b.addDouble(val(t,i));
        end
        %compliance information
        connection.b.addDouble(0.0);

        connection.port.write(connection.b);
        disp('Have send the message:');
        val(t,:)
        disp('We receive: ');
        connection.port.read(connection.c);
        disp(connection.c);
    end
    
    %Send information about the end of the trajectory and verify it
    %receives it.
    connection.b.clear();
    connection.b.addDouble(0.0)
    connection.port.write(connection.b);
    connection.port.read(connection.c);
    disp(connection.c);
end