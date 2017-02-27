%play the nbData first position

data = y_trial_Tot{trial};

for t = 1 : nbData
    b.clear();
    for i = 1 : nbDof(1) %+ nbDof(2)
        val(t,i) = data(totalTimeTrial(trial)*(i-1)+t);
        b.addDouble(val(t,i));
    end
    port.write(b);
   disp('Have send the message.');
    port.read(c);
    disp(c);
    num = str2num(c);
    disp(['Receiving: f =', num2str(num(1,1)), ' ', num2str(num(1,2)),' ', num2str(num(1,3)), 'm=', num2str(num(1,4)), ' ',num2str(num(1,5)), ' ',num2str(num(1,6)) ]);
end

rep = input('End of the known data. Please press a button to do the inference.\n');
