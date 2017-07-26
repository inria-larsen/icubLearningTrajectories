/*
 * Updated version
 * 
 * Author: Serena Ivaldi, Oriane Dermy
 * email:  serena.ivaldi@inria.fr, oriane.dermy@inria.fr
*/

/*
 * Copyright (C) 2011-2012 MACSi Project
 * Author: Serena Ivaldi
 * email:  serena.ivaldi@isir.upmc.fr
 * website: www.macsi.isir.upmc.fr
 * Permission is granted to copy, distribute, and/or modify this program
 * under the terms of the GNU General Public License, version 2 or any
 * later version published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details
*/

/**
@ingroup macsi_tools

\defgroup grasper grasper

A module for commanding pre-defined grasps, but also to provide
a basic interface for reaching

\section intro_sec Description

This module can be used to command pre-defined grasps and reach for objects.
It relies on the common Cartesian interface for reaching desired poses for the hands
(both position and orientation are entailed).
It reads a configuration file, with the configuration of the fingers for
different types of grasps, and several parameters used to set offsets and performance.
A rpc port can be used to command the hands in the Cartesian
space, move the fingers and execute different grasps.


\section lib_sec Libraries
- YARP libraries.
- iCub libraries.

\section parameters_sec Parameters

--name \e name
- the name of the module, used to open ports

--robot \e robot
- the robot to connect to, either icub or icubSim

The configuration file will also have a section like the following:

\code
name	grasper
robot 	icub

# the velocity for moving the fingers
# 		j7	j8	j9	j10	j11	j12	j13	j14	j15
vels_hand       20.0  	40.0  	50.0  	50.0  	50.0  	50.0  	50.0  	50.0  	80.0

# the hand configuration for such grasp (joints pos)
# grasp_name	j7	j8	j9	j10	j11	j12	j13	j14	j15
open_hand       0.0   	0.0   	0.0   	0.0   	0.0   	0.0   	0.0   	0.0   	0.0
close_hand      0.0   	80.0  	30.0  	20.0  	30.0  	40.0  	30.0  	40.0  	150.0
green_ball	22.0	30.0	38.0	36.0	56.0	99.0	52.0	104.0	192.0
open_pince_1    8.0   	78.0   	0.0   	0.0   	0.0   	0.0   	0.0   	0.0   	0.0
close_pince_1   8.0     78.0 	6.0 	22.0 	28.0 	36.8 	32.9 	36.8 	0.0
closer_pince_1  8.0 	81.0 	20.0 	34.4	33.1 	45.2 	35.5 	37.2 	0.0
open_pince_2 	26.0 	90.0 	19.1 	6.0 	43.0 	0.0 	48.0 	5.0 	0.0
close_pince_2   26.0 	90.0 	25.0 	12.2 	70.7 	14.3 	72.6 	13.5 	0.0
open_pince_3 	26.0 	90.0 	19.1 	6.0 	43.0 	0.0 	48.0 	5.0 	0.0
close_pince_3   26.0 	90.0 	25.0 	12.2 	70.7 	14.3 	72.6 	13.5 	0.0

# how much to lift the ball
lift_offset	0.05

#offsets for reaching
offset_x	0.0 0.0 0.0
offset_o	0.0 0.0 0.0 0.0

# init and test pose
left_init	-0.257	-0.379	0.194	-0.3027	0.3531	-0.8852	2.5988
left_reach	-0.356	-0.152	0.081	0.0443	-0.0170	0.9988	2.9173
right_init	-0.228	0.409	0.174	-0.4069	-0.9126	-0.0370	2.9913
right_reach	-0.313	0.208	0.103	0.1034	-0.9924	-0.0661	3.0712

# params for both arms
# put: true, false
enableTrackingMode	false
enableTorso		false
\endcode

where \e vels_hand is the velocity of the fingers while moving, whereas the other vectors
represent configurations for the fingers associated to pre-defined grasps.

\section portsa_sec Ports Accessed
It connects automatically to the iCubInterface to retrieve the command interfaces to the hands.

\section portsc_sec Ports Created
- \e /<name>/rpc:i

\section portsc_sec Example

In a terminal, simply launch

\code
grasper
\endcode

then to send commands open a rpc port:

\code
yarp rpc --client /myPort
\endcode

and connect it to the grasper port

\code
yarp connect /myPort /grasper/rpc:i
\endcode

finally type commands in the rpc port, like:

\code
left stat
left open_hand
left close_hand
right green_ball
\endcode

\section tested_os_sec Tested OS
Linux

\author Based on the grasper.cpp of Serena Ivaldi, modified by Oriane Dermy
*/

