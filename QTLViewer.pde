/**
* QTL Viewer main module.
*
* This module contains methods that operate the UI, which include event handling, input prompting, etc.
*
* @author Braden Kell
* @version 22 April 2011
* @since 1.6
*/

import processing.opengl.*;
import java.util.ArrayList;
import java.awt.*;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.JColorChooser;

boolean exiting = false;
double menuY, menuTargetY;
p_button yes, no;
PFont large, buttonfont = createFont("Arial", 16, true);
p_tree fileTree;
ArrayList<Parent_File> parentFiles;
float[] chrLengths, chrOffsets, chrMarkerpos;
String[] chrNames;
float chrTotal, maxLod = -1.0, velocity = 0.1, tabsXTarget = 335.0;
p_container texts;
p_radiogroup unitSelect;
p_tabfolder tabs;
p_button loadcfg;
LODDisplay loddisplay;
int chrColumns = 7;

void setup() {
    // set up base UI
    size(1100, 700, OPENGL); // use OPENGL for 4x anti-aliasing (looks better)
    smooth(); // enable Processing 2x AA
    hint(ENABLE_OPENGL_4X_SMOOTH); // enable OPENGL 4x AA
    frameRate(60);
    frame.setTitle("QTL Viewer");
    
    String[] titles = {"LOD Score view", "Chromosome view"};
    tabs = new p_tabfolder(335, 30, 10, 10, titles);
    
    // init menu bar, sub menus, menu items, etc.
    MenuBar menu = new MenuBar();
    
    Menu fileMenu = new Menu("File");
    MenuItem openFileItem = new MenuItem("Open File...", new MenuShortcut(KeyEvent.VK_O));
    // action handling callbacks using anonymous inner classes
    openFileItem.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            openFile();
        }
    });
    MenuItem openFolderItem = new MenuItem("Open Folder...", new MenuShortcut(KeyEvent.VK_O, true));
    openFolderItem.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            loadFolder();
        }
    });
    MenuItem loadConfigItem = new MenuItem("Load config...", new MenuShortcut(KeyEvent.VK_E));
    loadConfigItem.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if(exiting) return;
            loadConfig();
        }
    });
    
    fileMenu.add(openFileItem);
    fileMenu.add(openFolderItem);
    fileMenu.add(new MenuItem("-"));
    fileMenu.add(loadConfigItem);
    
    Menu viewMenu = new Menu("View");
    MenuItem menuup = new MenuItem("Show Menu", new MenuShortcut(KeyEvent.VK_UP, true));
    menuup.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            menuTargetY = -100.0;
        }
    });
    MenuItem menudown = new MenuItem("Hide Menu", new MenuShortcut(KeyEvent.VK_DOWN, true));
    menudown.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            menuTargetY = 0.0;
        }
    });
    MenuItem nextchr = new MenuItem("Next Chromosome", new MenuShortcut(KeyEvent.VK_PERIOD));
    nextchr.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            loddisplay.nextChr();
        }
    });
    MenuItem prevchr = new MenuItem("Previous Chromosome", new MenuShortcut(KeyEvent.VK_COMMA));
    prevchr.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            loddisplay.prevChr();
        }
    });
    MenuItem showall = new MenuItem("Show All", new MenuShortcut(KeyEvent.VK_BACK_SPACE));
    showall.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            loddisplay.allChr();
        }
    });
    
    viewMenu.add(menuup);
    viewMenu.add(menudown);
    viewMenu.add(new MenuItem("-"));
    viewMenu.add(nextchr);
    viewMenu.add(prevchr);
    viewMenu.add(showall);
    
    menu.add(fileMenu);
    menu.add(viewMenu);
    frame.setMenuBar(menu);
    
    //frame.setResizable(true);
    
    // init chr position information, all stored as centimorgans
    chrLengths = new float[20];
    chrNames = new String[chrLengths.length]; // human-readable representations of chromosomes (e.g. "X"->chr 20)
    chrOffsets = new float[chrLengths.length]; // chromosome offset from beginning of genome
    chrMarkerpos = new float[chrLengths.length]; // marker positions, used in chromsome display
    chrLengths[0] = 112.0;
    chrLengths[1] = 114.0;
    chrLengths[2] = 95.0;
    chrLengths[3] = 84.0;
    chrLengths[4] = 92.0;
    chrLengths[5] = 75.0;
    chrLengths[6] = 74.0;
    chrLengths[7] = 82.0;
    chrLengths[8] = 79.0;
    chrLengths[9] = 82.0;
    chrLengths[10] = 104.0;
    chrLengths[11] = 66.0;
    chrLengths[12] = 80.0;
    chrLengths[13] = 69.0;
    chrLengths[14] = 74.6;
    chrLengths[15] = 72.0;
    chrLengths[16] = 58.0;
    chrLengths[17] = 59.0;
    chrLengths[18] = 57.0;
    chrLengths[19] = 79.44;
    chrOffsets[0] = chrMarkerpos[0] = 0.0;
    chrTotal = chrLengths[0];
    
    for (int i = 1; i < chrLengths.length; i++) {
        chrNames[i-1] = str(i);
        chrOffsets[i] = chrOffsets[i-1] + chrLengths[i-1];
        chrTotal += chrLengths[i];
        chrMarkerpos[i] = 0.0;
    }
    
    chrNames[chrLengths.length-1] = "X";
    
    // set up menu
    p_textinput upperDefault, lowerDefault;
    upperDefault = new p_textinput(14, 0, 200, 50, "Default upper threshold");
    upperDefault.setText("3.0");
    lowerDefault = new p_textinput(14, 0, 200, 50, "Default lower threshold");
    lowerDefault.setText("1.5");
    
    String[] groupNames = {"Centimorgans", "Base pairs"};
    unitSelect = new p_radiogroup(275, height, groupNames);
    
    loadcfg = new p_button(425, height, "Load config", new p_action() {
        public void doAction() {
            loadConfig();
        }
    });
    
    texts = new p_container();
    texts.add(lowerDefault);
    texts.add(upperDefault);
    
    menuY = menuTargetY = 0.0;
    
    // set up exit prompt, fonts
    yes = new p_button((width/2.0)-40, (height/2.0)-24, "Yes", new p_action() {
        public void doAction() { exit(); }
    });
    no = new p_button((width/2.0)+8, (height/2.0)-24, "No", new p_action() { public void doAction() { exiting = false; } } );
    large = createFont("Arial", 32, true);
    textFont(large, 32);
    
    parentFiles = new ArrayList<Parent_File>(); // this ArrayList maps to the contents of fileTree
    fileTree = new p_tree(10, 10, 315, height-20, new p_listener() { // remove file
        public int eventHeard(int i, int j) {
            parentFiles.remove(i);
            return i;
        }
    }, new p_listener() { // remove phenotype
        public int eventHeard(int i, int j) {
            ((Parent_File)parentFiles.get(i)).remove(j);
            return j;
        }
    });
    
    tabs.addComponent(loddisplay = new LODDisplay(400, 40, -35, -25), 0, 0);
    tabs.addComponent(new ChrDisplay(360, 40, -35, -25), 1, 0);
}

