/*
* Copyright (c) 2010 The Jackson Laboratory
*
* This software was developed by Matt Hibbs's Lab at The Jackson
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
* This uses the default entry delimeter.
*
* See readCSV(InputStreamReader, char)
*/
String[][] readCSV(InputStreamReader reader) throws IOException, Exception {
    return readCSV(reader, ',');
}

/**
* This method parses a CSV file, and returns a matrix of the values as Strings.
*
* @param reader the InputStreamReader being used to read the file
* @param delim the character separating entries (usually ',')
* @return the matrix (two-dimensional array) of table entries in the file
*/
String[][] readCSV(InputStreamReader reader, char delim) throws IOException, Exception {
    char[] cbuf = new char[2048], total = new char[0];
    int readLen, oldLen;
    String[][] returnData = new String[1][0]; // String matrix to be returned
    boolean inQuotes = false; // whether or not a quoted entry is being parsed
    String data = ""; // one entry in the table
    
    while ((readLen = reader.read(cbuf, 0, cbuf.length)) != -1) {
        total = expand(total, (oldLen = total.length) + readLen);
        arrayCopy(cbuf, 0, total, oldLen, readLen);
    }
    
    for (int i = 0; i < total.length; i++) {
        if (total[i] == delim && !inQuotes) { // reached delimiter, not in quotes
            returnData[returnData.length - 1] = append(returnData[returnData.length - 1], data);
            data = "";
            continue;
        } else if (!inQuotes && total[i] == '"') { // reached a quoted entry
            inQuotes = true;
            continue;
        } else if (inQuotes && total[i] == '"') { // ended a quoted entry...
            if (i == total.length - 1) {
                inQuotes = false;
                returnData[returnData.length - 1] = append(returnData[returnData.length - 1], data);
                data = "";
                continue;
            } else { // ...unless it is escaped with a following quote
                if (total[i + 1] == '"') {
                    data += total[i++];
                } else {
                    inQuotes = false;
                    //returnData[returnData.length - 1] = append(returnData[returnData.length - 1], data);
                    //data = "";
                }
                continue;
            }
        } else if (!inQuotes && (total[i] == '\n' || total[i] == '\r')) { // reached a new line/entry
        
            if (i < total.length - 1 && total[i + 1] == '\n') {
                i++;
            }
            
            returnData[returnData.length - 1] = append(returnData[returnData.length - 1], data);
            data = "";
            returnData = (String[][])append(returnData, new String[0]);
            continue;
        } else if (i == total.length - 1) { // reached the last character
            data += total[i];
            returnData[returnData.length - 1] = append(returnData[returnData.length - 1], data);
            data = "";
            continue;
        }
        data += total[i]; // just another character to be added
    }
    
    if (returnData[returnData.length - 1].length == 0) {
        returnData = (String[][])shorten(returnData);
    }
    
    return returnData;
}
