/**
* This module is a container for methods that parse and read data.
*/

/**
* This method is (only) called by loadFile in module QTLViewer.
*
* @param path the file being parsed by loadFile
* @return the modified path to be used for loading supplementary files
*/
String getModifiedPath(String path) {
   String modifiedPath = "";
    
    if (split(path, ".").length == 2) {
        modifiedPath = split(path, ".")[0];
    } else if (split(path, ".").length == 1) {
        modifiedPath = path;
    } else {
        for (int i = 0; i < split(path, ".").length - 2; i++) {
            modifiedPath += split(path, ".")[i] + ".";
        }
        
        if (modifiedPath.length() > 0) {
            modifiedPath = modifiedPath.substring(0, modifiedPath.length() - 1);
        }
    }
    return modifiedPath;
}

/**
* Associates threshold data with a phenotype.
*
* @param currentPhenotype the Phenotype object to add data to.
* @param thresholdData the data from readThresholds
* @return true or false, whether or not the operation was successful
*/
boolean addThresholdData(Phenotype currentPhenotype, ArrayList<HashMap<String, float[]>> thresholdData) {
    try {
        currentPhenotype.thresholds = new float[1][0];
        float[] threshArray = thresholdData.get(0).get(currentPhenotype.name);
        
        for (float threshValue : threshArray) {
            currentPhenotype.thresholds[0] = append(currentPhenotype.thresholds[0], threshValue);
        }
        
        if (thresholdData.size() > 1) {
            float[] threshXArray = thresholdData.get(1).get(currentPhenotype.name);
            if (thresholdData.get(1).get(currentPhenotype.name) != null) {
                currentPhenotype.thresholds = (float[][])append(currentPhenotype.thresholds, new float[0]);
                
                for (float threshXValue : threshXArray) {
                    currentPhenotype.thresholds[1] = append(currentPhenotype.thresholds[1], threshXValue);
                }
                
                currentPhenotype.useXDefaults = false;
            }
        } else {
            currentPhenotype.useXDefaults = true;
        }
        
        currentPhenotype.useDefaults = false;
    } catch (Exception error) {
        println("EXCEPTION:");
        println(error.getLocalizedMessage());
        return false;
    }
    
    return true;
}

/**
* Associates threshold data with a phenotype.
*
* @param currentPhenotype the Phenotype object to add data to.
* @param csvThresh the CSV data from readCSV
* @param alphaCol the index of the alpha column
* @return true or false, whether or not the operation was successful
*/
boolean addThresholdData(Phenotype currentPhenotype, String[][] csvThresh, int alphaCol) {
    try {
        String mark = (alphaCol >= 0) ? csvThresh[1][alphaCol] : "";
        int col = -1;
        for (int j = (alphaCol == -1) ? 1 : 2; j < csvThresh[0].length; j++) {
            if (csvThresh[0][j].equals(currentPhenotype.name)) {
                col = j;
                break;
            }
        }
        currentPhenotype.thresholds = new float[1][0];
        
        if (col == -1) {
            throw new Exception(""); // not sure if this is an accepted practice, but it should work
        }
        
        for (int j = 1; j < csvThresh.length; j++) {
            if (alphaCol > -1 && !csvThresh[j][alphaCol].equals(mark)) {
                if (currentPhenotype.thresholds.length == 1) currentPhenotype.thresholds = (float[][])append(currentPhenotype.thresholds, new float[0]);
                currentPhenotype.thresholds[1] = (float[])append(currentPhenotype.thresholds[1], float(csvThresh[j][col]));
                currentPhenotype.useXDefaults = false;
            } else {
                currentPhenotype.thresholds[0] = (float[])append(currentPhenotype.thresholds[0], float(csvThresh[j][col]));
            }
        }
        
        if (currentPhenotype.thresholds[0].length < 2) {
            currentPhenotype.thresholds[0] = (float[])append(currentPhenotype.thresholds[0], -height);
        }
        
        if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1].length < 2) {
            currentPhenotype.thresholds[1] = (float[])append(currentPhenotype.thresholds[1], -height);
        }
        
        currentPhenotype.useDefaults = false;
    } catch (Exception error) {
        println("EXCEPTION:");
        println(error.getLocalizedMessage());
        return false;
    }
    return true;
}

/**
* Associates threshold data with a phenotype.
*
* @param currentPhenotype the Phenotype object to add data to.
* @param threshCSVFile the InputStreamReader representing the CSV file
* @return true or false, whether or not the operation was successful
*/
boolean addThreshCSVFile(Phenotype currentPhenotype, InputStreamReader threshCSVFile) {
    try {
        String[][] csvData = readCSV(threshCSVFile);
        currentPhenotype.thresholds = new float[1][2];
        currentPhenotype.thresholds[0][0] = float(csvData[1][1]);
        currentPhenotype.thresholds[0][1] = float(csvData[2][1]);
        
        if (csvData.length > 4) {
            currentPhenotype.thresholds = (float[][])append(currentPhenotype.thresholds, new float[2]);
            currentPhenotype.thresholds[1][0] = float(csvData[3][1]);
            currentPhenotype.thresholds[1][1] = float(csvData[4][1]);
            currentPhenotype.useXDefaults = false;
        } else {
            currentPhenotype.useXDefaults = true;
        }
        
        currentPhenotype.useDefaults = false;
    } catch (Exception error) {
        println("EXCEPTION:");
        println(error.getLocalizedMessage());
        return false;
    }
    return true;
}

