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
//using namespace yarp::math;

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
    Vector xd; //desired position
    Vector od; //desired orientation 
    string part; // part of the robot we control
    
    // my data
    int totalIt, totalTraj;
    int flagRecord; //flag to record the trajectory (when the dark button of the geomagic is pressed)
    ofstream record;
    BufferedPort<Bottle> port; //port to read forces
    double currentTime, startTrajectory;
    string fileName, folderName; //name of the file within the trajectory is recorded
    Vector x,o,xRobot,oRobot; // positionand orientation of the simulated robot and the geomagic one   
        
    //initialize file before writing in it
    bool initFile()
	{
		fileName = string(folderName + "/record"+ boost::lexical_cast<string>(totalTraj) + ".txt");  
		cout << "File name : " << fileName << endl;
		record.open(fileName.c_str(), ios::out | ios::trunc); 
	    if (!record)
	    {  
			cerr << "Cannot create the file " << totalTraj  << " for recording movements." << endl;
			fileName = string("record"+ boost::lexical_cast<string>(totalTraj) + ".txt");  
			cout << "We try file name : " << fileName << endl;
			record.open(fileName.c_str(), ios::out | ios::trunc); 
		    if (!record)
			{  
				cerr << "Cannot create the file " << totalTraj  << " for recording movements." << endl;
				return false;
			}
		}
		
		cout << "Correctly created " << fileName << endl;
		
		startTrajectory = Time::now();
			
		return true;
	}
	
	//close the file at the end of a trajectory
	bool closeFile()
	{
			totalTraj++;
			record.close();
			return true;
	}

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
        string robot=rf.check("robot",Value("icubSim")).asString().c_str();
		string part=rf.check("part",Value("left_arm")).asString().c_str();	
    	folderName = rf.check("folder",Value("../../../MatlabProgram/Data/newTraj")).asString().c_str();	
        string geomagic=rf.check("geomagic",Value("geomagic")).asString().c_str();
        minForce=fabs(rf.check("min-force-feedback",Value(0.01)).asDouble());
        maxForce=fabs(rf.check("max-force-feedback",Value(1.5)).asDouble());
        bool swap_x=rf.check("swap_x",Value("false")).asBool();
        bool swap_y=rf.check("swap_y",Value("false")).asBool();
        verbosity=rf.check("verbosity",Value(1)).asInt();
		
		cout << "verbosity: "<< verbosity<< endl;
        port.open("/record/read");  

        flagRecord = 0; // precise if we are recording or not (if the button has been pressed or not).
        totalTraj = 0; //total number of trajectories
		
	if (!initGeomagic(name,geomagic)) return false;
        
        if (!initCartesian(robot,part,1,1)) return false;

        client.getPose(x,o); // get current pose as x,o
        feedback=yarp::math::operator*(x,0.0);	
	verifyFeedback();
	igeo->setFeedback(feedback);

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

    bool updateModule()
    { 
        Vector buttons,pos,rpy;
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
			totalIt= 0;
			initFile();
			cout << "Recording the " << totalTraj + 1 <<" trajectory ..." << endl;

		}
		
		//Treatment of the end of a trajectory
		else if((buttons[0] == 0.0) && (flagRecord == 1) && (totalIt > 5))
		{
			cout << "End of the recorded trajectory." << endl;
			cout << "We've recorded " << totalTraj +1 << " trajectories." << endl;
			record << endl;
			closeFile();
			flagRecord = 0;
		}

		//Recording a trajectory
		if(flagRecord == 1)
		{
			totalIt++;
			
			//read actual time
			currentTime = Time::now();
			// read forces given by the wholeBodyDynamicsTree programm
			Bottle *input = port.read(false);
			if (input!=NULL) //record information with forces
			{				
				if(verbosity == 1) cout << "Read forces: " << input->toString().c_str() << endl;
				record << currentTime - startTrajectory  <<" " 
				<< x[0] << " " << x[1] << " " << x[2]  << " " 
				<< input->get(0).asDouble() << " " << input->get(1).asDouble() << " " << input->get(2).asDouble() << " " 
				<< input->get(3).asDouble() << " " << input->get(4).asDouble() << " " << input->get(5).asDouble() << " " 
				<< xRobot[0] << " " << xRobot[1] << " " << xRobot[2] <<endl;
			}
			else //record information without forces
			{ 
				if(verbosity == 1) cout << "Warning, read no forces." << endl;
				//record all the information into the file opened by record.
				record << currentTime - startTrajectory  <<" " 
				<< x[0] << " " << x[1] << " " << x[2]  << " " 
				<< -1.0 << " " << -1.0 << " " << -1.0 << " " 
				<< -1.0<< " " << -1.0 << " " << -1.0 << " " 
				<< xRobot[0] << " " << xRobot[1] << " " << xRobot[2] <<endl;
				
			}

			
			client.goToPose(xd,od); // new target is xd,od


		}
		
		//if we don't record trajectory (no event)
		else
		{
			client.goToPose(xd,od); // the simulated robot goes where the end effector of the haptic device is
			//The simulated robot doesn't give any forces feedback to the geomagic.
			feedback=yarp::math::operator*(x,0.0);
			verifyFeedback();
			igeo->setFeedback(feedback);
		}
		     
        return true;
    }    
};



int main(int argc,char *argv[])
{           
    Network yarp;
    int r=0;

    if (!yarp.checkNetwork())
    {
        yError("YARP server not found!");
        return 1;
    }

    ResourceFinder rf;
    bool ret = rf.configure(argc,argv);
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
