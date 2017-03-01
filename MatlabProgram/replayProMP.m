
function replayProMP(i, proMP, connection,z)
%In this function we will play the trajectory into gazebo.

data = proMP.PSI_z*proMP.mu_w;

    for t = 1 : z
        connection.b.clear();
        for i = 1 : proMP.traj.nbInput %+ nbDof(2)
            val(t,i) = data(z*(i-1)+t);
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