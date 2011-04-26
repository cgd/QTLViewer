/**
* Class that handles the chromosome view.
*/
class ChrDisplay implements UIComponent {
  
    boolean focus = false, active = true, dragReady = true, dragging = false, chr_ready = true, update = false;
    double x = 25.0, y = 25.0, w, h, legendX, legendY, legendW, legendH;
    PFont legendFont = createFont("Arial", 16, true), normFont = createFont("Arial", 12, true);
    float legendOffsetX = -1, legendOffsetY = -1, legendA = 0x00, maxOffset = -1.0, chromosomeWidth, chromosomeHeight, multiplier;

    ChrOrganizer[] chrs = new ChrOrganizer[chrLengths.length];
    
    public ChrDisplay(double ex, double why, double doubleu, double ache) {
        legendX = width-400.0;
        legendY = 400.0;
        for (int i = 0; i < chrs.length; i++) chrs[i] = new ChrOrganizer();
        x = ex; y = why; w = doubleu; h = ache;
    }
    
    void update() {
        if (w <= 0.0) w = (width-x)+w;
        if (h <= 0.0) h = (height-y)+h;
        chromosomeWidth = (float)w/chrColumns;
        chromosomeHeight = (float)h/ceil(chrLengths.length/(float)chrColumns);
        multiplier = (chromosomeHeight-24.0)/max(chrLengths);
        update = (update || fileTree.hasUpdated());
        stroke(0x00);
        fill(0x00);
        strokeWeight(1);
        textFont(normFont);
        ellipseMode(CENTER);
        for (int i = 0; i < chrLengths.length; i++) {
            strokeWeight(1); noStroke();
            text("chromosome "+chrNames[i], (float)x+(chromosomeWidth*(i%chrColumns))+2/*(chromosomeWidth-(textWidth("chromosome "+str(i+1))/2.0))*/, (float)y+(chromosomeHeight*floor(i/(float)chrColumns))+14);
            ellipse((float)x+(chromosomeWidth*(i%chrColumns))+8/*+(chromosomeWidth/2.0)*/, (float)y+(chromosomeHeight*floor(i/(float)chrColumns))+20, 8, 8);
            strokeWeight(2); stroke(0x00);
            line((float)x+(chromosomeWidth*(i%chrColumns))+8/*+(chromosomeWidth/2.0)*/, (float)y+(chromosomeHeight*floor(i/(float)chrColumns))+20+(chrMarkerpos[i]*multiplier), (float)x+(chromosomeWidth*(i%chrColumns))+8/*+(chromosomeWidth/2.0)*/, (float)y+(chromosomeHeight*floor(i/(float)chrColumns))+20+(multiplier*chrLengths[i]));
        }
        strokeWeight(1);
        textFont(legendFont);
        int[] colors = new int[0];
        String[] names = new String[0];
        float maxLen = -1.0;
        noStroke(); fill(0x00);
        /*int num = 0; for (int i = 0; i < phenos.size(); i++) for (int j = 0; j < ((UITreeNode)filetree.get(i)).size(); j++)
            if (((UITreeNode)((UITreeNode)filetree.get(i)).get(j)).checked)
                num += ((UITreeNode)filetree.get(i)).size();*/
        if (update) for (ChrOrganizer co : chrs)
            co.clear();
        for (int i = 0; i < parentFiles.size(); i++) {
            for (int j = 0; j < ((UITreeNode)fileTree.get(i)).size(); j++) {
                Phenotype p = ((Parent_File)parentFiles.get(i)).get(j);
                UITreeNode tn = ((UITreeNode)((UITreeNode)fileTree.get(i)).get(j));
                if (tn.checked) {
                    names = append(names, p.name+" ("+((UITreeNode)fileTree.get(i)).title+")");
                    colors = append(colors, tn.drawcolor);
                    if (textWidth(p.name+" ("+((UITreeNode)fileTree.get(i)).title+")") > maxLen) maxLen = textWidth(p.name+" ("+((UITreeNode)fileTree.get(i)).title+")");
                    if (!update) continue;
                    for (int k = 0; k < p.bayesintrange.length; k++) {
                        chrs[p.chr_chrs[k]-1].add(p.chr_peaks[k], p.bayesintrange[k], tn.drawcolor, (float)x+(chromosomeWidth*((p.chr_chrs[k]-1)%chrColumns))+16/*+(chromosomeWidth/2.0)*/,
                            (multiplier*(p.bayesintrange[k].lower))+(float)y+(chromosomeHeight*floor((p.chr_chrs[k]-1)/(float)chrColumns))+20, 
                            multiplier*(p.bayesintrange[k].upper - p.bayesintrange[k].lower),
                            (multiplier*((p.chr_peaks[k]-1)))+(float)y+(chromosomeHeight*floor((p.chr_chrs[k]-1)/(float)chrColumns))+20);
                    }
                }
            }
        } for (int i = 0; i < chrs.length; i++) {
            for (int j = 0; j < chrs[i].peaks.length; j++) {
                fill(chrs[i].colors[j]); strokeWeight(1); stroke(chrs[i].colors[j]);
                line((float)chrs[i].uppers[j].getX()+(8*chrs[i].layers[j]), (float)chrs[i].uppers[j].getY(), (float)chrs[i].uppers[j].getX()+(8*chrs[i].layers[j]), (float)chrs[i].uppers[j].getY()+chrs[i].heights[j]);
                //zfill(255-red(chrs[i].colors[j]), 255-green(chrs[i].colors[j]), 255-blue(chrs[i].colors[j])); noStroke();
                ellipse((float)chrs[i].uppers[j].getX()+(8*chrs[i].layers[j]), chrs[i].peakYs[j], 6, 6);
            }
        }
        if (update) for (ChrOrganizer co : chrs) co.organize();
        update = false;
        //lastNum = num;                
        if (names.length > 0 && colors.length > 0) {
            if (mouseX > legendX && mouseX < legendX+legendW && mouseY > legendY && mouseY < legendY+legendH && active) {
                legendA += (legendA < 0xFF) ? frameRate/5.0 : 0;
                if (legendA > 0xFF) legendA = 0xFF;
                if (dragReady && mousePressed && mouseButton == LEFT) {
                    dragging = true;
                    if (legendOffsetX == -1 || legendOffsetY == -1) {
                        legendOffsetX = mouseX - (float)legendX;
                        legendOffsetY = mouseY - (float)legendY; 
                    }
                }
            } else {
                legendA -= (legendA > 0x00) ? frameRate/5.0 : 0;
                if (legendA < 0x00) legendA = 0x00;
            } if (dragging) {
                legendX = mouseX - legendOffsetX;
                legendY = mouseY - legendOffsetY;
                if (legendX < x) legendX = x;
                else if (legendX > (x+w)-legendW) legendX = (x+w)-legendW;
                if (legendY < y) legendY = y;
                else if (legendY > (y+h)-legendH) legendY = (y+h)-legendH;
            } if (!mousePressed || mouseButton != LEFT || !active) {
                legendOffsetX = legendOffsetY = -1;
                dragging = false;
            }
            fill(0x00, 0x2A);
            stroke(0x00, legendA);
            rect((float)legendX, (float)legendY, (float)(legendW=maxLen+18), (float)(legendH=(names.length*16)+4));
            stroke(0x00);
            for (int i = 0; i < names.length; i++) {
                fill(colors[i]);
                rect((float)legendX+4.0, (float)legendY+((i+1)*16)-11, 10, 10);
                fill(0x00);
                text(names[i], (float)legendX+16.0, (float)legendY+((i+1)*16));
            }
            if (mouseX > legendX && mouseX < legendX+legendW && mouseY > legendY && mouseY < legendY+legendH && active)
                dragReady = (!mousePressed || mouseButton != LEFT);
            else dragReady = !(mousePressed && mouseButton == LEFT && active);
            if (mouseX > x && mouseY > y && mouseX < width-50 && mouseY < height-100 && active)
                chr_ready = (!mousePressed || mouseButton != LEFT);
            else chr_ready = !(mousePressed && mouseButton == LEFT && active && dragging);
        }
    }
    
