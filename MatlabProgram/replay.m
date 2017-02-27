%In this function we will play the trajectory into gazebo.

i = input('Then, give the trajectory you want to replay (1,2 or 3)\n');
data = PSI_z*mu_w{i};
done = 0;
while(~done)
    for t = 1 : z
        b.clear();
        for i = 1 : nbDof(1) %+ nbDof(2)
            val(t,i) = data(z*(i-1)+t);
            b.addDouble(val(t,i));
        end
        %compliance information
        b.addDouble(0.0);

       %  message = num2string(val(t,:))
        port.write(b);
        disp('Have send the message:');
        val(t,:)
        disp('We receive: ');
        port.read(c);
        disp(c);
    end
    
    %Send information about the end of the trajectory and verify it
    %receives it.
    b.clear();
    b.addDouble(0.0)
    port.write(b);
   % display('writing 0.0.');
    port.read(c);
    disp(c);
    
    msg = input('Send q to quit', 's');
    if(msg == 'q')
        done=1;
    else
        i = input('Then, give the trajectory you want to replay (1,2 or 3)\n');
        clear data;
        data = PSI_z*mu_w{i};
    end
end