void draw() {
    background(0xAA);
    double dif;
    
    // expand/contract fileTree view area
    if (Math.abs(tabs.x - tabsXTarget) < 0.1) tabs.x = tabsXTarget;
    fileTree.w -= (tabs.x - tabsXTarget) * velocity;
    tabs.x -= (tabs.x - tabsXTarget) * velocity;
    ((LODDisplay)tabs.get(0).get(0)).x = tabs.x + 65;
    ((LODDisplay)tabs.get(0).get(0)).w = -35;
    ((ChrDisplay)tabs.get(1).get(0)).x = tabs.x + 25;
    ((ChrDisplay)tabs.get(1).get(0)).w = -35;
    if (tabs.x != tabsXTarget) ((ChrDisplay)tabs.get(1).get(0)).update = true; // update the ChrDisplay if its width has changed
    
    // draw triangle for view select
    fill(0x55);
    if (!exiting && mouseX > fileTree.x + fileTree.w && mouseX < tabs.x && mouseY > fileTree.y && mouseY < height + menuTargetY) {
        fill(0x00);
    }
    
    noStroke();
    pushMatrix();
    translate((float)tabs.x - 6, height / 2.0);
    rotate(PI * (float)((tabs.x - 110.0) / (335.0 - 110.0)));
    beginShape();
    vertex(3.0, 0);
    vertex(-3.0, -(3.0 / cos(PI / 6.0)));
    vertex(-3.0, (3.0 / cos(PI / 6.0)));
    endShape();
    popMatrix();
    
    // update focus, activity settings based on whether or not the user is being prompted for exit
    tabs.setFocus(!exiting);
    tabs.setActive(!exiting);
    tabs.update();
    fileTree.setFocus(!exiting);
    fileTree.setActive(!exiting);
    fileTree.update();
    
    // draw the menu, set focus/activity based on whether or not the menu is shown
    stroke(0xCC);
    fill(0x00, 0x00, 0x00, 0xAA);
    pushMatrix();
    
    if (menuTargetY == -100.0) { // menu is shown
        texts.setActive(!exiting);
        texts.setFocus(!exiting);
        unitSelect.setActive(!exiting);
        unitSelect.setFocus(!exiting);
        loadcfg.setFocus(!exiting);
        loadcfg.setActive(!exiting);
        //upperDefault.setActive(true);
        //lowerDefault.setActive(true);
    } else { // menu is hidden
        texts.setActive(false);
        texts.setFocus(false);
        unitSelect.setActive(false);
        unitSelect.setFocus(false);
        loadcfg.setFocus(false);
        loadcfg.setActive(false);
        //upperDefault.setActive(false);
        //lowerDefault.setActive(false);
    }
    
    translate(0.0, (float)menuY, 0);
    menuY += (menuTargetY - menuY) * velocity; // this moves the menu up or down in a non-linear way
    if (abs((float)(menuTargetY - menuY)) < 0.25)
        menuY = menuTargetY;

    // draw the menu outline, taking cues from the sine function
    beginShape();
    for (int i = 0; i < 20; i+=2)
        vertex(i+10, (-sin((i*HALF_PI)/20.0)*20.0)+height);
    vertex(75, height-20);
    for (int i = 20; i >= 0; i -= 2)
        vertex(95-i, (-sin((abs(i)*HALF_PI)/20.0)*20.0)+height);
    vertex(width-10, height);
    vertex(width-10, height+100);
    vertex(10, height+100);
    vertex(10, height);
    endShape();
    
    // update, draw menu components
    fill(0xFF);
    popMatrix();
    //upperDefault.setY((height+menuY)+10);
    //lowerDefault.setY((height+menuY)+36);
    ((p_component)texts.get(0)).setY((height+menuY)+10);
    ((p_component)texts.get(1)).setY((height+menuY)+36);
    unitSelect.setY(height+menuY+10);
    loadcfg.setY(height+menuY+10);
    //upperDefault.update();
    //lowerDefault.update();
    texts.update();
    unitSelect.update();
    loadcfg.update();
    //text((error.length() > 0) ? "Error: " + error : "", 35, (height+(float)menuY)+32);
    
    // display exit prompt, buttons if appropriate
    if (exiting) {
        noStroke();
        fill(0x00, 0x00, 0x00, 0xAA);
        rect(0, 0, width, height);
        no.setFocus(true);
        yes.setActive(true);
        no.setActive(true);
        no.update();
        yes.update();
        textFont(large);
        fill(0xCC);
        text("Exit?", (width/2.0)-textWidth("Exit?")/2.0, (height/2.0)-32.0);
    } else {
        yes.setFocus(false);
        yes.setActive(false);
        no.setActive(false);
    }
    //folder.setFocus(menuY > -2.5 && !exiting && mouseY < height+menuY);
    //folder.setActive(menuY > -2.5 && !exiting && mouseY < height+menuY);
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
    }/* else if (key == CODED && keyCode == RIGHT && keyEvent.getModifiersEx() == 0)
        folder.nextPage();
    else if (key == CODED && keyCode == LEFT && keyEvent.getModifiersEx() == 0)
        folder.prevPage();
    else if (key == CODED && keyCode == DOWN && keyEvent.getModifiersEx() == 0) {
        if (menuY > -5.0) folder.zoomOut();
        else menuTargetY = 0.0;
    } else if (key == CODED && keyCode == UP && keyEvent.getModifiersEx() == 0) {
        if (folder.isZoomed()) folder.zoomIn();
        else menuTargetY = -100.0;
    } else if (folder.isActive() && folder.isFocused()) {
        folder.keyAction(key, keyCode, keyEvent.getModifiersEx());
    } */else {
        //upperDefault.keyAction(key, keyCode, keyEvent.getModifiersEx());
        //lowerDefault.keyAction(key, keyCode, keyEvent.getModifiersEx());
        texts.keyAction(key, keyCode, keyEvent.getModifiersEx());
    }
}

