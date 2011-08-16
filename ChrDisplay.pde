/**
* Class that handles the chromosome view.
*/
class ChrDisplay extends UIComponent {
  
    boolean chr_ready = true, update = true;
    PFont normFont = createFont("Arial", 12, true);
    float maxOffset = -1.0, chromosomeWidth, chromosomeHeight, multiplier;
    float maxLen = -1.0;
    
    ChrOrganizer[] chrs = new ChrOrganizer[chrLengths.length];
    
    public ChrDisplay(float newX, float newY, float newWidth, float newHeight) {
        super(newX, newY, newWidth, newHeight);
        
        for (int i = 0; i < chrs.length; i++) {
            chrs[i] = new ChrOrganizer();
        }
    }
    
    void update() {
        chromosomeWidth = cWidth / chrColumns;
        chromosomeHeight = cHeight / ceil(chrLengths.length / (float)chrColumns);
        multiplier = (chromosomeHeight - 24) / max(chrLengths);
        
        update = (ENABLE_KINECT) ? fileTree.hasUpdated() : (update || fileTree.hasUpdated());
        
        stroke(0x00);
        fill(0x00);
        strokeWeight(1);
        textFont(normFont);
        ellipseMode(CENTER);
        
        // draw chromosomes
        drawChromosomes(this);
        
        strokeWeight(1);
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
                    if (!update) {
                        continue;
                    }
                    
                    // recalculate, only if updating
                    for (int k = 0; k < currentPhenotype.bayesintrange.length; k++) {
                      
                        chrs[currentPhenotype.chr_chrs[k] - 1].add(
                            currentPhenotype.chr_peaks[k], // peak position in cM
                            currentPhenotype.bayesintrange[k], // range of values (length of colored line)
                            jTreeNode.drawcolor, // color of phenotype, line
                            x + (chromosomeWidth * ((currentPhenotype.chr_chrs[k] - 1) % chrColumns)) + 16, // x coordinate of the drawn chromosome
                            (multiplier * (currentPhenotype.bayesintrange[k].lower)) + y + (chromosomeHeight * floor((currentPhenotype.chr_chrs[k] - 1) / chrColumns)) + 20, // y coordinate of the drawn chromosome
                            multiplier * (currentPhenotype.bayesintrange[k].upper - currentPhenotype.bayesintrange[k].lower), // the length of the chromosome in pixels
                            (multiplier * ((currentPhenotype.chr_peaks[k] - 1))) + y + (chromosomeHeight * floor((currentPhenotype.chr_chrs[k] - 1) / chrColumns)) + 20 // the position of the peak in cM (used for sorting)
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
                    (float)chrs[i].uppers[j].getX() + (8 * chrs[i].layers[j]),
                    (float)chrs[i].uppers[j].getY(),
                    (float)chrs[i].uppers[j].getX() + (8 * chrs[i].layers[j]),
                    (float)chrs[i].uppers[j].getY() + chrs[i].heights[j]
                );
                
                ellipse(
                    (float)chrs[i].uppers[j].getX() + (8 * chrs[i].layers[j]),
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
    }
    
    void mouseAction() {
        // switch to LOD view if a chromosome is selected
        if (mousePressed && mouseButton == LEFT && mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y + cHeight) {
            if (floor((mouseX - x) / chromosomeWidth) + (chrColumns * floor((mouseY - y) / chromosomeHeight)) < chrLengths.length &&
                floor((mouseX - x) / chromosomeWidth) + (chrColumns * floor((mouseY - y) / chromosomeHeight)) >= 0) {
                
                int chrNum = floor((mouseX - x) / chromosomeWidth) + (chrColumns * floor((mouseY - y) / chromosomeHeight));
                
                if (chrs[chrNum].peaks.length > 0) {
                    loddisplay.current_chr = chrNum;
                    loddisplay.zoomFactor = 1.0;
                    loddisplay.offset = 0.0;
                    updateGenes = true;
                    tabs.prevPage();
                }
            }
        }
    }
    
    int size() { return 0; }
    
    void updateOrganizer() {
        
    }
}
