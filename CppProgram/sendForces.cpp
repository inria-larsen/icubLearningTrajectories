/* 
 * contact: oriane.dermy@inria.fr (11/05/17)
 * 
 * In this program, you can send forces from the haptic device (geomagic touch), from two ports:
 * 1. "/portForcesAndWrench:o"  send forces and fakewrench information: fx fy fz 0 0 0.
 * 2. "/portForces:o" send forces information: fx fy fz.
 * 
 * 
 * / UTILISATION
 * If you press the dark button of the geomagic, the program will compute some forces that are proportional to the distance between a reference position and the current position of the tip of the geomagic.
 * The reference position is the position from where you begin to maintain the geomagic button.
 * Note that if you want to have big forces (nead to the maximum allowed by maxForce), you have to begin the movement from the bottom left deeper position.
 * 
 * / INPUT:
 * maxForce: you can precise the maximum force you want to send to the robot. Then, you will receive a vector of forces that respects: (fx + fy + fz) < maxForce
 * 
 * / REQUIREMENT
 * You need to have launched:
 * launch yarpserver
 * yarprobotinterface --context geomagic --config geomagic.xml
 * See https://github.com/inria-larsen/icub-manual/wiki/Installation-with-the-Geomagic-Touch for more information
 * 
 * PS: Commentaries will allow to modify the program easlily if you want to link the geomagic position with the icub position (using goToPose and igeo->setFeedback(feedback)).
 * 
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

//#include "cartesianClient.h"

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
    //Vector maxFeedback;
    //Vector feedback;
    //double minForce, maxForce;
    int verbosity;

    // cartesian parameters
    //CartesianClient client; 

    string part; //part of the robot we control
    // my data
    BufferedPort<Bottle> portForcesAndWrench, portForces; //port to read forces
    Vector x_t, x0; //position
    //Vector or_old, or_t; //orientation 
    Vector forces;
    double valK; //stiffness 
	bool flagSendForces;
    //Vector x,o,xRobot,oRobot; // positionand orientation of the simulated robot and the geomagic one   

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
        //feedback.resize(3,0.0);
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
    
    //bool initCartesian(const string &robot, const string &part, bool swap_x=false,bool swap_y=false)
    //{                        
        //client.init(robot,part,swap_x,swap_y);
        //xd.resize(3);
        //od.resize(4);
        //return true;
    //}
    
    //void closeCartesian()
    //{    
      //client.close();      
    //}

public:
 
    
    bool configure(ResourceFinder &rf)
    {    
		double maxF=rf.check("maxForce",Value(50)).asDouble();
		string name=rf.check("name",Value("test_feedback")).asString().c_str();
        //string robot=rf.check("robot",Value("icubGazeboSim")).asString().c_str();
		//string part=rf.check("part",Value("left_arm")).asString().c_str();	
    	//folderName = rf.check("folder",Value("../../../MatlabProgram/Data/newTraj")).asString().c_str();	
        string geomagic=rf.check("geomagic",Value("geomagic")).asString().c_str();
        //minForce=fabs(rf.check("min-force-feedback",Value(0.01)).asDouble());
        //maxForce=fabs(rf.check("max-force-feedback",Value(1.5)).asDouble());
        //bool swap_x=rf.check("swap_x",Value("false")).asBool();
        //bool swap_y=rf.check("swap_y",Value("false")).asBool();
        verbosity=rf.check("verbosity",Value(1)).asInt();
		
		cout << "verbosity: "<< verbosity<< endl;
        //port.open("/record/read");  
        portForces.open("/sendForces:o");
		portForcesAndWrench.open("/sendForcesAndWrench:o");
		if(verbosity==1) cout << "ports /sendForces:o and /sendForcesAndWrench:o are open" << endl;
		x_t.resize(3);
		x0.resize(3);
		forces.resize(6);
		valK= maxF ; //3 is the estimation of the maximum distance you can compute from the geomagic.
		flagSendForces = false;
		//reference position of the haptic device (bottom left deeper position)
		//x0[0]=-0.104632;
		//x0[1]= -0.092409;
		//x0[2]= -0.108048;
		if (!initGeomagic(name,geomagic)) return false;


        //if (!initCartesian(robot,part,1,1)) return false;

        //client.getPose(x,o); // get current pose as x,o
        //feedback=yarp::math::operator*(x,0.0);	
		//verifyFeedback();
		//igeo->setFeedback(feedback);

        return true;
    }
    
    bool close()
    {
		closeGeomagic();
		//closeCartesian();
		return true;
    }

    double getPeriod()
    {	
        return 0.01;
    }


	//void verifyFeedback()                     
	//{
        //for (size_t i=0;i<3;i++)
        //{
          //if (feedback[i]>maxForce) feedback[i]=maxForce;
          //if (feedback[i]<-maxForce) feedback[i]=-maxForce;
          //if ((feedback[i]>=0) && (feedback[i]<minForce)) feedback[i]=0.0; // remove small values
          //if ((feedback[i]<0) && (feedback[i]>-minForce)) feedback[i]=0.0; // remove small values
        //}
	//}

    bool updateModule()
    { 
        Vector buttons;
        
        igeo->getButtons(buttons);

		
        // the desired position the simulated robot has to achieve correspond to the position of the geomagic.
        //xd=pos;
        //od[0]=-0.039151; od[1]=0.601265; od[2]=-0.79809; od[3]=2.851949; //see serena-ivaldi/WoZ/app/basicfiles/action.conf for more information about this values
        
        
        //client.getPose(x,o); // get current position and orientation of the robot in the frame of the geomagic
        //client.getRobotPose(xRobot,oRobot); // get the real current position of the robot

		if(buttons[0] ==0.0 && flagSendForces==true)
			flagSendForces = false;
		else if(buttons[0] != 0.0 && flagSendForces==false)
		{
			igeo->getPosition(x0);
			flagSendForces = true;
			//cout << x0[0] << ' ' << x0[1] << ' ' << x0[2] << endl;
			////igeo->getOrientation(or0);
		}
        //sendForces
        if(buttons[0] != 0.0) 
        {
			igeo->getPosition(x_t);
			forces[0] = valK*(x_t[0] - x0[0]);
			forces[1] = valK*(x_t[1] - x0[1]);
			forces[2] = valK*(x_t[2] - x0[2]);
		}
		else
		{
			forces[0] = 0.0;
			forces[1] = 0.0;
			forces[2] = 0.0;
		}
		forces[3] = 0.0;
		forces[4] = 0.0;
		forces[5] = 0.0;


		Bottle& output = portForcesAndWrench.prepare();
		output.clear();
		output.addDouble(forces[0]);
		output.addDouble(forces[1]);
		output.addDouble(forces[2]);
		output.addDouble(forces[3]);
		output.addDouble(forces[4]);
		output.addDouble(forces[5]);
		if(verbosity==2) cout << "writing forces and wrench " << output.toString().c_str() << endl;
		portForcesAndWrench.write();
		
		Bottle& output2 = portForces.prepare();
		output2.clear();
		output2.addDouble(forces[0]);
		output2.addDouble(forces[1]);
		output2.addDouble(forces[2]);
		if(verbosity==2) cout << "writing forces " << output2.toString().c_str() << endl;
		portForces.write();
	
			//client.goToPose(xd,od); // new target is xd,od


		
		//if we don't record trajectory (no event)
	//	else
		//{
			//client.goToPose(xd,od); // the simulated robot goes where the end effector of the haptic device is
			//The simulated robot doesn't give any forces feedback to the geomagic.
			//feedback=yarp::math::operator*(x,0.0);
			//verifyFeedback();
		//	igeo->setFeedback(feedback);
		//}
		     
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
	} 
    
    return r;
}
