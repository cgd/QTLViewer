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
    char[] cbuf = new char[10], total = new char[0];
    int l, oldl;
    String[][] ret = new String[1][0];
    boolean inQuotes = false;
    String data = "";
    
    while ((l = reader.read(cbuf, 0, cbuf.length)) != -1) {
        total = expand(total, (oldl = total.length) + l);
        arrayCopy(cbuf, 0, total, oldl, l);
    }
    
    for (int i = 0; i < total.length; i++) {
        if (total[i] == delim && !inQuotes) {
            ret[ret.length - 1] = append(ret[ret.length - 1], data);
            data = "";
            continue;
        } else if (!inQuotes && total[i] == '"') {
            inQuotes = true;
            continue;
        } else if (inQuotes && total[i] == '"') {
            if (i == total.length - 1) {
                inQuotes = false;
                ret[ret.length - 1] = append(ret[ret.length - 1], data);
                data = "";
                continue;
            } else {
                if (total[i + 1] == '"') {
                    data += total[i++];
                } else {
                    inQuotes = false;
                    //ret[ret.length - 1] = append(ret[ret.length - 1], data);
                    //data = "";
                }
                continue;
            }
        } else if (!inQuotes && (total[i] == '\n' || total[i] == '\r')) {
            if (i < total.length - 1 && total[i + 1] == '\n') {
                i++;
            }
            
            ret[ret.length - 1] = append(ret[ret.length - 1], data);
            data = "";
            ret = (String[][])append(ret, new String[0]);
            continue;
        } else if (i == total.length - 1) {
            data += total[i];
            ret[ret.length - 1] = append(ret[ret.length - 1], data);
            data = "";
            continue;
        }
        data += total[i];
    }
    
    if (ret[ret.length-1].length == 0) {
        ret = (String[][])shorten(ret);
    }
    
    return ret;
}
