# icub-learning-arm-trajectories

If you have some questions or remarks, please send an email to oriane.dermy@inria.fr.

This program is a subpart of the project "icub-learning-trajectories" composed of different programs:
1. recordTrajectories.cpp: to record into some files (recordX.txt, were 'X' is your new trajectory) the icub's arm movement as following:
"X_geom Y_geom Z_geom Fx Fy Fz mx my mz x_robot y_robot z_robot" where the trio values are: the position given by the geomagic, the forces and moment received by "wholeBodyDynamicsTree", and the cartesian position of the icub simulated robot.
2. Some matlab scripts to learn the distirubtion other these trajectories and to infer the end of an initiated movement:
- demo_plotProMP(s).m: It plots the different results (observed trajectories, learned distribution, infered trajectory from few samples);
- demo_replayProMPs.m combined with replayTrajectories.cpp: It replays learned and predicted movements on the simulated robot.
- demo_replayProMPsWithGeom.m: combined with replayTrajectoriesWithGeom.cpp: It allows you to move the robot's arm in the simulation, using the haptic device. You can then initate a trajectory and ask the robot to finish this movement when you want.

## PRE-INSTALLATION:
You need to have installed:  
icub-main  
yarp  
gazebo  
WholeBodyDynamicsTree  
The geomagic touch software (see here: https://github.com/inria-larsen/icub-manual/wiki/Installation-with-the-Geomagic-Touch)

## INSTALLATION:
`cd CppProgram`   
`mkdir build`   
`cd build`   
`ccmake ../`   
`make install`   

Then, you can add some aliases to simplify the utilisation of our Gazebo world (that contains iCubGazeboSim and some balls that represents goals to reach). For example add these aliases:
alias gazebo_2goal="cd $YOURPATH/CppProgram/configFiles/myWorld && gazebo -slibgazebo_yarp_clock.so world2height.sdf"
alias gazebo_3goal="cd $YOURPATH/CppProgram/configFiles/myWorld && gazebo -slibgazebo_yarp_clock.so world3height.sdf"
alias gazebo_promps="cd $YOURPATH/CppProgram/configFiles/myWorld && gazebo -slibgazebo_yarp_clock.so worldPROMPS.sdf"

# Launch the program recordTrajectories.cpp

Using this program, you can learn trajectories from the Geomagic touch. You can use gazebo_3goal to have some goal to achieve with the robot left arm. 
Open the code of this function to have more information about how to launch it.
It requires to have installed the geomagic touch driver and  to have done all its setup (see pre-installation). Then, you have to launch:
1. yarpserver
2. yarprun --server /icub01
3. yarprobotinterface --context geomagic --config geomagic.xml 
You have to run it from a terminal where the geomagic's environement variable are defined, and  where you have done the geomagic calibration, as explained here https://github.com/inria-larsen/icub-manual/wiki/Installation-with-the-Geomagic-Touch
4. gazebo_3goal
5. yarpmanager
From yarpmanager, open the xml file (in folder /App) and launch one by one the applications:
wholeBodyDynamicsTree
iKinCartesianSolver 
simCartesianControl 
recordTrajectoriesWithGeomagic
6. Connect from this same xml file the port:
yarp connect /wholeBodyDynamicsTree/left_arm/cartesianEndEffectorWrench:o /record/read

Now, when you press the black button of the geomagic, it will creates a file record0.txt. You can learn many trajectories (that will create other files as record1.txt, record2.txt and so on).

Remark: If you have trouble with the ini files (not found), you can go into the folder CppProgram/configFiles and use these .ini files when you launch yarpmanager.

# Pre-traitment to use the Matlab scripts to learn and infer trajectories.

1. Move the previous "recordX.txt" files into a folder, for example "$YOURPATH/Data/traj1".
In either "demo_plotProMPs.m" and "demo_replayProMPs.m", you then have to change some information:
l39: "loadTrajectory" load your data. In first argument you can give the path of your folder. The second argument correspond to the label you give to your trajectory (its name). The others arguments are not required.

You might also have to change some parameters:
- z: it is the reference time (this reference time just has to be littler than the number of iteration of each trajectory you recorded).
- nbInput: you can remove this variable, but if you want to have some inputs that are not used for the inference part: put in nbInput(1) the number of inputs that have to be used for the inference, and in nbInput(2) the ones that you don't want it use for the inference.
- nbFunctions (its size is equal to "2" if you precise the "input" value as seen before, but "1" else). It correspond of the number of basis function you use to model the trajectory. Put a little number of basis functions (as here 5) and increase them if the trajectory are not well represented by the model. It can happens if your trajectory variates a lot or if this trajectory is really long. 
- expNoise: It corresponds to the expected measurement noise. Here we suppose it is really little to force the new trajectory to pass by the first observed samples of the new trajectory (accuracy = 0.00001).
- nbData: this variable is used for the inference part. It corresonds to the number of observed data from which the robot has to do the inference of the continuation of the movement.

# Launch the demo_plotProMPs program
You just have to launch this program.

# Launch the demo_replayProMPs program

1. yarpserver; the server yarprun --server /icub01 and the geomagic have to be launched as before.
2. Run demo_replayProMPs.m on Matlab.
This programm will wait with the message "Please connect to a bottle sink (e.g. yarp read) and press a button."
3. run yarpmanager. Open the xml file (in folder /App) and launch one by one the applications:
- gazebo
- wholeBodyDynamicsTree
- iKinCartesianSolver 
- simCartesianControl 
- replayTrajectoriesWithGeomagic
4. Connect the ports from yarpmanager.
5. Go back to the Matlab program, press enter and follow the instruction.



