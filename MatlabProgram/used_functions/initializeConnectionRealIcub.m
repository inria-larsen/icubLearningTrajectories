function connection = initializeConnectionRealIcub
%initializeConnection opens the port and create bottles to communicates with the "replay" program.



LoadYarp;
import yarp.Port;
import yarp.Bottle;

connection.port=Port;
connection.port.close;

connection.port2=Port;
connection.port2.close;

connection.port3=Port;
connection.port3.close;


connection.port4=Port;
connection.port4.close;

connection.port5=Port;
connection.port5.close;

connection.portGrasp=Port;
connection.portGrasp.close;


disp('Going to open port /matlab/write');
connection.port.open('/matlab/write');
disp('Going to open port /matlab/ispeak');
connection.port2.open('/matlab/ispeak');
disp('Going to open port /matlab/skin');
connection.port3.open('/matlab/skin');
disp('Going to open port /matlab/wrenches');
connection.port4.open('/matlab/wrenches');
disp('Going to open port /matlab/state');
connection.portGrasp.open('/matlab/state');
disp('Going to open port /matlab/grasp:o');
connection.portGrasp.open('/matlab/grasp:o');

rep = input('Please connect to a bottle sink (e.g. yarp read/write) and press a button.\n');
connection.b = Bottle;
connection.c = Bottle;
connection.ispeak = Bottle;
connection.skin = Bottle;
connection.wrenches = Bottle;
connection.state = Bottle;
connection.grasp = Bottle;
connection.graspAns =Bottle;





end
