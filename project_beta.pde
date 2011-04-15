import processing.opengl.*;
import java.util.ArrayList;
import java.awt.*;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.JColorChooser;

//p_horizontalfolder folder;
boolean exiting = false;
double mx, mtarget;
p_button yes, no;
PFont large, buttonfont = createFont("Arial", 16, true);
//p_listbox files, display;
p_tree filetree;
String error = "";
ArrayList<Parent_File> phenos;
float[] chr_lengths, chr_offsets, chr_markerpos;
String[] chr_names;
float chr_total, maxLod = -1.0, v = 0.1, t_target = 335.0;
p_container texts;
p_radiogroup unitSelect;
p_tabfolder TEST;
p_button loadcfg;
//p_progressbar progress;
LODDisplay loddisplay;
int chr_columns = 7;
void setup() {
  size(1100, 700, OPENGL);
  String[] s = {"LOD Score view", "Chromosome view"};
  TEST = new p_tabfolder(335, 30, 10, 10, s);
  frame.setTitle("");
  MenuBar mb = new MenuBar();
  Menu f = new Menu("File");
  MenuItem op = new MenuItem("Open File...", new MenuShortcut(KeyEvent.VK_O));
  op.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      if (exiting) return;
      openFile();
    }
  });
  MenuItem of = new MenuItem("Open Folder...", new MenuShortcut(KeyEvent.VK_O, true));
  of.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      if (exiting) return;
      loadFolder();
    }
  });
  f.add(op);
  f.add(of);
  f.add(new MenuItem("-"));
  MenuItem lc = new MenuItem("Load config...", new MenuShortcut(KeyEvent.VK_E));
  lc.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      if(exiting) return;
      loadConfig();
    }
  });
  
  f.add(lc);
  Menu v = new Menu("View");
  /*MenuItem next = new MenuItem("Next Page", new MenuShortcut(KeyEvent.VK_RIGHT, true));
  next.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      folder.nextPage();
    }
  });
  MenuItem prev = new MenuItem("Previous Page", new MenuShortcut(KeyEvent.VK_LEFT, true));
  prev.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      folder.prevPage();
    }
  });*/
  MenuItem menuup = new MenuItem("Show Menu", new MenuShortcut(KeyEvent.VK_UP, true));
  menuup.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      if (exiting) return;
      mtarget = -100.0;
    }
  });
  MenuItem menudown = new MenuItem("Hide Menu", new MenuShortcut(KeyEvent.VK_DOWN, true));
  menudown.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      if (exiting) return;
      mtarget = 0.0;
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
  //v.add(next);
  //v.add(prev);
  //v.add(new MenuItem("-"));
  v.add(menuup);
  v.add(menudown);
  v.add(new MenuItem("-"));
  v.add(nextchr);
  v.add(prevchr);
  v.add(showall);
  mb.add(f);
  mb.add(v);
  frame.setMenuBar(mb);
  //frame.setResizable(true);
  smooth();
  hint(ENABLE_OPENGL_4X_SMOOTH);
  frameRate(60);
  chr_lengths = new float[20];
  chr_names = new String[chr_lengths.length];
  chr_offsets = new float[chr_lengths.length];
  chr_markerpos = new float[chr_lengths.length];
  chr_lengths[0] = 112.0;
  chr_lengths[1] = 114.0;
  chr_lengths[2] = 95.0;
  chr_lengths[3] = 84.0;
  chr_lengths[4] = 92.0;
  chr_lengths[5] = 75.0;
  chr_lengths[6] = 74.0;
  chr_lengths[7] = 82.0;
  chr_lengths[8] = 79.0;
  chr_lengths[9] = 82.0;
  chr_lengths[10] = 104.0;
  chr_lengths[11] = 66.0;
  chr_lengths[12] = 80.0;
  chr_lengths[13] = 69.0;
  chr_lengths[14] = 74.6;
  chr_lengths[15] = 72.0;
  chr_lengths[16] = 58.0;
  chr_lengths[17] = 59.0;
  chr_lengths[18] = 57.0;
  chr_lengths[19] = 79.44;
  chr_offsets[0] = chr_markerpos[0] = 0.0;
  chr_total = chr_lengths[0];
  for (int i = 1; i < chr_lengths.length; i++) {
    chr_names[i-1] = str(i);
    chr_offsets[i] = chr_offsets[i-1] + chr_lengths[i-1];
    chr_total += chr_lengths[i];
    chr_markerpos[i] = 0.0;
  }
  chr_names[chr_lengths.length-1] = "X";
  String[] titles = {"File management", "LOD Score view", "Chromosome view", "Genome browser"};
  p_text upper, lower;
  upper = new p_text(14, 0, 200, 50, "Default upper threshold");
  upper.setText("3.0");
  lower = new p_text(14, 0, 200, 50, "Default lower threshold");
  lower.setText("1.5");
  String[] t = {"Centimorgans", "Base pairs"};
  unitSelect = new p_radiogroup(275, height, t);
  loadcfg = new p_button(425, height, "Load config", new p_action() {
    public void doAction() {
      loadConfig();
    }
  });
  texts = new p_container();
  texts.add(lower);
  texts.add(upper);
  phenos = new ArrayList<Parent_File>();
  //folder = new p_horizontalfolder(25, 25, 4, 0, titles);
  mx = mtarget = 0.0;
  yes = new p_button((width/2.0)-40, (height/2.0)-24, "Yes", new p_action() {
    public void doAction() { exit(); }
  });
  no = new p_button((width/2.0)+8, (height/2.0)-24, "No", new p_action() { public void doAction() { exiting = false; } } );
  large = createFont("Arial", 32, true);
  textFont(large, 32);
  filetree = new p_tree(10, 10, 315/*getButtonWidth("Load Folder")*/, height-20, new p_listener() {
    public int eventHeard(int i, int j) {
      phenos.remove(i);
      return i;
    }
  }, new p_listener() {
    public int eventHeard(int i, int j) {
      ((Parent_File)phenos.get(i)).remove(j);
      return j;
    }
  });
  /*for (int i = 0; i < 10; i++) {
    filetree.add(new p_treenode("File", true));
    for (int j = 0; j < 10; j++)
      ((p_treenode)filetree.last()).add(new p_treenode("Phenotype"));
  }*/
  
  //folder.addComponent(filetree, 0, 0);
  /*folder.addComponent(files = new p_listbox(50, 50, 200, height-100, "test"), 0, 0);
  folder.addComponent(display = new p_listbox(width-250, 50, 200, height-100, "test"), 0, 0);
  for (int i = 0; i < 10; i++) {
    files.add("string "+i);
    display.add("string "+i);
  }*/
  /*folder.addComponent(new p_button(width-50-getButtonWidth("Load Folder"), 50, "Load File", new p_action() {
    public void doAction() {
      new Thread() {
        public void run() {
          loadFile();
        }
      }.start();
      // the above code doesn't work (Invalid memory access of location 0x0 eip=0x70cb3ab),
      openFile(); // so blocking is the only option
      // update: had something to do with p_progress bar, which has now been removed
    }
  }), 0, 0); 
  folder.addComponent(new p_button(width-50-getButtonWidth("Load Folder"), 80, "Load Folder", new p_action() {
    public void doAction() {
      loadFolder();
    }
  }), 0, 0);*/
  //folder.addComponent((progress = new p_progressbar(width-50-getButtonWidth("Load Folder"), 120, getButtonWidth("Load Folder"), height-170)), 0, 0);
  //progress.setVertical();
  //folder.addComponent(loddisplay = new LODDisplay(), 1, 0);
  //folder.addComponent(new ChrDisplay(), 2, 0);
  TEST.addComponent(loddisplay = new LODDisplay(400, 40, -35, -25), 0, 0);
  TEST.addComponent(new ChrDisplay(360, 40, -35, -25), 1, 0);
}

