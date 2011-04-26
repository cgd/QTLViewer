/**
* This module is a container for methods that parse and read data.
*/

void addThresholdData(Phenotype currentPhenotype, ArrayList<HashMap<String, float[]>> thresholdData) {
    currentPhenotype.thresholds = new float[1][0];
    float[] th = thresholdData.get(0).get(currentPhenotype.name);
    
    for (float thf : th) {
        currentPhenotype.thresholds[0] = append(currentPhenotype.thresholds[0], thf);
    }
    
    if (thresholdData.size() > 1) {
        float[] thx = thresholdData.get(1).get(currentPhenotype.name);
        if (thresholdData.get(1).get(currentPhenotype.name) != null) {
            currentPhenotype.thresholds = (float[][])append(currentPhenotype.thresholds, new float[0]);
            for (float thf : thx) {
                currentPhenotype.thresholds[1] = append(currentPhenotype.thresholds[1], thf);
            }
            currentPhenotype.useXDefaults = false;
        }
    } else {
        currentPhenotype.useXDefaults = true;
    }
    
    currentPhenotype.useDefaults = false;
}

void addThresholdData(Phenotype currentPhenotype, String[][] csvThresh, int alphaCol) throws Exception {
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
}

void addThreshCSVFile(Phenotype currentPhenotype, InputStreamReader threshCSVFile) throws IOException, Exception {
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
}

void addPeakData(Phenotype currentPhenotype, float[][] values) {
    for (int j = 0; j < values.length; j++) {
        if (values[j].length == 0) {
            continue;
        }
        
        currentPhenotype.chr_chrs = append(currentPhenotype.chr_chrs, j+1);
        currentPhenotype.chr_peaks = append(currentPhenotype.chr_peaks, values[j][0]);
        Range r = new Range();
        r.upper = values[j][2];
        r.lower = values[j][1];
        currentPhenotype.bayesintrange = (Range[])append(currentPhenotype.bayesintrange, r);
    }
}

void addPeakData(Phenotype currentPhenotype, String[][] csvData) {
    for (int j = 1; j < csvData.length; j++) {
        if (csvData[j][0].startsWith(currentPhenotype.name)) {
            currentPhenotype.chr_chrs = (int[])append(currentPhenotype.chr_chrs, getChr(csvData[j][1]));
            currentPhenotype.chr_peaks = (float[])append(currentPhenotype.chr_peaks, csvData[j][2]);
            Range r = new Range();
            r.lower = float(csvData[j][3]);
            r.upper = float(csvData[j][4]);
            currentPhenotype.bayesintrange = (Range[])append(currentPhenotype.bayesintrange, r);
        }
    } 
}

void addPeakCSVFile(Phenotype currentPhenotype, InputStreamReader peakCSVFile) throws IOException, Exception {
    String[][] csvData = readCSV(peakCSVFile);
    for (int j = 1; j < csvData.length; j++) {
        if (csvData[j].length < 7) {
            continue;
        }
        
        currentPhenotype.chr_chrs = append(currentPhenotype.chr_chrs, getChr(csvData[j][1]));
        currentPhenotype.chr_peaks = append(currentPhenotype.chr_peaks, float(csvData[j][2]));
        String range = csvData[j][6];
        Range r = new Range();
        r.upper = float(range.split("-")[1].trim());
        r.lower = float(range.split("-")[0].trim());
        currentPhenotype.bayesintrange = (Range[])append(currentPhenotype.bayesintrange, r);
    }
}