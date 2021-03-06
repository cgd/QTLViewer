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

int[] geneColors  = new int[] {
  color(0xFF, 0x00, 0x00),
  color(0x00, 0xFF, 0x00),
  color(0x00, 0x00, 0xFF),
  color(0xFF, 0xFF, 0x00),
  color(0xFF, 0x00, 0xFF),
  color(0x00, 0xFF, 0xFF)
};

int cIndex = 0;

class Gene {
    String name, altName;
    int chromosome;
    char strand;
    float geneStart, geneEnd; // stored as cM, in file as bP
    float codeStart, codeEnd;
    float[][] exons = null;
    boolean draw = true;
    int drawColor;
    
    Gene(String line) { // parse a line from gene file
        String[] segs = line.split("\t");
        name = segs[0].trim();
        altName = segs[1].trim();
        chromosome = getChr(segs[2]);
        
        if (chromosome > chrLengths.length) { // chromosome Y (?)
            draw = false;
            return;
        }
        
        strand = segs[3].trim().toCharArray()[0];
        geneStart = (float)unitConverter.basePairsToCentimorgans(chromosome, Long.parseLong(segs[4]));
        geneEnd = (float)unitConverter.basePairsToCentimorgans(chromosome, Long.parseLong(segs[5]));
        codeStart = (float)unitConverter.basePairsToCentimorgans(chromosome, Long.parseLong(segs[6]));
        codeEnd = (float)unitConverter.basePairsToCentimorgans(chromosome, Long.parseLong(segs[7]));

        int exonCount = int(getNumeric(segs[8]));
        String[] exonStarts = segs[9].split(",");
        String[] exonEnds = segs[10].split(",");
        
        if (exonCount >= 0) {
            exons = new float[exonCount][2];
            
            for (int i = 0; i < exonCount; i++) {
                float start = (float)unitConverter.basePairsToCentimorgans(chromosome, Long.parseLong(exonStarts[i]));
                float end = (float)unitConverter.basePairsToCentimorgans(chromosome, Long.parseLong(exonEnds[i]));
                
                exons[i]  = new float[] { start, end };
            }
        }
        
        drawColor = geneColors[cIndex++ % geneColors.length];
    }
    
    boolean drawThis(float startPos, float endPos) {
        if (!draw) {
            return false;
        }
        
        return (geneEnd >= startPos && geneStart <= endPos);
    }
    
    boolean drawThis(double startPos, double endPos) {
        if (!draw) {
            return false;
        }
        
        return (geneEnd >= startPos && geneStart <= endPos);
    }
}

Gene[] readGenes(InputStreamReader reader) throws IOException {
    Gene[] ret = new Gene[0];
    char[] cbuf = new char[2048000], total = new char[0];
    int readLen, oldLen;
    
    while ((readLen = reader.read(cbuf, 0, cbuf.length)) != -1) {
        total = expand(total, (oldLen = total.length) + readLen);
        arrayCopy(cbuf, 0, total, oldLen, readLen);
    }
    
    String[] lines = new String(total).split("\n");
    
    ArrayList<String> names = new ArrayList<String>();
    
    for (String l : lines) {
        if (l.trim().length() > 0) {
            Gene g;
            ret = (Gene[])append(ret, g = new Gene(l));
            
            if (names.contains(g.name.toLowerCase())) {
                ret[ret.length - 1].draw = g.draw = false;
            } else {
                names.add(g.name.toLowerCase());
            }
        }
    }
    
    return ret;
}

String getNumeric(String s) {
    String ret = "";
    
    for (char c : s.toCharArray()) {
        if (c == 46 || (c >= 48 && c <= 57)) {
            ret += c;
        }
    }
    
    return ret;
}
