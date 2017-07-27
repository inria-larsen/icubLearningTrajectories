function continueMovement(inf,connection,nbData,z, PHI_norm, varargin)
%continueMovement plays the trajectory recognized into gazebo.


data =inf.PHI*inf.mu_w;%PHI_norm*inf.mu_w; %inf.PHI*inf.mu_w; %PHI_norm*inf.mu_w;
for i=1:7
    for j=1:inf.timeInf
        val(j,i) = data(inf.timeInf*(i-1)+j);
    end
end

%data = PHI_norm*inf.mu_w;
data_max = inf.PHI*(inf.mu_w + 1.96*sqrt(diag(inf.sigma_w)));
data_min = inf.PHI*(inf.mu_w - 1.96*sqrt(diag(inf.sigma_w)));
compliance = 0.0;

if(~isempty(varargin))
    list= varargin{1}
else
    list= {'unamed','unamed','unamed','unamed','unamed','unamed', 'unamed','unamed','unamed'}
end

for t = nbData:inf.timeInf
    display('In for');
%for t = round(inf.alpha*nbData): z
    connection.b.clear();
    for i = 1 : 7 %cartesian position information
        connection.b.addDouble(val(t,i));
    end
    
    %compliance inforamtion calculate in the previous boucle
    connection.b.addDouble(compliance);
    
    connection.port.write(connection.b);
    display(['Sending ', num2str(val(t,1)), ' ' , num2str(val(t,2)), ' etc. Waiting answer']);
    connection.port.read(connection.c);
    num = str2num(connection.c);
   %disp(['Receiving: forces = ', num2str(num(1,1)), ' ',num2str(num(1,2)),' ', num2str(num(1,3))]);
   % disp(['Expected:  forces = ', num2str(data(z*(4-1)+t)),' ', num2str(data(z*(5-1)+t)),' ', num2str(data(z*(6 -1)+t))]);
    
%    disp(['Receiving: wrenches = ', num2str(num(1,4)), ' ',num2str(num(1,5)), ' ',num2str(num(1,6))]);
%    disp(['Expected:  wrenches = ', num2str(data(z*(7-1)+t)),' ', num2str(data(z*(8-1)+t)), ' ',num2str(data(z*(9 -1)+t))]);

    compliance = 0.0;
%     
%     for i= 1 : 6 %forces&wrench information
%         f(t,i) = data(z*(i-1 + 3)+t);
%         fmax(t,i) = data_max((z*(i-1 + 3)+t));
%         fmin(t,i) = data_min((z*(i-1 + 3)+t));
%         valActu = num(1, i);
%         if(( valActu > fmin(t,i)) && (valActu <= f(t,i)))
%             compliance = compliance + 1 -  (abs(f(t,i) - valActu )/ abs(fmin(t,i) - f(t,i)));
%         elseif(( valActu < fmax(t,i)) && (valActu > f(t,i)))
%             compliance = compliance +  1 - (abs(f(t,i) - valActu )/ abs(fmax(t,i) - f(t,i)));
%         else
%  %           disp(['Input ', list{i+3}, ' is not expected. We have ',num2str(valActu), ' It should be between ', num2str(fmin(t,i)), ' and ', num2str(fmax(t,i))]);
%         end
%     end
%     compliance = compliance / 6;
 %   disp(['Compliance = ', num2str(compliance)]);
end

%Send information about the end of the trajectory and verify it
%receives it.
connection.b.clear();
connection.b.addDouble(0.0);
connection.port.write(connection.b);
connection.port.read(connection.c);
%disp(connection.c);

% msg = input('Send q to quit\n', 's');
% if(msg == 'q')
%     disp('End of the programm.');
% else
%     inferenceFromZero;
% end

end
