function continueMovementiCubGui(inf,connection,nbData,z, PHI_norm, varargin)
%continueMovement plays the trajectory recognized into gazebo.

data = PHI_norm*inf.mu_w;
data_max = PHI_norm*(inf.mu_w + 1.96*sqrt(diag(inf.sigma_w)));
data_min = PHI_norm*(inf.mu_w - 1.96*sqrt(diag(inf.sigma_w)));
compliance = 0.0;

if(~isempty(varargin))
    list= varargin{1}
else
    list= {'unamed','unamed','unamed','unamed','unamed','unamed', 'unamed','unamed','unamed'}
end

for t = round(inf.alpha*nbData): z
    connection.b.clear();
    
    connection.b.addString('object');
    connection.b.addString('ball');
    
    %dimensions
    connection.b.addDouble(0.5);
    connection.b.addDouble(0.5);
    connection.b.addDouble(0.5);
    %position
    for i = 1 : 3 %cartesian position information
        val(t,i) = data(z*(i-1)+t);
        connection.b.addDouble(val(t,i));
    end
    %orientation
    connection.b.addDouble(0);
    connection.b.addDouble(0);
    connection.b.addDouble(0);
    %color
    connection.b.addInt(255);
    connection.b.addInt(0);
    connection.b.addInt(0);
    %alpha
    connection.b.addDouble(0.7);
  
    connection.portIG.write(connection.b);
   
end

end