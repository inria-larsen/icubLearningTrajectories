# icub-learning-arm-trajectories

If you have some questions or remarks, please send an email to oriane.dermy@inria.fr. 

This program is a subpart of the project "icub-learning-trajectories" composed of different programs:

- recordTrajectories.cpp: to record into files (recordX.txt, were 'X' is your new trajectory) the iCub's arm movements as following:
"TimeStep X_geom Y_geom Z_geom Fx Fy Fz mx my mz x_robot y_robot z_robot" where X/Y/Z_geom are the Geomgic position; Fx/y/z mx/y/z the forces and moments given by "wholeBodyDynamicsTree"; x/y/z_robot the Cartesian position of the iCub simulated robot.

- demo_plotProMP(s).m: these Matlab scripts plot the different results (observed trajectories, learned distribution, infered trajectory from few samples) that we obtain thanks to the geomagic for one or many ProMPs;

- demo_plotProMPsIcub : plots the different results (observed trajectories, learned distribution, infered trajectory from few samples) that we obtain recorded on the registred from iCub;

- demo_replayProMPs.m + replayTrajectories.cpp: used to replay, learn, and predict movements on the simulated robot. Predictions are done from offline initated movement.

- demo_replayProMPsWithGeom.m: + replayTrajectoriesWithGeom.cpp: used to replay, learn, and predict movements on the simulated robot. Predictions are done from movements initiated by the Geomagic haptic device.

Videos (tutorial and samples) are available in the "Videos" folder.

In this README, "$YourPath" refers to the path where this software has been cloned.

## PRE-INSTALLATION and requirement:

This toolbox is tested on Ubuntu 16 with the iCubSim.  

