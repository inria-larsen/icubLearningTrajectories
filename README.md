# icub-learning-arm-trajectories

If you have some questions or remarks, please send an email to oriane.dermy@inria.fr.

This program is a subpart of the project "icub-learning-trajectories" composed of different programs:
1. recordTrajectories.cpp: to record into some files (recordX.txt, were 'X' is your new trajectory) the icub's arm movement as following:
"X_geom Y_geom Z_geom Fx Fy Fz mx my mz x_robot y_robot z_robot" where the trio values are: the position given by the geomagic, the forces and moment received by "wholeBodyDynamicsTree", and the cartesian position of the icub simulated robot.
2. proMPs.m: to learn the distirubtion of these trajectories; to infer a trajectory and to replay a learned or recognized trajectory
   replayTrajectories.cpp: has to be used with the proMPs matlab program. It replays movements on the simulated robot.


## PRE-INSTALLATION:
You need to have installed the geomagic touch, see here: https://github.com/inria-larsen/icub-manual/wiki/Installation-with-the-Geomagic-Touch

## INSTALLATION:
`cd CppProgram`   
`mkdir build`   
`cd build`   
`ccmake ../`   
`make`   

# Launch the program recordTrajectories.cpp

To launch this program that learn trajectories from the geomagic touch. You can use the world "worldPROMPS.sdf" to have some goal to achieve with the robot left arm. Open the code of this function to have more information about how to launch it.

1. It requires to have installed the geomagic touch driver and  to have done all its setup (see pre-installation). Then, you have to launch:
2. 1st terminal:
yarprobotinterface --context geomagic --config geomagic.xml
3. 2nd terminal:
gazebo -slibgazebo_yarp_clock.so worldPROMPS.sdf
4. 3d terminal: 
wholeBodyDynamicsTree --autoconnect --robot icubGazeboSim
5. 4th terminal:
iKinCartesianSolver --robot icubGazeboSim --part left_arm (from the path where the .ini linked to gazebo are, if they are not well configured)
6. 5th terminal:simCartesianControl --robot icubGazeboSim (from the path where the .ini linked to gazebo are) 
7. Then, you can launch the program record (in CppProgram/build/bin)

Remark: If you have trouble with the ini files (not found), you can go into the folder CppProgram/configFiles and then launch the 3rd and 4th terminal from it. 

# Launch the matlab program to learn and infer trajectories.

1. Using the previous program, create three files of trajectories (for each file, you can do several samples) and replace the files in MatlabProgram.Data by them.   
2. Launch a yarpserver.   
3. Launch proMPs.m on Matlab. It will compute the distribution of your trajectories. This programm will wait with the message "Please connect to a bottle sink (e.g. yarp read) and press a button."
4. Do the step 1 to 6 of the previous section.
7. Launch the programm replayTrajectories in ./CppProgram/build/bin
8. Go back to the matlab windows and follow the instruction.

