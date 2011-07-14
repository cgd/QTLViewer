/**
* QTL Viewer main module.
*
* This module contains methods that operate the UI, which include event handling, input prompting, etc.
*
* @author Braden Kell
* @version 22 April 2011
* @since 1.6
*/

public static final boolean ENABLE_KINECT = true; // whether or not to use Kinect
public static final boolean ENABLE_KINECT_SIMULATE = true; // simulate Kinect with the mouse

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

int chrColumns = 7;
int unitThreshold;
int mouseId = -1;

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

PFont legendFont = createFont("Arial", 16, true);
PFont large, buttonfont = createFont("Arial", 16, true);

UITree fileTree;
UIContainer texts;
UIRadioGroup unitSelect;
UITabFolder tabs;
UIButton yes, no;
UIButton loadcfg;
LODDisplay loddisplay;
ChrDisplay chrdisplay;
UIKFileBrowser filebrowser;

MouseMap unitConverter;

PGraphics icon;

SimpleOpenNI context;

void setup() {
    // set up base UI
    if (ENABLE_KINECT) {
         size(screen.width, drawHeight = screen.height); // SimpleOpenNI is apparently not compatible with OpenGL
         drawWidth = (int)((4.0 / 3.0) * drawHeight);
    } else {
        size(drawWidth = 1100, drawHeight = 700, OPENGL); // use OPENGL for 4x anti-aliasing (looks better)
        hint(ENABLE_OPENGL_4X_SMOOTH); // enable OPENGL 4x AA
    }
    
    smooth(); // enable Processing 2x AA
    frameRate(60);
    frame.setTitle("QTL Viewer");
    
    // see InitUI for init* methods
    initMenuBar();
    
    initConstants();
    
    initMenu();
    
    if (ENABLE_KINECT) {
        initKinect();
    }
    
    // set up exit prompt, fonts
    if (ENABLE_KINECT) {
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
    
    parentFiles = new ArrayList<Parent_File>(); // this ArrayList maps to the contents of fileTree
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
    
    initMouseWheelListener();
    
    // set up tab container
    String[] titles;
    
    if (ENABLE_KINECT) {
        titles = new String[] {"File Management", "LOD Score view", "Chromosome view", "Genome Browser", "User Management"};
    } else {
        titles = new String[] {"LOD Score view", "Chromosome view", "Genome Browser"};
    }
    
    tabs = new UITabFolder((!ENABLE_KINECT) ? 335 : 10, 30, 10, 10, titles);
    tabs.addComponent(loddisplay = new LODDisplay((!ENABLE_KINECT) ? 400 : 65, 40, -35, -25), (ENABLE_KINECT) ? 1 : 0, 0);
    tabs.addComponent(chrdisplay = new ChrDisplay((!ENABLE_KINECT) ? 360 : 25, 40, -35, -25), (ENABLE_KINECT) ? 2 : 1, 0);
    
    if (ENABLE_KINECT) {
        tabs.addComponent(new UIButton((drawWidth / 2.0) - 128, (drawHeight / 2.0) - 64, "Stop Tracking", 256, 128, 32, new UIAction() {
            public void doAction() {
                if (!ENABLE_KINECT_SIMULATE) {
                    context.stopTrackingSkeleton(mouseId);
                    context.startPoseDetection("Psi", mouseId);
                }
            }
        }), 4, 0);
        
        tabs.addComponent(filebrowser = new UIKFileBrowser(tabs.x + 10, tabs.y + 10, tabs.cWidth - 720, tabs.cHeight - 20), 0, 0);
    }
    
    legendX = drawWidth - 400.0;
    legendY = 250.0;
    
    lastTime = System.currentTimeMillis();
    
    int dim;
    if (System.getProperty("os.name").toLowerCase().indexOf("mac") >= 0) {
      dim = 128;
    } else if (System.getProperty("os.name").toLowerCase().indexOf("win") >= 0) {
      dim = 32;
    } else {
      dim = 64;
    }
    
    icon = createGraphics(dim, dim, JAVA2D);
    icon.beginDraw();
    icon.background(0x00, 0x55);
    icon.smooth();
    icon.textFont(createFont("Arial", dim / 2, true));
    icon.fill(0xFF, 0x00, 0x00);
    icon.text("QTL", 0, (dim / 2) + (dim / 8));
    icon.textFont(createFont("Arial", dim / 4, true));
    icon.text("VIEWER", 0, (dim / 2) + (dim / 8) + (dim / 4));
    icon.endDraw();
    frame.setIconImage(icon.image);
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

void keyPressed() { // most key events are handled by the MenuBar
    if (key == ESC) {
        exiting = !exiting;
        key = 0; // nullify the key, preventing Processing from closing automatically
    }
    
    if (exiting) {
        yes.keyAction(key, keyCode, keyEvent.getModifiersEx());
        no.keyAction(key, keyCode, keyEvent.getModifiersEx());
        return;
    } else {
        texts.keyAction(key, keyCode, keyEvent.getModifiersEx());
    }
}

void keyReleased() {
    if (! exiting && tabs.active && tabs.focus) {
        tabs.keyAction(key, keyCode, keyEvent.getModifiersEx());
    }
}

void mousePressed() {
    if (mouseX > 10 && mouseX < 95 && mouseY < menuY + drawHeight && mouseY > menuY + drawHeight - 20 && !exiting && !dragging) {
        menuTargetY = (menuY == 0.0) ? -100.0 : 0.0;
        tabs.focus = (menuY == 0.0);
    }
    
    if (!ENABLE_KINECT && !exiting && !dragging && mouseX > fileTree.x + fileTree.cWidth && mouseX < tabs.x && mouseY > fileTree.y && mouseY < drawHeight + menuTargetY && (mouseX < legendX || mouseX > legendX + legendW || mouseY < legendY || mouseY > legendY + legendH)) {
        if (tabsXTarget == 110) {
            tabsXTarget = 335;
        } else {
            tabsXTarget = 110;
        }
    } else if (exiting) {
        yes.mouseAction();
        no.mouseAction();
    } else if (mouseY < drawHeight + menuTargetY && (mouseX < legendX || mouseX > legendX + legendW || mouseY < legendY || mouseY > legendY + legendH)) {
        tabs.mouseAction();
    } else {
        texts.mouseAction();
    }
}

void mouseMoved() {
    if (!exiting && !dragging) {
        tabs.mouseAction();
        texts.mouseAction();
    } else {
        yes.mouseAction();
        no.mouseAction();
    }
}

void mouseReleased() {
    if (!exiting && !dragging) {
        tabs.mouseAction();
        texts.mouseAction();
    } else {
        yes.mouseAction();
        no.mouseAction();
    }
}

    /*JFileChooser fd = new JFileChooser();
    fd.setFileSelectionMode(JFileChooser.FILES_ONLY);
    fd.setMultiSelectionEnabled(false);
    fd.setDialogTitle("Select .lod.csv file");
    if (fd.showOpenDialog(null) == JFileChooser.APPROVE_OPTION && fd.getCurrentDirectory() != null && fd.getSelectedFile() != null) {*/
        /*if (path.toLowerCase().endsWith(".chr.csv"))
            path = path.substring(0, path.length() - 8) + ".lod.csv";*/
    //path = fd.getCurrentDirectory().toString() + fd.getSelectedFile().toString();
/**
* This method prompts the user to select a file for loading.
*
* The openFile method _only_ prompts the user for a file, it does not handle any I/O. This is done by the loadFile method.
* It is also important to note that due to some issues with Processing, neither selectInput nor selectFolder work on all setups. My AWT solution should work.
*/
void openFile() {
  
    String path;    
    // <OPTION 1> (works on my laptop):
    FileDialog fd = new FileDialog((Frame)null, "Select .lod.csv file...", FileDialog.LOAD); // annoying work-around; selectInput was hanging
    fd.setVisible(true); // http://code.google.com/p/processing/issues/detail?id=445
    path = fd.getDirectory() + fd.getFile();
    if (fd.getDirectory() != null && fd.getFile() != null) {// ^^ details
        loadFile(path);
    }
    // </OPTION 1>
    
    // <OPTION 2> (works on lab desktop):
    //if ((path = selectInput("Select .lod.csv file...")) != null) {
    // </OPTION 2>
    
}

/**
* This method loads the given file, parses it and any associated files, and prepares the UI for display.
*
* loadFile may load twice as many additional files as the number of phenotypes represented by the main table. It can be called by either openFile or loadFolder.
*
* @param path a String representing the path of the main LOD data file
*/
void loadFile(String path) {
  
    if (path.split("/").length < 1) {
        return;
    }
    
    String pathName = path.split("/")[path.split("/").length - 1];
    String modifiedPath = getModifiedPath(path);
    
    fileTree.add(new UITreeNode(pathName, true));
    Parent_File parent = new Parent_File(pathName);
    float autoLower = 1.5, autoUpper = 3.0;
    
    try {
        autoLower = float(((UITextInput)texts.get(0)).getText());
        autoUpper = float(((UITextInput)texts.get(1)).getText());
    } catch (Exception error) {
        error.printStackTrace();
    }
    
    try {
        FileReader fr = new FileReader(path);
        String[][] data = readCSV(fr);
        fr.close();
        String[] names = new String[0];
        HashMap<String, float[][]> chrData = new HashMap<String, float[][]>();
        ArrayList<HashMap<String, float[]>> thresholdData = new ArrayList<HashMap<String, float[]>>();
        String[][] csvPeaks = new String[0][0], csvThresh = new String[0][0];
        int alphaCol = -1;
        
        if (new File(modifiedPath + ".peaks.txt").exists()) {
            FileReader peaksFileReader = new FileReader(modifiedPath + ".peaks.txt");
            chrData = readPeaks(peaksFileReader);
            peaksFileReader.close();
            Iterator it = chrData.keySet().iterator();
            
            while (it.hasNext()) {
                names = (String[])append(names, it.next());
            }
        } else if (new File(modifiedPath + ".peaks.csv").exists()) {
            InputStreamReader csvFile = new InputStreamReader(new FileInputStream(modifiedPath + ".peaks.csv"));
            csvPeaks = readCSV(csvFile);
            csvFile.close();
        }
        
        if (new File(modifiedPath + ".thresh.txt").exists()) {
            FileReader threshFileReader = new FileReader(modifiedPath + ".thresh.txt");
            thresholdData = getThresholdData(threshFileReader, names, parent);
            threshFileReader.close();
        } else if (new File(modifiedPath + ".thresh.csv").exists()) {
            FileReader threshCSVReader = new FileReader(modifiedPath + ".thresh.csv");
            int[] alphaArray = new int[1];
            csvThresh = getThresholdData(threshCSVReader, parent, names, alphaArray);
            alphaCol = alphaArray[0];
            threshCSVReader.close();
        }
        
        if (names.length == 0 && new File(modifiedPath + ".thresh.txt").exists()) {
            for (int i = 3; i < data[0].length; i++) {
                names = (String[])append(names, data[0][i].trim());
            }
            
            FileReader threshFileReader = new FileReader(modifiedPath + ".thresh.txt");
            thresholdData = getThresholdData(threshFileReader, names, parent);
            threshFileReader.close();
        }
        
        for (int i = 3; i < data[0].length; i++) {
            ((UITreeNode)fileTree.last()).add(new UITreeNode(data[0][i].trim()));
            Phenotype currentPhenotype = new Phenotype(data[0][i]);
            
            boolean useBP = false;
            
            if (float(data[1][2]) > unitThreshold) { // cM should be less than this, bP _should_ be more
                useBP = true;
            }
                
            
            // load LOD scores
            for (int j = 1; j < data.length; j++) {
                if (data[j].length-1 >= i) {
                    currentPhenotype.lodscores = append(currentPhenotype.lodscores, float(data[j][i]));
                    int posChr = getChr(data[j][1]);
                    
                    if (useBP) {
                        currentPhenotype.position = append(currentPhenotype.position, (float)unitConverter.basePairsToCentimorgans(posChr, (long)Double.parseDouble(data[j][2])));
                    } else {
                        currentPhenotype.position = append(currentPhenotype.position, float(data[j][2]));
                    }
                    
                    currentPhenotype.chromosome = append(currentPhenotype.chromosome, posChr);
                }
            }
            
            // load threshold information
            if (new File(modifiedPath + ".thresh.txt").exists() && !parent.useModelThresholds) {
                if (! addThresholdData(currentPhenotype, thresholdData)) {
                    currentPhenotype.thresholds = new float[][] { { autoLower, autoUpper } };
                    currentPhenotype.useDefaults = true;
                    currentPhenotype.useXDefaults = true;
                }
            } else if (new File(modifiedPath + ".thresh.csv").exists() && !parent.useModelThresholds) {
                if (! addThresholdData(currentPhenotype, csvThresh, alphaCol)) {
                    currentPhenotype.thresholds = new float[][] { { autoLower, autoUpper } };
                    currentPhenotype.useDefaults = true;
                    currentPhenotype.useXDefaults = true;
                }
            } else if (new File(modifiedPath + "_" + currentPhenotype.name + ".sum.csv").exists()) {
                FileReader sumFile = new FileReader(modifiedPath + "_" + currentPhenotype.name + ".sum.csv");
                if (! addThreshCSVFile(currentPhenotype, sumFile)) {
                    currentPhenotype.thresholds = new float[][] { { autoLower, autoUpper } };
                    currentPhenotype.useDefaults = true;
                    currentPhenotype.useXDefaults = true;
                }
                sumFile.close();
            }
            
            // load peak information
            if (new File(modifiedPath + ".peaks.txt").exists()) {
                addPeakData(currentPhenotype, chrData.get(currentPhenotype.name));  
            } else if (new File(modifiedPath + ".peaks.csv").exists()) {
                addPeakData(currentPhenotype, csvPeaks);
            } else if (new File(modifiedPath + "_" + currentPhenotype.name + ".chr.csv").exists()) {
                FileReader peakCSVReader = new FileReader(modifiedPath + "_" + currentPhenotype.name + ".chr.csv");
                addPeakCSVFile(currentPhenotype, peakCSVReader);
                peakCSVReader.close();
            }
            
            parent.add(currentPhenotype);
        }
        
        parentFiles.add(parent);
    } catch (Exception error) {
        fileTree.remove(fileTree.size() - 1);
        error.printStackTrace();
    }
    
    parent.update();
    
}

/**
* This method prompts the user to select a folder for loading.
*
* Besides prompting for a folder, this method looks for LOD files in the folder root and executes loadFile on each one.
* It is also important to note that due to some issues with Processing, neither selectInput nor selectFolder work on all setups. My AWT solution should work.
*/
void loadFolder() {
  
    /*selectFolder();*/
    // ^^ same issue as with selectInput
    FileDialog folderPrompt = new FileDialog((Frame)null, "Select folder...", FileDialog.LOAD);
    System.setProperty("apple.awt.fileDialogForDirectories", "true"); // how would anyone ever know to do this??
    folderPrompt.setVisible(true);
    System.setProperty("apple.awt.fileDialogForDirectories", "false");
    
    if (folderPrompt.getDirectory() != null && folderPrompt.getFile() != null && new File(folderPrompt.getDirectory() + folderPrompt.getFile()).isDirectory()) {
        for (String path : new File(folderPrompt.getDirectory() + folderPrompt.getFile()).list()) {
            if (path.toLowerCase().endsWith(".lod.csv") && !(new File(folderPrompt.getDirectory() + folderPrompt.getFile() + "/" + path).isDirectory())) {
                loadFile(folderPrompt.getDirectory() + folderPrompt.getFile() + "/" + path);
            }
        }
    }
                
}

/**
* This method is used to determine the layout of the UI based on buttons.
*
* @param text the text contents of the button
* @return the floating-point width of the button
*/
float getButtonWidth(String text) {
  
    textFont(buttonfont);
    return textWidth(text) + 8.0;
    
}

/**
* This method loads a configuration file in the Java Properties (java.util.Properties) format.
* The key "chromosome_list" contains a comma-separated list of chromosome numbers
* The other keys are:
*   chromosome_c -- name
*   chromosome_c_length -- length in cM or bp
*   chromosome_c_centromere -- position of the centromere in cM or bp
* where c is a chromosome number
*/
void loadConfig() {
    FileDialog fd = new FileDialog((Frame)null, "Select config file...", FileDialog.LOAD);
    fd.setVisible(true);
    if (fd.getDirectory() != null && fd.getFile() != null) {
        try {
            FileInputStream inputConfig = new FileInputStream(fd.getDirectory() + fd.getFile());
            
            Properties configFile = new Properties();
            configFile.load(inputConfig);
            String[] chrNumbers = ((String)configFile.get("chromosome_list")).split(",");
            
            // prepare arrays to be loaded with new data
            chrLengths = new float[0];
            chrNames = new String[0];
            chrMarkerpos = new float[0];
            chrOffsets = new float[0];
            chrTotal = 0.0;

            // update the arrays
            for (String number : chrNumbers) {
                chrNames = append(chrNames, (String)configFile.get("chromosome_" + number.trim()));
                String newLength = (String)configFile.get("chromosome_" + number.trim() + "_length");
                String newPos = (String)configFile.get("chromosome_" + number.trim() + "_centromere");
                
                if (float(newLength) > unitThreshold) {
                    chrLengths = append(chrLengths, (float)unitConverter.basePairsToCentimorgans(int(number.trim()), Long.parseLong(newLength)));
                } else {
                    chrLengths = append(chrLengths, float(newLength));
                }
                
                if (float(newPos) > unitThreshold) {
                    chrMarkerpos = append(chrMarkerpos, (float)unitConverter.basePairsToCentimorgans(int(number.trim()), Long.parseLong(newPos)));
                } else {
                    chrMarkerpos = append(chrMarkerpos, float(newPos)); 
                }
            }
            
            chrOffsets = new float[chrLengths.length];
            chrTotal = chrLengths[0];
            
            // recalculate the offsets and total length (see initConstants in the InitUI module)
            for (int i = 1; i < chrLengths.length; i++) {
                chrOffsets[i] = chrOffsets[i-1] + chrLengths[i-1];
                chrTotal += chrLengths[i];
            }

            inputConfig.close();
        } catch (Exception error) {
            initConstants(); // reload the old settings if the above fails
            error.printStackTrace();
        }
    }
}

/**
* This method is used to get a chromosome's order given its human-readable form.
*
* Consider the following example (for a mouse chromosome): getChr("X") == 20
*
* @param stringChr the human-readable name for a chromosome
* @return the order of the chromosome
*/
int getChr(String stringChr) {
  
    int chr = 1;
    try {
        chr = Integer.parseInt(stringChr);
    } catch (NumberFormatException error) {
        for (int i = 0; i < chrNames.length; i++)
            if (chrNames[i].equals(stringChr)) {
                chr = i+1;
                break;
            }
    }
    return chr;
    
}

boolean mouseInRect(float x1, float y1, float x2, float y2) {
    for (int i = 0; i < users.size(); i++) {
        PVector mouse = users.get(i).cursorPos;
        if (mouse.x > x1 && mouse.x < x2 && mouse.y > y1 && mouse.y < y2) {
            return true;
        }
    }
    
    return false;
}

boolean mousePressedInRect(float x1, float y1, float x2, float y2) {
    for (int i = 0; i < users.size(); i++) {
        PVector mouse = users.get(i).cursorPos;
        if (mouse.x > x1 && mouse.x < x2 && mouse.y > y1 && mouse.y < y2 && users.get(i).pressed) {
            return true;
        }
    }
    
    return false;
}

PVector addAngle(PVector p, float angle) {
    PVector newp = new PVector();
    
    float a = atan(-p.y / p.x);
    
    if (p.x < 0.0) {
        a = PI + a;
    } else if (a < 0.0) {
        a = TWO_PI + a;
    } else if (a == -0.0) {
        a = 0.0;
    }
    
    a += angle;
    
    while (a > TWO_PI) {
        a -= TWO_PI;
    }
    
    while (a < 0.0) {
        a += TWO_PI;
    }
    
    float m = dist(0, 0, p.x, p.y);
    
    newp.x = cos(a) * m;
    newp.y = -sin(a) * m;
    
    return newp;
}

PVector[] addAngleBatch(PVector[] p, float angle) {
    PVector[] ret = new PVector[p.length];
    
    for (int i = 0; i < p.length; i++) {
        ret[i] = addAngle(p[i], angle);
    }
    
    return ret;
}
