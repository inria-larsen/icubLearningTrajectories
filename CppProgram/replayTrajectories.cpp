
/* Author: Oriane Dermy
 * email: oriane.dermy@inria.fr
 *
 * This program is used to replay trajectories send by the matlab program proMPs.m from the port /matlab/write.
 * To finish this project, this program could be ameliorated by changing the compliance of the robot's arm according to matlab information stocked in the variable "compliance".
 * 
 * To launch this program
 * 1. launch yarpserver
 * 2. launch gazebo 
 * 3. launch wholeBodyDynamicsTree --autoconnect --robot icubGazeboSim (to have information about forces)
 * 4. launch iKinCartesianSolver --robot icubGazeboSim --part left_arm
 * 5. launch simCartesianControl --robot icubGazeboSim
 * 6. launch demo_replayProMPs.m on matlab 
 * 7. launch this program.
 * 8. connect the port by typing in a terminal:
 * yarp connect /matlab/write /replay/read
 * yarp connect /replay/read /matlab/write
 * yarp connect /wholeBodyDynamicsTree/left_arm/cartesianEndEffectorWrench:o /replay/readForces
 */

#include <cmath>
#include <string>
#include <algorithm>
#include <map>
#include <iostream>
#include <fstream>

#include <yarp/os/all.h>
#include <yarp/dev/all.h>
#include <yarp/sig/all.h>
#include <yarp/math/Math.h>

#include "cartesianClient.h"

#define DEG2RAD     (M_PI/180.0)
#define RAD2DEG     (180.0/M_PI)
#define MAX_TORSO_PITCH     0.0    // [deg]

using namespace std;
using namespace yarp::os;
using namespace yarp::sig;


class TestReplay: public RFModule
{
protected:
    // cartesian
    CartesianClient client;
    Vector xd;
    Vector od;
    Vector fext;
    string part;
    string robot;
    
    //my data   
    BufferedPort<Bottle> port, portForces; // port to read matlab information and forces.
    double compliance;//in the futur the compliance of the robot will be adjusted thanks to this variable
    double trajTime; //depends if the robot is simulated or not: change the velocity of the movement.
    bool flagReturn; //flag that indicates the robot has to go back in the initial position.
    int verbositylevel;
    
    //initialize cartesian controller
    bool initCartesian(const string &part, bool swap_x=false,bool swap_y=false)
    {           
		cout << "in initCartesian " << endl;             
        client.init(robot,part,swap_x,swap_y); 
        cout << "after client.init " << endl;             
        
        client.setPosePriority("position");
        return true;
    }
    
    void closeCartesian()
    {    
      client.close();      
    }

public:
 
    TestReplay(int verbose = 2): RFModule()
    {
	    verbositylevel = verbose; 
    }
    
    bool configure(ResourceFinder &rf)
    {    
		string name=rf.check("name",Value("test_feedback")).asString().c_str();
        robot=rf.check("robot",Value("icubSim")).asString().c_str();
		if(robot =="icubSim") trajTime = 0.1;
		else trajTime = 0.5;
		string part=rf.check("part",Value("left_arm")).asString().c_str();	
        bool swap_x=rf.check("swap_x",Value("false")).asBool();
        bool swap_y=rf.check("swap_y",Value("false")).asBool();    
		
		//initialize variable used in this program
		xd.resize(3); // desired position of the robot (matlab order)
        od.resize(4); // desired orientation of the rbbot 
        //od[0]=-0.039151; od[1]=0.601265; od[2]=-0.79809; od[3]=2.851949; //see serena-ivaldi/WoZ/app/basicfiles/action.conf for more information about this values
        fext.resize(6); // external forces received by WBDT
		flagReturn=true; // flag to order the robot to come back in the initial position.
		compliance = 1; // compliance's value ordered by the matlab program.
		
		//initialize ports
		port.open("/replay/read");  //communication with the matlab program.
	    portForces.open("/replay/readForces");   // to read forces from the wholebodyDynamics program.
		
		
        if (!initCartesian(part,1,1))
          return false;
          
        client.getRobotPose(xd,od); // get current pose as x,o

        return true;
       
    }
    
    bool close()
    {
		if(verbositylevel == 1) cout << "Close the module." << endl;
		closeCartesian();
		if(verbositylevel == 1) cout << "Close the yarp port and connection." << endl;
		port.close();
		portForces.close();
		int sys = system("Yarp clean");
		return true;
    }

