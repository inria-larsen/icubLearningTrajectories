function closeConnection(connection)
%finishConnection
%this function closes the C++ program "replay" and close its port.
connection.b.clear();
connection.b.addDouble(-1);    
connection.port.write(connection.b);
connection.port.close;
end