#include <yarp/sig/Vector.h>
#include <yarp/os/all.h>
#include <yarp/dev/PolyDriver.h>
#include <yarp/dev/Drivers.h>
#include <yarp/dev/ControlBoardInterfaces.h>
#include <string>
#include <fstream>
#include <iostream>
#include <stdio.h>
#include <math.h>


using namespace std;
using namespace yarp::os;
using namespace yarp::dev;
using namespace yarp::sig;
//using namespace yarp::math;
//using namespace iCub::ctrl;


// utils for printing parameters
#define DSCPA(V) cout<<"  "<< #V <<" : "<<V<<endl;
#define DSCPAv(V) cout<<"  "<< #V <<" : "<<V.toString()<<endl;
#define DSCPAs(S,V) cout<<"  "<< S <<" : "<<V.toString()<<endl;
#define DSCPAd(S,V) cout<<"  "<< S <<" : "<<V<<endl;



//===============================
//        GRASPER MODULE
//===============================
class Grasper: public RFModule
{
private:

    Port rpc; // the port to handle messages
    int count;

    //
    string name;
    string robot;
    //
    Vector  vels_hand;
    Vector  open_hand, close_hand,
            green_ball,
            open_pince_1, close_pince_1, closer_pince_1,
            open_pince_2, close_pince_2,
            open_pince_3, close_pince_3;
    //
    Property optionsR, optionsL;
    PolyDriver *ddR, *ddL;
    IPositionControl *iposR, *iposL,*ipos;
    IEncoders *iencR, *iencL,*ienc;

    double trajectory_time;


public:

    //---------------------------------------------------------
    Grasper()
    {
        ddR=ddL=0;
        iposR=iposL=ipos=0;
        iencR=iencL=ienc=0;
        count=0;
        trajectory_time = 3.0;
    }

    //---------------------------------------------------------
    double getPeriod() { return 1.0; }

    //---------------------------------------------------------
    bool updateModule()
    {
        if(count%60==0)
            cout<<" grasper module alive since "<<(count/60)<<" mins ... "<<endl;

        if(count%600==0)
            cout<<"\n---------------------------------"<<endl
                <<" Here some suggestions on the available commands, for a cycle with left arm: "<<endl
                <<" left_init "<<endl
                <<" left open_pince_1"<<endl
                <<" left_reach "<<endl
                <<" left close_pince_2"<<endl
                <<" left lift"<<endl
                <<" left open_pince_2"<<endl
                <<" left_init"<<endl
                <<"---------------------------------\n"<<endl;
        count++;
        return true;
    }

