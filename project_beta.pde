import processing.opengl.*;
import java.util.ArrayList;
import java.awt.*;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.JColorChooser;

p_horizontalfolder folder;
boolean exiting = false;
double mx, mtarget;
p_button yes, no;
PFont large, buttonfont = createFont("Arial", 16, true);
p_listbox files, display;
p_tree filetree;
String error = "";
ArrayList<Parent_File> phenos;
float[] chr_lengths, chr_offsets, chr_markerpos;
float chr_total, maxLod = -1.0;
p_container texts;
//p_progressbar progress;
LODDisplay loddisplay;
int chr_columns = 7;
void setup() {
  size(1024, 768, OPENGL);
  frame.setTitle("");
  MenuBar mb = new MenuBar();
  Menu f = new Menu("File");
  MenuItem op = new MenuItem("Open File...", new MenuShortcut(KeyEvent.VK_O));
  op.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      openFile();
    }
  });
  MenuItem of = new MenuItem("Open Folder...", new MenuShortcut(KeyEvent.VK_O, true));
  of.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      loadFolder();
    }
  });
  f.add(op);
  f.add(of);
  Menu v = new Menu("View");
  MenuItem next = new MenuItem("Next Page", new MenuShortcut(KeyEvent.VK_RIGHT, true));
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
  });
  MenuItem menuup = new MenuItem("Show Menu", new MenuShortcut(KeyEvent.VK_UP, true));
  menuup.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      mtarget = -100.0;
    }
  });
  MenuItem menudown = new MenuItem("Hide Menu", new MenuShortcut(KeyEvent.VK_DOWN, true));
  menudown.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      mtarget = 0.0;
    }
  });
  MenuItem nextchr = new MenuItem("Next Chromosome", new MenuShortcut(KeyEvent.VK_PERIOD));
  nextchr.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      loddisplay.nextChr();
    }
  });
  MenuItem prevchr = new MenuItem("Previous Chromosome", new MenuShortcut(KeyEvent.VK_COMMA));
  prevchr.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      loddisplay.prevChr();
    }
  });
  MenuItem showall = new MenuItem("Show All", new MenuShortcut(KeyEvent.VK_BACK_SPACE));
  showall.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      loddisplay.allChr();
    }
  });
  v.add(next);
  v.add(prev);
  v.add(new MenuItem("-"));
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
    chr_offsets[i] = chr_offsets[i-1] + chr_lengths[i-1];
    chr_total += chr_lengths[i];
    chr_markerpos[i] = 0.0;
  }
  String[] titles = {"File management", "LOD Score view", "Chromosome view", "Genome browser"};
  p_text upper, lower;
  upper = new p_text(14, 0, 200, 50, "Default upper threshold");
  upper.setText("3.0");
  lower = new p_text(14, 0, 200, 50, "Default lower threshold");
  lower.setText("1.5");
  texts = new p_container();
  texts.add(lower);
  texts.add(upper);
  phenos = new ArrayList<Parent_File>();
  folder = new p_horizontalfolder(25, 25, 4, 0, titles);
  mx = mtarget = 0.0;
  yes = new p_button((width/2.0)-40, (height/2.0)-24, "Yes", new p_action() {
    public void doAction() { exit(); }
  });
  no = new p_button((width/2.0)+8, (height/2.0)-24, "No", new p_action() { public void doAction() { exiting = false; } } );
  large = createFont("Arial", 32, true);
  textFont(large, 32);
  filetree = new p_tree(50, 50, width-150-getButtonWidth("Load Folder"), height-100, new p_listener() {
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
  
  folder.addComponent(filetree, 0, 0);
  /*folder.addComponent(files = new p_listbox(50, 50, 200, height-100, "test"), 0, 0);
  folder.addComponent(display = new p_listbox(width-250, 50, 200, height-100, "test"), 0, 0);
  for (int i = 0; i < 10; i++) {
    files.add("string "+i);
    display.add("string "+i);
  }*/
  folder.addComponent(new p_button(width-50-getButtonWidth("Load Folder"), 50, "Load File", new p_action() {
    public void doAction() {
      /*new Thread() {
        public void run() {
          loadFile();
        }
      }.start();*/
      // the above code doesn't work (Invalid memory access of location 0x0 eip=0x70cb3ab),
      openFile(); // so blocking is the only option
      // update: had something to do with p_progress bar, which has now been removed
    }
  }), 0, 0); 
  folder.addComponent(new p_button(width-50-getButtonWidth("Load Folder"), 80, "Load Folder", new p_action() {
    public void doAction() {
      loadFolder();
    }
  }), 0, 0);
  //folder.addComponent((progress = new p_progressbar(width-50-getButtonWidth("Load Folder"), 120, getButtonWidth("Load Folder"), height-170)), 0, 0);
  //progress.setVertical();
  folder.addComponent(loddisplay = new LODDisplay(), 1, 0);
  folder.addComponent(new ChrDisplay(), 2, 0);
}

void draw() {
  background(0xAA);
  folder.update();
  stroke(0xCC);
  fill(0x00, 0x00, 0x00, 0xAA);
  pushMatrix();
  if (mtarget == -100.0) {
    texts.setActive(true);
    texts.setFocus(true);
    //upper.setActive(true);
    //lower.setActive(true);
  } else {
    texts.setActive(false);
    texts.setFocus(false);
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
  //upper.update();
  //lower.update();
  texts.update();
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
  folder.setFocus(mx > -2.5 && !exiting && mouseY < height+mx);
  folder.setActive(mx > -2.5 && !exiting && mouseY < height+mx);
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
  } */else if (folder.isActive() && folder.isFocused()) {
    folder.keyAction(key, keyCode, keyEvent.getModifiersEx());
  } else {
    //upper.keyAction(key, keyCode, keyEvent.getModifiersEx());
    //lower.keyAction(key, keyCode, keyEvent.getModifiersEx());
    texts.keyAction(key, keyCode, keyEvent.getModifiersEx());
  }
}

void keyReleased() {
  if (! exiting && folder.isActive() && folder.isFocused()) {
    folder.keyAction(key, keyCode, keyEvent.getModifiersEx());
  }
}

void mousePressed() {
  if (mouseX > 10 && mouseX < 95 && mouseY < mx + height && mouseY > mx + height - 20 && !exiting) {
    //mx = (mx == 0.0) ? -100.0 : 0.0;
    mtarget = (mx == 0.0) ? -100.0 : 0.0;
    folder.setFocus(mx == 0.0);
  } else if (exiting) {
    yes.mouseAction();
    no.mouseAction();
  } else {
    folder.mouseAction();
    //upper.mouseAction();
    //lower.mouseAction();
    texts.mouseAction();
  }
}

void mouseMoved() {
  if (! exiting) {
    folder.mouseAction();
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
    folder.mouseAction();
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
    modpath += "_";
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
    int lfiles = 0, tfiles = 3 * (data[0].length - 3);
    for (int i = 3; i < data[0].length; i++) {
      ((p_treenode)filetree.last()).add(new p_treenode(data[0][i].trim()));
      Phenotype p = new Phenotype(data[0][i]);
      for (int j = 1; j < data.length; j++)
        if (data[j].length-1 >= i) {
          p.lodscores = append(p.lodscores, float(data[j][i]));
          p.position = append(p.position, float(data[j][2]));
          p.chromosome = append(p.chromosome, int(data[j][1].replace("x", str(chr_lengths.length)).replace("X", str(chr_lengths.length))));
        }
      lfiles++;
     // progress.setValue(lfiles/(double)tfiles);
      try {
        FileReader sum = new FileReader(modpath + p.name + ".sum.csv");
        String[][] sdata = readCSV(sum);
        p.Alower = float(sdata[1][1]);
        p.Aupper = float(sdata[2][1]);
        if (sdata.length > 4) {
          p.Xlower = float(sdata[3][1]);
          p.Xupper = float(sdata[4][1]);
          p.useXDefaults = false;
        } else {
          p.Xlower = autoLower;
          p.Xupper = autoUpper;
          p.useXDefaults = true;
        }
        p.useDefaults = false;
        sum.close();
      } catch (Exception error1) {
        println("EXCEPTION:");
        println(error1.getLocalizedMessage());
        p.Alower = p.Xlower = autoLower;
        p.Aupper = p.Xupper = autoUpper;
        p.useDefaults = true;
        p.useXDefaults = true;
      }
      lfiles++;
      //progress.setValue(lfiles/(double)tfiles);
      try {
        FileReader chr = new FileReader(modpath + p.name + ".chr.csv");
        String[][] cdata = readCSV(chr);
        for (int j = 1; j < cdata.length; j++) {
          if (cdata[j].length < 7) continue;
          p.chr_chrs = append(p.chr_chrs, int(cdata[j][1]));
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
