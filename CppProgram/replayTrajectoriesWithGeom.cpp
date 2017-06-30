/* 
 * For information: oriane.dermy@inria.fr (11/07/16)
 * 
 * In this program, we can control the arm robot the simulated robot using the geomagic touch.
 * During all the movement the partner has to maintain the black button, to allow the robot to record data in the file text.txt. 
 * 
 * Be careful, when you replay the trajectory, the geomagic movement is quite brutal, you should keep holding (in a compliant way) the pen of the geomagic to avoid big movement. 
 * 
 * Moreover the orientation of the arm is corrected to be natural.
 * 
 * 
 * For more information, look at the README file of the project.
 * 
 * Another program allows to replay the movement we do, see README for more information. 
 * After that, if we press the white button, the robot will replay the movement. The geomagic touch arm robot will follow this movement.
 *
 * TO LAUNCH THIS PROGRAM:
 * 
 * 1. launch yarpserver
 * 1.b yarprobotinterface --context geomagic --config geomagic.xml
 * 2. launch gazebo -slibgazebo_yarp_clock.so worldPROMPS.sdf 
 * 3. launch wholeBodyDynamicsTree --autoconnect --robot icubGazeboSim (if you want information about forces)
 * 4. launch iKinCartesianSolver --robot icubGazeboSim --part left_arm
 * 5. launch simCartesianControl --robot icubGazeboSim
 * 6. launch demo_replayProMPs.m on matlab 
 * 7. launch this program.
 * 8. connect the port by typing in a terminal:
 * 	yarp connect /wholeBodyDynamicsTree/left_arm/cartesianEndEffectorWrench:o /record/read
 */

#include <cmath>
#include <string>
#include <algorithm>
#include <map>
#include <iostream>
#include <fstream>
#include <boost/lexical_cast.hpp>

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
using namespace yarp::dev;
using namespace yarp::sig;

class RecordWithGeomagic: public yarp::os::RFModule
{
protected:
    // geomagic parameters
    PolyDriver drvGeomagic;
    IHapticDevice *igeo;    
    Vector maxFeedback;
    Vector feedback;
    double minForce;
    double maxForce;
    int verbosity;

    // cartesian parameters
    CartesianClient client;
    Vector xd;
    Vector od;
    string part; // part of the robot we control
    string robot;
    
    // my data
    int totalIt, totalTraj;
    int flagRecord, flagReturn; //flag to record the trajectory (when the dark button of the geomagic is pressed)
    ofstream record;
    BufferedPort<Bottle> port, portForces; //port to read forces
    double currentTime, startTrajectory, compliance;
    string fileName; //name of the file within the trajectory is recorded
    Vector x,o,xRobot,oRobot; // positionand orientation of the simulated robot and the geomagic one   
    Vector fext;
    double trajTime; //depends if the robot is simulated or not: change the velocity of the movement.

    
        
	//initialize the geomagic device (creation of its port...)
    bool initGeomagic(const string &name, const string &geomagic)
    {
        Property optGeo("(device hapticdeviceclient)");
        optGeo.put("remote",("/"+geomagic).c_str());
        optGeo.put("local",("/"+name+"/geomagic").c_str());
        if (!drvGeomagic.open(optGeo)) 
		{
			cout<<"Error during configuration: cannot find the Geomagic. Is it attached ?"<<endl;
			Time::delay(3.0);
			return false;
		}
        cout<<"Geomagic is opened."<<endl;

        drvGeomagic.view(igeo);              

        Matrix T=yarp::math::zeros(4,4);
        T(0,1)=1.0;
        T(1,2)=1.0;
        T(2,0)=1.0;
        T(3,3)=1.0;
        igeo->setTransformation(yarp::math::SE3inv(T));
        igeo->setCartesianForceMode();                
        feedback.resize(3,0.0);
        return true;
    }
    
    //close the geomagic and its feedback.
    void closeGeomagic()
    {
		cout << "Closing geomagic..." << endl;	
		igeo->setTransformation(yarp::math::eye(4,4));
		igeo->stopFeedback();
        drvGeomagic.close();                
        cout << "Geomagic is closed." << endl;	
    }
    
    
    
    bool initCartesian(const string &robot, const string &part, bool swap_x=false,bool swap_y=false)
    {                        
        client.init(robot,part,swap_x,swap_y);
        xd.resize(3);
        od.resize(4);
        return true;
    }
    
