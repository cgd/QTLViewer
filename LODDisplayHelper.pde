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

double lastZoomFactor = 1.0, lastOffset = 0.0;
int lastChr = -1;
boolean updateGenes = true;
PGraphics geneDisplay;
PFont tiny = createFont("Arial", (ENABLE_KINECT) ? 24.0 : 10.0, true);

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
* Stores the max LOD score and max position from the base
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
        float y_off = map(tempMaxLod, 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
        text("1", display.x - 16 - textWidth("1"), (display.y + display.plotHeight) - 50 - y_off + 8);
        line(display.x, (display.y + display.plotHeight) - 50 - y_off, display.x - 16, (display.y + display.plotHeight) - 50 - y_off);
        y_off = map(0, 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
        text("0", display.x - 16 - textWidth("0"), (display.y + display.plotHeight) - 50 - y_off + 8);
        line(display.x, (display.y + display.plotHeight) - 50 - y_off, display.x - 16, (display.y + display.plotHeight) - 50 - y_off);
    } else {
        for (int i = 0; i <= 4; i++) {
            int value = round((i*tempMaxLod)/4.0);
            float y_off = map(value, 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
            text(str(value), display.x - 16 - textWidth(str(value)), (display.y + display.plotHeight) - 50 - y_off + 8);
            line(display.x, (display.y + display.plotHeight) - 50 - y_off, display.x - 16, (display.y + display.plotHeight) - 50 - y_off);
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
    float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    
    int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
    
    float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    
    if (currentPhenotype.thresholds.length > 1) {
        for (float i = endX; i < (display.x + display.cWidth) - 10; i += 20.0) {                 
            if (currentPhenotype.thresholds[1][0] <= tempMaxLod) {
                line(i, (display.y + display. plotHeight) - 50 - y_offXL, i + 10.0, (display.y + display.plotHeight) - 50 - y_offXL);
            }
            
            if (currentPhenotype.thresholds[1][1] <= tempMaxLod) {
                line(i, (display.y + display.plotHeight) - 50 - y_offXU, i + 10.0, (display.y + display.plotHeight) - 50 - y_offXU);
            }
        }
    }
    
    for (float xp = display.x; xp < endX - 10; xp += 20.0) {
        if (xp > display.x + display.cWidth || xp + 10 > display.x + display.cWidth) {
            break;
        }
        
        if (currentPhenotype.thresholds[0][1] <= tempMaxLod) {
            line(xp, (display.y + display.plotHeight) - 50 - y_offU, xp + 10.0, (display.y + display.plotHeight) - 50 - y_offU);
        }
        
        if (currentPhenotype.thresholds[0][0] <= tempMaxLod) {
            line(xp, (display.y + display.plotHeight) - 50 - y_offL, xp + 10.0, (display.y + display.plotHeight) - 50 - y_offL);
        }
    }
                        
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][1] <= tempMaxLod) {
        String label = "a=" + (round(currentPhenotype.thresholds[1][1] * 100) / 100.0);
        
        if (endX + textWidth(label) < display.x + display.cWidth + 20) {
            text(label, endX, display.y + display.plotHeight - y_offXU - 54);
        }
    }
    
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][0] <= tempMaxLod) {
        String label = "a=" + (round(currentPhenotype.thresholds[1][0] * 100) / 100.0);
        
        if (endX + textWidth(label) < display.x + display.cWidth + 20) {
            text(label, endX, display.y + display.plotHeight - y_offXL - 54);
        }
    }
    
    if (currentPhenotype.thresholds[0][1] <= tempMaxLod) {
        String label = "a=" + (round(currentPhenotype.thresholds[0][1] * 100) / 100.0);
        
        if (endX + textWidth(label) < display.x + display.cWidth + 20 && endX - textWidth(label) > display.x) {
            text(label, endX - textWidth(label), display.y + display.plotHeight - y_offU - 54);
        } else if (endX - textWidth(label) > display.x) {
            text(label, display.x + display.cWidth - textWidth(label), display.y + display.plotHeight - y_offU - 54);
        }
    }
    
    if (currentPhenotype.thresholds[0][0] <= tempMaxLod) {
        String label = "a=" + (round(currentPhenotype.thresholds[0][0] * 100) / 100.0);
        
        if (endX + textWidth(label) < display.x + display.cWidth + 20 && endX - textWidth(label) > display.x) {
            text(label, endX - textWidth(label), display.y + display.plotHeight - y_offL - 54);
        } else if (endX - textWidth(label) > display.x) {
            text(label, display.x + display.cWidth - textWidth(label), display.y + display.plotHeight - y_offL - 54);
        }
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
    float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    
    int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
    
    float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][1] <= tempMaxLod) {
        String label = "a=" + (round(currentPhenotype.thresholds[0][1] * 100) / 100.0);
        text(label, display.x + display.cWidth - textWidth(label), (display.y + display.plotHeight) - y_offXU - 54);
    }
    
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][0] <= tempMaxLod) {
        String label = "a=" + (round(currentPhenotype.thresholds[0][0] * 100) / 100.0);
        text(label, display.x + display.cWidth - textWidth(label), display.y + display.plotHeight - y_offXL - 54);
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
    float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    
    int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
    
    float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    
    int xNum = chrLengths.length;
    
    if (((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1]) <= tempMaxLod) {
        String label = "a=" + (round(((display.current_chr == xNum) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1]) * 100) / 100.0);
        text(label, display.x + display.cWidth - textWidth(label), display.y + display.plotHeight - ((display.current_chr == xNum) ? y_offXU : y_offU) - 54);
    }
    
    if (((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0]) <= tempMaxLod) {
        String label = "a=" + (round(((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0]) * 100) / 100.0);
        text(label, display.x + display.cWidth - textWidth(label), display.y + display.plotHeight - ((display.current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL) - 54);
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
  
    float lastx = (float)map(display.offset + currentPhenotype.position[0] + chrOffsets[currentPhenotype.chromosome[0] - 1], 0.0, (float)display.zoomFactor * chrTotal, 0.0, display.cWidth);
    float lasty = (float)map(currentPhenotype.lodscores[0], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
    
    if (display.current_chr != -1) {
        lastx = -1.0;
    }
    
    for (int k = 1; k < currentPhenotype.position.length; k++) { // draw LOD curves
        if (display.current_chr == -1 && lastx < 0.0) {
            lastx = (float)map(display.offset + currentPhenotype.position[k] + chrOffsets[currentPhenotype.chromosome[k] - 1], 0.0, (float)display.zoomFactor * chrTotal, 0.0, display.cWidth);
            lasty = (float)map(currentPhenotype.lodscores[k], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
            continue;
        } else if (display.current_chr == -1 && (lastx > display.cWidth || map(display.offset + currentPhenotype.position[k] + chrOffsets[currentPhenotype.chromosome[k] - 1], 0.0, (float)display.zoomFactor * chrTotal, 0.0, display.cWidth) > display.cWidth)) {
            break;
        }
        
        try {
            if (display.current_chr != -1) {
                if (lastx < 0.0 && currentPhenotype.chromosome[k] - 1 == display.current_chr) {
                    lastx = (float)map(display.offset + currentPhenotype.position[k], 0.0, (float)display.zoomFactor * ceil(display.maxOffset), 0.0, display.cWidth);
                    lasty = (float)map(currentPhenotype.lodscores[k], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
                } else if (currentPhenotype.chromosome[k] - 1 == display.current_chr && (lastx > display.cWidth || map(display.offset + currentPhenotype.position[k], 0.0, (float)display.zoomFactor * ceil(display.maxOffset), 0.0, display.cWidth) > display.cWidth)) {
                    break;
                } else if (currentPhenotype.chromosome[k] - 1 == display.current_chr) {
                    line(display.x + lastx, display.y + display.plotHeight - lasty - 50, display.x + (lastx = (float)map(display.offset + currentPhenotype.position[k], 0.0, 
                        display.zoomFactor * ceil(display.maxOffset), 0.0, display.cWidth)), display.y + display.plotHeight - (lasty = map(currentPhenotype.lodscores[k], 0.0, tempMaxLod, 0.0, display.plotHeight - 50)) - 50);
                } else if (currentPhenotype.chromosome[k] - 1 > display.current_chr) {
                    break;
                }
                
                continue;
            }
            
            if (currentPhenotype.chromosome[k - 1] != currentPhenotype.chromosome[k]) {
                lastx = (float)map(display.offset + currentPhenotype.position[k] + chrOffsets[currentPhenotype.chromosome[k] - 1], 0.0, display.zoomFactor * chrTotal, 0.0, display.cWidth);
                lasty = map(currentPhenotype.lodscores[k], 0.0, tempMaxLod, 0.0, display.plotHeight - 50);
            } else {
                line(display.x + lastx, display.y + display.plotHeight - lasty - 50, display.x + (lastx = (float)map(display.offset + currentPhenotype.position[k] + chrOffsets[currentPhenotype.chromosome[k] - 1], 0.0, display.zoomFactor * chrTotal, 0.0, display.cWidth)),
                    display.y + display.plotHeight - (lasty = map(currentPhenotype.lodscores[k], 0.0, tempMaxLod, 0.0, display.plotHeight - 50)) - 50);
            }
        } catch (ArrayIndexOutOfBoundsException error) {
            error.printStackTrace();
        }
    }
}


void drawGenes(LODDisplay display) {
    if (!genesLoaded) { // genes aren't loaded yet, don't draw anything
        return;
    } else if ((geneDisplay == null || (lastZoomFactor != display.zoomFactor && !ENABLE_KINECT) || 
        (lastOffset != display.offset && abs(display.velocity) < 0.1 && !ENABLE_KINECT) || lastChr != display.current_chr || updateGenes) && (!display.dragging && display.panId == -1)) {
        lastZoomFactor = display.zoomFactor;
        lastOffset = display.offset;
        lastChr = display.current_chr;
        updateGenes = false;
        
        geneDisplay = createGraphics((int)display.cWidth, (int)(display.cHeight - display.plotHeight), JAVA2D);
        geneDisplay.smooth();
        geneDisplay.beginDraw();
        
        int startChromosome = 1, endChromosome = 20;
        
        // last position (in cM) visible 
        double mOffset = map(display.cWidth * display.zoomFactor, 0.0, display.cWidth, 0.0, (display.current_chr == -1) ? chrTotal : display.maxOffset) - display.offset;
        
        if (display.current_chr == -1) {
            for (int i = 1; i < chrOffsets.length; i++) {
                if (Math.abs(display.offset) >= chrOffsets[i - 1] && Math.abs(display.offset) < chrOffsets[i]) {
                    startChromosome = i;
                }
                
                if (mOffset >= chrOffsets[i - 1] && mOffset < chrOffsets[i]) {
                    endChromosome = i;
                }
            }
        } else {
            startChromosome = endChromosome = display.current_chr + 1;
        }
        
        if (Math.abs(display.offset) > chrTotal) {
            startChromosome = 20;
        }

        geneDisplay.noStroke();
        geneDisplay.rectMode(CORNERS);
        geneDisplay.textFont(tiny);
        
        for (Gene g : genes) {
            try {
                double chrStart, chrEnd;
                
                if (g.chromosome == startChromosome) {
                    chrStart = Math.abs(display.offset) - ((display.current_chr == -1) ? chrOffsets[g.chromosome - 1] : 0.0);
                } else {
                    chrStart = 0.0;
                }
                
                if (g.chromosome == endChromosome) {
                    chrEnd = mOffset - ((display.current_chr == -1) ? chrOffsets[g.chromosome - 1] : 0.0);
                } else {
                    chrEnd = chrLengths[g.chromosome - 1];
                }

                if (g.chromosome < startChromosome || g.chromosome > endChromosome || !g.drawThis(chrStart, chrEnd)) {
                    continue;
                }
                
                geneDisplay.fill(g.drawColor);
                
                float _maxOffset = (display.current_chr == -1) ? chrTotal : display.maxOffset;
                float chrOffset = (display.current_chr == -1) ? chrOffsets[g.chromosome - 1] : 0.0;
                float yOffset = (g.strand == '+') ? 0.0 : 4 * display.strandHeight;
                float xStart = (float)map(display.offset + chrOffset + g.geneStart, 0.0, display.zoomFactor * _maxOffset, 0.0, display.cWidth);
                float xEnd = (float)map(display.offset + chrOffset + g.geneEnd, 0.0, display.zoomFactor * _maxOffset, 0.0, display.cWidth);
                float codeStart = (float)map(display.offset + chrOffset + g.codeStart, 0.0, display.zoomFactor * _maxOffset, 0.0, display.cWidth);
                float codeEnd = (float)map(display.offset + chrOffset + g.codeEnd, 0.0, display.zoomFactor * _maxOffset, 0.0, display.cWidth);
                
                if (Math.abs(xEnd - xStart) <= 1.0) {
                    geneDisplay.stroke(g.drawColor);
                    geneDisplay.line(xStart, yOffset, xStart, yOffset + display.strandHeight - 1.0);
                    geneDisplay.noStroke();
                } else if (Math.abs(xEnd - xStart) < 4.0) {
                    geneDisplay.rect(xStart, yOffset, xEnd, yOffset + display.strandHeight);
                } else {
                    geneDisplay.rect(xStart, yOffset + (display.strandHeight / 4.0), codeStart, yOffset + (3 * (display.strandHeight / 4.0)));
                    geneDisplay.rect(codeEnd, yOffset + (display.strandHeight / 4.0), xEnd, yOffset + (3 * (display.strandHeight / 4.0)));
                    
                    geneDisplay.stroke(g.drawColor);
                    geneDisplay.line(codeStart, yOffset + (display.strandHeight / 2.0), codeEnd, yOffset + (display.strandHeight / 2.0));
                    geneDisplay.noStroke();
                    
                    for (int i = 0; i < g.exons.length; i++) {
                        float exonStart = (float)map(display.offset + chrOffset + g.exons[i][0], 0.0, display.zoomFactor * _maxOffset, 0.0, display.cWidth);
                        float exonEnd = (float)map(display.offset + chrOffset + g.exons[i][1], 0.0, display.zoomFactor * _maxOffset, 0.0, display.cWidth);
                        geneDisplay.rect(exonStart, yOffset, exonEnd, yOffset + display.strandHeight);
                    }
                    
                    String _name = g.name;
                    
                    if (sin(QUARTER_PI) * textWidth(_name) > 4 * display.strandHeight) {
                        while (sin(QUARTER_PI) * textWidth(_name + "...") > 4 * display.strandHeight) {
                            _name = _name.substring(0, _name.length() - 1);
                        }
                        
                        _name += "...";
                    }
                    
                    geneDisplay.stroke(0x00);
                    geneDisplay.fill(0x00);
                    
                    geneDisplay.pushMatrix();
                    geneDisplay.translate(xStart, yOffset + display.strandHeight + 10);
                    geneDisplay.rotate(QUARTER_PI);
                    geneDisplay.text(_name, 0, 0);
                    geneDisplay.popMatrix();
                    
                    geneDisplay.noStroke();
                }
            } catch (ArrayIndexOutOfBoundsException error) { // g.chromosome probably is 21, so ignore
                // the follwing is a fix to a strange bug that would disappear when I tried to fix it
                // by printing mOffset (or anything, even an empty string) at line 346, it would go away
                mOffset = map(display.cWidth * display.zoomFactor, 0.0, display.cWidth, 0.0, (display.current_chr == -1) ? chrTotal : display.maxOffset) - display.offset;
            }
        }
        
        geneDisplay.endDraw();
    }
    
    try {
        image(geneDisplay, display.x, display.y + display.plotHeight);
    } catch (NullPointerException error) { // geneDisplay is still null for some reason, ignore and it next frame
    }
}

// convenience method comparing two sets of threshold data
boolean thresholdsEqual(float[][] thresholds) {
    return (thresholds[0][0] == thresholds[1][0] && thresholds[0][1] == thresholds[1][1]);
}