void draw() {
  background(0xAA);
  double dif;
  if (Math.abs(TEST.x-t_target) < 0.1) TEST.x = t_target;
  filetree.w -= (TEST.x-t_target)*v;
  TEST.x -= (TEST.x-t_target)*v;
  ((LODDisplay)TEST.get(0).get(0)).x = TEST.x+65;
  ((LODDisplay)TEST.get(0).get(0)).w = -35;
  ((ChrDisplay)TEST.get(1).get(0)).x = TEST.x+25;
  ((ChrDisplay)TEST.get(1).get(0)).w = -35;
  if (TEST.x != t_target) ((ChrDisplay)TEST.get(1).get(0)).update = true;
  
  fill(0x55);
  if (!exiting && mouseX > filetree.x+filetree.w && mouseX < TEST.x && mouseY > filetree.y && mouseY < height+mtarget) fill(0x00);
  
  noStroke();
  pushMatrix();
  translate((float)TEST.x-6, height/2.0);
  rotate(PI*(float)((TEST.x-110.0)/(335.0-110.0)));
  beginShape();
  vertex(3.0, 0);
  vertex(-3.0, -(3.0/cos(PI/6.0)));
  vertex(-3.0, (3.0/cos(PI/6.0)));
  endShape();
  popMatrix();
  
  //folder.update();
  TEST.setFocus(!exiting);
  TEST.setActive(!exiting);
  TEST.update();
  filetree.setFocus(!exiting);
  filetree.setActive(!exiting);
  filetree.update();
  stroke(0xCC);
  fill(0x00, 0x00, 0x00, 0xAA);
  pushMatrix();
  if (mtarget == -100.0) {
    texts.setActive(!exiting);
    texts.setFocus(!exiting);
    unitSelect.setActive(!exiting);
    unitSelect.setFocus(!exiting);
    loadcfg.setFocus(!exiting);
    loadcfg.setActive(!exiting);
    //upper.setActive(true);
    //lower.setActive(true);
  } else {
    texts.setActive(false);
    texts.setFocus(false);
    unitSelect.setActive(false);
    unitSelect.setFocus(false);
    loadcfg.setFocus(false);
    loadcfg.setActive(false);
    //upper.setActive(false);
    //lower.setActive(false);
  }
  translate(0.0, (float)mx, 0);
  mx += (mtarget - mx)*0.1;
  if (abs((float)(mtarget - mx)) < 0.25)
    mx = mtarget;
  beginShape();
  for (int i = 0; i < 20; i+=2)
    vertex(i+10, (-sin((i*HALF_PI)/20.0)*20.0)+height);
  vertex(75, height-20);
  //for (int i = 0; i > -20; i-=2)
  for (int i = 20; i >= 0; i -= 2)
    vertex(95-i, (-sin((abs(i)*HALF_PI)/20.0)*20.0)+height);
  vertex(width-10, height);
  vertex(width-10, height+100);
  vertex(10, height+100);
  vertex(10, height);
  endShape();
  fill(0xFF);
  popMatrix();
  //upper.setY((height+mx)+10);
  //lower.setY((height+mx)+36);
  ((p_component)texts.get(0)).setY((height+mx)+10);
  ((p_component)texts.get(1)).setY((height+mx)+36);
  unitSelect.setY(height+mx+10);
  loadcfg.setY(height+mx+10);
  //upper.update();
  //lower.update();
  texts.update();
  unitSelect.update();
  loadcfg.update();
  //text((error.length() > 0) ? "Error: " + error : "", 35, (height+(float)mx)+32);
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
  //folder.setFocus(mx > -2.5 && !exiting && mouseY < height+mx);
  //folder.setActive(mx > -2.5 && !exiting && mouseY < height+mx);
}

