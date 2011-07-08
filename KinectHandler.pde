/**
* Contains methods for receiving input from the Kinect.
*/

void initKinect() {
    context = new SimpleOpenNI(this);
    context.enableScene(); // enable user color display
    context.enableDepth(); // enable depth map display, necessary for everything
    context.enableUser(SimpleOpenNI.SKEL_PROFILE_UPPER); // only track upper body
    
    users = new ArrayList<KinectUser>();
}

void updateKinect() {
    noCursor();
    
    context.update();
    
    float controlWidth = height * (4.0 / 3.0); // maintain source 4:3 ratio
    float imgHeight = (width - controlWidth) / (4.0 / 3.0);
    image(context.sceneImage(), controlWidth, height - imgHeight, width - controlWidth, height - imgHeight);
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
