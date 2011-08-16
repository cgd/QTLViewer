/*
* Copyright (c) 2010 The Jackson Laboratory
*
* This software was developed by Matt Hibbs's Lab at The Jackson
* Laboratory (see http://cbfg.jax.org/).
*
* This is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

/**
* Contains methods for receiving input from the Kinect.
*/

PVector leftHand = new PVector(0, 0, 565);
PFont alert = createFont("Arial", 32, true);
float imgHeight;
long alertTime = -1;
String alertText = "";

void initKinect() {
    users = new ArrayList<KinectUser>();
    
    if (ENABLE_KINECT_SIMULATE) {
        return;
    }
    
    context = new SimpleOpenNI(this);
    context.enableScene(); // enable user color display
    context.enableDepth(); // enable depth map display, necessary for everything
    context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL); // track full body
}

void updateKinect() {
    noCursor();
    
    if (ENABLE_KINECT_SIMULATE) {
        if (users.size() == 0) {
            KinectUser fake = new KinectUser(mouseX, mouseY);
            fake.ID = 0;
            users.add(fake);
        }
        
        if (keyPressed && key == CODED && keyCode == LEFT) {
            leftHand.x -= 5;
        } else if (keyPressed && key == CODED && keyCode == RIGHT) {
            leftHand.x += 5;
        } else if (keyPressed && key == CODED && keyCode == UP) {
            leftHand.y -= 5;
        } else if (keyPressed && key == CODED && keyCode == DOWN) {
            leftHand.y += 5;
        } else if (keyPressed && key == 'w') {
            leftHand.z = 0;
        } else if (keyPressed && key == 's') {
            leftHand.z = 565;
        }
        
        stroke(0x00);
        strokeWeight(1);
        fill(0xFF, 0x00, 0x00);
        ellipseMode(CENTER);
        //ellipse(leftHand.x, leftHand.y, 20.0, 20.0);
        mousePressed = users.get(0).update(leftHand, new PVector(mouseX, mouseY, 0), new PVector(width / 2.0, height / 2.0,  284.2105));
        
        return;
    }
    
    if (context == null || context.sceneImage() == null) {
        return;
    }

    context.update();

    imgHeight = (width - drawWidth) / (4.0 / 3.0);
    image(context.sceneImage(), drawWidth, height - imgHeight, width - drawWidth, imgHeight);
    
    boolean isAnyPressed = false;
    
    for (int i = 0; i < users.size(); i++) {
        PVector _right = new PVector(), right = new PVector();
        PVector _left = new PVector(), left = new PVector();
        PVector _newCoM = new PVector(), newCoM = new PVector();
        
        context.getJointPositionSkeleton(users.get(i).ID, SimpleOpenNI.SKEL_RIGHT_HAND, _right);
        context.getJointPositionSkeleton(users.get(i).ID, SimpleOpenNI.SKEL_LEFT_HAND, _left);
        context.getCoM(users.get(i).ID, _newCoM);
        
        context.convertRealWorldToProjective(_right, right);
        context.convertRealWorldToProjective(_left, left);
        context.convertRealWorldToProjective(_newCoM, newCoM);
        
        right.x = drawWidth - map(right.x, 0, 640, 0, drawWidth) - (width - drawWidth);
        right.y = map(right.y, 0, 480, 0, drawHeight);
        
        left.x = drawWidth - map(left.x, 0, 640, 0, drawWidth) - (width - drawWidth);
        left.y = map(left.y, 0, 640, 0, drawWidth);
        
        newCoM.x = drawWidth - map(newCoM.x, 0, 640, 0, drawWidth) - (width - drawWidth);
        newCoM.y = map(newCoM.y, 0, 640, 0, drawWidth);
        
        if (users.get(i).update(right, left, newCoM)) { // NOTICE: left and right are switched because input is NOT mirrored
            isAnyPressed = true;
        }
    }
    
    textFont(alert);
    fill(0x00);
    
    text(alertText, drawWidth + 4, height - imgHeight - 4);
    
    mousePressed = isAnyPressed;
    
    if (alertTime != -1 && System.currentTimeMillis() - alertTime > 3000) {
        alertText = "";
        alertTime = -1;
    }
}

// callbacks
void onNewUser(int userId) {
    alertText = "New user " + userId;
    
    context.startPoseDetection("Psi",userId);
}

void onLostUser(int userId) {
    alertTime = System.currentTimeMillis();
    
    alertText = "Lost user " + userId;
    
    for (int i = 0; i < users.size(); i++) {
        if (users.get(i).ID == userId) {
            users.remove(i);
            break;
        }
    }
}

void onStartCalibration(int userId) {
}

void onEndCalibration(int userId, boolean successfull) {
    if (successfull) {
        alertTime = System.currentTimeMillis();
        
        alertText = "Calibrated user " + userId;
        
        context.startTrackingSkeleton(userId);
        
        if (!hasUser(userId)) {
            KinectUser newU = new KinectUser();
            newU.ID = userId;
            users.add(newU);
        }
    } else {
        alertTime = System.currentTimeMillis();
        
        alertText = "Failed to calibrate user " + userId;
        
        context.startPoseDetection("Psi",userId);
    }
}

void onStartPose(String pose,int userId) {
    alertTime = System.currentTimeMillis();
    
    alertText = "Calibrating user " + userId + "...";
    
    context.stopPoseDetection(userId); 
    context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose,int userId) {

}

boolean hasUser(int userId) {
    for (int i = 0; i < users.size(); i++) {
        if (users.get(i).ID == userId) {
            return true;
        }
    }
    
    return false;
}

KinectUser getUser(int userId) {
    for (int i = 0; i < users.size(); i++) {
        if (users.get(i).ID == userId) {
            return users.get(i);
        }
    }
    
    return null;
}

PVector addAngle(PVector p, float angle) {
  PVector newp = new PVector();

  float a = realTan(p);

  a += angle;

  while (a > TWO_PI) {
    a -= TWO_PI;
  }

  while (a < 0.0) {
    a += TWO_PI;
  }

  float m = dist(0, 0, p.x, p.y);

  newp.x = cos(a) * m;
  newp.y = sin(a) * m;

  return newp;
}

PVector[] addAngleBatch(PVector[] p, float angle) {
  PVector[] ret = new PVector[p.length];

  for (int i = 0; i < p.length; i++) {
    ret[i] = addAngle(p[i], angle);
  }

  return ret;
}

float realTan(PVector p) {
  float a = atan(p.y / p.x);

  if (p.y == 0.0) {
    if (p.x > 0.0) {
      a = 0;
    } 
    else if (p.x < 0.0) {
      a += PI;
    }
  } 
  else if (p.x < 0.0 && p.y > 0.0) {
    a += PI;
  } 
  else if (p.x > 0.0 && p.y < 0.0) {
    a = TWO_PI + a;
  } 
  else if (p.x < 0.0 && p.y < 0.0) {
    a += PI;
  }

  while (a > TWO_PI) {
    a -= TWO_PI;
  }

  while (a < 0.0) {
    a += TWO_PI;
  }

  return a;
}
