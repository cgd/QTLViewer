/**
* Class that handles the chromosome view.
*/
class ChrDisplay extends UIComponent {
  
    boolean dragReady = true, dragging = false, chr_ready = true, update = false;
    float legendX, legendY, legendW, legendH;
    PFont legendFont = createFont("Arial", 16, true), normFont = createFont("Arial", 12, true);
    float legendOffsetX = -1, legendOffsetY = -1, legendBorder = 0x00, maxOffset = -1.0, chromosomeWidth, chromosomeHeight, multiplier;

    ChrOrganizer[] chrs = new ChrOrganizer[chrLengths.length];
    
    public ChrDisplay(float newX, float newY, float newWidth, float newHeight) {
        super(newX, newY, newWidth, newHeight);
        legendX = width-400.0;
        legendY = 400.0;
        
        for (int i = 0; i < chrs.length; i++) {
            chrs[i] = new ChrOrganizer();
        }
    }
    
    void update() {
        if (cWidth <= 0.0) {
            cWidth = (width - x) + cWidth;
        }
        
        if (cHeight <= 0.0) {
            cHeight = (height - y) + cHeight;
        }
        
        chromosomeWidth = cWidth/chrColumns;
        chromosomeHeight = cHeight/ceil(chrLengths.length/chrColumns);
        multiplier = (chromosomeHeight - 24.0)/max(chrLengths);
        update = (update || fileTree.hasUpdated());
        
        stroke(0x00);
        fill(0x00);
        strokeWeight(1);
        textFont(normFont);
        ellipseMode(CENTER);
        
        // draw chromosomes
        for (int i = 0; i < chrLengths.length; i++) {
            strokeWeight(1);
            noStroke();
            
            text("chromosome " + chrNames[i], x+(chromosomeWidth*(i%chrColumns)) + 2, y + (chromosomeHeight*floor(i/chrColumns)) + 14); // draw the label
            ellipse(x + (chromosomeWidth*(i%chrColumns)) + 8, y + (chromosomeHeight*floor(i/chrColumns)) + 20, 8, 8); // draw marker, usually at the base
            
            strokeWeight(2);
            stroke(0x00);
            
            // (i % chrColumns) is the column that the chromosome is drawn in, chrColumns is defined in QTLViewer.pde and defaults to 7
            // (multiplier) is the ratio of the length of the longest chromosome to its length on the screen
            line(x + (chromosomeWidth*(i%chrColumns)) + 8, y + (chromosomeHeight*floor(i/chrColumns)) + 20 + (chrMarkerpos[i]*multiplier),
                x + (chromosomeWidth*(i%chrColumns)) + 8, y + (chromosomeHeight*floor(i/chrColumns)) + 20 + (multiplier*chrLengths[i]));
        }
        
        strokeWeight(1);
        textFont(legendFont);
        int[] colors = new int[0];
        String[] names = new String[0];
        float maxLen = -1.0;
        noStroke();
        fill(0x00);
        
        // clear the calculated values if the UI needs to update
        if (update) {
            for (ChrOrganizer co : chrs) {
                co.clear();
            }
        }
        
        for (int i = 0; i < parentFiles.size(); i++) {
            for (int j = 0; j < ((UITreeNode)fileTree.get(i)).size(); j++) {
                Phenotype currentPhenotype = ((Parent_File)parentFiles.get(i)).get(j);
                UITreeNode jTreeNode = ((UITreeNode)((UITreeNode)fileTree.get(i)).get(j));
                
                if (jTreeNode.checked) {
                    names = append(names, currentPhenotype.name+" ("+((UITreeNode)fileTree.get(i)).title+")");
                    colors = append(colors, jTreeNode.drawcolor);
                    
                    if (textWidth(currentPhenotype.name+" ("+((UITreeNode)fileTree.get(i)).title+")") > maxLen) {
                        maxLen = textWidth(currentPhenotype.name+" ("+((UITreeNode)fileTree.get(i)).title+")");
                    }
                    
                    if (!update) {
                        continue;
                    }
                    
                    // recalculate, only if updating
                    for (int k = 0; k < currentPhenotype.bayesintrange.length; k++) {
                      
                        chrs[currentPhenotype.chr_chrs[k] - 1].add(
                            currentPhenotype.chr_peaks[k], // peak position in cM
                            currentPhenotype.bayesintrange[k], // range of values (length of colored line)
                            jTreeNode.drawcolor, // color of phenotype, line
                            x + (chromosomeWidth*((currentPhenotype.chr_chrs[k] - 1)%chrColumns)) + 16, // x coordinate of the drawn chromosome
                            (multiplier*(currentPhenotype.bayesintrange[k].lower)) + y + (chromosomeHeight*floor((currentPhenotype.chr_chrs[k] - 1)/chrColumns)) + 20, // y coordinate of the drawn chromosome
                            multiplier*(currentPhenotype.bayesintrange[k].upper - currentPhenotype.bayesintrange[k].lower), // the length of the chromosome in pixels
                            (multiplier*((currentPhenotype.chr_peaks[k] - 1))) + y + (chromosomeHeight*floor((currentPhenotype.chr_chrs[k] - 1)/chrColumns)) + 20 // the position of the peak in cM (used for sorting)
                        );
                        
                    }
                }
            }
        } 
        
        // draw ranges, peaks
        for (int i = 0; i < chrs.length; i++) {
            for (int j = 0; j < chrs[i].peaks.length; j++) {
                fill(chrs[i].colors[j]);
                strokeWeight(1); 
                stroke(chrs[i].colors[j]);
                
                line(
                    (float)chrs[i].uppers[j].getX()+(8*chrs[i].layers[j]),
                    (float)chrs[i].uppers[j].getY(),
                    (float)chrs[i].uppers[j].getX()+(8*chrs[i].layers[j]),
                    (float)chrs[i].uppers[j].getY()+chrs[i].heights[j]
                );
                
                ellipse(
                    (float)chrs[i].uppers[j].getX()+(8*chrs[i].layers[j]),
                    chrs[i].peakYs[j],
                6, 6);
                
            }
        }
        
        if (update) {
            for (ChrOrganizer co : chrs) {
                co.organize();
            }
        }
        
        update = false;
             
        // manipulate the legend
        if (names.length > 0 && colors.length > 0) {
            if (mouseX > legendX && mouseX < legendX + legendW && mouseY > legendY && mouseY < legendY + legendH && active) {
                legendBorder += (legendBorder < 0xFF) ? frameRate/5.0 : 0;
                
                if (legendBorder > 0xFF) {
                    legendBorder = 0xFF;
                }
                
                if (dragReady && mousePressed && mouseButton == LEFT) {
                    dragging = true;
                    if (legendOffsetX == -1 || legendOffsetY == -1) {
                        legendOffsetX = mouseX - legendX;
                        legendOffsetY = mouseY - legendY; 
                    }
                }
            } else {
                legendBorder -= (legendBorder > 0x00) ? frameRate/5.0 : 0;
                
                if (legendBorder < 0x00) {
                    legendBorder = 0x00;
                }
            }
            
            if (dragging) {
                legendX = mouseX - legendOffsetX;
                legendY = mouseY - legendOffsetY;
                
                if (legendX < x) {
                    legendX = x;
                } else if (legendX > (x + cWidth) - legendW) {
                    legendX = (x + cWidth) - legendW;
                }
                
                if (legendY < y) {
                    legendY = y;
                } else if (legendY > (y + cHeight) - legendH) {
                    legendY = (y + cHeight) - legendH;
                }
            }
            
            if (!mousePressed || mouseButton != LEFT || !active) {
                legendOffsetX = legendOffsetY = -1;
                dragging = false;
            }
            
            fill(0x00, 0x2A);
            stroke(0x00, legendBorder);
            rect(legendX, legendY, (legendW=maxLen+18), (legendH=(names.length*16)+4));
            stroke(0x00);
            
            for (int i = 0; i < names.length; i++) {
                fill(colors[i]);
                rect(legendX+4.0, legendY+((i+1)*16)-11, 10, 10);
                fill(0x00);
                text(names[i], legendX+16.0, legendY+((i+1)*16));
            }
            
            if (mouseX > legendX && mouseX < legendX+legendW && mouseY > legendY && mouseY < legendY+legendH && active) {
                dragReady = (!mousePressed || mouseButton != LEFT);
            } else {
                dragReady = !(mousePressed && mouseButton == LEFT && active);
            }
            
            if (mouseX > x && mouseY > y && mouseX < width-50 && mouseY < height-100 && active) {
                chr_ready = (!mousePressed || mouseButton != LEFT);
            } else {
                chr_ready = !(mousePressed && mouseButton == LEFT && active && dragging);
            }
        }
    }
    
    void mouseAction() {
        // switch to LOD view if a chromosome is selected
        if (mousePressed && mouseButton == LEFT && !dragging && chr_ready && mouseX > x && mouseX < (x + cWidth) && mouseY > y && mouseY < (y + cHeight)
            && !(mouseX > legendX && mouseX < legendX + legendW && mouseY > legendY && mouseY < legendY + legendH)) {
              
            if (floor((mouseX - x)/chromosomeWidth) + (chrColumns*floor((mouseY - y)/chromosomeHeight)) < chrLengths.length &&
                floor((mouseX - x)/chromosomeWidth) + (chrColumns*floor((mouseY - y)/chromosomeHeight)) >= 0) {
                
                int chrNum = floor((mouseX - x)/chromosomeWidth) + (chrColumns*floor((mouseY - y)/chromosomeHeight));
                
                if (chrs[chrNum].peaks.length > 0) {
                    loddisplay.current_chr = chrNum;
                    tabs.prevPage();
                }
            }
        }
    }
    
    int size() { return 0; }
    
    void updateOrganizer() {
        
    }
}