/**
* Associates peak data with a phenotype.
*
* @param currentPhenotype the Phenotype object to add data to.
* @param values the float matrix of peak ranges
* @return true or false, whether or not the operation was successful
*/
void addPeakData(Phenotype currentPhenotype, float[][] values) {
    for (int j = 0; j < values.length; j++) {
        if (values[j].length == 0) {
            continue;
        }
        
        currentPhenotype.chr_chrs = append(currentPhenotype.chr_chrs, j + 1);
        currentPhenotype.chr_peaks = append(currentPhenotype.chr_peaks, values[j][0]);
        Range r = new Range();
        r.upper = values[j][2];
        r.lower = values[j][1];
        currentPhenotype.bayesintrange = (Range[])append(currentPhenotype.bayesintrange, r);
    }
}

/**
* Associates peak data with a phenotype.
*
* @param currentPhenotype the Phenotype object to add data to.
* @param csvData the data from readCSV
* @return true or false, whether or not the operation was successful
*/
boolean addPeakData(Phenotype currentPhenotype, String[][] csvData) {
    try {
        for (int j = 1; j < csvData.length; j++) {
            if (csvData[j].length <= 1) {
                continue;
            }
            if (csvData[j][0].startsWith(currentPhenotype.name)) {
                currentPhenotype.chr_chrs = append(currentPhenotype.chr_chrs, getChr(csvData[j][1]));
                Range r = new Range();

                if (float(csvData[j][2]) > unitThreshold) {
                     currentPhenotype.chr_peaks = append(currentPhenotype.chr_peaks, (float)unitConverter.basePairsToCentimorgans(getChr(csvData[j][1]), Long.parseLong(csvData[j][2])));
                     r.lower = (float)unitConverter.basePairsToCentimorgans(getChr(csvData[j][1]), Long.parseLong(csvData[j][3]));
                     r.upper = (float)unitConverter.basePairsToCentimorgans(getChr(csvData[j][1]), Long.parseLong(csvData[j][4]));
                } else {
                    currentPhenotype.chr_peaks = append(currentPhenotype.chr_peaks, float(csvData[j][2]));
                    r.lower = float(csvData[j][3]);
                    r.upper = float(csvData[j][4]);
                }
                
                currentPhenotype.bayesintrange = (Range[])append(currentPhenotype.bayesintrange, r);
            }
        }
    } catch (Exception error) {
        println("EXCEPTION:");
        println(error.getLocalizedMessage());
        error.printStackTrace();
        return false;
    }
    return true;
}

/**
* Associates peak data with a phenotype.
*
* @param currentPhenotype the Phenotype object to add data to.
* @param peakCSVFile the InputStreamReader to read CSV data from
* @return true or false, whether or not the operation was successful
*/
boolean addPeakCSVFile(Phenotype currentPhenotype, InputStreamReader peakCSVFile) {
    try {
        String[][] csvData = readCSV(peakCSVFile);
        for (int j = 1; j < csvData.length; j++) {
            if (csvData[j].length < 7) {
                continue;
            }
            
            currentPhenotype.chr_chrs = append(currentPhenotype.chr_chrs, getChr(csvData[j][1]));
            String range = csvData[j][6];
            Range r = new Range();
            String rangeUpper = range.split("-")[1].trim();
            String rangeLower = range.split("-")[0].trim();
            
            if (float(csvData[j][2]) > unitThreshold) {
                currentPhenotype.chr_peaks = append(currentPhenotype.chr_peaks, (float)unitConverter.basePairsToCentimorgans(getChr(csvData[j][1]), Long.parseLong(csvData[j][2])));
                 r.lower = (float)unitConverter.basePairsToCentimorgans(getChr(csvData[j][1]), Long.parseLong(rangeLower));
                 r.upper = (float)unitConverter.basePairsToCentimorgans(getChr(csvData[j][1]), Long.parseLong(rangeUpper));
            } else {
                currentPhenotype.chr_peaks = append(currentPhenotype.chr_peaks, float(csvData[j][2]));
                r.upper = float(rangeUpper);
                r.lower = float(rangeLower);
                currentPhenotype.bayesintrange = (Range[])append(currentPhenotype.bayesintrange, r);
            }
        }
    } catch (Exception error) {
        println("EXCEPTION:");
        println(error.getLocalizedMessage());
        return false;
    }
    return true;
}
