function connection = initializeConnection
%initializeConnection opens the port and create bottles to communicates with the "replay" program.



LoadYarp;
import yarp.Port;
import yarp.Bottle;

connection.port=Port;

%first close the port just in case
connection.port.close;

disp('Going to open port /matlab/write and read');
connection.port.open('/matlab/write');
rep = input('Please connect to a bottle sink (e.g. yarp read) and press a button.\n');
connection.b = Bottle;
connection.c = Bottle;
end
