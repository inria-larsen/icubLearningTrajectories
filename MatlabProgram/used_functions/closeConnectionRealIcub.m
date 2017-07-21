function closeConnectionRealIcub(connection)
%closeConnection closes the C++ program "replay" and close its port.
connection.b.clear();
connection.b.addDouble(-1);    
connection.port.write(connection.b);
connection.port.close;
connection.port2.close;
connection.port3.close;
connection.port4.close;
connection.port5.close;
connection.portGrasp.close;
end