    double getPeriod()
    {	
        return 0.01;
    }

    bool updateModule()
    { 
       Vector buttons,rpy;
       Vector x,o;    

		if(verbositylevel == 2) cout << "Before reading matlab information" << endl;
        Bottle *input = port.read();
        if(verbositylevel == 2) cout << "Before reading forces from WBDT." << endl;
		Bottle *inputForces = portForces.read(false);

        if (input!=NULL)  // Treatment only if it receives matlab order
        {
            if(verbositylevel == 2) cout << "Got: " << input->toString().c_str() << endl;
            
            // if we receive only one input, it requires specific treatment:
            if(input->size() == 1)
            {
				 if(input->get(0).asDouble() == -1.0) // if we receive -1 we close the program
				 {
					 if(verbositylevel == 1) cout << "Receive command to close the programm." << endl;
					 return false;
				 }
				 else if(input->get(0).asDouble() == 0.0) // if we receive 0 we go back to initial position
				 {
					 if(verbositylevel == 1) cout << "Receive ask to return in initial position." << endl;
					 flagReturn = true;
					 Bottle& output = port.prepare();
					 output.clear();
					 output.addDouble(0); // return ack.
					 port.write();
					 return true;
				 }
            }
			
			//if we receive many input, the robot has to follow a trajectory
            for (int i=0; i<3; i++) 
            {
                xd[i] = input->get(i).asDouble(); // position ordered by matlab
            
            }
            compliance = input->get(3).asDouble(); // compliance ordered by matlab 
            
			// read forces given by the wholeBodyDynamicsTree programm            
            for (int i=0; i<6; i++)
            {
				if (inputForces!=NULL)  //WBDT forces informatipn
				{
					fext[i] = inputForces->get(i).asDouble();
					//cout << "Read forces/wrench." << endl;

				}
				else // if it didn't receive forces information return -1 (for example not connected)
				{	
					fext[i] = -1;
					cout << "Read no forces/wrench." << endl;
                }
			}

            
            double dist;
            int nbIt=0;
            
            //Follow matlab's previous order
            do
            {
				//if(flagReturn==true) //When the robot receive an order to go back in the initial position
				//{
					//client.setTrajectoryTime(3.0);
					//if(verbositylevel == 1) cout << "Rythme slow to begin the movement" << endl;
					//if("icubSim" != robot) client.goToPoseSyncRobot(xd,od);   // send request and wait for reply
					//client.goToPoseRobot(xd,od);
					//if("icubSim" != robot) client.waitMotionDone(0.04);  // wait until the motion is done and ping at each 0.04 seconds
					//flagReturn = false;
				//}else //When the robot has to move
				//{
					client.setTrajectoryTime(trajTime);
					if("icubSim" != robot) client.goToPoseSyncRobot(xd,od);   // send request and wait for reply
					client.goToPoseRobot(xd,od); // new target is xd,od
					if("icubSim" != robot) client.waitMotionDone(0.04);
				//}
				
				client.getRobotPose(x,o); // get current pose as x,o
				dist = (x[0] -xd[0])*(x[0]-xd[0]) + (x[1] -xd[1])*(x[1]-xd[1]) + (x[2] -xd[2])*(x[2]-xd[2]);
				nbIt++;
			}while(dist > 0.001 && nbIt< 100);
			
			if(verbositylevel ==1)
			{
			yInfo("Current position = (%s)",x.toString(3,3).c_str());
			yInfo("Target position = (%s)",xd.toString(3,3).c_str());
			yInfo("Compliance      = (%f)\n",compliance);
		}
			//Give to matlab forces information
            Bottle& output = port.prepare();
            output.clear();
            output.addDouble(fext[0]);
            output.addDouble(fext[1]);
            output.addDouble(fext[2]);
            output.addDouble(fext[3]);
            output.addDouble(fext[4]);
            output.addDouble(fext[5]);
            if(verbositylevel == 2) cout << "It is writing: " << output.toString().c_str() << endl;
            port.write();
        }    
        return true;
    }    
};

int main(int argc,char *argv[])
{           
   Network yarp;

    if (!yarp.checkNetwork())
    {
        yError("YARP server not found!");
        return 1;
    }

    ResourceFinder rf;
    rf.configure(argc,argv);

    TestReplay test;    
        
    return test.runModule(rf);
}
