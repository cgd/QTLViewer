/**
* Contains methods for receiving input from the Kinect.
*/

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
    if (ENABLE_KINECT_SIMULATE) {
        if (users.size() == 0) {
            KinectUser fake = new KinectUser(mouseX, mouseY);
            fake.ID = 0;
            users.add(fake);
        }
        
        users.get(0).update(new PVector(0, 0, 0), new PVector(mouseX, mouseY, 0), new PVector(0, 0,  563.16));
        
        return;
    }
    
    noCursor();
    
    context.update();

    float imgHeight = (width - drawWidth) / (4.0 / 3.0);
    image(context.sceneImage(), drawWidth, height - imgHeight, width - drawWidth, imgHeight);
    
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
        
        users.get(i).update(right, left, newCoM); // NOTICE: left and right are switched because input is NOT mirrored
    }
}

// callbacks
void onNewUser(int userId) {
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  context.startPoseDetection("Psi",userId);
}

void onLostUser(int userId) {
  println("onLostUser - userId: " + userId);
}

void onStartCalibration(int userId) {
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull) {
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
    
    if (!hasUser(userId)) {
        KinectUser newU = new KinectUser();
        newU.ID = userId;
        users.add(newU);
    }
  } else {
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId) {
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose,int userId) {
  println("onEndPose - userId: " + userId + ", pose: " + pose);
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