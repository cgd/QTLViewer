/**
* ChrOrganizer class: organizes peak ranges so that they fit in the ChrDisplay efficiently.
*
* Unfortunately, any model seems to have similar ranges for each chromosome, so there is not usually a more efficient way.
*/
class ChrOrganizer {
    int[] colors, layers;
    Range[] ranges;
    float[] peaks, heights, peakYs;
    Point[] uppers;
    
    public ChrOrganizer() {
        clear();
    }
    
    void add(float peak, Range lineRange, int phenotypeColor, float x, float y, float chrLength, float peakY) {
        colors = append(colors, phenotypeColor);
        layers = append(layers, 0);
        ranges = (Range[])append(ranges, lineRange);
        peaks = append(peaks, peak);
        Point drawPoint = new Point();
        drawPoint.setLocation(x, y);
        uppers = (Point[])append(uppers, drawPoint);
        heights = append(heights, chrLength);
        peakYs = append(peakYs, peakY);
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
                float t1 = peaks[i]; // temp vars
                Range t2 = ranges[i]; 
                color t3 = colors[i]; 
                Point t4 = uppers[i]; 
                float t5 = heights[i]; 
                float t6 = peakYs[i];
                peaks[i] = peaks[i-1]; 
                ranges[i] = ranges[i-1]; 
                colors[i] = colors[i-1]; 
                uppers[i] = uppers[i-1]; 
                heights[i] = heights[i-1]; 
                peakYs[i] = peakYs[i-1];
                peaks[i-1] = t1; 
                ranges[i-1] = t2; 
                colors[i-1] = t3; 
                uppers[i-1] = t4; 
                heights[i-1] = t5; 
                peakYs[i-1] = t6;
                
                sorted = false;
            } else {
                sorted = true;
            }
            
            if (!sorted) {
                i = 0; // start back at index 1
            }
        }
        
        layers = new int[0];
        layers = append(layers, 0);
        
        if (peaks.length == 0) {
            return;
        }
        
        
        for (int i = 1; i < peaks.length; i++) {
            boolean canFit = false;
            
            for (int j = 0; j < layers.length; j++) {
                if (ranges[i].lower > ranges[j].upper || ranges[i].upper < ranges[j].lower) { // range i can fit either above or below range j
                    canFit = true;
                    
                    for (int k = j + 1; k < layers.length; k++) { // look through the rest of the layers
                        if (layers[k] != layers[j]) {
                            continue;
                        }
                        
                        if (ranges[i].lower > ranges[k].upper || ranges[i].upper < ranges[k].lower) {
                            canFit = true;
                        } else {
                            canFit = false;
                            break;
                        }
                    }
                    
                    if (canFit) {
                        layers = append(layers, layers[j]);
                        break;
                    }
                }
            }
            
            if (!canFit) {
                layers = append(layers, max(layers) + 1); // add a new layer to accomodate the range
            }
        }
    }
}

/**
* Updates the legend for a ChrDisplay.
*
* @param display the ChrDisplay on which to draw the legend
* @param names a String array containing the names of the phenotypes
* @param colors an int array containing the colors of the phenotypes
*/
void updateLegend(ChrDisplay display, String[] names, int[] colors) {
    if (mouseX > display.legendX && mouseX < display.legendX + display.legendW && mouseY > display.legendY && mouseY < display.legendY + display.legendH && display.active) {
        display.legendBorder += (display.legendBorder < 0xFF) ? frameRate/5.0 : 0;
                
        if (display.legendBorder > 0xFF) {
            display.legendBorder = 0xFF;
        }
        
        if (display.dragReady && mousePressed && mouseButton == LEFT) {
            display.dragging = true;
            if (display.legendOffsetX == -1 || display.legendOffsetY == -1) {
                display.legendOffsetX = mouseX - display.legendX;
                display.legendOffsetY = mouseY - display.legendY;
            }
        }
    } else {
        display.legendBorder -= (display.legendBorder > 0x00) ? frameRate/5.0 : 0;
        
        if (display.legendBorder < 0x00) {
            display.legendBorder = 0x00;
        }
    }
    
    if (display.dragging) {
        display.legendX = mouseX - display.legendOffsetX;
        display.legendY = mouseY - display.legendOffsetY;
    }
    
    if (display.legendX < display.x) {
        display.legendX = display.x;
    } else if (display.legendX > (display.x + display.cWidth) - display.legendW) {
        display.legendX = (display.x + display.cWidth) - display.legendW;
    }
    
    if (display.legendY < display.y) {
        display.legendY = display.y;
    } else if (display.legendY > (display.y + display.cHeight) - display.legendH) {
        display.legendY = (display.y + display.cHeight) - display.legendH;
    }
    
    if (!mousePressed || mouseButton != LEFT || !display.active) {
        display.legendOffsetX = display.legendOffsetY = -1;
        display.dragging = false;
    }
    
    fill(0x00, 0x2A);
    stroke(0x00, display.legendBorder);
    rect(display.legendX, display.legendY, (display.legendW=display.maxLen+18), (display.legendH=(names.length*16)+4));
    stroke(0x00);
    
    for (int i = 0; i < names.length; i++) {
        fill(colors[i]);
        rect(display.legendX + 4.0, display.legendY+((i + 1)*16) - 11, 10, 10);
        fill(0x00);
        text(names[i], display.legendX + 16.0, display.legendY + ((i + 1)*16));
    }
    
    if (mouseX > display.legendX && mouseX < display.legendX+display.legendW && mouseY > display.legendY && mouseY < display.legendY+display.legendH && display.active) {
        display.dragReady = (!mousePressed || mouseButton != LEFT);
    } else {
        display.dragReady = !(mousePressed && mouseButton == LEFT && display.active);
    }
    
    if (mouseX > display.x && mouseY > display.y && mouseX < width-50 && mouseY < height-100 && display.active) {
        display.chr_ready = (!mousePressed || mouseButton != LEFT);
    } else {
        display.chr_ready = !(mousePressed && mouseButton == LEFT && display.active && display.dragging);
    }
}

/**
* Draws the blank chromosomes on a ChrDisplay
*
* @param display the ChrDisplay on which to draw chromosomes
*/
void drawChromosomes(ChrDisplay display) {
    for (int i = 0; i < chrLengths.length; i++) {
        strokeWeight(1);
        noStroke();
        
        text("chromosome " + chrNames[i], display.x + (display.chromosomeWidth*(i%chrColumns)) + 2, display.y + (display.chromosomeHeight*floor(i/chrColumns)) + 14); // draw the label
        ellipse(display.x + (display.chromosomeWidth*(i%chrColumns)) + 8, display.y + (display.chromosomeHeight*floor(i/chrColumns)) + 20, 8, 8); // draw marker, usually at the base
        
        strokeWeight(2);
        stroke(0x00);
        
        // (i % chrColumns) is the column that the chromosome is drawn in, chrColumns is defined in QTLViewer.pde and defaults to 7
        // (multiplier) is the ratio of the length of the longest chromosome to its length on the screen
        line(display.x + (display.chromosomeWidth*(i%chrColumns)) + 8, display.y + (display.chromosomeHeight*floor(i/chrColumns)) + 20 + (chrMarkerpos[i]*display.multiplier),
            display.x + (display.chromosomeWidth*(i%chrColumns)) + 8, display.y + (display.chromosomeHeight*floor(i/chrColumns)) + 20 + (display.multiplier*chrLengths[i]));
    }
}
