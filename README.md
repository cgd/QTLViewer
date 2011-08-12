# QTL Viewer

### Standard version:

### Kinect version:

**Installation**

Requires simple-openni wrapper for Processing. See <http://code.google.com/p/simple-openni/wiki/Installation>.  

**Setup**

Stand about 10 feet from the Kinect sensor. On the right side of the screen there is a camera display; make sure that your limbs are visible. To calibrate, hold both hands at head level with shoulders and elbows making right angles.  

**Interaction**

* Use your right hand to control the cursor (a red circle).
  * The cursor becomes more sensitive to movement as your hand gets further from your body.
  * If your hand drops below the threshold of sensitivity, the cursor will become translucent.
  * To select an item, keep your hand in the same position for two seconds. A blue circle will begin to wrap around the circle, activating after a full revolution. Activation will fail if the cursor is moved. After activation, the cursor will have to be moved again to allow another action.
* Use your left hand to pan vertically and horizontally.
  * A black arrow will appear to indicate direction.
  * Vertical panning is used in the file browser to switch between pages in directories with many files.
  * Horizontal panning is used in the phenotype selector to switch between files, and in the LOD score plot to move across when zoomed in.
  * In addition, panning quickly down in the LOD score plot will reset the pan and zoom.
* Use both hands to zoom.
  * This action is similar to using a multi-touch device: move hands together to zoom out, and apart to zoom in.
  * Keep your hands in the same positions until the indication bar disappears to end zooming.
* Hold your left hand at an angle to use secondary selection.
  * A green progress meter will appear, and will activate after 2.5 seconds. Move your left hand out of the required angle to stop activation.
  * The cursor can be moved during the activation progress.
  * After activation, move your left hand to allow another action.
