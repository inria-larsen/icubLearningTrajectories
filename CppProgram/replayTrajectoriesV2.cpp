//TODO rendre propre le code
#include <cstdio>
#include <cmath>

#include <yarp/os/Network.h>
#include <yarp/os/RFModule.h>
#include <yarp/os/RateThread.h>
#include <yarp/os/Time.h>
#include <yarp/sig/Vector.h>
#include <yarp/math/Math.h>

#include <yarp/dev/Drivers.h>
#include <yarp/dev/CartesianControl.h>
#include <yarp/dev/PolyDriver.h>

#define CTRL_THREAD_PER     0.02    // [s]
#define PRINT_STATUS_PER    1.0     // [s]
#define MAX_TORSO_PITCH     15.0    // [deg]

using namespace std;
using namespace yarp::os;
using namespace yarp::dev;
using namespace yarp::sig;
using namespace yarp::math;


class CtrlThread: public RateThread,
                  public CartesianEvent
{
protected:
    PolyDriver         client;
    ICartesianControl *icart;

    //IPositionControl *pos;
    //IEncoders *encs;
    //IControlMode2 *ictrl;
    //IInteractionMode *iint;
    //IImpedanceControl *iimp;
    //ITorqueControl *itrq;


    Vector xd;
    Vector od;

    int startup_context_id;

    double t;
    double t0;
    double t1;
	BufferedPort<Bottle> port;
	
    // the event callback attached to the "motion-ongoing"
    virtual void cartesianEventCallback()
    {
        fprintf(stdout,"20%% of trajectory attained\n");
    }

public:
    CtrlThread(const double period) : RateThread(int(period*1000.0))
    {
        // we wanna raise an event each time the arm is at 20%
        // of the trajectory (or 80% far from the target)
        cartesianEventParameters.type="motion-ongoing";
        cartesianEventParameters.motionOngoingCheckPoint=0.2;
    }

    virtual bool threadInit()
    {

        Property option("(device cartesiancontrollerclient)");
        option.put("remote","/icub/cartesianController/left_arm");
        option.put("local","/cartesian_client_replay/left_arm");

        if (!client.open(option))
        {
			cout << "Error " << endl;
            return false;
			}
        // open the view
        client.view(icart);

        // latch the controller context in order to preserve
        // it after closing the module
        // the context contains the dofs status, the tracking mode,
        // the resting positions, the limits and so on.
        icart->storeContext(&startup_context_id);

        // set trajectory time
        icart->setTrajTime(3.0);

        // get the torso dofs
        Vector newDof, curDof;
        icart->getDOF(curDof);
        newDof=curDof;

        // enable the torso yaw and pitch
        // disable the torso roll
        newDof[0]=0;
        newDof[1]=0;
        newDof[2]=0;
        
        // send the request for dofs reconfiguration
        icart->setDOF(newDof,curDof);
        
        // impose some restriction on the torso pitch
        limitTorsoPitch();       

        // print out some info about the controller
        Bottle info;
        icart->getInfo(info);
        fprintf(stdout,"info = %s\n",info.toString().c_str());

        // register the event, attaching the callback
        icart->registerEvent(*this);

        xd.resize(3);
        od.resize(4);
        
        icart->getPose(xd,od); // get current pose as x,o
        
        
        //initialize ports
		port.open("/replay/read");  //communication with the matlab program.
	    //portForces.open("/replay/readForces");   // to read forces from the wholebodyDynamics program.

        return true;
    }

    virtual void afterStart(bool s)
    {
        if (s)
            fprintf(stdout,"Thread started successfully\n");
        else
            fprintf(stdout,"Thread did not start\n");

        t=t0=t1=Time::now();
    }

    virtual void run()
    {
        t=Time::now();

        int ok = generateTarget();
		if (ok==-1)
		{
			threadRelease();
		}


        // go to the target :)
        // (in streaming)
        cout << "Go to pose" << xd[0] << " " << xd[1] << " " << xd[2] << endl; 
        
        
        Vector xdhat, odhat, qdhat;
		bool possible = icart->askForPose(xd,od, xdhat,odhat,qdhat);
        if(possible)
        
		{   
			icart->goToPoseSync(xdhat,odhat);
			icart->waitMotionDone(0.04);  // wait until the motion is done and ping at each 0.04 seconds
		}
	    //Give to matlab forces information
            Bottle& output = port.prepare();
            output.clear();
            output.addDouble(0.0);
            output.addDouble(0.0);
            output.addDouble(0.0);
            output.addDouble(0.0);
            output.addDouble(0.0);
            output.addDouble(0.0);
            cout << "It is writing: " << output.toString().c_str() << endl;
            port.write();
            

        // some verbosity
        printStatus();
    }

    virtual void threadRelease()
    {
        // we require an immediate stop
        // before closing the client for safety reason
        cout << "close properly the program." << endl;
        icart->stopControl();

        // it's a good rule to restore the controller
        // context as it was before opening the module
        icart->restoreContext(startup_context_id);

        client.close();
	port.close();
	cout << "end of close properly" << endl;

    }


	void checkSafety()
	{
		cout << "checkSafety" << endl;
		int ok=0;
			if(xd[0]<-0.28) xd[0] = -0.28;
			else if(xd[0] > -0.13 ) xd[0] = -0.13 ;
			else ok = 1;
			if( ok==0) cout << "change x pos" << endl;
			ok=0;
			if(xd[1]<-0.42) xd[1] = -0.42;
			else if(xd[1] >-0.08) xd[1] =-0.08 ;
			else ok=1;
			if( ok==0) cout << "change y pos" << endl;
			ok=0;
			
			if(xd[2]<-0.12) xd[2] = -0.12;
			else if(xd[2] > 0.14) xd[2] = 0.14 ;
			else ok=1;
			if( ok==0) cout << "change x pos" << endl;
			
	}

    int generateTarget()
    {
		
	cout << "Before reading matlab information" << endl;
        Bottle *input = port.read();
		
		
	if (input!=NULL)  // Treatment only if it receives matlab order
	{
		cout << "Got: " << input->toString().c_str() << endl;
            
            	// if we receive only one input, it requires specific treatment:
            	if(input->size() == 1)
        	{
				 if(input->get(0).asDouble() == -1.0) // if we receive -1 we close the program
				 {
					cout << "Receive command to close the programm." << endl;
					return -1;//threadRelease();
				 }
				 //~ else if(input->get(0).asDouble() == 0.0) // if we receive 0 we go back to initial position
				 //~ {
					 //~ //cout << "Receive ask to return in initial position." << endl;
					 //~ Bottle& output = port.prepare();
					 //~ output.clear();
					 //~ output.addDouble(0); // return ack.
					 //~ port.write();
					 //~ return true;
				 //~ }
            }else
			{
				//if we receive many input, the robot has to follow a trajectory
	            for (int i=0; i<3; i++) 
	            {
	                xd[i] = input->get(i).asDouble(); // position ordered by matlab	
	            
	            }
	            for (int i=0; i<4; i++) 
	            {
	                od[i] = input->get(i+4).asDouble(); // orientation ordered by matlab	
	            
	            }

	            //compliance = input->get(3).asDouble(); // compliance ordered by matlab 
			}
		}
		return 0;
    }

    void limitTorsoPitch()
    {
        int axis=0; // pitch joint
        double min, max;

        // sometimes it may be helpful to reduce
        // the range of variability of the joints;
        // for example here we don't want the torso
        // to lean out more than 30 degrees forward

        // we keep the lower limit
        icart->getLimits(axis,&min,&max);
        icart->setLimits(axis,min,MAX_TORSO_PITCH);
    }

    void printStatus()
    {
        if (t-t1>=PRINT_STATUS_PER)
        {
            Vector x,o,xdhat,odhat,qdhat;

            // we get the current arm pose in the
            // operational space
            icart->getPose(x,o);

            // we get the final destination of the arm
            // as found by the solver: it differs a bit
            // from the desired pose according to the tolerances
            icart->getDesired(xdhat,odhat,qdhat);

            double e_x=norm(xdhat-x);
            double e_o=norm(odhat-o);

            fprintf(stdout,"+++++++++\n");
            fprintf(stdout,"xd          [m] = %s\n",xd.toString().c_str());
            fprintf(stdout,"xdhat       [m] = %s\n",xdhat.toString().c_str());
            fprintf(stdout,"x           [m] = %s\n",x.toString().c_str());
            fprintf(stdout,"od        [rad] = %s\n",od.toString().c_str());
            fprintf(stdout,"odhat     [rad] = %s\n",odhat.toString().c_str());
            fprintf(stdout,"o         [rad] = %s\n",o.toString().c_str());
            fprintf(stdout,"norm(e_x)   [m] = %g\n",e_x);
            fprintf(stdout,"norm(e_o) [rad] = %g\n",e_o);
            fprintf(stdout,"---------\n\n");

            t1=t;
        }
    }
};


class CtrlModule: public RFModule
{
protected:
    CtrlThread *thr;

public:
    virtual bool configure(ResourceFinder &rf)
    {
        Time::turboBoost();

        thr=new CtrlThread(CTRL_THREAD_PER);
        if (!thr->start())
        {
            delete thr;
            return false;
        }

        return true;
    }

    virtual bool close()
    {
        thr->stop();
        delete thr;

        return true;
    }

    virtual double getPeriod()    { return 1.0;  }
    virtual bool   updateModule() { return true; }
};


int main()
{
    Network yarp;
    if (!yarp.checkNetwork())
    {
        fprintf(stdout,"Error: yarp server does not seem available\n");
        return 1;
    }

    CtrlModule mod;

    ResourceFinder rf;
    return mod.runModule(rf);
}
