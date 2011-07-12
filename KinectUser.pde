/**
* This class stores information about a user interacting through the Kinect.
*/

class KinectUser {
    public static final float DEPTH_LOWER = 300.0;
    public static final float DEPTH_UPPER = 800.0;
    
    int ID;
    PVector lefthand = null; // hand coords
    PVector righthand = null;
    PVector plefthand; // previous hand coords
    PVector prighthand;
    PVector CoM; // center of mass coords, used for hand depth
    long lefthandDown; // time held
    long righthandDown;
    float leftvelocity; // pixels/second
    float rightvelocity;
    float leftangle; // hand angle in degrees
    float rightangle;
    PVector cursorPos;
    
    public KinectUser() {
        cursorPos = new PVector(drawWidth / 2.0, drawHeight / 2.0);
    }
    
    public KinectUser(float x, float y) {
        cursorPos = new PVector(x, y);
    }
    
    void update(PVector newleft, PVector newright, PVector newCoM) {
        float seconds = (System.currentTimeMillis() - lastTime) / 1000.0;
        lastTime = System.currentTimeMillis();

        if (lefthand != null) {
            leftvelocity = (float)dist(newleft.x, newleft.y, lefthand.x, lefthand.y) / seconds;
            
            if (plefthand != null) {
            }
        }
        
        plefthand = lefthand;
        lefthand = newleft;
        
        if (righthand != null) {
            rightvelocity = (float)dist(newright.x, newright.y, righthand.x, righthand.y) / seconds;
            
            if (prighthand != null && newCoM.z - righthand.z > DEPTH_LOWER) {
                float coef = map(DEPTH_UPPER - (newCoM.z - righthand.z), 0, DEPTH_UPPER - DEPTH_LOWER, 0.1, 2);
                cursorPos.x += coef * (righthand.x - prighthand.x);
                cursorPos.y += coef * (righthand.y - prighthand.y);
            }
        }
        
        prighthand = righthand;
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
        ellipse(cursorPos.x, cursorPos.y, 25.0, 25.0);
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