void keyReleased() {
    if (! exiting && tabs.isActive() && tabs.isFocused()) {
        tabs.keyAction(key, keyCode, keyEvent.getModifiersEx());
    }
}

void mousePressed() {
    if (mouseX > 10 && mouseX < 95 && mouseY < menuY + height && mouseY > menuY + height - 20 && !exiting) {
        //menuY = (menuY == 0.0) ? -100.0 : 0.0;
        menuTargetY = (menuY == 0.0) ? -100.0 : 0.0;
        tabs.setFocus(menuY == 0.0);
    }
    if (!exiting && mouseX > fileTree.x+fileTree.w && mouseX < tabs.x && mouseY > fileTree.y && mouseY < height+menuTargetY) {
        if (tabsXTarget == 110) tabsXTarget = 335;
        else tabsXTarget = 110;
    } else if (exiting) {
        yes.mouseAction();
        no.mouseAction();
    } else if (mouseY < height+menuTargetY) {
        tabs.mouseAction();
        //upperDefault.mouseAction();
        //lowerDefault.mouseAction();
    } else {
        texts.mouseAction();
    }
}

void mouseMoved() {
    if (! exiting) {
        tabs.mouseAction();
        //upperDefault.mouseAction();
        //lowerDefault.mouseAction();
        texts.mouseAction();
    } else {
        yes.mouseAction();
        no.mouseAction();
    }
}

