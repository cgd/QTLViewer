/**
* @return the index of the last chromosome for which any phenotype has data
*/
int lastChr() {
    int maxChr = -1;
    
    for(int i = 0; i < parentFiles.size(); i++) {
        Parent_File parent = (Parent_File)parentFiles.get(i);
        
        for (int j = 0; j < parent.size(); j++) {
            Phenotype currentPhenotype = parent.get(j);
            
            if (((UITreeNode)((UITreeNode)fileTree.get(i)).get(j)).checked && currentPhenotype.chromosome[currentPhenotype.chromosome.length - 1] > maxChr) {
                maxChr = currentPhenotype.chromosome[currentPhenotype.chromosome.length - 1];
            }
        }
    }
    
    return maxChr;
}

/**
* Stores tha max LOD score and max position from the base
*
* @param display the LODDisplay object
*/

void findMax(LODDisplay display) {
    maxLod = display.maxOffset = -1.0;
    
    for(int i = 0; i < parentFiles.size(); i++) {
        Parent_File parent = (Parent_File)parentFiles.get(i);
        
        for (int j = 0; j < parent.size(); j++) {
            Phenotype currentPhenotype = parent.get(j);
            
            if (((UITreeNode)((UITreeNode)fileTree.get(i)).get(j)).checked) {
                float tempmaxLod;
                
                if (display.current_chr == -1 && (tempmaxLod = max(currentPhenotype.lodscores)) > maxLod) {
                    maxLod = tempmaxLod;
                } else {
                  
                    for (int k = 0; k < currentPhenotype.lodscores.length; k++) {
                      
                        if (currentPhenotype.chromosome[k] == display.current_chr + 1) {
                          
                            if (currentPhenotype.lodscores[k] > maxLod) {
                                maxLod = currentPhenotype.lodscores[k];
                            }
                            
                            if (currentPhenotype.position[k] > display.maxOffset) {
                                display.maxOffset = currentPhenotype.position[k];
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (display.maxOffset != -1.0 && display.maxOffset < chrLengths[display.current_chr]) {
        display.maxOffset = chrLengths[display.current_chr];
    }
}

/**
* Draws the numbers on the left side of the graph.
*
* @param display the LODDisplay on which to draw
* @param tempMaxLod the maximum LOD score of those being drawn
* @return the new max LOD for those being drawn
*/
int drawLODScale(LODDisplay display, int tempMaxLod) {
    if (maxLod < 1.0) {
        tempMaxLod = 1;
        float y_off = map(tempMaxLod, 0.0, tempMaxLod, 0.0, display.cHeight - 50);
        text("1", display.x - 16 - textWidth("1"), (display.y + display.cHeight) - 50 - y_off + 8);
        line(display.x, (display.y + display.cHeight) - 50 - y_off, display.x - 16, (display.y + display.cHeight) - 50 - y_off);
        y_off = map(0, 0.0, tempMaxLod, 0.0, display.cHeight - 50);
        text("0", display.x - 16 - textWidth("0"), (display.y + display.cHeight) - 50 - y_off + 8);
        line(display.x, (display.y + display.cHeight) - 50 - y_off, display.x - 16, (display.y + display.cHeight) - 50 - y_off);
    } else {
        for (int i = 0; i <= 4; i++) {
            int value = round((i*tempMaxLod)/4.0);
            float y_off = map(value, 0.0, tempMaxLod, 0.0, display.cHeight - 50);
            text(str(value), display.x - 16 - textWidth(str(value)), (display.y + display.cHeight) - 50 - y_off + 8);
            line(display.x, (display.y + display.cHeight) - 50 - y_off, display.x - 16, (display.y + display.cHeight) - 50 - y_off);
        }
    }
    
    return tempMaxLod;
}

/**
* Draws the threshold labels, including the X chromosome
*
* @param display the LODDisplay on which to draw the labels
* @param currentPhenotype the Phenotype object that contains the threshold data to be drawn
* @param endX the X offset of the X chromosome
* @param tempMaxLod the maximum LOD score for those being drawn
*/
void drawThresholdLabelsX(LODDisplay display, Phenotype currentPhenotype, float endX, int tempMaxLod) {
    float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
    
    float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    if (currentPhenotype.thresholds.length > 1) {
        for (float i = endX; i < (display.x + display.cWidth) - 10; i += 20.0) {
                              
            if (currentPhenotype.thresholds[1][0] <= tempMaxLod) {
                line(i, (display.y +display. cHeight) - 50 - y_offXL, i + 10.0, (display.y + display.cHeight) - 50 - y_offXL);
            }
            
            if (currentPhenotype.thresholds[1][1] <= tempMaxLod) {
                line(i, (display.y + display.cHeight) - 50 - y_offXU, i + 10.0, (display.y + display.cHeight) - 50 - y_offXU);
            }
        }
    }
                        
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][1] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[1][1]*100)/100.0), (display.x + display.cWidth) - textWidth("a=" + (round(currentPhenotype.thresholds[1][1]*100)/100.0)), (display.y + display.cHeight) - y_offXU - 54.0);
    }
    
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][0] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[1][0]*100)/100.0), (display.x + display.cWidth) - textWidth("a=" + (round(currentPhenotype.thresholds[1][0]*100)/100.0)), (display.y + display.cHeight) - y_offXL - 54.0);
    }
    
    if (currentPhenotype.thresholds[0][1] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[0][1]*100)/100.0), endX - textWidth("a=" + (round(currentPhenotype.thresholds[0][1]*100)/100.0)), (display.y + display.cHeight) - y_offU - 54.0);
    }
    
    if (currentPhenotype.thresholds[0][0] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[0][0]*100)/100.0), endX - textWidth("a=" + (round(currentPhenotype.thresholds[0][0]*100)/100.0)), (display.y + display.cHeight) - y_offL - 54.0);
    }
}

