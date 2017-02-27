#include <string>
#include <yarp/dev/all.h>
#include <yarp/sig/all.h>

static const double MAX_TORSO_PITCH=0.0;    // [deg]

class CartesianClient
// Helper for cartesian clients: open the polydriver and initialize the client
// with sensible default values
{
protected:
    yarp::dev::PolyDriver client;
    yarp::dev::ICartesianControl *icart;
    int startup_context_id;
    yarp::sig::Vector txd;
    std::string part;
    bool swap_y; // left to right vs. right to left
    bool swap_x; // front to back vs. back to front
    void limitTorsoPitch()
    {
        int axis=0; // pitch joint
        double min, max;
        icart->getLimits(axis,&min,&max);
        icart->setLimits(axis,min,MAX_TORSO_PITCH);
    }

public:
    bool init(const std::string &robot,const std::string & part, bool swap_x=false, bool swap_y=false);
    void close();    
    void goToPose(const yarp::sig::Vector &xd,const yarp::sig::Vector &od);
    void goToPoseRobot(const yarp::sig::Vector &xd,const yarp::sig::Vector &od);
    void getPose(yarp::sig::Vector &x, yarp::sig::Vector &o);
    void getRobotPose(yarp::sig::Vector &x, yarp::sig::Vector &o);
    void setTrajectoryTime(double trajTime);
    void setPosePriority( std::string str);
	void getReferenceMode( bool *f);
	void waitMotionDone(double a);
	void goToPoseSync(const yarp::sig::Vector &xd,const yarp::sig::Vector &od);
	void goToPoseSyncRobot(const yarp::sig::Vector &xd,const yarp::sig::Vector &od);

};
