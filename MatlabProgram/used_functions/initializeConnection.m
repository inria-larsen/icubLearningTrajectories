function connection = initializeConnection
%initializeConnection opens the port and create bottles to communicates with the "replay" program.



LoadYarp;

import yarp.Port;
import yarp.Bottle;

connection.port=Port;
%first close the port just in case
connection.port.close;

connection.port2=Port;
connection.port2.close;

disp('Going to open port /matlab/write');
connection.port.open('/matlab/write');
disp('Going to open port /matlab/ispeak');
connection.port2.open('/matlab/ispeak');
rep = input('Please connect to a bottle sink (e.g. yarp read/write) and press a button.\n');
connection.b = Bottle;
connection.c = Bottle;
connection.ispeak = Bottle;

end
