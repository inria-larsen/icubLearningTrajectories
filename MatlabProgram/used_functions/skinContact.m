ok=0;
connection.skin.clear();
connection.port3.read(connection.skin); 

dataR = connection.skin.toString()
if(dataR.length >0)
    dataTMP = dataR.split('\)');
    data2 = dataTMP(1).split(' ');
    if(str2num(char(data2(2))) == 3)
        valuePression= dataTMP(length(dataTMP))
        valuePression = str2num(valuePression);
        if(valuePression > 20.0)
            display('The contact is perceived');
            ok =1;
        else
            display('arm contact to weak');
        end
    else
        display('no contact on the arm');
    end
else
    display('No contact');
end