void mouseReleased() {
    if (! exiting) {
        tabs.mouseAction();
        //upperDefault.mouseAction();
        //lowerDefault.mouseAction();
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
    if (fd.getDirectory() != null && fd.getFile() != null) // ^^ details
        loadFile(path);
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
    if (path.split("/").length < 1) return;
    String pathName = path.split("/")[path.split("/").length - 1];
    String modifiedPath = "";
    if (split(path, ".").length == 2) modifiedPath = split(path, ".")[0];
    else if (split(path, ".").length == 1) modifiedPath = path;
    else {
        for (int i = 0; i < split(path, ".").length - 2; i++)
            modifiedPath += split(path, ".")[i] + ".";
        if (modifiedPath.length() > 0) modifiedPath = modifiedPath.substring(0, modifiedPath.length()-1);
        //modifiedPath += "_";
    }
    fileTree.add(new p_treenode(pathName, true));
    Parent_File parent = new Parent_File(pathName);
    //parentFiles.add(new Parent_File(pathName));
    float autoLower = 1.5, autoUpper = 3.0;
    try {
        autoLower = float(((p_textinput)texts.get(0)).getText());
        autoUpper = float(((p_textinput)texts.get(1)).getText());
    } catch (Exception error3) {
        println("EXCEPTION:");
        println(error3.getLocalizedMessage());
    } try {
        FileReader fr = new FileReader(path);
        String[][] data = readCSV(fr);
        fr.close();
        String[] names = new String[0];
        HashMap<String, float[][]> chrdata = new HashMap<String, float[][]>();
        ArrayList<HashMap<String, float[]>> tdata = new ArrayList<HashMap<String, float[]>>();
        String[][] csvPeaks = new String[0][0], csvThresh = new String[0][0];
        int alphacol = -1;
        if (new File(modifiedPath + ".peaks.txt").exists()) {
            FileReader chrf = new FileReader(modifiedPath + ".peaks.txt");
            chrdata = readPeaks(chrf);
            chrf.close();
            Iterator it = chrdata.keySet().iterator();
            while (it.hasNext()) names = (String[])append(names, it.next());
        } else if (new File(modifiedPath + ".peaks.csv").exists()) {
            FileReader chrf = new FileReader(modifiedPath + ".peaks.csv");
            chrdata = readPeaks(chrf);
            chrf.close();
        } if (new File(modifiedPath + ".thresh.txt").exists()) {
            tdata = getThresholdData(modifiedPath + ".thresh.txt", names, parent);
        } else if (new File(modifiedPath + ".thresh.csv").exists()) try {
                FileReader tf = new FileReader(modifiedPath + ".thresh.csv");
                csvThresh = readCSV(tf);
                tf.close();
                if (csvThresh[0][1].equalsIgnoreCase("alpha")) alphacol = 0;
                if (csvThresh[0].length == 3 && names.length > 1) {
                    String mark = (alphacol >= 0) ? csvThresh[1][alphacol] : "";
                    for (int i = 1; i < csvThresh.length; i++) {
                        if (!csvThresh[i][alphacol].equals(mark) && alphacol != -1) {
                            if (parent.data.length == 1) parent.data = (float[][])append(parent.data, new float[0]);
                            parent.data[1] = (float[])append(parent.data, float(csvThresh[i][2]));
                        } else parent.data[0] = (float[])append(parent.data, float(csvThresh[i][2]));
                    }
                    parent.useModelThresholds = true;
                }
            } catch (Exception error) {
                println("EXCEPTION:");
                println(error.getLocalizedMessage());
            }
        int lfiles = 0, tfiles = 3 * (data[0].length - 3);
        if (names.length == 0 && new File(modifiedPath + ".thresh.txt").exists()) {
            for (int i = 3; i < data[0].length; i++) names = (String[])append(names, data[0][i].trim());
            tdata = getThresholdData(modifiedPath + ".thresh.txt", names, parent);
        }
        for (int i = 3; i < data[0].length; i++) {
            ((p_treenode)fileTree.last()).add(new p_treenode(data[0][i].trim()));
            Phenotype p = new Phenotype(data[0][i]);
            for (int j = 1; j < data.length; j++)
                if (data[j].length-1 >= i) {
                    p.lodscores = append(p.lodscores, float(data[j][i]));
                    p.position = append(p.position, float(data[j][2]));
                    p.chromosome = append(p.chromosome, getChr(data[j][1]));
                }
            if (new File(modifiedPath + ".thresh.txt").exists() && !parent.useModelThresholds) try {
                    p.thresholds = new float[1][0];
                    float[] th = tdata.get(0).get(p.name);
                    for (float thf : th) p.thresholds[0] = append(p.thresholds[0], thf);
                    if (tdata.size() > 1) {
                        float[] thx = tdata.get(1).get(p.name);
                        if (tdata.get(1).get(p.name) != null) {
                            p.thresholds = (float[][])append(p.thresholds, new float[0]);
                            for (float thf : thx) p.thresholds[1] = append(p.thresholds[1], thf);
                            p.useXDefaults = false;
                        }
                    } else p.useXDefaults = true;
                    p.useDefaults = false;
                } catch (NullPointerException error) {
                    println("ERROR: No threshold data associated with phenotype \""+p.name+"\"."); 
                    //p.Alower = p.Xlower = autoLower;
                    //p.Aupper = p.Xupper = autoUpper;
                    p.thresholds = new float[][] { { autoLower, autoUpper } };
                    p.useDefaults = true;
                    p.useXDefaults = true;
                } catch (Exception e) {
                    println("EXCEPTION:");
                    println(e.getLocalizedMessage());
                    //p.Alower = p.Xlower = autoLower;
                    //p.Aupper = p.Xupper = autoUpper;
                    p.thresholds = new float[][] { { autoLower, autoUpper } };
                    p.useDefaults = true;
                    p.useXDefaults = true;
            } else if (new File(modifiedPath + ".thresh.csv").exists() && !parent.useModelThresholds) try {
                String mark = (alphacol >= 0) ? csvThresh[1][alphacol] : "";
                int col = -1;
                for (int j = (alphacol == -1) ? 1 : 2; j < csvThresh[0].length; j++)
                    if (csvThresh[0][j].equals(p.name)) {
                        col = j;
                        break;
                    }
                p.thresholds = new float[1][0];
                if (col == -1) throw new Exception(""); // not sure if this is an accepted practice, but it should work
                for (int j = 1; j < csvThresh.length; j++) {
                    if (alphacol > -1 && !csvThresh[j][alphacol].equals(mark)) {
                        if (p.thresholds.length == 1) p.thresholds = (float[][])append(p.thresholds, new float[0]);
                        p.thresholds[1] = (float[])append(p.thresholds[1], float(csvThresh[j][col]));
                        p.useXDefaults = false;
                    } else p.thresholds[0] = (float[])append(p.thresholds[0], float(csvThresh[j][col]));
                }
                if (p.thresholds[0].length < 2) p.thresholds[0] = (float[])append(p.thresholds[0], -height);
                if (p.thresholds.length > 1 && p.thresholds[1].length < 2) p.thresholds[1] = (float[])append(p.thresholds[1], -height);
                p.useDefaults = false;
            } catch(Exception error) {
                println("EXCEPTION:");
                println(error.getLocalizedMessage());
                p.thresholds = new float[][] { { autoLower, autoUpper } };
                p.useDefaults = true;
                p.useXDefaults = true;
            } else if (new File(modifiedPath + "_" + p.name + ".sum.csv").exists()) try {
                FileReader sum = new FileReader(modifiedPath + "_" + p.name + ".sum.csv");
                String[][] sdata = readCSV(sum);
                p.thresholds = new float[1][2];
                p.thresholds[0][0] = float(sdata[1][1]);
                p.thresholds[0][1] = float(sdata[2][1]);
                if (sdata.length > 4) {
                    p.thresholds = (float[][])append(p.thresholds, new float[2]);
                    p.thresholds[1][0] = float(sdata[3][1]);
                    p.thresholds[1][1] = float(sdata[4][1]);
                    p.useXDefaults = false;
                } else //{
                    //p.Xlower = autoLower;
                    //p.Xupper = autoUpper;
                    p.useXDefaults = true;
                //}
                p.useDefaults = false;
                sum.close();
            } catch (Exception error1) {
                println("EXCEPTION:");
                println(error1.getLocalizedMessage());
                //p.Alower = p.Xlower = autoLower;
                //p.Aupper = p.Xupper = autoUpper;
                p.thresholds = new float[][] { { autoLower, autoUpper } };
                p.useDefaults = true;
                p.useXDefaults = true;
            }
            if (new File(modifiedPath + ".peaks.txt").exists()) {
                float[][] values = chrdata.get(p.name);
                for (int j = 0; j < values.length; j++) {
                    if (values[j].length == 0) continue;
                    p.chr_chrs = append(p.chr_chrs, j+1);
                    p.chr_peaks = append(p.chr_peaks, values[j][0]);
                    Range r = new Range();
                    r.upper = values[j][2];
                    r.lower = values[j][1];
                    p.bayesintrange = (Range[])append(p.bayesintrange, r);
                }
            } else if (new File(modifiedPath + ".peaks.csv").exists()) try {
                for (int j = 1; j < csvPeaks.length; j++)
                    if (csvPeaks[j][0].startsWith(p.name)) {
                        p.chr_chrs = (int[])append(p.chr_chrs, getChr(csvPeaks[j][1]));
                        p.chr_peaks = (float[])append(p.chr_peaks, csvPeaks[j][2]);
                        Range r = new Range();
                        r.lower = float(csvPeaks[j][3]);
                        r.upper = float(csvPeaks[j][4]);
                        p.bayesintrange = (Range[])append(p.bayesintrange, r);
                    }
            } catch (Exception error) {
                println("EXCEPTION:");
                println(error.getLocalizedMessage());
            } else if (new File(modifiedPath + "_" + p.name + ".chr.csv").exists()) try {
                FileReader chr = new FileReader(modifiedPath + "_" + p.name + ".chr.csv");
                String[][] cdata = readCSV(chr);
                for (int j = 1; j < cdata.length; j++) {
                    if (cdata[j].length < 7) continue;
                    p.chr_chrs = append(p.chr_chrs, getChr(cdata[j][1]));
                    p.chr_peaks = append(p.chr_peaks, float(cdata[j][2]));
                    String range = cdata[j][6];
                    Range r = new Range();
                    r.upper = float(range.split("-")[1].trim());
                    r.lower = float(range.split("-")[0].trim());
                    p.bayesintrange = (Range[])append(p.bayesintrange, r);
                }
                chr.close();
            } catch (Exception error2) {
                println("EXCEPTION:");
                println(error2.getLocalizedMessage());
            }
            //p.name = ((p_treenode)filetree.last()).title;
            parent.add(p);
            //((Parent_File)parentFiles).add(p);
        }
        parentFiles.add(parent);
    } catch (Exception error) {
        fileTree.remove(fileTree.size() - 1);
        println("EXCEPTION:");
        println(error.getLocalizedMessage());
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
    if (folderPrompt.getDirectory() != null && folderPrompt.getFile() != null && new File(folderPrompt.getDirectory() + folderPrompt.getFile()).isDirectory())
        for (String path : new File(folderPrompt.getDirectory() + folderPrompt.getFile()).list())
            if (path.toLowerCase().endsWith(".lod.csv") && !(new File(folderPrompt.getDirectory() + folderPrompt.getFile() + "/" + path).isDirectory()))
                loadFile(folderPrompt.getDirectory() + folderPrompt.getFile() + "/" + path);
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

void loadConfig() {
    
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

/**
* This method is used to obtain threshold information from a text file generated by an R script.
*
* It returns an ArrayList of HashMaps (one for each chromosome specified) that match Strings to float arrays. Each String is the name of a phenotype, and each float array contains the specified thresholds, as ordered by the file.
* Due to the nature of the file format (variable-width space-delimited), this method must be given the names of the phenotypes, which are often not known by the Parent_File until all data has been parsed.
* Note that while this method could throw one of three exceptions, they will be caught and handled when it is called (in loadFile).
*
* @throws FileNotFoundException if the file represented by path was not found
* @throws IOException if a general I/O exception is encountered
* @throws Exception if a general exception is encountered
* @param path a String representing the path of the threshold file
* @param names a String array containing the list of phenotypes from the main LOD data file
* @param parent the Parent_File containing the rest of the information about the phenotypes
* @return an ArrayList of phenotype names mapped to threshold information
*/
ArrayList<HashMap<String, float[]>> getThresholdData(String path, String[] names, Parent_File parent) throws FileNotFoundException, IOException, Exception {
    FileReader pathInput = new FileReader(path);
    ArrayList<HashMap<String, float[]>> threshData = readThresholds(pathInput, names, new String[0], new String[0]);
    pathInput.close();
    for (int i = 0; i < threshData.size(); i++) {
        HashMap<String, float[]> h = threshData.get(i);
        Iterator it = h.keySet().iterator();
        String[] tnames = new String[0];
        while (it.hasNext()) tnames = (String[])append(tnames, it.next());
        if (tnames.length == 1 && names.length > 1) {
            String n = tnames[0];
            parent.useModelThresholds = true;
            float[] th = threshData.get(0).get("*");
            parent.data[0] = th;
            if (threshData.size() > 1) {
                parent.data = (float[][])append(parent.data, new float[0]);
                float[] thx = threshData.get(1).get("*");
                parent.data[1] = thx;
            }
            parent.useModelThresholds = true;
        }
    }
    return threshData;
}
