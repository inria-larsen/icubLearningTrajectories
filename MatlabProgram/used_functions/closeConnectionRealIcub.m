function closeConnectionRealIcub(connexion)
%closeconnexion closes the C++ program "replay" and close its port.
connexion.b.clear();
connexion.b.addDouble(-1);    
connexion.port.write(connexion.b);
connexion.port.close;
%connexion.port2.close;
connexion.portSkin.close;
%connexion.port4.close;
connexion.portState.close;
connexion.portGrasp.close;


connexion.b.clear();
connexion.b.addString('reset');
connexion.portIG.write(connexion.b);
connexion.portIG.close;
end