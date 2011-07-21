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
      
            while (it.hasNext ()) {
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
                  currentPhenotype.thresholds = new float[][] { 
                    { 
                      autoLower, autoUpper
                    }
                  };
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
        for (int i = 0; i < chrNames.length; i++) {
            if (chrNames[i].equals(stringChr)) {
              chr = i+1;
              break;
            }
        }
    }
    
    return chr;
}
