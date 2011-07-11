/**
* This class stores information about a user interacting through the Kinect.
*/

class KinectUser {
    int ID;
    PVector lefthand = null; // hand coords
    PVector righthand = null;
    PVector CoM; // center of mass coords, used for hand depth
    long lefthandDown; // time held
    long righthandDown;
    float leftvelocity; // pixels/second
    float rightvelocity;
    float leftangle; // hand angle in degrees
    float rightangle;
    
    void update(PVector newleft, PVector newright, PVector newCoM) {
        float seconds = (System.currentTimeMillis() - lastTime) / 1000.0;
        lastTime = System.currentTimeMillis();

        if (lefthand != null) {
            leftvelocity = (float)dist(newleft.x, newleft.y, lefthand.x, lefthand.y) / seconds;
        }
    
        lefthand = newleft;
        
        if (righthand != null) {
            rightvelocity = (float)dist(newright.x, newright.y, righthand.x, righthand.y) / seconds;
        }
        
        righthand = newright;
        
        rightangle = getAngle(newCoM, righthand);
        leftangle = getAngle(newCoM, lefthand);
        
        if (Float.toString(rightangle).equals("NaN")) {
            rightangle = Float.NaN;
        }
        
        if (Float.toString(leftangle).equals("NaN")) {
            leftangle = Float.NaN;
        }
        
        CoM = newCoM;
        
        fill(0xFF, 0x00, 0x00);
        stroke(0x00);
        strokeWeight(1);
        ellipseMode(CENTER);
        ellipse(righthand.x, righthand.y, 25.0, 25.0);
        ellipse(lefthand.x, lefthand.y, 25.0, 25.0);
    }
    
    float getAngle(PVector center, PVector pt) {
        if (pt.y < center.y) {
            return (180.0 / PI) * atan(abs(center.x - pt.x) / abs(center.y - pt.y));
        } else if (pt.y > center.y) {
            return 90.0 + ((180.0 / PI) * atan(abs(center.x - pt.x) / abs(center.y - pt.y)));
        } else {
            return 90.0;
        }
    }
}
