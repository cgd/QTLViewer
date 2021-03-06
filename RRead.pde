/*
* Copyright (c) 2010 The Jackson Laboratory
*
* This software was developed by Matt Hibbs' Lab at The Jackson
* Laboratory (see http://cbfg.jax.org/).
*
* This is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

/**
* RRead module, methods used to read files of different formats generated by R.
*/

/**
* Reads peaks from a .txt file.
*
* @param threshFileReader an InputStreamReader to read text from
* @return a HashMap matching Strings (phenotype names) to float matrices (ranges)
*/
public HashMap<String, float[][]> readPeaks(InputStreamReader threshFileReader) throws IOException, Exception {
    HashMap<String, float[][]> data = new HashMap<String, float[][]>();
    char[] cbuf = new char[2048], total = new char[0];
    int len, oldLen;
    
    while ((len = threshFileReader.read(cbuf, 0, cbuf.length)) != -1) {
        total = expand(total, (oldLen = total.length) + len);
        arrayCopy(cbuf, 0, total, oldLen, len);
    }
    
    int i = 0;
    while (i < total.length) {
        if (total[i] == '\n') { 
            i++;
            continue;
        }
        
        float[][] values = new float[chrLengths.length][0];
        int c = 0;
        
        while (i + c < total.length && total[i+(c++)] != ':'); // read until a colon is encountered
        
        String label = new String(total, i, c-1);
        i += ++c;
        String text = "";
        
        while (i < total.length && total[i++] != '\n') {
            text += total[i];
        }
        
        String[] headers = splitNoDupes(text);
        
        while (i < total.length && total[i] != '\n') {
            String text1 = "";
            
            while (i < total.length && total[i++] != '\n') {
                text1 += total[i];
            }
            
            String[] cols = splitNoDupes(text1);
            values[getChr(cols[1]) - 1] = new float[3];
            
            for (int j = 0; j < 3; j++) {
                if (float(cols[j + 2]) > unitThreshold) {
                    values[getChr(cols[1]) - 1][j] = (float)unitConverter.basePairsToCentimorgans(getChr(cols[1]), Long.parseLong(cols[j + 2]));
                } else {
                    values[getChr(cols[1]) - 1][j] = float(cols[j + 2]);
                }
            }
        }
        data.put(label, values);
    }
    
    return data;
}

/**
* Reads thresholds from a .txt file.
*
* @param threshFileReader an InputStreamReader to read text from
* @param phenos a String array of phenotype names
* @return an ArrayList of HashMaps matching Strings (phenotype names) to float arrays (thresholds)
*/
public ArrayList<HashMap<String, float[]>> readThresholds(InputStreamReader threshFileReader, String[] phenos) throws IOException, Exception {
    ArrayList<HashMap<String, float[]>> data = new ArrayList<HashMap<String, float[]>>();
    char[] cbuf = new char[2048], total = new char[0];
    int len, oldLen;
    
    while ((len = threshFileReader.read(cbuf, 0, cbuf.length)) != -1) {
        total = expand(total, (oldLen = total.length) + len);
        arrayCopy(cbuf, 0, total, oldLen, len);
    }
    
    int i = 0;
    
    while (i < total.length) {
        while (i < total.length && total[i++] != '\n');
        int c = 0;
        
        while (c + i < total.length && total[i + (c++)] != '\n'); // read until a newline is encountered
        
        HashMap<String, float[]> entry = new HashMap<String, float[]>();
        String line = new String(total, i, c).trim();
        i += c;
        String[][] table = new String[0][0];
        
        while (i < total.length && total[i++] != '\n') {
            c = 0;
            while (c + i < total.length && total[i + (c++)] != '\n');
            String ls = new String(total, i , c).trim();
            table = (String[][])append(table, splitNoDupes(ls));
            i += c;
        }

        int col = 0;
        for (int j = 0; j < phenos.length && line.length() > 0; j++) {
            if (line.substring(0, phenos[j].length()).equals(phenos[j])) {
                float[] values = new float[table.length];
                
                for (int k = 0; k < values.length; k++) {
                    values[k] = float(table[k][col + 1]);
                }
                
                entry.put(phenos[j], values);
                line = line.substring(phenos[j].length()).trim();
                j = -1;
                col++;
            }
        }
        data.add(entry);
    }
    return data;
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
ArrayList<HashMap<String, float[]>> getThresholdData(InputStreamReader pathInput, String[] names, Parent_File parent) throws FileNotFoundException, IOException, Exception {
    ArrayList<HashMap<String, float[]>> threshData = readThresholds(pathInput, names);
    for (int i = 0; i < threshData.size(); i++) {
        HashMap<String, float[]> h = threshData.get(i);
        Iterator it = h.keySet().iterator();
        String[] tnames = new String[0];
        
        while (it.hasNext()) {
            tnames = (String[])append(tnames, it.next());
        }
        
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

/**
* Reads thresholds from a .txt file.
*
* @param threshFileReader an InputStreamReader to read text from
* @param parent the Parent_File containing information on other phenotypes
* @param names a String array of phenotype
* @param phenos a String array of phenotype names
* @param alphaArray an int array to store the alpha column of the file
* @return a String matrix of CSV data
*/
String[][] getThresholdData(InputStreamReader threshFileReader, Parent_File parent, String[] names, int[] alphaArray) throws IOException, Exception {
    String[][] csvThresh = readCSV(threshFileReader);
    
    int alphaCol = -1;
    
    if (csvThresh[0][1].equalsIgnoreCase("alpha")) {
        alphaCol = 0;
    }

    if (csvThresh[0].length == 3 && names.length > 1) {
        String mark = (alphaCol >= 0) ? csvThresh[1][alphaCol] : "";
        
        for (int i = 1; i < csvThresh.length; i++) {
            if (!csvThresh[i][alphaCol].equals(mark) && alphaCol != -1) {
                if (parent.data.length == 1) {
                    parent.data = (float[][])append(parent.data, new float[0]);
                }
                
                parent.data[1] = (float[])append(parent.data[1], float(csvThresh[i][2]));
            } else {
                parent.data[0] = (float[])append(parent.data[0], float(csvThresh[i][2]));
            }
        }
        
        parent.useModelThresholds = true;
    }

    alphaArray[0] = alphaCol;
    return csvThresh;
}

/**
* Splits a String, removing any extra spaces.
*
* @param s the String to split
* @return the array of non-empty Strings
*/
private String[] splitNoDupes(String s) {
    String[] split = s.split(" ");
    String[] ret = new String[0];
    
    for (String t : split) {
        if (!t.trim().equals(" ") && t.length() != 0) {
            ret = append(ret, t.trim());
        }
    }
    
    return ret;
}