void keyPressed() {
  if (key == ESC) {
    exiting = !exiting;
    key = 0;
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
    if (mx > -5.0) folder.zoomOut();
    else mtarget = 0.0;
  } else if (key == CODED && keyCode == UP && keyEvent.getModifiersEx() == 0) {
    if (folder.isZoomed()) folder.zoomIn();
    else mtarget = -100.0;
  } else if (folder.isActive() && folder.isFocused()) {
    folder.keyAction(key, keyCode, keyEvent.getModifiersEx());
  } */else {
    //upper.keyAction(key, keyCode, keyEvent.getModifiersEx());
    //lower.keyAction(key, keyCode, keyEvent.getModifiersEx());
    texts.keyAction(key, keyCode, keyEvent.getModifiersEx());
  }
}

void keyReleased() {
  if (! exiting && /*folder*/TEST.isActive() && /*folder*/TEST.isFocused()) {
    //folder.keyAction(key, keyCode, keyEvent.getModifiersEx());
    TEST.keyAction(key, keyCode, keyEvent.getModifiersEx());
  }
}

void mousePressed() {
  if (mouseX > 10 && mouseX < 95 && mouseY < mx + height && mouseY > mx + height - 20 && !exiting) {
    //mx = (mx == 0.0) ? -100.0 : 0.0;
    mtarget = (mx == 0.0) ? -100.0 : 0.0;
    /*folder*/TEST.setFocus(mx == 0.0);
  }
  if (!exiting && mouseX > filetree.x+filetree.w && mouseX < TEST.x && mouseY > filetree.y && mouseY < height+mtarget) {
    if (t_target == 110) t_target = 335;
    else t_target = 110;
  } else if (exiting) {
    yes.mouseAction();
    no.mouseAction();
  } else if (mouseY < height+mtarget) {
    /*folder*/TEST.mouseAction();
    //upper.mouseAction();
    //lower.mouseAction();
  } else {
    texts.mouseAction();
  }
}

