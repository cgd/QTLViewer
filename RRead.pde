/**
*
*/
public HashMap<String, float[][]> readPeaks(InputStreamReader e) throws IOException, Exception {
    HashMap<String, float[][]> data = new HashMap<String, float[][]>();
    char[] cbuf = new char[10], total = new char[0];
    int l, oldl;
    while ((l = e.read(cbuf, 0, cbuf.length)) != -1) {
        total = expand(total, (oldl = total.length) + l);
        arrayCopy(cbuf, 0, total, oldl, l);
    }
    int i = 0;
    while (i < total.length) {
        if (total[i] == '\n') { i++; continue; }
        float[][] values = new float[chrLengths.length][0];
        int c = 0;
        while (i+c < total.length && total[i+(c++)] != ':');
        String label = new String(total, i, c-1);
        i += ++c;
        String text = "";
        while (i < total.length && total[i++] != '\n') text += total[i];
        String[] headers = splitNoDupes(text);
        while (i < total.length && total[i] != '\n') {
            String text1 = "";
            while (i < total.length && total[i++] != '\n') text1 += total[i];
            String[] cols = splitNoDupes(text1);
            values[getChr(cols[1])-1] = new float[3];
            for (int j = 0; j < 3; j++) values[getChr(cols[1])-1][j] = float(cols[j+2]);
        }
        data.put(label, values);
    }
    return data;
}

public ArrayList<HashMap<String, float[]>> readThresholds(InputStreamReader e, String[] phenos, String[] percents, String[] info_ptr) throws IOException, Exception {
    ArrayList<HashMap<String, float[]>> data = new ArrayList<HashMap<String, float[]>>();
    char[] cbuf = new char[10], total = new char[0];
    int l, oldl;
    while ((l = e.read(cbuf, 0, cbuf.length)) != -1) {
        total = expand(total, (oldl = total.length) + l);
        arrayCopy(cbuf, 0, total, oldl, l);
    }
    int i = 0;
    while (i < total.length) {
        while (i < total.length && total[i++] != '\n');
        int c = 0;
        while (c+i < total.length && total[i+(c++)] != '\n');
        HashMap<String, float[]> entry = new HashMap<String, float[]>();
        String line = new String(total, i, c).trim();
        i += c;
        String[][] table = new String[0][0];
        while (i < total.length && total[i++] != '\n') {
            c = 0;
            while (c+i < total.length && total[i+(c++)] != '\n');
            String ls = new String(total, i , c).trim();
            table = (String[][])append(table, splitNoDupes(ls));
            i += c;
        }
        /*if (table[0].length == 2) { // only one threshold for the model
            float[] values = new float[table.length];
            for (int k = 0; k < values.length; k++)
                    /*println("\t"+(values[k] = float(table[k][1]);//));
            entry.put("*", values);
            data.add(entry);
            continue;
        }*/
        int col = 0;
        for (int j = 0; j < phenos.length && line.length() > 0; j++) {
            if (line.substring(0, phenos[j].length()).equals(phenos[j])) {
                float[] values = new float[table.length];
                for (int k = 0; k < values.length; k++)
                    values[k] = float(table[k][col+1]);
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

private String[] splitNoDupes(String s) {
    String[] split = s.split(" ");
    String[] ret = new String[0];
    for (String t : split) {
        if (!t.trim().equals(" ") && t.length() != 0) ret = append(ret, t.trim());
    }
    return ret;
}
