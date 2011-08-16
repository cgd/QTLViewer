/**
 * QTL Viewer main module.
 *
 * This module contains methods that operate the UI, which include event handling, input prompting, etc.
 *
 * @author Braden Kell
 * @version 22 April 2011
 * @since 1.6
 */

public static final boolean ENABLE_KINECT = false; // whether or not to use Kinect
public static final boolean ENABLE_KINECT_SIMULATE = false; // simulate Kinect with the mouse

import processing.opengl.*;
import java.util.ArrayList;
import java.awt.*;
import java.awt.event.*;
import javax.swing.JColorChooser;
import org.jax.mousemap.*;
import org.jax.mousemap.MouseMap.*;
import org.jax.util.datastructure.SequenceUtilities;
import SimpleOpenNI.*;

boolean exiting = false;
boolean dragReady = true, dragging = false;
boolean kinect_showmenu = false;
boolean genesLoaded = false;
boolean hasInit = false;

int chrColumns = 7;
int unitThreshold;
int mouseId = -1;
int mouseLock = -1;

long lastFrame = 0;
long lastTime;

float menuY, menuTargetY;
float legendOffsetX = -1, legendOffsetY = -1, legendBorder = 0x00;
float legendX, legendY, legendW, legendH;
float chrTotal, maxLod = -1.0, velocity = 0.1, tabsXTarget = 335.0;
int drawWidth, drawHeight;
float[] chrLengths, chrOffsets, chrMarkerpos;

String[] chrNames;

ArrayList<Parent_File> parentFiles;
ArrayList<KinectUser> users;
Gene[] genes;

PFont legendFont;
PFont large, buttonfont = createFont("Arial", 16, true);

UITree fileTree;
UIContainer texts;
UIRadioGroup unitSelect;
UITabFolder tabs;
UIButton yes, no;
UIButton loadcfg;
UIButton quit;
LODDisplay loddisplay;
ChrDisplay chrdisplay;
UIKFileBrowser filebrowser;
UIKSpinner defUpper;
UIKSpinner defLower;
UITextInput upperDefault, lowerDefault;

MouseMap unitConverter;

SimpleOpenNI context = null;

void init() {
    super.init();
}

void start() { 
    super.start();
}

