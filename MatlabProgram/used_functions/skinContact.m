ok=0;
connexion.skin.clear();
connexion.port3.read(connexion.skin); 

dataR = connexion.skin.toString();
if(dataR.length >0)
    dataTMP = dataR.split('\)');
    data2 = dataTMP(1).split(' ');
    if(str2num(char(data2(2))) == 3)
        valuePression= str2num(dataTMP(length(dataTMP)));
        
        if(valuePression > 15.0)
            ok =1;
        end
    end
%else
    %display('No contact');
end