    void closeCartesian()
    {    
      client.close();      
    }

public:
 
    
    bool configure(ResourceFinder &rf)
    {    
		string name=rf.check("name",Value("test_feedback")).asString().c_str();
        robot=rf.check("robot",Value("icubSim")).asString().c_str();
		part=rf.check("part",Value("left_arm")).asString().c_str();	
    	
        string geomagic=rf.check("geomagic",Value("geomagic")).asString().c_str();
        minForce=fabs(rf.check("min-force-feedback",Value(0.01)).asDouble());
        maxForce=fabs(rf.check("max-force-feedback",Value(1.5)).asDouble());
        bool swap_x=rf.check("swap_x",Value("false")).asBool();
        bool swap_y=rf.check("swap_y",Value("false")).asBool();
        verbosity=rf.check("verbosity",Value(1)).asInt();
		
		cout << "verbosity: "<< verbosity<< endl;
        port.open("/test/read");  
		portForces.open("/test/readForces");
        flagRecord = 0; // precise if we are recording or not (if the button has been pressed or not).
		flagReturn=true;
        
        totalTraj = 0; //total number of trajectories
		
		if (!initGeomagic(name,geomagic)) return false;
        
        if (!initCartesian(robot,part,1,1)) return false;

        client.getPose(x,o); // get current pose as x,o
        feedback=yarp::math::operator*(x,0.0);	
		verifyFeedback();
		igeo->setFeedback(feedback);


		if(robot =="icubSim") trajTime = 0.1;
		else trajTime = 0.5;
		//initialize variable used in this program
		xd.resize(3); // desired position of the robot (matlab order)
        od.resize(4); // desired orientation of the rbbot 
        od[0]=-0.039151; od[1]=0.601265; od[2]=-0.79809; od[3]=2.851949; //see serena-ivaldi/WoZ/app/basicfiles/action.conf for more information about this values
        fext.resize(6); // external forces received by WBDT
		compliance = 1; // compliance's value ordered by the matlab program.


        return true;
    }
    
    bool close()
    {
		cout << "Closing all modules" << endl;
		closeGeomagic();
		closeCartesian();
		cout << "All modules are closed" << endl;
		return true;
    }

    double getPeriod()
    {	
        return 0.01;
    }


	void verifyFeedback()                     
	{
        for (size_t i=0;i<3;i++)
        {
          if (feedback[i]>maxForce) feedback[i]=maxForce;
          if (feedback[i]<-maxForce) feedback[i]=-maxForce;
          if ((feedback[i]>=0) && (feedback[i]<minForce)) feedback[i]=0.0; // remove small values
          if ((feedback[i]<0) && (feedback[i]>-minForce)) feedback[i]=0.0; // remove small values
        }
	}


	void recordTrajectory()
	{
	    Vector buttons,pos,rpy;
        bool continueR=true;
        while (continueR)
        {
	        //read geomagic informations (buttons/position and orientation)
	        igeo->getButtons(buttons);
	        igeo->getPosition(pos);
	        igeo->getOrientation(rpy);
			
	        // the desired position the simulated robot has to achieve correspond to the position of the geomagic.
	        xd=pos;
	        od[0]=-0.039151; od[1]=0.601265; od[2]=-0.79809; od[3]=2.851949; //see serena-ivaldi/WoZ/app/basicfiles/action.conf for more information about this values
	        
	        
	        client.getPose(x,o); // get current position and orientation of the robot in the frame of the geomagic
	        client.getRobotPose(xRobot,oRobot); // get the real current position of the robot
	
	        //Treatement of a new trajectory we have to record
	        if((buttons[0] != 0.0) && (flagRecord ==0))
	        {
				flagRecord = 1;
				cout << "You can record a trajectory."<< endl;
				//envoyer message matlab debut ou pas	
			}
			
			//Treatment of the end of a trajectory
			else if((buttons[0] == 0.0) && (flagRecord == 1))
			{
				cout << "End of the recorded trajectory." << endl;
				cout << "We've recorded " << totalTraj +1 << " trajectories." << endl;
				//envoyer message fin
				Bottle& output = port.prepare();
				output.clear();
				output.addDouble(-2.0); 
				port.write();

				flagRecord = 0;
				continueR=false;
			}
	
			//Recording a trajectory
			if(flagRecord == 1)
			{

				// read forces given by the wholeBodyDynamicsTree programm
				Bottle *input = portForces.read(false);
				if (input!=NULL) //record information with forces
				{				
					//if(verbosity == 1) cout << "Read forces: " << input->toString().c_str() << endl;
					
					Bottle& output = port.prepare();
					output.clear();
					output.addDouble(x[0]); 
					output.addDouble(x[1]); 
					output.addDouble(x[2]); 
					output.addDouble(input->get(0).asDouble()); 
					output.addDouble(input->get(1).asDouble()); 
					output.addDouble(input->get(2).asDouble()); 
					output.addDouble(input->get(3).asDouble()); 
					output.addDouble(input->get(4).asDouble()); 
					output.addDouble(input->get(5).asDouble()); 
					output.addDouble(xRobot[0]); 
					output.addDouble(xRobot[1]); 
					output.addDouble(xRobot[2]); 			
					
					port.write();
				
				}
				else //record information without forces
				{ 
				//	if(verbosity == 1) cout << "Warning, read no forces." << endl;
	
					Bottle& output = port.prepare();
					output.clear();
					output.addDouble(x[0]); 
					output.addDouble(x[1]); 
					output.addDouble(x[2]); 
					output.addDouble( -1);
					output.addDouble( -1);
					output.addDouble( -1);
					output.addDouble( -1);
					output.addDouble( -1);
					output.addDouble( -1); 
					output.addDouble(xRobot[0]); 
					output.addDouble(xRobot[1]); 
					output.addDouble(xRobot[2]); 				
				}
				
			}
			else//if we don't record trajectory (no event)
			{
				//The simulated robot doesn't give any forces feedback to the geomagic.
				feedback=yarp::math::operator*(x,0.0);
				verifyFeedback();
				igeo->setFeedback(feedback);
			}
			double dist;
            int nbIt=0;
            
            //Follow matlab's previous order
            do
            {
				client.goToPose(xd,od); // new target is xd,od
				client.getPose(x,o); // get current pose as x,o
				dist = (x[0] -xd[0])*(x[0]-xd[0]) + (x[1] -xd[1])*(x[1]-xd[1]) + (x[2] -xd[2])*(x[2]-xd[2]);
				nbIt++;
			}while(dist > 0.001 && nbIt< 100);
		}
		

		     
    }    
	


