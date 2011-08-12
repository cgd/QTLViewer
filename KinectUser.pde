/**
* This class stores information about a user interacting through the Kinect.
*/

class KinectUser {
    public static final float DEPTH_LOWER = 200.0;
    public static final float DEPTH_UPPER = 800.0;
    
    int ID;
    
    PVector lefthand = null; // hand coords
    PVector righthand = null;
    PVector plefthand; // previous hand coords
    PVector prighthand;
    PVector dragstart = null;
    PVector CoM; // center of mass coords, used for hand depth
    
    PVector[] arrow = new PVector[] {
        new PVector(-16, 0),
        new PVector(-16, -8),
        new PVector(-8, -8),
        new PVector(-8, -32),
        new PVector(-32, -32),
        new PVector(0, -sin(PI / 3.0) * 64.0),
        new PVector(32, -32),
        new PVector(8, -32),
        new PVector(8, -8),
        new PVector(16, -8),
        new PVector(16, 0)
    };
    
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
    boolean dragReady = true;
    boolean pressed = false;
    
    PVector cursorPos;
    
    PFont big = createFont("Arial", 64.0, true);
    
    KinectUser() {
        cursorPos = new PVector(drawWidth / 2.0, drawHeight / 2.0);
    }
    
    KinectUser(float x, float y) {
        cursorPos = new PVector(x, y);
    }
    