/**
* Draws the threshold labels, NOT including the X chromosome
*
* @param display the LODDisplay on which to draw the labels
* @param currentPhenotype the Phenotype object that contains the threshold data to be drawn
* @param tempMaxLod the maximum LOD score for those being drawn
*/
void drawThresholdLabels(LODDisplay display, Phenotype currentPhenotype, int tempMaxLod) {
    float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
    
    float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][1] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[0][1]*100)/100.0), (display.x + display.cWidth) - textWidth("a=" + (round(currentPhenotype.thresholds[0][1]*100)/100.0)), (display.y + display.cHeight) - y_offXU - 54.0);
    }
    
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][0] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[0][0]*100)/100.0), (display.x + display.cWidth) - textWidth("a=" + (round(currentPhenotype.thresholds[0][0]*100)/100.0)), (display.y + display.cHeight) - y_offXL - 54.0);
    }
}

/**
* Draws the threshold labels for a specific chromosome
*
* @param display the LODDisplay on which to draw the labels
* @param currentPhenotype the Phenotype object that contains the threshold data to be drawn
* @param tempMaxLod the maximum LOD score for those being drawn
*/
void drawChrThresholdLabels(LODDisplay display, Phenotype currentPhenotype, int tempMaxLod) {
    float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
    
    float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    int xNum = chrLengths.length;
    
    if (((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1]) <= tempMaxLod) {
        text("a="+(round(((display.current_chr == xNum) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1])*100)/100.0), 
            (display.x + display.cWidth) - textWidth("a=" + (round(((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1])*100)/100.0)), 
            (display.y + display.cHeight) - ((display.current_chr == xNum) ? y_offXU : y_offU) - 54.0);
    }
    
    if (((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0]) <= tempMaxLod) {
        text("a=" + (round(((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0])*100)/100.0), 
            (display.x + display.cWidth) - textWidth("a=" + (round(((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0])*100)/100.0)), 
            (display.y + display.cHeight) - ((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL) - 54.0);
    }
}

/**
* Draws the LOD curve for a certain phenotype
*
* @param display the LODDisplay on which to draw the labels
* @param currentPhenotype the Phenotype object that contains the LOD scores
* @param tempMaxLod the maximum LOD score for those being drawn
*/
void drawLODCurve(LODDisplay display, Phenotype currentPhenotype, int tempMaxLod) {
  
    float lastx = map(currentPhenotype.position[0] + chrOffsets[currentPhenotype.chromosome[0] - 1], 0.0, chrTotal, 0.0, display.cWidth);
    float lasty = map(currentPhenotype.lodscores[0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    if (display.current_chr != -1) {
        lastx = -1.0;
    }
    
    for (int k = 1; k < currentPhenotype.position.length; k++) { // draw LOD curves
        try {
            if (display.current_chr != -1) {
                if (lastx == -1.0 && currentPhenotype.chromosome[k]-1 == display.current_chr) {
                    lastx = map(currentPhenotype.position[k], 0.0, ceil(display.maxOffset), 0.0, display.cWidth);
                    lasty = map(currentPhenotype.lodscores[k], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
                } else if (currentPhenotype.chromosome[k]-1 == display.current_chr) {
                    line(display.x + lastx, (display.y + display.cHeight) - lasty - 50.0, display.x + (lastx = map(currentPhenotype.position[k], 0.0, ceil(display.maxOffset), 0.0, display.cWidth)), (display.y + display.cHeight) - (lasty = map(currentPhenotype.lodscores[k], 0.0, tempMaxLod, 0.0, display.cHeight - 50)) - 50.0);
                }
                
                continue;
            }
            
            if (currentPhenotype.chromosome[k-1] != currentPhenotype.chromosome[k]) {
                lastx = map(currentPhenotype.position[k] + chrOffsets[currentPhenotype.chromosome[k] - 1], 0.0, chrTotal, 0.0, display.cWidth);
                lasty = map(currentPhenotype.lodscores[k], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
            } else {
                line(display.x + lastx, (display.y + display.cHeight) - lasty - 50.0, display.x + (lastx = map(currentPhenotype.position[k] + chrOffsets[currentPhenotype.chromosome[k] - 1], 0.0, chrTotal, 0.0, display.cWidth)),
                    (display.y + display.cHeight) - (lasty = map(currentPhenotype.lodscores[k], 0.0, tempMaxLod, 0.0, display.cHeight - 50)) - 50.0);
            }
        } catch (ArrayIndexOutOfBoundsException error) {
            println("EXCEPTION:");
            println(error.getLocalizedMessage());
        }
    }
}

// convenience method comparing two sets of threshold data
boolean thresholdsEqual(float[][] thresholds) {
    return (thresholds[0][0] == thresholds[1][0] && thresholds[0][1] == thresholds[1][1]);
}
