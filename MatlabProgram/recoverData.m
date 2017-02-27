%RECOVERDATA recovers trajectories when they are separated in
%files. 
%For each kind of trajectory "i" there is a folder "traji" in the folder
%"MatlabProgram/Data" and for each trajectory j of this type, there is a file
%in "MatlabProgram/Data/traji/recordj.txt".
%these trajectories are saved in the variable y{i}{j} and its number of
%iteration in totalTime(i,j) and the real time is saved in realTime{i,j}
%moreover, to test the inference, the last trajectory is not included in
%these variable, but are saved in y_trial (only first iterations),
%y_trial_Tot (the whole tested trajectory), totalTimeTrial and realTimeTrial

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Recover the data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
for i=1:nbKindOfTraj
    cont=1;
    nameT=['Data/traj', num2str(i)];
    j=1;
    if ~exist([nameT,'/record',num2str(j-1),'.txt'])
        cont=0;
    end
    while cont==1
        data_tot{i}{j} = load([nameT,'/record',num2str(j-1),'.txt']);

        data{i}{j} = zeros( size(data_tot{i}{j},1),9); % tall: nbIteration:9 (9 for position, forces and moment) 
        data{i}{j}(:,1:9) = [data_tot{i}{j}(:,11:13),data_tot{i}{j}(:,5:10)]; %11:13: real position of the robot; 5:10 forces and wrench
        j=j+1;
        if ~exist([nameT,'/record',num2str(j-1),'.txt'])
            cont=0;
        end
    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create the y vector  and other useful variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nbDofTot = size(data{1}{1},2);
i
% We keep the last sample to try to recognize the movement
for k=1:nbKindOfTraj
    var(k) = size(data{k},2) - 1;
    % totalTime will be the number of iteration for each trajectories
    % y is the input vector of data
    %ymean{k} = zeros(z*(nbDofTot),1);
    for i=1:var(k)
        y{k}{i} = [];
        val = [];
        %to avoid problem after
       	totalTime(k,i) =size(data{k}{i},1) ;
        realTime{k}{i} = data_tot{k}{i}(:,1);
        for j = 1:nbDofTot
           y{k}{i}=  [ y{k}{i} ; data{k}{i}(1:totalTime(k,i),j) ];
           
           val =  [val ; data{k}{i}(1:floor(size(data{k}{i},1)/z):totalTime(k,i),j)];
        end
    end 
end


% %we keep the last sample of each trajectory to see if we recognize
% %correctly the last movement
for k=1:nbKindOfTraj
	i = size(data{k},2);
	totalTimeTrial(k) = size(data{k}{i},1);
	y_trial_Tot{k} = [];
    y_trial{k} = [];
    realTimeTrial{k} = data_tot{k}{i}(:,1);
	for j=1:nbDofTot
	    y_trial_Tot{k} =  [ y_trial_Tot{k} ; data{k}{i}(1: totalTimeTrial(k),j)  ] ;
		y_trial{k} = [ y_trial{k} ; data{k}{i}(1:nbData,j)];
    end
end


clear nam* affich data i j k;