You need to have installed:  
icub-main  
yarp  
gazebo  
WholeBodyDynamicsTree  
The Geomagic Touch software (see here: https://github.com/inria-larsen/icub-manual/wiki/Installation-with-the-Geomagic-Touch)

A tutorial that explains how to install these modules is available at: https://github.com/inria-larsen/icub-manual/wiki/How-to-install-the-software-on-your-machine-(Ubuntu-14)
Note that wholeBodyDynamicsTree is currently included in the codyco-superbuild project.


## INSTALLATION:
`git clone https://github.com/inria-larsen/icubLearningTrajectories` 
`cd iCubLearningTrajectories`   
`mkdir build`   
`cd build`   
`ccmake ../`   
`make install`   

Then, you can add some aliases to simplify the utilisation of our Gazebo world (that contains icubSim and some balls that represents the targets to reach). For example add these aliases:
alias gazebo_2goal="cd $SHARE_GAZEBO_MODELS/models/icub_with_two_vertical_targets && gazebo -slibgazebo_yarp_clock.so world2height.sdf"
alias gazebo_3goal="cd $SHARE_GAZEBO_MODELS/models/icub_with_three_vertical_targets && gazebo -slibgazebo_yarp_clock.so world3height.sdf"
alias gazebo_promps="cd $SHARE_GAZEBO_MODELS/models/icub_with_three_targets && gazebo -slibgazebo_yarp_clock.so worldPROMPS.sdf"
where $SHARE_GAZEBO_MODELS is the PATH where you have your Gazebo models installed (in our case is /home/icub/software/share/gazebo).


# Launching the Geomagic application

Its utilization requires to have installed the geomagic touch driver and to have done the pre-installation of the Geomagic Touch software. Then, you can launch:
1. yarpserver
2. yarprun --server /icub01

You have to run the previous command from a terminal where the geomagic's environement variable are defined, and  where you have done the geomagic calibration, as explained [here](https://github.com/inria-larsen/icub-manual/wiki/Installation-with-the-Geomagic-Touch), in part  "Usage - yarp drivers".

# Launching the program recordTrajectories.cpp

By using this program, you can learn trajectories that you guide from the Geomagic Touch haptic device. The device movements are connected to the left arm of the simulated iCub. You can use gazebo_3goal to have some goal to achieve.
At the beginning of this cpp function, you can read further information.

1. Follow the section "launching the Geomagic application"
2. gazebo_3goal
3. yarpmanager
From yarpmanager, open the xml file (in folder $YourPath/App) and launch:
wholeBodyDynamicsTree, yarprobotinterface, iKinCartesianSolver, and recordTrajectoriesWithGeomagic

4. Connect from this same xml file the port:
yarp connect /wholeBodyDynamicsTree/left_arm/cartesianEndEffectorWrench:o /record/read

Now, press and hold the black button of the geomagic to record a movement. You can record many movements. For each recorded movements, a file called recordX.txt is created, where X is the movement number.

# Pre-traitment before using the Matlab scripts used to learn and infer trajectories.
You can use the Matlab scripts for your own trajectories, that can represent any kind of data.

1. Move the previous "recordX.txt" files into a folder, for example "$YOURPATH/Matlab/Data/yourTraj".

In all the demo scripts, you then can adapt the following variable to your trajectories' specificities:
```
%%%%%%%%%%%%%%%VARIABLES, please refer you to the readme
%can be either ".mat" or ".txt".
DataPath= 'Data/yourTraj' %could be something like 'Data/traj1_1DOF.mat';
typeRecover= '.txt' % or '.mat', it depends on your choice of data file.
inputName = {'x[m]','y[m]','z[m]','f_x[N]','f_y[N]','f_z[N]', 'm_x[Nm]','m_y[Nm]','m_z[Nm]'}; %label of your inputs
s_ref=100; %reference number of samples
nbInput(1) = 3; %number of inputs used to compute the posterior distribution of ProMPs (e.g. Cartesian position)
%nbInput(2) = 6; %number of other inputs that you don't want to use to compute the posterior distribution of ProMPs (e.g. wrenches)
M(1) = 5; %number of basis functions to represent nbInput(1)
%M(2) = 10; %number of basis functions to represent nbInput(2)
percentData = 30; %percent of observed data during the inference
%This variable is the expected data noise, you can tune this parameter to achieve the trajectory correctly
expNoise = 0.00001;
% type of criterion used to infer the time modulation
% ('MO':model/'ML'maximum likelihood/ 'ME' average/'DI' distance).
%%%%%%%%%%%%%% END VARIABLE CHOICE
```

# Launching the demo_plotProMP(s(Icub)) program
You just have to launch this program from Matlab to see examples of ProMPs.

# Launching the demo_replayProMPs program

For this program, you have to call yarp from Matlab (see [this link](http://wiki.icub.org/wiki/Calling_yarp_from_Matlab))
1. Follow the section "launching the Geomagic application"
2. Run demo_replayProMPs.m on Matlab.
This programm will then be waiting for port connexion with the message "Please connect to a bottle sink (e.g. yarp read) and press a button."
3. Run gazebo_3goal
3. Run yarpmanager. Open the xml file (in folder /App) and launch one by one the modules:
- wholeBodyDynamicsTree
- iKinCartesianSolver 
- simCartesianControl 
- replayTrajectories
- (Note: if you want the robot to say the name of the recognize ProMP, you can launch the yarpdev module)
4. Connect the ports from yarpmanager.
5. Go back to the Matlab program, press enter and follow the instruction.

# Launching the demo_replayProMPsWithGeom program

This program is similar than the previous, where the inference is done online, guided by the user thanks to the geomagic Touch haptic device. 
You can launch it by following the same steps, where you launch the Matlab script demo_replayProMPsreplayTrajectoriesWithGeom instead of demo_replayTrajectories and launch the application replayTrajectoriesWithGeom instead of replayTrajectories.

First, the programm will allow you to replay trajectories.Then, the message "You can begin a movement. Maintain the dark geomagic button pressed and realase it when you want it finish it." will appear. At that moment, you can use the haptic device to initiate a movement from which the robot has to do the inference. During this early-movement, press and hold the black button of the Geomagic (see [this photo](https://drive.google.com/file/d/0B9sXstBzNOiudG45czhvV2VkVWc/view?usp=sharing) )
