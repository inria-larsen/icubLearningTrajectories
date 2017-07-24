#include <string>
#include <yarp/dev/all.h>
#include <yarp/sig/all.h>
#include <yarp/os/all.h>
#include <yarp/math/Math.h>
#include "cartesianClient.h"

using namespace std;
using namespace yarp::dev;
using namespace yarp::sig;
using namespace yarp::os;
using namespace yarp::math;

bool CartesianClient::init(const string &robot,const string & part,bool swap_x, bool swap_y)
{                        
    this->swap_y=swap_y;
    this->swap_x=swap_x;
    Property option("(device cartesiancontrollerclient)");  
    option.put("remote","/"+robot+"/cartesianController/"+part);
    option.put("local","/cartesian_client/"+part);

	cout << "before open client" << endl;
    if (!client.open(option))
        return false;
	cout << "before view" << endl;
    client.view(icart);
    icart->storeContext(&startup_context_id);
    // get the torso dofs
    Vector newDof, curDof;
    icart->getDOF(curDof);
    newDof=curDof;
    // disable the torso yaw and pitch
    // disable the torso roll
    newDof[0]=0;
    newDof[1]=0;
    newDof[2]=0;
    // if pitch enabled above, impose some restriction on the torso pitch
    // limitTorsoPitch();
    // send the request for dofs reconfiguration
    icart->setDOF(newDof,curDof);
    icart->setTrajTime(0.1);

    // print out some info about the controller
    Bottle info;
    icart->getInfo(info);
    fprintf(stdout,"info = %s\n",info.toString().c_str());

    txd.resize(3);
    if (part=="left_arm")
    {
      txd[0]=-0.3; // x is toward the back of the robot
      txd[1]=-0.1; // y is facing right
      txd[2]=+0.1; // z is towards the head
    }
    else if (part=="right_arm")
    {
      txd[0]=-0.3;
      txd[1]=+0.1;
      txd[2]=+0.1;
    }
    // TODO else error !
    return true;
}


void CartesianClient::setPosePriority( std::string str)
{
	icart->setPosePriority(str);
}

void CartesianClient::getReferenceMode( bool *f)
{
	icart->getReferenceMode(f);
}

void CartesianClient::close()
{    
    icart->stopControl();
    icart->restoreContext(startup_context_id);
    client.close();
}

void CartesianClient::goToPose(const Vector &xd,const Vector &od)
{
	// TODO:
	// * use a proper transformation (matrix to be set at init time ?) instead of static translation and swap*
	Vector x=xd;
	if (swap_x)
	{
		x[0]=-x[0];
	}
	if (swap_y)
	{    
		x[1]=-x[1]; 
	}
	x+=txd;
	icart->goToPose(x,od);
}

void CartesianClient::goToPoseRobot(const Vector &xd,const Vector &od)
{
	icart->goToPose(xd,od);
}

void CartesianClient::goToPoseSyncRobot(const Vector &xd,const Vector &od)
{
	icart->goToPoseSync(xd,od);
}

void CartesianClient::goToPoseSync(const Vector &xd,const Vector &od)
{
  // TODO:
  // * use a proper transformation (matrix to be set at init time ?) instead of static translation and swap*
  Vector x=xd;
  if (swap_x)
  {
	x[0]=-x[0];
  }
  if (swap_y)
  {    
	x[1]=-x[1]; 
  }
	x+=txd;
	icart->goToPoseSync(x,od);
}

void CartesianClient::waitMotionDone(double a)
{
	icart->waitMotionDone(0.04);

}	

void CartesianClient::setTrajectoryTime(double trajTime)
{
	icart->setTrajTime(trajTime);

}

void CartesianClient::getPose(Vector &x, Vector &o)
{
	icart->getPose(x,o);
	x-=txd;
	if (swap_x)
	{
		x[0]=-x[0];
	}
	if (swap_y)   
	{
		x[1]=-x[1];
	}  
}

void CartesianClient::getRobotPose(Vector &x, Vector &o)
{
	icart->getPose(x,o);
}
