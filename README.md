# QTL Viewer

### Standard version:

### Kinect version:

**Installation**

Requires simple-openni wrapper for Processing. See <http://code.google.com/p/simple-openni/wiki/Installation>.  

**Setup**

Stand about 10 feet from the Kinect sensor. On the right side of the screen there is a camera display; make sure that all limbs are visible. To calibrate, hold both hands at head level with shoulders and elbows making right angles.  

**Interaction**

* Use right hand to control the cursor (a red circle).
  * The cursor becomes more sensitive to movement as hand gets closer to the sensor.
  * If hand drops below the threshold of sensitivity, the cursor will become translucent.
  * To select an item, keep hand in the same position for two seconds. A blue circle will begin to wrap around the circle, activating after a full revolution. Activation will fail if the cursor is moved. After activation, the cursor will have to be moved again to allow another action.
* Use left hand to pan vertically and horizontally.
  * A black arrow will appear to indicate direction.
  * Vertical panning is used in the file browser and phenotype list to switch between pages of a folder list/file.
  * Horizontal panning is used in the phenotype selector to switch between files, and in the LOD score plot to move across when zoomed in.
  * In addition, panning quickly down in the LOD score plot will reset the pan and zoom.
* Use both hands to zoom.
  * This action is similar to using a multi-touch device: move hands together to zoom out, and apart to zoom in.
  * Keep hands in the same positions until the indication bar disappears to end zooming.
* Hold left hand at an angle to use secondary selection.
  * A green progress meter will appear, and will activate after 2.5 seconds. Move left hand out of the required angle to stop activation.
  * The cursor can be moved during activation.
  * After activation, move left hand to allow another action.

**Usage**

* File browser:
  * Select a folder to browse its contents, or a file to load it.
  * Use left hand to scroll up and down.
  * The name of the current directory is shown at the top on the right.
  * Select one of the folders in the complete path shown at the top to change directly.
* Phenotype list:
  * Select a phenotype to change its color. Select outside of the box to end color selection.
  * Use secondary selection to choose a phenotype for display.
  * Select the file name at the top to remove it from the list.
  * Use left hand to scroll vertically through pages, and horizontally through files.
* LOD score plot:
  * Zoom in with both hands, and scroll with left hand.
  * Select a chromosome to view it individually.
  * Scroll quickly down to reset pan and zoom.
* Chromosome view:
  * Select a chromosome to view its LOD plot.
* Settings page:
  * Select the +/- buttons to change the default LOD thresholds.
  * Select the centimorgans or base pairs radio options to change units.
  * Select the "Stop tracking" button to stop using the program.
  * Select the "Exit" button to be prompted for closing the program.
