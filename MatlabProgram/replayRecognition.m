%In this function we will play the trajectory recognized into gazebo.

data = PSI_z*mu_new;
data_max = PSI_z*(mu_new + 1.96*sqrt(diag(sigma_new)));
data_min = PSI_z*(mu_new - 1.96*sqrt(diag(sigma_new)));
compliance = 0.0;

for t = round(mu_alpha(reco{1})*nbData): z
    b.clear();
    for i = 1 : nbDof(1) %+ nbDof(2)
        val(t,i) = data(z*(i-1)+t);
        b.addDouble(val(t,i));
    end
    %compliance inforamtion calculate in the previous boucle
    b.addDouble(compliance);
    
    port.write(b);
    %disp('Have send the message.');
    port.read(c);
    disp(c);
    num = str2num(c);
    disp(['Receiving: forces = ', num2str(num(1,1)), ' ',num2str(num(1,2)),' ', num2str(num(1,3))]);
    disp(['Expected:  forces = ', num2str(data(z*(4-1)+t)),' ', num2str(data(z*(5-1)+t)),' ', num2str(data(z*(6 -1)+t))]);
    
    disp(['Receiving: wrench = ', num2str(num(1,4)), ' ',num2str(num(1,5)), ' ',num2str(num(1,6))]);
    disp(['Expected:  wrench = ', num2str(data(z*(7-1)+t)),' ', num2str(data(z*(8-1)+t)), ' ',num2str(data(z*(9 -1)+t))]);
    
    
    compliance = 0.0;
    
    for i= 1 : 3
        
        f(t,i) = data(z*(i-1 + nbDof(1))+t);
        fmax(t,i) = data_max((z*(i-1 + nbDof(1))+t));
        fmin(t,i) = data_min((z*(i-1 + nbDof(1))+t));
        valActu = num(1, i);
        if(( valActu > fmin(t,i)) && (valActu <= f(t,i)))
      %      disp(['Val actu = ', num2str(valActu), ' is sup to min = ', num2str(fmin(t,i)), ' and inf than mean : ', num2str(f(t,i))]);
            compliance = compliance + 1 -  (abs(f(t,i) - valActu )/ abs(fmin(t,i) - f(t,i)));
        elseif(( valActu < fmax(t,i)) && (valActu > f(t,i)))
     %       disp(['Val actu = ', num2str(valActu), ' is inf to max = ', num2str(fmax(t,i)), ' and sup than mean : ', num2str(f(t,i))]);
            compliance = compliance +  1 - (abs(f(t,i) - valActu )/ abs(fmax(t,i) - f(t,i)));
        else
            disp(['Forces are not like learned : ',num2str(valActu), ' Should be between ', num2str(fmin(t,i)), ' and ', num2str(fmax(t,i))]);
        end
    end
    % disp(['compliance = ', num2str(compliance)]);
    compliance = compliance / nbDof(2);
    disp(['compliance = ', num2str(compliance)]);
end

%Send information about the end of the trajectory and verify it
%receives it.
b.clear();
b.addDouble(0.0)
port.write(b);
display('writing 0.0');
port.read(c);
disp(c);

% msg = input('Send q to quit\n', 's');
% if(msg == 'q')
%     disp('End of the programm.');
% else
%     inferenceFromZero;
% end