void setup() {
    // set up base UI
    if (ENABLE_KINECT) {
        size(screen.width, drawHeight = screen.height); // SimpleOpenNI is apparently not compatible with OpenGL
        drawWidth = (int)((4.0 / 3.0) * drawHeight);
    } else {
        size(drawWidth = 1600, drawHeight = 900, OPENGL); // use OPENGL for 4x anti-aliasing (looks better)
        hint(ENABLE_OPENGL_4X_SMOOTH); // enable OPENGL 4x AA
    }
  
    smooth(); // enable Processing 2x AA
    frameRate(60);
    frame.setTitle("QTL Viewer");
  
    if (!hasInit) {
        hasInit = true;
    } else {
        return;
    }
  
    // see InitUI for init* methods
    initMenuBar();
  
    initConstants();
  
    initMenu();
  
    if (ENABLE_KINECT) {
        initKinect();
  
        legendFont = createFont("Arial", 32, true);
    
        // set up exit prompt, fonts
        yes = new UIButton((drawWidth / 2.0) - 80, (drawHeight / 2.0) - 24, "Yes", 72, 48, 32, new UIAction() {
            public void doAction() {
                exit();
            }
        });
    
        no = new UIButton((drawWidth / 2.0) + 8, (drawHeight / 2.0) - 24, "No", 72, 48, 32, new UIAction() {
            public void doAction() {
                exiting = false;
            }
        });
    } else {
        legendFont = createFont("Arial", 16, true);
    
        yes = new UIButton((drawWidth / 2.0) - 40, (drawHeight / 2.0) - 24, "Yes", new UIAction() {
            public void doAction() {
                exit();
            }
        });
    
        no = new UIButton((drawWidth / 2.0) + 8, (drawHeight / 2.0) - 24, "No", new UIAction() {
            public void doAction() {
                exiting = false;
            }
        });
    }
  
    large = createFont("Arial", (ENABLE_KINECT) ? 64 : 32, true);
    textFont(large);
  
    // set up tab container
    String[] titles;
  
    if (ENABLE_KINECT) {
        titles = new String[] {
            "File management", "LOD Score view", "Chromosome view", "Settings"
        };
    } else {
        titles = new String[] {
            "LOD Score view", "Chromosome view"
        };
    }
  
    parentFiles = new ArrayList<Parent_File>(); // this ArrayList maps to the contents of fileTree
    tabs = new UITabFolder((!ENABLE_KINECT) ? 335 : 10, 30, 10, 10, titles);
  
    if (ENABLE_KINECT) {
        fileTree = new UIKTree(tabs.cWidth - 670, tabs.y + 10, 670, tabs.cHeight - 92, new UIListener() { // remove file
            public int eventHeard(int i, int j) {
                parentFiles.remove(i);
                return i;
            }
        }, new UIListener() { // remove phenotype
            public int eventHeard(int i, int j) {
                ((Parent_File)parentFiles.get(i)).remove(j);
                return j;
            }
        }) {
            public void blockEvents() {
                filebrowser.lastFrame = frameCount;
            }
        };
    
        tabs.addComponent(fileTree, 0, 0);
    } else {
        fileTree = new UITree(10, 10, 315, drawHeight - 20, new UIListener() { // remove file
            public int eventHeard(int i, int j) {
                parentFiles.remove(i);
                return i;
            }
        }, new UIListener() { // remove phenotype
            public int eventHeard(int i, int j) {
                ((Parent_File)parentFiles.get(i)).remove(j);
                return j;
            }
        });
    }
  
    initMouseWheelListener();
  
    tabs.addComponent(loddisplay = new LODDisplay((!ENABLE_KINECT) ? 400 : 65, 40, 0, 0) {
        public void update() {
            cWidth = (drawWidth - x) - 35;
            cHeight = (drawHeight - y)    - 25;
            plotHeight = cHeight - ((ENABLE_KINECT) ? 400 : 200);
            super.update();
        }
    }, (ENABLE_KINECT) ? 1 : 0, 0);
  
    if (ENABLE_KINECT) {
        loddisplay.strandHeight = 50.0;
    }
  
    tabs.addComponent(chrdisplay = new ChrDisplay((!ENABLE_KINECT) ? 360 : 25, 40, 0, 0) {
        public void update() {
            cWidth = (drawWidth - x) - 35;
            cHeight = (drawHeight - y) - 25;
            super.update();
        }
    }, (ENABLE_KINECT) ? 2 : 1, 0);
  
    if (ENABLE_KINECT) {    
        tabs.addComponent(quit = new UIButton((drawWidth / 2.0) + 8, (tabs.cHeight / 2.0) + tabs.y + 192, "Exit", 256, 128, 48, new UIAction() {
            public void doAction() {
                kinect_showmenu = false;
                exiting = true;
            }
        }), 3, 0);
  
        tabs.addComponent(defUpper = new UIKSpinner(0, 400, 48, 3.0, "Default upper threshold") {
            public void update() {
                this.x = (tabs.cWidth / 2.0) - getWidth() - 32 + tabs.x;
                upperDefault.data = str(value);
                textColor = color(0x00);
                super.update();
            }
        }, 3, 0);
  
        tabs.addComponent(defLower = new UIKSpinner(0, 558, 48, 1.5, "Default lower threshold") {
            public void update() {
                this.x = (tabs.cWidth / 2.0) - getWidth() - 32 + tabs.x;
                lowerDefault.data = str(value);
                textColor = color(0x00);
                super.update();
            }
        }, 3, 0);
    
        tabs.addComponent(unitSelect = new UIRadioGroup((tabs.cWidth / 2.0) + 32 + tabs.x, 400, 48.0, 100.0, new String[] {
            "Centimorgans", "Base pairs"
        }) {
            public void update() {
                super.textColor = color(0x00);
                super.update();
            }
        }, 3, 0);
  
        tabs.addComponent(new UIButton((tabs.cWidth / 2.0) - 264 + tabs.x, (tabs.cHeight / 2.0) + tabs.y + 192, "Stop Tracking", 256, 128, 36, new UIAction() {
            public void doAction() {
                if (!ENABLE_KINECT_SIMULATE) {
                    for (int i = 0; i < users.size(); i++) {
                        if (users.get(i).ID == mouseId) {
                            users.remove(i);
                        }
                    }
          
                    context.stopTrackingSkeleton(mouseId);
                    context.startPoseDetection("Psi", mouseId);
                }
            }
        }), 3, 0);
  
        tabs.addComponent(filebrowser = new UIKFileBrowser(tabs.x + 10, tabs.y + 10, tabs.cWidth - 720, tabs.cHeight - 20), 0, 0);
    }
  
    legendX = drawWidth - 400.0;
    legendY = 250.0;
  
    lastTime = System.currentTimeMillis();
}

void draw() {
    background(0xAA);
  
    // see module UpdateUI for update* methods
    updateViewArea();
  
    if (!ENABLE_KINECT) {
        updateMenu();
    }
  
    updateLegend();
  
    // display exit prompt, buttons if appropriate
    if (exiting) {
        noStroke();
        fill(0x00, 0x00, 0x00, 0xAA);
        rect(0, 0, drawWidth, drawHeight);
        no.focus = true;
        yes.active = true;
        no.active = true;
        no.update();
        yes.update();
        textFont(large);
        fill(0xCC);
        text("Exit?", (drawWidth - textWidth("Exit?")) / 2.0, (drawHeight / 2.0) - 32.0);
    } else {
        yes.active = false;
        yes.active = false;
        no.active = false;
    } 
  
    if (ENABLE_KINECT) {
        updateKinect();
    }
}

double map(double value, double src_low, double src_high, double dest_low, double dest_high) {
    return (((value - src_low) / (src_high - src_low)) * (dest_high - dest_low)) + dest_low;
}

