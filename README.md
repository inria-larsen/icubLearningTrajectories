# icub-learning-arm-trajectories

If you have some questions or remarks, please send an email to oriane.dermy@inria.fr.

This program is a subpart of the project "icub-learning-trajectories" composed of different programs:
1. recordTrajectories.cpp: to record into some files (recordX.txt, were 'X' is your new trajectory) the icub's arm movement as following:
"X_geom Y_geom Z_geom Fx Fy Fz mx my mz x_robot y_robot z_robot" where the trio values are: the position given by the geomagic, the forces and moment received by "wholeBodyDynamicsTree", and the cartesian position of the icub simulated robot.
2. Two matlab program to learn the distirubtion other these trajectories and to infer the end of an initiated movement:
2. demo_plotProMPs.m: It plots the different results (observed trajectories, learned distribution, infered trajectory from few samples);
3. demo_replay.m combined with replayTrajectories.cpp: It replays learned and predicted movements on the simulated robot.

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
`make`   

# Launch the program recordTrajectories.cpp

To launch this program that learn trajectories from the geomagic touch. You can use the world "worldPROMPS.sdf" to have some goal to achieve with the robot left arm. Open the code of this function to have more information about how to launch it.

1. It requires to have installed the geomagic touch driver and  to have done all its setup (see pre-installation). Then, you have to launch:
2. 0st terminal:
yarpserver
3. 1st terminal:
yarprobotinterface --context geomagic --config geomagic.xml
4. 2nd terminal:
gazebo -slibgazebo_yarp_clock.so worldPROMPS.sdf
5. 3d terminal: 
wholeBodyDynamicsTree --autoconnect --robot icubGazeboSim
6. 4th terminal:
iKinCartesianSolver --robot icubGazeboSim --part left_arm (from the path where the .ini linked to gazebo are, if they are not well configured)
7. 5th terminal:
simCartesianControl --robot icubGazeboSim (from the path where the .ini linked to gazebo are) 
8. 6th terminal: in CppProgram/build/bin:
./record
9. 7th terminal: create the connection:
yarp connect /wholeBodyDynamicsTree/left_arm/cartesianEndEffectorWrench:o /record/read

Now you can use the launched program:
When you press the black button of the geomagic, it will creates a file record0.txt. You can learn many trajectories (that will create other files as record1.txt, record2.txt and so on).

Remark: If you have trouble with the ini files (not found), you can go into the folder CppProgram/configFiles and then launch the 3rd and 4th terminal from it. 

# Pre-traitment fo the matlab programs to learn and infer trajectories.

1. Move the previous "recordX.txt" files into a folder, for example "traj1". 
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

2. Launch a yarpserver.
3. Launch demo_replayProMPs.m on Matlab.
This programm will wait with the message "Please connect to a bottle sink (e.g. yarp read) and press a button."
4.  launch yarpserver
5. launch gazebo -slibgazebo_yarp_clock.so worldPROMPS.sdf 
6. launch wholeBodyDynamicsTree --autoconnect --robot icubGazeboSim (to have information about forces)
7. launch iKinCartesianSolver --robot icubGazeboSim --part left_arm
8. launch simCartesianControl --robot icubGazeboSim
9. launch demo_replayProMPs.m on matlab 
10. launch the replay program (in CppProgram/build/bin)
11. connect the port by typing in a terminal:
 * yarp connect /matlab/write /replay/read
 * yarp connect /replay/read /matlab/write
 * yarp connect /wholeBodyDynamicsTree/left_arm/cartesianEndEffectorWrench:o /replay/readForces