    void mouseAction() {
        if (mousePressed && mouseButton == LEFT && !dragging && chr_ready && mouseX > x && mouseX < (x+w) && mouseY > y && mouseY < (y+h)
            && !(mouseX > legendX && mouseX < legendX+legendW && mouseY > legendY && mouseY < legendY+legendH))
            if (floor((mouseX-(float)x)/chromosomeWidth)+(chrColumns*floor((mouseY-(float)y)/chromosomeHeight)) < chrLengths.length && floor((mouseX-(float)x)/chromosomeWidth)+(chrColumns*floor((mouseY-(float)y)/chromosomeHeight)) >= 0) {
                int c = floor((mouseX-(float)x)/chromosomeWidth)+(chrColumns*floor((mouseY-(float)y)/chromosomeHeight));
                if (chrs[c].peaks.length > 0) {
                    loddisplay.current_chr = c;
                    //folder.prevPage();
                    tabs.prevPage();
                }
            }
    }
    void keyAction(char c, int i, int j) { }
    int size() { return 0; }
    void addComponent(UIComponent p) { }
    void addComponent(UIComponent p, int i, int j) { }
    void removeComponent(int index1, int index2) { }
    void updateComponents() { }
    boolean isFocused() { return focus; }
    void setFocus(boolean f) { focus = f; }
    void setX(double newx) { }
    void setY(double newy) { }
    double getX() { return 0.0; }
    double getY() { return 0.0; }
    String toString() { return ""; }
    void setActive(boolean a) { active = a; }
    boolean isActive() { return active; }
    void updateOrganizer() {
        
    }
}