    //---------------------------------------------------------
    /* Message handler. Just echo all received messages. */
    bool respond(const Bottle& command, Bottle& reply)
    {
        ConstString cmd = command.get(0).asString();
        cout<<"first command = "<<cmd<<endl;

        if (cmd=="quit")
            return false;

        if (cmd=="list" || cmd=="help")
        {
            reply.clear();
            reply.addString("Here is the list of available commands: ");
            reply.addString("left/right + stat/open_hand/close_hand/open_pince_1..3/close_pince_1..3");
            reply.addString("left/right + stat/open_hand/close_hand/open_pince_1..3/close_pince_1..3");
            return true;
        }  
         else if(cmd=="left")
        {
            ddL->view(ienc); ddL->view(ipos); 
        }
        else if(cmd=="right")
        {
            ddR->view(ienc); ddR->view(ipos); 
        }
        
        
        else
        {
            reply.clear();
            reply.addString("ERROR");
            reply.addString("The first item is left/right, to choose the hand.");
            return true;
        }

        ConstString config = command.get(1).asString();
        cout<<"second command = "<<config<<endl;
        if(config=="stat")
        {
            double cur;
            double curtol;
            reply.clear();
            reply.addString("OK");
            reply.addString("fingers");
            for(int i=0;i<9;i++)
            {
                ienc->getEncoder(i+7,&cur);
                reply.addDouble(cur);
            }
            
            return true;
        }
        else if(config=="open_hand")        moveFings(open_hand);
        else if(config=="close_hand")       moveFings(close_hand);
        else if(config=="green_ball")       moveFings(green_ball);
        else if(config=="open_pince_2")     moveFings(open_pince_2);
        else if(config=="close_pince_2")    moveFings(close_pince_2);
        else if(config=="open_pince_1")     moveFings(open_pince_1);
        else if(config=="close_pince_1")    moveFings(close_pince_1);
        else if(config=="closer_pince_1")   moveFings(closer_pince_1);
        else if(config=="open_pince_3")     moveFings(open_pince_3);
        else if(config=="close_pince_3")    moveFings(close_pince_3);
        else
        {
            reply.clear();
            reply.addString("ERROR");
            reply.addString("Unknown grasp");
            return true;
        }

        reply.clear();
        reply.addString("OK");
        reply.addString(command.get(0).asString());
        reply.addString(command.get(1).asString());
        // DEBUG: echoes the received messages
        //reply = command;
        return true;
    }

    //---------------------------------------------------------
    void moveFings(Vector &v)
    {
		cout << "in MoveFings ";
		
        for(int i=0;i<9;i++)
        {
            ipos->setRefSpeed(i+7,vels_hand[i]);
        }
        Time::delay(0.01);
        for(int i=0;i<9;i++)
        {
            ipos->positionMove(i+7,v[i]);
            cout << v[i] << " " ;
		}
		cout << endl;
    }

    //---------------------------------------------------------
    void readFings(ResourceFinder &rf, string s, Vector &v)
    {
		cout << s << endl;
        v.resize(9,0.0);
        if(rf.check(s.c_str()))
        {
            Bottle &grp = rf.findGroup(s.c_str());
            int sz=grp.size()-1;
            int len=sz>9?9:sz;
            for (int i=0; i<len; i++)
                v[i]=grp.get(1+i).asDouble();
            DSCPAs(s,v);
        }
        else
        {
            cout<<"Could not find parameters for "<<s<<endl
                <<"Setting everything to zero by default"<<endl;
        }
    }

    //---------------------------------------------------------
    void readValue(ResourceFinder &rf, string s, double &v, double vdefault)
    {
        if(rf.check(s.c_str()))
        {
            v = rf.find(s.c_str()).asDouble();
        }
        else
        {
            v = vdefault;
            cout<<"Could not find parameters for "<<s<<endl
                <<"Setting default "<<vdefault<<endl;
        }
    }

    //---------------------------------------------------------
    void readParams(ResourceFinder &rf, string s, Vector &v, int len)
    {
        v.resize(len,0.0);
        cout << "s: " << s << endl;
        if(rf.check(s.c_str()))
        {
            Bottle &grp = rf.findGroup(s.c_str());
            for (int i=0; i<len; i++)
                v[i]=grp.get(1+i).asDouble();
            DSCPAs(s,v);
        }
        else
        {
            cout<<"Could not find parameters for "<<s<<endl
                <<"Setting everything to zero by default"<<endl;
        }
    }


