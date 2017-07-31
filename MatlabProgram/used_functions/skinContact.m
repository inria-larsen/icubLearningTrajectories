%function ok = skinContact(threshold)

ok=0;
connexion.skin.clear();
connexion.portSkin.read(connexion.skin); 

dataR = connexion.skin.toString();
if(dataR.length >0)
    dataTMP = dataR.split('\)');
    data2 = dataTMP(1).split(' ');
    if(str2num(char(data2(2))) == 3)% && str2num(char(data2(3))) == 4)
        valuePression= str2num(dataTMP(length(dataTMP)));
        if(valuePression > threshold)
            ok =1;
        end
    end
end

%end


%((43187 3 6 1) (0.0 0.0 0.0) (-0.0 -0.0 -0.0) (0.0 0.0 0.0) (0.0 0.0 0.0) (0.0 0.0 0.0) (31) 10.58982) 
%((43188 3 4 2) (0.0 0.0 0.0) (-0.0 -0.0 -0.0) (0.0 0.0 0.0) (0.0 0.0 0.0) (0.0 0.0 0.0) (0 1 2 45 48 49 180 181 188 189 191 204 206 207 208 212 213 215 252 253) 51.526551)
