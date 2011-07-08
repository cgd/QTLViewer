/**
* This class stores information about a user interacting through the Kinect.
*/

class KinectUser {
    int ID;
    PVector lefthand; // hand coords
    PVector plefthand; // previous hand coords
    PVector righthand;
    PVector prighthand;
    PVector shoulder; // shoulder middle coords, used for hand depth
    long lefthandDown; // time held
    long righthandDown;
    float leftvelocity;
    float rightvelocity
    
    void update(PVector newleft, PVector newright, long lastFrame) {
        float seconds = (System.currentTimeMillis() - lastFrame);
        
    }
}
