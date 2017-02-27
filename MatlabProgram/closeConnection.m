%CLOSECONNECTION
%this function closes the cpp replay program and close its port.
b.clear();
b.addDouble(-1);    
port.write(b);
port.close;
%portForces.close;
clear all;