    boolean update(PVector newleft, PVector newright, PVector newCoM) {
        textFont(big);
        if (pressed) {
            pressed = false;
        }
        
        float seconds = (System.currentTimeMillis() - lastTime) / 1000.0;
        boolean retVal = false;
        lastTime = System.currentTimeMillis();
        
        plefthand = lefthand;
        lefthand = newleft;
        
        if (righthand != null) {
            rightvelocity = (float)dist(newright.x, newright.y, righthand.x, righthand.y) / seconds;
            
            if (prighthand != null && newCoM.z - righthand.z > DEPTH_LOWER) {
                float coef = map(newCoM.z - righthand.z  , 0, DEPTH_UPPER - DEPTH_LOWER, 0.1, 2);
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
        if (rightvelocity < 150.0 && newCoM.z - righthand.z > DEPTH_LOWER && !dragZoom && (lefthandDown == -1 || (System.currentTimeMillis() - lefthandDown) > 3000)) {
            if (righthandDown == -1) {
                righthandDown = System.currentTimeMillis();
            }
        } else {
            righthandDown = -1;
            ready = true;
        }
        
        if (dragstart != null && !(CoM.z - lefthand.z > DEPTH_LOWER)) { // dragstart is about to be set to null, tell components to stop panning
            switch (tabs.currentpage) {
                case 0:
                    if (lefthand.x > filebrowser.x && lefthand.x < filebrowser.x + filebrowser.cWidth && lefthand.y > filebrowser.y && lefthand.y < filebrowser.y + filebrowser.cHeight) {
                        filebrowser.panEnd(ID);
                    }
                    
                    ((UIKTree)fileTree).panEnd(ID);
                    break;
                case 1:
                    loddisplay.panEnd(ID);
                    break;
            }
        }
        
        // left and right hands down
        if (CoM.z - lefthand.z > DEPTH_LOWER && CoM.z - righthand.z > DEPTH_LOWER && zoomReady && tabs.currentpage == 1) {
            double old = 1.0;
            
            if (!dragZoom) {
                firsthandDiff = abs(lefthand.x - righthand.x);
                loddisplay.oldzoomFactor = old = loddisplay.zoomFactor;
                loddisplay.zoomStart(ID);
            }
            
            if (tabs.currentpage == 1) {
                old = loddisplay.zoomFactor;
                loddisplay.zoomFactor = loddisplay.oldzoomFactor * (100.0 / map(handDiff, 0, firsthandDiff, 0, 100));
                
                if (loddisplay.zoomFactor < 0.01 || loddisplay.zoomFactor > 1.0) {
                    loddisplay.zoomFactor = old;
                } else {
                    if (loddisplay.current_chr == -1) {
                        loddisplay.offset -= ((old * chrTotal) - (loddisplay.zoomFactor * chrTotal)) / 2.0;
                    } else {
                        loddisplay.offset -= ((old * loddisplay.maxOffset) - (loddisplay.zoomFactor * loddisplay.maxOffset)) / 2.0;
                    }
                }
            }
            
            dragZoom = true;
            righthandDown = -1;
            lefthandDown = -1;
            leftReady = false; // don't register angles while zooming
            ready = false;
            dragstart = null;
        } else if (leftangle > 100.0 && leftangle < 120.0 && dragstart == null) { // left hand in angle region
            // NOTE: using center of mass (CoM) only provides one other point to use in calculating the angle
            // for this reason, angles are larger than they otherwise would be
            if (lefthandDown == -1) {
                lefthandDown = System.currentTimeMillis();
            }
            
            if (System.currentTimeMillis() - lefthandDown > 3000) {
                ready = true;
            } else {
                ready = false;
            }
            
            if (dragZoom) {
                loddisplay.zoomEnd(ID);
            }
            
            dragZoom = false;
            zoomReady = false;
        } else if (CoM.z - lefthand.z > DEPTH_LOWER) {
            if (dragstart == null) {
                dragstart = lefthand;
                
                switch (tabs.currentpage) {
                    case 0:
                        if (lefthand.x > filebrowser.x && lefthand.x < filebrowser.x + filebrowser.cWidth && lefthand.y > filebrowser.y && lefthand.y < filebrowser.y + filebrowser.cHeight) {
                            filebrowser.panStart(ID);
                        }
                        
                        ((UIKTree)fileTree).panStart(ID);
                        break;
                    case 1:
                        loddisplay.panStart(ID);
                        break;
                }
            }
            
            lefthandDown = -1;
        } else {
            lefthandDown = -1;
            
            if (dragZoom) {
                loddisplay.zoomEnd(ID);
            }
            
            dragZoom = false;
            dragstart = null;
            leftReady = true;
            
            if (!(CoM.z - lefthand.z > DEPTH_LOWER && CoM.z - righthand.z > DEPTH_LOWER)) {
                zoomReady = true;
            }
        }
        
        // right hand has been held down
        if (!dragZoom && righthandDown != -1 && System.currentTimeMillis() - righthandDown >= 2000 && System.currentTimeMillis() - righthandDown < 2500 && ready) {
            mousePressed = retVal = pressed = true;
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
            mousePressed = retVal = pressed = true;
            mouseButton = RIGHT;
            mouseX = round(cursorPos.x);
            mouseY = round(cursorPos.y);
            
            mouseId = ID;
            
            mousePressed();
            
            leftReady = false;
            ready = true;
        }
        
        // start timer if hand distance changes less than 5.0 pixels
        if (dragZoom && phandDiff != -1.0 && CoM.z - lefthand.z > DEPTH_LOWER && abs(phandDiff - handDiff) < 10.0) {
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
            
            loddisplay.zoomEnd(ID);
        }
        
        stroke(0x00);
        strokeWeight(1);
        ellipseMode(CENTER);
        
        if (dragstart != null) {
            pushStyle();
            noStroke();
            fill(0x00);
            
            float hyp = dist(lefthand.x, lefthand.y, dragstart.x, dragstart.y);
            float angle = acos((lefthand.x - dragstart.x) / hyp);
            
            if (lefthand.y - dragstart.y < 0.0) {
                angle = TWO_PI - angle;
            }
            
            angle += HALF_PI;
            
            while (angle > TWO_PI) {
                angle = TWO_PI - angle;
            }
            
            while (angle < 0.0) {
                angle += TWO_PI;
            }
            
            if (!exiting && !kinect_showmenu) {
                switch (tabs.currentpage) {
                    case 0: // file management
                        if (lefthand.x > filebrowser.x && lefthand.x < filebrowser.x + filebrowser.cWidth && lefthand.y > filebrowser.y && lefthand.y < filebrowser.y + filebrowser.cHeight) {
                            filebrowser.pan(new PVector(lefthand.x - dragstart.x, lefthand.y - dragstart.y));
                            ((UIKTree)fileTree).pan(new PVector(lefthand.x - dragstart.x, 0));
                        } else {
                            ((UIKTree)fileTree).pan(new PVector(lefthand.x - dragstart.x, lefthand.y - dragstart.y));
                        }
                        break;
                    case 1:
                        loddisplay.pan(new PVector(1.5 * (lefthand.x - dragstart.x), lefthand.y - dragstart.y));
                        break;
                }
            }
            
            dragstart = lefthand;
            
            if (hyp < 10.0) {
                ellipse(lefthand.x, lefthand.y, 25, 25);
            } else {
                beginShape();
                
                for (PVector _p : addAngleBatch(arrow, angle)) {
                    vertex(lefthand.x + _p.x, lefthand.y + _p.y);
                }
                
                endShape(CLOSE);
                
                popStyle();
            }
        }
        
        if (lefthandDown != -1 && System.currentTimeMillis() - lefthandDown > 1000 && System.currentTimeMillis() - lefthandDown < 3000) {
            float radius = 50.0;
            
            if (righthandDown != -1 && System.currentTimeMillis() - righthandDown > 1000 && System.currentTimeMillis() - righthandDown < 2500) {
                radius = 70.0;
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
            
            arc(cursorPos.x, cursorPos.y, 50.0, 50.0, 0.0, map(System.currentTimeMillis() - righthandDown, 1000, 2000, 0.0, TWO_PI));
        }

        if (!dragZoom) {
            fill(0xFF, 0x00, 0x00, (newCoM.z - righthand.z > DEPTH_LOWER) ? 0xFF : 0x7F);
            ellipse(cursorPos.x, cursorPos.y, 30.0, 30.0);
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
            return 180 - ((180.0 / PI) * atan(abs(center.x - pt.x) / abs(center.y - pt.y)));
        } else if (pt.y > center.y) {
            return (180.0 / PI) * atan(abs(center.x - pt.x) / abs(center.y - pt.y));
        } else {
            return 90.0;
        }
    }
}
