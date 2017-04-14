 function [trajectory] = loadTrajectory(PATH, nameT,varargin)
%LOADTRAJECTORY recovers trajectories of the folder PATH.
%input:
% PATH: path for the trajectory where the "recordX.txt" files are 
% nameT: label of the type of trajectory
% varargin: you can precise the reference time duration of trajectory (to
% compute the phasis of the trajectory).
%OUTPUT:
% trajectory: give an object trajectory 
% FILE STRUCTURE
%The file .txt has to be structured as following:
%#TIME #geomagicPositionX #geomagicPositionY #geomagicPositionZ #fx #fy #fz #wx #wy #wz #icubX #icubY #icubZ.
%This function records an object "trajectory" where the input variable are (iCubX; iCubY; iCubZ; fx; fy; fz; wx; wy; wz).

    cont=1; %verify if exists other trajectories
    j=1;
    if ~exist([PATH,'/record',num2str(j-1),'.txt'])
        display('error no files with this name');
        display([PATH,'/record',num2str(j-1),'.txt']);
        cont=0;
    end
    while cont==1
        data_tot{j} = load([PATH,'/record',num2str(j-1),'.txt']);

        data{j} = zeros( size(data_tot{j},1),9); % tall: nbIteration:9 (9 for position, forces and moment) 
        data{j}(:,1:9) = [data_tot{j}(:,11:13),data_tot{j}(:,5:10)]; %11:13: real position of the robot; 5:10 forces and wrench
        j=j+1;
        if ~exist([PATH,'/record',num2str(j-1),'.txt'])
            cont=0;
        end
    end
    trajectory.nbTraj = size(data,2);
    trajectory.nbInput = size(data{1},2);
    for i=1:size(data,2)
        trajectory.y{i} = [];
        %val = [];
        %to avoid problem after
       	totalTime(i) =size(data{i},1) ;
        trajectory.realTime{i} = data_tot{i}(:,1);
        trajectory.yMat{i} =  data{i}(1:totalTime(i),:);
        for j = 1: trajectory.nbInput
           trajectory.y{i}=  [ trajectory.y{i} ; data{i}(1:totalTime(i),j) ];
           %val =  [val ; data{i}(1:floor(size(data{i},1)/z):totalTime(i),j)];
        end
    end 
    
    trajectory.totTime = totalTime;
    trajectory.label = nameT;
    for j=1:2:length(varargin)
        if(varargin{j} =='z')
            for i=1:trajectory.nbTraj
                trajectory.alpha(i) = varargin{j+1} / totalTime(i);
            end
        elseif(varargin{j}=='nbInput')
            trajectory.nbInput= varargin{j+1};
        end
    end

end
