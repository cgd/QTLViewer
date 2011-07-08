/**
* Contains methods for receiving input from the Kinect.
*/

void initKinect() {
    context = new SimpleOpenNI(this);
    context.enableScene(); // enable user color display
    context.enableDepth(); // enable depth map display, necessary for everything
    context.enableUser(SimpleOpenNI.SKEL_PROFILE_UPPER); // only track upper body
}

void updateKinect() {
    noCursor();
    
    context.update();
}
