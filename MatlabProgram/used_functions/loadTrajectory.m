 function [trajectory] = loadTrajectory(PATH, nameT,varargin)
%LOADTRAJECTORY recovers trajectories of the folder PATH.
%
%INPUTS:
% PATH: path for the trajectory where the "recordX.txt" files are 
% nameT: label of the type of trajectory
% varargin: parameters that you can add
% ['refNum', x]: precise the reference number of iteration 'x'.
% ['nbInput', x]: precise the number of inputs: 
%                 if x=[a,b] then only the first 'a' inputs will be used to
%                 recognize the trajectory during inference
% ['Specific', x]: precise information about the data structure.
% If x='FromGeom': retrieve the data structure of the C++ program that
% records geomagic data.
% If x='Time': the first data column corresponds to the time
%OUTPUT:
% trajectory: give an object trajectory 
% FILE STRUCTURE
%The file .txt has to be structured as following:
%#TIME #geomagicPositionX #geomagicPositionY #geomagicPositionZ #fx #fy #fz #wx #wy #wz #icubX #icubY #icubZ.
%This function records an object "trajectory" where the input variable are (iCubX; iCubY; iCubZ; fx; fy; fz; wx; wy; wz).


    specific=0;
    columnTime=0;
    referenceNumber= -1;
    nbInput=-1;
    %Treat varargin possibilities
    for j=1:2:length(varargin)
        if(strcmp(varargin{j},'refNb')==1)
                referenceNumber = varargin{j+1};
                %display(['Specification: reference number=', num2str(referenceNumber)]);
        elseif(strcmp(varargin{j},'nbInput')==1)
            nbInput= varargin{j+1};
        elseif(strcmp(varargin{j},'Specific')==1)
            if(strcmp(varargin{j+1},'Time')==1)
                columnTime=1;
            elseif(strcmp(varargin{j+1}, 'FromGeom')==1) %from the geomagic program that records: "Time Xgeom Ygeom Zgeom Fx Fy Fz Mx My Mz Xicub Yicub zicub"
               % display('specification: data from geomagic');
                specific=1;
            end
        end
    end
    
    
    %Retrieve all data in data{j} cells for each trajectory, and put
    %"trajectory.realTime{j} cells value, if it readed.
    cont=1; %verify if exists other trajectories
    j=1;
    listtmp = dir(PATH);
    listtmp2 = find(vertcat(listtmp.isdir));
    list = listtmp(listtmp2);
    if(length(list)>3) %treats record files that are in subfolder of PATH
        for parc=3:length(list)
            cont=1;
            k=1;
            PATH2 = [PATH, '/', list(parc).name];
            if (~exist([PATH2,'/record',num2str(k-1),'.txt']))
                display('error no files with this name');
                display([PATH,'/record',num2str(j-1),'.txt']);
                cont=0;
            end
            while cont==1
                data_tot{j} = load([PATH2,'/record',num2str(k-1),'.txt']);
				if(specific==1)%if it correspond to "Time Xgeom Ygeom Zgeom Fx Fy Fz Mx My Mz Xicub Yicub zicub"
		            data{j} = zeros( size(data_tot{j},1),9); % tall: nbIteration:9 (9 for position, forces and moment) 
		            data{j}(:,1:9) = [data_tot{j}(:,11:13),data_tot{j}(:,5:10)]; %11:13: real position of the robot; 5:10 forces and wrench
		            trajectory.realTime{j} = data_tot{j}(:,1); %Time information
		        elseif(columnTime==1) %if the first column corresponds to time information
		                data{j} = [data_tot{j}(:,2:size(data_tot{j},2))]; %all
		                trajectory.realTime{j} = data_tot{j}(:,1);
		        else
		                data{j} = data_tot{j};
                end

                j=j+1;
                k = k+1;
                if ~exist([PATH2,'/record',num2str(k-1),'.txt'])
                    cont=0;
                end
            end
        end
    else %treats record files directly in the PATH folder
	    if ~exist([PATH,'/record',num2str(j-1),'.txt'])
	        display('error no files with this name');
	        display([PATH,'/record',num2str(j-1),'.txt']);
	        cont=0;
	    end
	    while cont==1
	        data_tot{j} = load([PATH,'/record',num2str(j-1),'.txt']);
	        if(specific==1)%if it correspond to "Time Xgeom Ygeom Zgeom Fx Fy Fz Mx My Mz Xicub Yicub zicub"
	            data{j} = zeros(size(data_tot{j},1),9); % tall: nbIteration:9 (9 for position, forces and moment) 
	            data{j}(:,1:9) = [data_tot{j}(:,11:13),data_tot{j}(:,5:10)]; %11:13: real position of the robot; 5:10 forces and wrench
	            trajectory.realTime{j} = data_tot{j}(:,1); %Time information
	        elseif(columnTime==1) %if the first column corresponds to time information
	                data{j} = [data_tot{j}(:,2:size(data_tot{j},2))]; %all
	                trajectory.realTime{j} = data_tot{j}(:,1);
	        else
	                data{j} = data_tot{j};
	        end
	        j=j+1;
	        if ~exist([PATH,'/record',num2str(j-1),'.txt'])
	            cont=0;
	        end
	    end
    end
    
    
    
    %%%Fill trajectories information using the retrieved data{j} values
    trajectory.nbTraj = size(data,2); %total number of trajectory
    if(nbInput ==-1) %if the number of input parameters is not given in input, it computes it
        trajectory.nbInput = size(data{1},2);
    else
        trajectory.nbInput = nbInput;
    end
    for i=1:trajectory.nbTraj %for each trajectory, fill other variables
        trajectory.y{i} = [];
        %val = [];
        %to avoid problem after
       	trajectory.totTime(i) =size(data{i},1) ; %total number of samples
        trajectory.interval(i) = (trajectory.realTime{i}(trajectory.totTime(i)) - trajectory.realTime{i}(1)) /trajectory.totTime(i); %time inteval between sample
        trajectory.yMat{i} =  data{i}(1:trajectory.totTime(i),:); %matrice that contains trajectory input (x= number of sample, y= number of input)
        for j = 1: sum(trajectory.nbInput)
           trajectory.y{i}=  [ trajectory.y{i} ; data{i}(1:trajectory.totTime(i),j) ]; %vector that contains trajectory inputs
           %val =  [val ; data{i}(1:floor(size(data{i},1)/z):totalTime(i),j)];
        end
    end 
    
    trajectory.label = nameT; %label of the trajectory.
    
    if(referenceNumber ~= -1)%compute the modulation time of the trajectory
        for i=1:trajectory.nbTraj
            trajectory.alpha(i) = referenceNumber / trajectory.totTime(i);
        end 
    end
   

end
