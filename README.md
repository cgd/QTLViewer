# QTL Viewer

### Standard version:

**Usage**

Click a tab to change to that page.

* File manager:
  * Go to File>Open to load a file or folder. The file(s) will appear in the side bar as a header with a list of phenotypes.
  * To activate a phenotype, check the square to the left of the label.
  * To change the color of a phenotype, click the colored rectangle to the left of the label. A color selection box will appear.
  * To show or hide a file's contents, click the appropriate symbol to the left of the file name.
  * To remove a file or phenotype from the list, click the "X" symbol to the right of the name. The "X" will not appear until the cursor is over the name.
  * To hide the file manager bar, click anywhere between it and the tab pages.
* LOD score plot:
  * Zoom in/out or reset with the appropriate options under the View menu option, or by holding command/control and scrolling the mouse wheel.
  * Scroll through the graph with the mouse wheel, or by clicking and dragging.
  * View an individual chromosome by clicking it.
  * Return to the genome-wide view with View>Show All, or by scrolling the mouse wheel quickly up.
  * Switch to the next or previous chromosome with the View menu.
* Chromosome view:
  * Click a chromosome to view it in the LOD score plot.
* Menu:
  * Click the menu tab at the bottom of the screen or use the View options to show/hide the menu.
  * Use the text boxes to change the default LOD thresholds.
  * Use the centimorgans and base pairs radio options to change the units.
  * Click the "Load config" button or use the File menu options to load a new configuration file.

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

Select a tab to change to that page.

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

### How to switch versions:

Change the boolean field **ENABLE_KINECT** on line 11 to _true_ for Kinect interaction, or _false_ for the regular application.