void mouseMoved() {
  if (! exiting) {
    /*folder*/TEST.mouseAction();
    //upper.mouseAction();
    //lower.mouseAction();
    texts.mouseAction();
  } else {
    yes.mouseAction();
    no.mouseAction();
  }
}

void mouseReleased() {
  if (! exiting) {
    /*folder*/TEST.mouseAction();
    //upper.mouseAction();
    //lower.mouseAction();
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
void openFile() {
  /*try {
    FileReader fr = new FileReader("/Users/student/Downloads/Brockman_QTV/Brockman_2006_sexadd.peaks.txt");
    readPeaks(fr);
  } catch (Exception error) {
    println(error.getMessage());
  }*/
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

void loadFile(String path) {
  String[] d = path.split("/");
  String modpath = "";
  //progress.setValue(0.0);
  if (split(path, ".").length == 2) modpath = split(path, ".")[0];
  else if (split(path, ".").length == 1) modpath = path;
  else {
    for (int i = 0; i < split(path, ".").length - 2; i++)
      modpath += split(path, ".")[i] + ".";
    if (modpath.length() > 0) modpath = modpath.substring(0, modpath.length()-1);
    //modpath += "_";
  }
  if (d.length < 1) return;
  filetree.add(new p_treenode(d[d.length-1], true));
  Parent_File f = new Parent_File(d[d.length-1]);
  //phenos.add(new Parent_File(d[d.length-1]));
  float autoLower = 1.5, autoUpper = 3.0;
  try {
    autoLower = float(((p_text)texts.get(0)).getText());
    autoUpper = float(((p_text)texts.get(1)).getText());
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
    if (new File(modpath + ".peaks.txt").exists()) {
      FileReader chrf = new FileReader(modpath + ".peaks.txt");
      chrdata = readPeaks(chrf);
      chrf.close();
      Iterator it = chrdata.keySet().iterator();
      while (it.hasNext()) names = (String[])append(names, it.next());
    } else if (new File(modpath + ".peaks.csv").exists()) {
      FileReader chrf = new FileReader(modpath + ".peaks.csv");
      chrdata = readPeaks(chrf);
      chrf.close();
    } if (new File(modpath + ".thresh.txt").exists()) {
      tdata = getData(modpath + ".thresh.txt", names, f);
    } else if (new File(modpath + ".thresh.csv").exists()) try {
        FileReader tf = new FileReader(modpath + ".thresh.csv");
        csvThresh = readCSV(tf);
        tf.close();
        if (csvThresh[0][1].equalsIgnoreCase("alpha")) alphacol = 0;
        if (csvThresh[0].length == 3 && names.length > 1) {
          String mark = (alphacol >= 0) ? csvThresh[1][alphacol] : "";
          for (int i = 1; i < csvThresh.length; i++) {
            if (!csvThresh[i][alphacol].equals(mark) && alphacol != -1) {
              if (f.data.length == 1) f.data = (float[][])append(f.data, new float[0]);
              f.data[1] = (float[])append(f.data, float(csvThresh[i][2]));
            } else f.data[0] = (float[])append(f.data, float(csvThresh[i][2]));
          }
          f.useModelThresholds = true;
        }
      } catch (Exception error) {
        println("EXCEPTION:");
        println(error.getLocalizedMessage());
      }
    int lfiles = 0, tfiles = 3 * (data[0].length - 3);
    if (names.length == 0 && new File(modpath + ".thresh.txt").exists()) {
      for (int i = 3; i < data[0].length; i++) names = (String[])append(names, data[0][i].trim());
      tdata = getData(modpath + ".thresh.txt", names, f);
    }
    for (int i = 3; i < data[0].length; i++) {
      ((p_treenode)filetree.last()).add(new p_treenode(data[0][i].trim()));
      Phenotype p = new Phenotype(data[0][i]);
      for (int j = 1; j < data.length; j++)
        if (data[j].length-1 >= i) {
          p.lodscores = append(p.lodscores, float(data[j][i]));
          p.position = append(p.position, float(data[j][2]));
          p.chromosome = append(p.chromosome, getChr(data[j][1]));
        }
      lfiles++;
     // progress.setValue(lfiles/(double)tfiles); 
      if (new File(modpath + ".thresh.txt").exists() && !f.useModelThresholds) try {
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
      } else if (new File(modpath + ".thresh.csv").exists() && !f.useModelThresholds) try {
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
      } else if (new File(modpath + "_" + p.name + ".sum.csv").exists()) try {
        FileReader sum = new FileReader(modpath + "_" + p.name + ".sum.csv");
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
      lfiles++;
      //progress.setValue(lfiles/(double)tfiles);
      if (new File(modpath + ".peaks.txt").exists()) {
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
      } else if (new File(modpath + ".peaks.csv").exists()) try {
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
      } else if (new File(modpath + "_" + p.name + ".chr.csv").exists()) try {
        FileReader chr = new FileReader(modpath + "_" + p.name + ".chr.csv");
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
      lfiles++;
      //progress.setValue(lfiles/(double)tfiles);
      //p.name = ((p_treenode)filetree.last()).title;
      f.add(p);
      //((Parent_File)phenos).add(p);
    }
    phenos.add(f);
  } catch (Exception error) {
    filetree.remove(filetree.size()-1);
    println("EXCEPTION:");
    println(error.getLocalizedMessage());
  }
  f.update();
}

void loadFolder() {
  //selectFolder();
  // ^^ same issue as with selectInput
  FileDialog fd = new FileDialog((Frame)null, "Select folder...", FileDialog.LOAD);
  System.setProperty("apple.awt.fileDialogForDirectories", "true"); // how would anyone ever know to do this??
  fd.setVisible(true);
  System.setProperty("apple.awt.fileDialogForDirectories", "false");
  if (fd.getDirectory() != null && fd.getFile() != null && new File(fd.getDirectory()+fd.getFile()).isDirectory())
    for (String s : new File(fd.getDirectory()+fd.getFile()).list())
      if (s.toLowerCase().endsWith(".lod.csv") && !(new File(fd.getDirectory()+fd.getFile()+"/"+s).isDirectory()))
        loadFile(fd.getDirectory()+fd.getFile()+"/"+s);
}

float getButtonWidth(String data) {
  textFont(buttonfont);
  return textWidth(data) + 8.0;
}

void loadConfig() {
  
}

int getChr(String s) {
  int chr = 1;
  try {
    chr = Integer.parseInt(s);
  } catch (NumberFormatException error) {
    for (int i = 0; i < chr_names.length; i++)
      if (chr_names[i].equals(s)) {
        chr = i+1;
        break;
      }
  }
  return chr;
}

ArrayList<HashMap<String, float[]>> getData(String path, String[] names, Parent_File f) throws Exception {
  FileReader tf = new FileReader(path);
  ArrayList<HashMap<String, float[]>> tdata = readThresholds(tf, names, new String[0], new String[0]);
  tf.close();
  for (int i = 0; i < tdata.size(); i++) {
    HashMap<String, float[]> h = tdata.get(i);
    Iterator it = h.keySet().iterator();
    String[] tnames = new String[0];
    while (it.hasNext()) tnames = (String[])append(tnames, it.next());
    if (tnames.length == 1 && names.length > 1) {
      String n = tnames[0];
      f.useModelThresholds = true;
      float[] th = tdata.get(0).get("*");
      f.data[0] = th;
      if (tdata.size() > 1) {
        f.data = (float[][])append(f.data, new float[0]);
        float[] thx = tdata.get(1).get("*");
        f.data[1] = thx;
      }
      f.useModelThresholds = true;
      /*println(n+":");
      for (float ft : h.get(n))
        println("\t"+ft);
      println();*/
    }
  }
  return tdata;
}