    //---------------------------------------------------------
    bool configure(ResourceFinder &rf)
    {
        Time::turboBoost();

        if(rf.check("name"))
            name    = rf.find("name").asString();
        else
            name    = "grasper";
        //....................................................
        if(rf.check("robot"))
            robot   = rf.find("robot").asString();
        else
            robot   = "icubSim"; //by default simulator, so we dont break the real one
        //....................................................

        cout<<"Parameters from init file: "<<endl;
        DSCPA(name);
        DSCPA(robot);
     
        readFings(rf,"vels_hand",vels_hand);
        readFings(rf,"open_hand",open_hand);
        readFings(rf,"close_hand",close_hand);
        readFings(rf,"green_ball",green_ball);
        readFings(rf,"open_pince_1",open_pince_1);
        readFings(rf,"close_pince_1",close_pince_1);
        readFings(rf,"closer_pince_1",closer_pince_1);
        readFings(rf,"open_pince_2",open_pince_2);
        readFings(rf,"close_pince_2",close_pince_2);
        readFings(rf,"open_pince_3",open_pince_3);
        readFings(rf,"close_pince_3",close_pince_3);
       
     
        //now connect to the robot
        optionsR.put("device","remote_controlboard");
        optionsR.put("local",string("/"+name+"/right_arm").c_str());
        optionsR.put("remote",string("/"+robot+"/right_arm").c_str());
        ddR = new PolyDriver;
        if(!ddR->open(optionsR))
        {
            cout<<"Problems connecting to the remote driver of right_arm"<<endl;
            close();
            return false;
        }
        if(!ddR->view(iencR) || !ddR->view(iposR) )
        {
            cout<<"Problems acquiring interfaces of right_arm"<<endl;
            close();
            return false;
        }
        optionsL.put("device","remote_controlboard");
        optionsL.put("local",string("/"+name+"/left_arm").c_str());
        optionsL.put("remote",string("/"+robot+"/left_arm").c_str());
        ddL = new PolyDriver;
        if(!ddL->open(optionsL))
        {
            cout<<"Problems connecting to the remote driver of left_arm"<<endl;
            close();
            return false;
        }
        if(!ddL->view(iencL) || !ddL->view(iposL) )
        {
            cout<<"Problems acquiring interfaces of left_arm"<<endl;
            close();
            return false;
        }

    


        //attach a port to the module, so we can send messages
        //and choose the type of grasp to execute
        //messages received from the port are redirected to the respond method
        rpc.open(string("/"+name+"/rpc:i").c_str());
        attach(rpc);

        //attach the terminal, so the text typed in the console is redirected
        //to the respond method
        //for the moment it is better to avoid this.. causes problems when closing
        //DEBUG
        //attachTerminal();
        return true;
    }

   

    //---------------------------------------------------------
    bool interruptModule()
    {
        cout<<"Interrupting your module, for port cleanup"<<endl;
        return true;
    }

    //---------------------------------------------------------
    bool close()
    {
       

        cout<<"Close rpc port"<<endl;
        rpc.interrupt();
        rpc.close();
        Time::delay(0.2);

        cout<<"Close drivers"<<endl;
        if(ddR) {delete ddR; ddR=0;}
        if(ddL) {delete ddL; ddL=0;}
        
        return true;
    }
};



//---------------------------------------------------------
//                  MAIN
//---------------------------------------------------------
int main(int argc, char * argv[])
{
   
    ResourceFinder rf;
    rf.setDefaultContext("learningTrajectoriesProMPFrontiers");
    rf.setDefaultConfigFile("grasper.ini");
    rf.configure(argc,argv);
  
    if (rf.check("help"))
    {
		printf("\n");
		yInfo("[GRASPER] Options:");
        yInfo("  --context           path:   where to find the called resource (default learningTrajectoriesProMPFrontiers).");
        yInfo("  --from              from:   the name of the .ini file (default grasper.ini).");
        yInfo("  --name              name:   the name of the module (default grasper).");
        yInfo("  --robot             robot:  the name of the robot. Default icub.");
        printf("\n");

        return 0;
    }
    
    Network yarp;
    if (!yarp.checkNetwork())
    {
        yError("YARP server not available!");
        return -1;
    }

    Grasper module;
    module.runModule(rf);

    return 0;
}