class ChrOrganizer {
    int[] colors, layers;
    Range[] ranges;
    float[] peaks, heights, peakYs;
    Point[] uppers;
    public ChrOrganizer() {
        clear();
    }
    void add(float p, Range r, int c, float ex, float why, float h, float peaky) {
        colors = append(colors, c);
        layers = append(layers, 0);
        ranges = (Range[])append(ranges, r);
        peaks = append(peaks, p);
        Point po = new Point();
        po.setLocation(ex, why);
        uppers = (Point[])append(uppers, po);
        heights = append(heights, h);
        peakYs = append(peakYs, peaky);
    }
    void clear() {
        colors = new int[0];
        layers = new int[0];
        ranges = new Range[0];
        peaks = new float[0];
        uppers = new Point[0];
        heights = new float[0];
        peakYs = new float[0];
    }
    void organize() {
        boolean sorted = false;
        for (int i = 1; i < peaks.length; i++) {
            if (peaks[i] < peaks[i-1]) {
                float t1 = peaks[i]; Range t2 = ranges[i]; color t3 = colors[i]; Point t4 = uppers[i]; float t5 = heights[i]; float t6 = peakYs[i];
                peaks[i] = peaks[i-1]; ranges[i] = ranges[i-1]; colors[i] = colors[i-1]; uppers[i] = uppers[i-1]; heights[i] = heights[i-1]; peakYs[i] = peakYs[i-1];
                peaks[i-1] = t1; ranges[i-1] = t2; colors[i-1] = t3; uppers[i-1] = t4; heights[i-1] = t5; peakYs[i-1] = t6;
                sorted = false;
            } else sorted = true;
            if (!sorted) i = 0;
        }
        layers = new int[0];
        if (peaks.length == 0) return;
        layers = append(layers, 0);
        for (int i = 1; i < peaks.length; i++) {
            boolean canFit = false;
            for (int j = 0; j < layers.length; j++) {
                if (ranges[i].lower > ranges[j].upper || ranges[i].upper < ranges[j].lower) {
                    canFit = true;
                    for (int k = j+1; k < layers.length; k++) {
                        if (layers[k] != layers[j]) continue;
                        if (ranges[i].lower > ranges[k].upper || ranges[i].upper < ranges[k].lower)
                            canFit = true;
                        else { canFit = false; break; }
                    } if (canFit) {
                        layers = append(layers, layers[j]);
                        break;
                    }
                }
            }
            if (!canFit) layers = append(layers, max(layers)+1);
        }
    }
}