    bool updateModule()
    { 
		 Vector buttons,rpy;
       Vector x,o;    

		if(verbosity == 2) cout << "Before reading matlab information" << endl;
        Bottle *input = port.read();
        if(verbosity == 2) cout << "Before reading forces from WBDT." << endl;
		Bottle *inputForces = portForces.read(false);

        if (input!=NULL)  // Treatment only if it receives matlab order
        {
            if(verbosity == 2) cout << "Got: " << input->toString().c_str() << endl;
            
            // if we receive only one input, it requires specific treatment:
            if(input->size() == 1)
            {
				 if(input->get(0).asDouble() == -1.0) // if we receive -1 we close the program
				 {
					 if(verbosity == 1) cout << "Receive command to close the programm." << endl;
					 return false;
				 }
				 else if(input->get(0).asDouble() == 0.0) // if we receive 0 we go back to initial position
				 {
					 if(verbosity == 1) cout << "Receive ask to return in initial position." << endl;
					 flagReturn = true;
					 Bottle& output = port.prepare();
					 output.clear();
					 output.addDouble(0); // return ack.
					 port.write();
					 return true;
				 }
				 else if(input->get(0).asDouble() == -2.0) // if we receive -2 we record trajectory
				 {
					 recordTrajectory();
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
				if(flagReturn==true) //When the robot receive an order to go back in the initial position
				{
					client.setTrajectoryTime(3.0);
					if(verbosity == 1) cout << "Rythme slow to begin the movement" << endl;
					if("icubSim" != robot) client.goToPoseSyncRobot(xd,od);   // send request and wait for reply
					client.goToPoseRobot(xd,od);
					if("icubSim" != robot) client.waitMotionDone(0.04);  // wait until the motion is done and ping at each 0.04 seconds
					flagReturn = false;
				}else //When the robot has to move
				{
					client.setTrajectoryTime(trajTime);
					if("icubSim" != robot) client.goToPoseSyncRobot(xd,od);   // send request and wait for reply
					client.goToPoseRobot(xd,od); // new target is xd,od
					if("icubSim" != robot) client.waitMotionDone(0.04);
				}
				
				client.getRobotPose(x,o); // get current pose as x,o
				dist = (x[0] -xd[0])*(x[0]-xd[0]) + (x[1] -xd[1])*(x[1]-xd[1]) + (x[2] -xd[2])*(x[2]-xd[2]);
				nbIt++;
			}while(dist > 0.001 && nbIt< 100);
			
			yInfo("Current position = (%s)",x.toString(3,3).c_str());
			yInfo("Target position = (%s)",xd.toString(3,3).c_str());
			yInfo("Compliance      = (%f)\n",compliance);
			
			//Give to matlab forces information
            Bottle& output = port.prepare();
            output.clear();
            output.addDouble(fext[0]);
            output.addDouble(fext[1]);
            output.addDouble(fext[2]);
            output.addDouble(fext[3]);
            output.addDouble(fext[4]);
            output.addDouble(fext[5]);
            if(verbosity == 2) cout << "It is writing: " << output.toString().c_str() << endl;
            port.write();
        }    
		     
        return true;
    }    
};



int main(int argc,char *argv[])
{           
    Network yarp;
    int r=0;

    cout << "begin" <<endl;

    if (!yarp.checkNetwork())
    {
        yError("YARP server not found!");
        return 1;
    }

    ResourceFinder rf;
    cout << "before conf" <<endl;
    bool ret = rf.configure(argc,argv);
	cout << "after conf" <<endl;
	if(ret==false)
	{
			for(int i=0; i<100;i++)
			{
				cout<<"Error during the configuration, aborting."<<endl;
				Time::delay(5.0);
			}
	}
	else
	{	
		RecordWithGeomagic test;    
		r=test.runModule(rf);
		cout<<"End run module."<<endl;
	Time::delay(5.0);
	} 
    
    return r;
}
