function connexion = initializeconnexionRealIcub
%initializeconnexion opens the port and create bottles to communicates with the "replay" program.



LoadYarp;
import yarp.Port;
import yarp.Bottle;

connexion.port=Port;
connexion.port.close;

%connexion.port2=Port;
%connexion.port2.close;

connexion.portSkin=Port;
connexion.portSkin.close;


%connexion.port4=Port;
%connexion.port4.close;

connexion.portState=Port;
connexion.portState.close;

 connexion.portGrasp=Port;
 connexion.portGrasp.close;


connexion.portIG=Port;
connexion.portIG.close;

disp('Going to open port /matlab/write');
connexion.port.open('/matlab/write');
%disp('Going to open port /matlab/ispeak');
%connexion.port2.open('/matlab/ispeak');
disp('Going to open port /matlab/skin');
connexion.portSkin.open('/matlab/skin');
%disp('Going to open port /matlab/wrenches');
%connexion.port4.open('/matlab/wrenches');
disp('Going to open port /matlab/state');
connexion.portState.open('/matlab/state');
disp('Going to open port /matlab/grasp:o');
connexion.portGrasp.open('/matlab/grasp:o');
disp('Going to open port /matlab/IG:o');
connexion.portIG.open('/matlab/IG:o');


rep = input('Please connect to a bottle sink (e.g. yarp read/write) and press a button.\n');
connexion.b = Bottle;
connexion.c = Bottle;
%connexion.ispeak = Bottle;
connexion.skin = Bottle;
%connexion.wrenches = Bottle;
 connexion.state = Bottle;
 connexion.grasp = Bottle;
 connexion.graspAns =Bottle;

end
