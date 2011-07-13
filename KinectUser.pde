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
    
    long righthandDown = -1; // time hold start
    long lefthandDown = -1; // same, but for angle
    long sameDistTime = -1; // time that the hand distance has been the same
    
    float rightvelocity; // pixels/second
    float leftangle; // hand angle in degrees
    float handDiff; // hand horizontal distance
    float phandDiff = -1.0;
    float firsthandDiff = -1.0;
    
    boolean ready = true;
    boolean leftReady = true;
    boolean dragZoom = false;
    boolean zoomReady = true;
    boolean pressed;
    
    PVector cursorPos;
    
    KinectUser() {
        cursorPos = new PVector(drawWidth / 2.0, drawHeight / 2.0);
    }
    
    KinectUser(float x, float y) {
        cursorPos = new PVector(x, y);
    }
    
    boolean update(PVector newleft, PVector newright, PVector newCoM) {
        float seconds = (System.currentTimeMillis() - lastTime) / 1000.0;
        boolean retVal = false;
        lastTime = System.currentTimeMillis();
        
        plefthand = lefthand;
        lefthand = newleft;
        
        if (righthand != null) {
            rightvelocity = (float)dist(newright.x, newright.y, righthand.x, righthand.y) / seconds;
            
            if (prighthand != null && newCoM.z - righthand.z > DEPTH_LOWER) {
                float coef = map(DEPTH_UPPER - (newCoM.z - righthand.z), 0, DEPTH_UPPER - DEPTH_LOWER, 0.1, 2);
                cursorPos.x += coef * (righthand.x - prighthand.x);
                cursorPos.y += coef * (righthand.y - prighthand.y);
            }
            
            if (cursorPos.x > drawWidth) {
                cursorPos.x = drawWidth;
            } else if (cursorPos.x < 0) {
                cursorPos.x = 0;
            }
            
             if (cursorPos.y > drawHeight) {
                 cursorPos.y = drawHeight;
             } else if (cursorPos.y < 0) {
                 cursorPos.y = 0;
             }
        }
        
        prighthand = righthand;
        righthand = newright;
        
        phandDiff = handDiff;
        handDiff = abs(newright.x - newleft.x);
        
        CoM = newCoM;
        
        leftangle = getAngle(newCoM, lefthand);
        
        if (Float.toString(leftangle).equals("NaN")) {
            leftangle = Float.NaN;
        }
        
        // right hand down
        if (rightvelocity < 5.0 && newCoM.z - righthand.z > DEPTH_LOWER && !dragZoom) {
            if (righthandDown == -1) {
                righthandDown = System.currentTimeMillis();
            }
            
            leftReady = false;
        } else {
            righthandDown = -1;
            ready = true;
            leftReady = true;
        }
        
        // left and right hands down
        if (CoM.z - lefthand.z > DEPTH_LOWER && CoM.z - righthand.z > DEPTH_LOWER && zoomReady && tabs.currentpage == 1) {
            if (!dragZoom) {
                firsthandDiff = abs(lefthand.x - righthand.x);
                ((LODDisplay)tabs.get(1).get(0)).oldzoomFactor = ((LODDisplay)tabs.get(1).get(0)).zoomFactor;
            }
                        
            if (tabs.currentpage == 1) {
                ((LODDisplay)tabs.get(1).get(0)).zoomFactor = ((LODDisplay)tabs.get(1).get(0)).oldzoomFactor * (100.0 / map(handDiff, 0, firsthandDiff, 0, 100));
            }
            
            dragZoom = true;
            righthandDown = -1;
            lefthandDown = -1;
            leftReady = false; // don't register angles while zooming
            ready = false;
        } else if (leftangle > 45.0 && leftangle < 60.0) { // left hand in angle region
            if (lefthandDown == -1) {
                lefthandDown = System.currentTimeMillis();
            }
            
            dragZoom = false;
            zoomReady = false;
        } else {
            lefthandDown = -1;
            dragZoom = false;
            leftReady = true;
            
            if (!(CoM.z - lefthand.z > DEPTH_LOWER && CoM.z - righthand.z > DEPTH_LOWER)) {
                zoomReady = true;
            }
        }
        
        // right hand has been held down
        if (!dragZoom && righthandDown != -1 && System.currentTimeMillis() - righthandDown >= 2000 && System.currentTimeMillis() - righthandDown < 2500 && ready) {
            mousePressed = retVal = true;
            mouseButton = LEFT;
            mouseX = round(cursorPos.x);
            mouseY = round(cursorPos.y);
            
            mouseId = ID;
            
            mousePressed();
            
            ready = false;
            leftReady = true;
        }
        
        // left hand has been held at an angle
        if (lefthandDown != -1 && System.currentTimeMillis() - lefthandDown >= 2500 && System.currentTimeMillis() - lefthandDown < 3000 && leftReady) {
            
            leftReady = false;
        }
        
        // start timer if hand distance changes less than 5.0 pixels
        if (dragZoom && phandDiff != -1.0 && CoM.z - lefthand.z > DEPTH_LOWER && abs(phandDiff - handDiff) < 5.0) {
            if (sameDistTime == -1) {
                sameDistTime = System.currentTimeMillis();
            }
        } else {
            sameDistTime = -1;
        }
        
        // both hands have been held in place, zooming stops
        if (sameDistTime != -1 && System.currentTimeMillis() - sameDistTime > 2000) {
            dragZoom = false;
            leftReady = true;
            ready = false;
            sameDistTime = -1;
            zoomReady = false;
            
            if (tabs.currentpage == 1) {
                ((LODDisplay)tabs.get(1).get(0)).oldzoomFactor = ((LODDisplay)tabs.get(1).get(0)).zoomFactor;
            }
        }
        
        stroke(0x00);
        strokeWeight(1);
        ellipseMode(CENTER);
        
        if (lefthandDown != -1 && System.currentTimeMillis() - lefthandDown > 1000 && System.currentTimeMillis() - lefthandDown < 3000) {
            float radius = 30.0;
            
            if (righthandDown != -1 && System.currentTimeMillis() - righthandDown > 1000 && System.currentTimeMillis() - righthandDown < 2500) {
                radius = 40.0;
            }
            
            if (System.currentTimeMillis() - lefthandDown > 2500) {
               fill(0x00, 0xFF, 0x00, map(System.currentTimeMillis() - lefthandDown, 2500, 3000, 0x00, 0xFF));
            } else {
                fill(0x00, 0xFF, 0x00);
            }
            
            arc(cursorPos.x, cursorPos.y, radius, radius, TWO_PI - map(System.currentTimeMillis() - lefthandDown, 1000, 2500, 0.0, TWO_PI), TWO_PI);
        }
        
        if (righthandDown != -1 && System.currentTimeMillis() - righthandDown > 1000 && System.currentTimeMillis() - righthandDown < 2500) {
            if (System.currentTimeMillis() - righthandDown > 2000) {
                fill(0x00, 0x00, 0xFF, map(System.currentTimeMillis() - righthandDown, 2000, 2500, 0x00, 0xFF));
            } else {
                fill(0x00, 0x00, 0xFF);
            }
            
            arc(cursorPos.x, cursorPos.y, 30.0, 30.0, 0.0, map(System.currentTimeMillis() - righthandDown, 1000, 2000, 0.0, TWO_PI));
        }

        if (!dragZoom) {
            fill(0xFF, 0x00, 0x00, (newCoM.z - righthand.z > DEPTH_LOWER) ? 0xFF : 0x7F);
            ellipse(cursorPos.x, cursorPos.y, 20.0, 20.0);
        } else {
            if (sameDistTime != -1) {
                stroke(0x00, map(System.currentTimeMillis() - sameDistTime, 0, 2000, 0xFF, 0x00));
            } else {
                stroke(0x00);
            }
            
            strokeWeight(3);
            
            line(lefthand.x, (drawHeight / 2.0) - 32, lefthand.x, (drawHeight / 2.0) + 32);
            line(righthand.x, (drawHeight / 2.0) - 32, righthand.x, (drawHeight / 2.0) + 32);
            line(lefthand.x, drawHeight / 2.0, righthand.x, drawHeight / 2.0);
            
            strokeWeight(1);
        }
        
        return retVal;
    }
    
    float getAngle(PVector center, PVector pt) {
        if (pt.y < center.y) {
            return 90.0 + ((180.0 / PI) * atan(abs(center.x - pt.x) / abs(center.y - pt.y)));
        } else if (pt.y > center.y) {
            return (180.0 / PI) * atan(abs(center.x - pt.x) / abs(center.y - pt.y));
        } else {
            return 90.0;
        }
    }
}
