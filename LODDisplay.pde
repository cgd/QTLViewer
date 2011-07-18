/**
* LOD display class.
*
* Draws the LOD curves, relies on Phenotype objects for data.
*/

class LODDisplay extends UIComponent {
  
    boolean chr_ready = true;
    PFont font = createFont("Arial", 24, true), smallFont = createFont("Arial", 12, true);
    float maxOffset = -1.0;
    float zoomFactor = 1.0;
    float oldzoomFactor = 1.0;
    float offset = 0.0; // measured in cM
    int current_chr = -1, panId = -1;
    
    LODDisplay(float newX, float newY, float newWidth, float newHeight) {
        super(newX, newY, newWidth, newHeight);
    }
    
    void update() {
        if (zoomFactor > 1.0) {
            zoomFactor = 1.0;
        }
        
        if (cWidth <= 0.0) {
            cWidth = (drawWidth - x) + cWidth;
        }
        
        if (cHeight <= 0.0) {
            cHeight = (drawHeight - y) + cHeight;
        }
        
        findMax(this);
        
        if (current_chr > lastChr() - 1) {
            current_chr = -1;
        }
        
        textFont(font);
        strokeWeight(2);
        stroke(0x00);
        line(x, y, x, (y + cHeight) - 50);
        line(x, (y + cHeight) - 50, x + cWidth, (y + cHeight) - 50);
        fill(0x00);
        strokeWeight(1);
        int xNum = chrLengths.length;
        
        for (int i = 0; i < chrNames.length; i++) {
            if (chrNames[i].equalsIgnoreCase("x")) {
                xNum = i;
            }
        }
        
        if (current_chr == -1) {
            for (int i = 0; i < chrLengths.length; i++) {
                float pos = map(offset + chrOffsets[i] + (chrLengths[i] / 2.0), 0.0, chrTotal * zoomFactor, 0.0, cWidth);
                
                if (pos >= cWidth || pos <= 0.0) {
                    continue;
                }
                
                text(chrNames[i], x + pos - (textWidth(chrNames[i]) / 2.0), (y + cHeight) - 14);
                line(x + pos, (y + cHeight) - 50, x + pos, (y + cHeight) - 34);
            }
        } else {
            for (int i = 1; i <= 4; i++) {
                int value = round((i * ceil(maxOffset)) / 4.0);
                float x_off = map(value, 0.0, ceil(maxOffset), 0.0, cWidth);
                String valueText = str(value), unit = "cM";
                
                if (unitSelect.selected == 1) {
                    unit = "bP";
                    valueText = str(Math.round(unitConverter.centimorgansToBasePairs(current_chr + 1, (double)value)/10000.0)*10000.0);
                }
                
                if (x + x_off + (textWidth(valueText + ((i == 1) ? unit : "")) / 2.0) > x + cWidth) {
                    text(valueText + ((i == 1) ? unit : ""), x + 16 + cWidth - (textWidth(valueText + ((i == 1) ? unit : ""))), (y + cHeight) - 14);
                } else {
                    text(valueText + ((i == 1) ? unit : ""), x + x_off - (textWidth(valueText + ((i == 1) ? unit : "")) / 2.0), (y + cHeight) - 14);
                }
                
                line(x + x_off, (y + cHeight) - 50, x + x_off, (y + cHeight) - 34);
            }
        } 
        
        if (maxLod == -1.0) {
            return;
        }
    
        int tempMaxLod = ceil(maxLod);
        tempMaxLod = drawLODScale(this, tempMaxLod); // see LODDisplayHelper module
        
        strokeWeight(1);
        fill(0x00);
        int[] colors = new int[0];
        String[] names = new String[0];
        float maxLen = -1.0, autoLower = 1.5, autoUpper = 3.0;
        
        try { // attempt to use user-specified default thresholds
            autoLower = float(((UITextInput)texts.get(0)).getText());
            autoUpper = float(((UITextInput)texts.get(1)).getText());
        } catch (Exception error) {
            error.printStackTrace();
        }
        
        fill(0xAA);
        strokeWeight(1);
        textFont(font);
        
        if (current_chr != -1) { // draw chromosome number
            text("chromosome " + ((current_chr == xNum) ? "X" : (current_chr + 1)), x + 2, y + 16);
        }
        
        for (int i = 0; i < parentFiles.size(); i++) {
            for (int j = 0; j < ((UITreeNode)fileTree.get(i)).size(); j++) {
                Phenotype currentPhenotype = ((Parent_File)parentFiles.get(i)).get(j);
                UITreeNode phenotypeNode = ((UITreeNode)((UITreeNode)fileTree.get(i)).get(j));
                
                if (!phenotypeNode.checked) {
                    continue;
                }
                
                textFont(legendFont);
                names = append(names, currentPhenotype.name + " (" + ((UITreeNode)fileTree.get(i)).title + ")");
                colors = append(colors, phenotypeNode.drawcolor);
                
                if (textWidth(currentPhenotype.name + " (" + ((UITreeNode)fileTree.get(i)).title + ")") > maxLen) { // find maximum phenotype name length
                    maxLen = textWidth(currentPhenotype.name + " (" + ((UITreeNode)fileTree.get(i)).title + ")");
                }
                
                stroke(phenotypeNode.drawcolor, 0x7F);
                fill(phenotypeNode.drawcolor, 0x7F);
                strokeWeight(3);
                
                if (currentPhenotype.useDefaults) {
                    currentPhenotype.thresholds[0][0] = autoLower;
                    currentPhenotype.thresholds[0][1] = autoUpper;
                }
                
                if (currentPhenotype.useXDefaults && currentPhenotype.thresholds.length > 1) {
                    currentPhenotype.thresholds[1][0] = autoLower;
                    currentPhenotype.thresholds[1][1] = autoUpper;
                }
                
                float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, cHeight - 50);
                float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, cHeight - 50);
                
                int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
                
                float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, cHeight - 50);
                float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, cHeight - 50);
                
                textFont(smallFont);
                
                if (current_chr == -1) {
                    float endX = -1.0;
                    
                    if ((currentPhenotype.thresholds.length > 1 && thresholdsEqual(currentPhenotype.thresholds))) {
                        endX = x + cWidth;
                    } else {
                        endX = map(chrOffsets[xNum], 0.0, chrTotal, x, (x + cWidth));
                    }
                    
                    if ((currentPhenotype.thresholds.length > 1 && !thresholdsEqual(currentPhenotype.thresholds)) || currentPhenotype.thresholds.length > 0) {
                        drawThresholdLabelsX(this, currentPhenotype, endX, tempMaxLod);
                    } else {
                        drawThresholdLabels(this, currentPhenotype, tempMaxLod);
                    }
                } else {
                    for (float xp = x; xp < x + cWidth - 10; xp += 20.0) {
                        if (((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1]) <= tempMaxLod) {
                            line(xp, (y + cHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXU : y_offU) - 50.0, xp + 10.0, (y + cHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXU : y_offU) - 50.0);
                        }
                        
                        if (((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0]) <= tempMaxLod) {
                            line(xp, (y + cHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL) - 50.0, xp + 10.0, (y + cHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL) - 50.0);
                        }
                    }
                                            
                    float upperThresh = (current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1];
                    float upperOffset = (current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXU : y_offU;
                    float lowerThresh = (current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0];
                    float lowerOffset = (current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL;
                    
                    float roundedUpper = round(upperThresh*100)/100.0;
                    float roundedLower = round(lowerThresh*100)/100.0;
                    
                    if (upperThresh < tempMaxLod) {
                        text("a=" + roundedUpper, (x + cWidth) - textWidth("a=" + roundedUpper), (y + cHeight) - upperOffset - 54.0);
                    }
                    
                    if (lowerThresh < tempMaxLod) {
                        text("a=" + roundedLower, (x + cWidth) - textWidth("a=" + roundedLower), (y + cHeight) - lowerOffset - 54.0);
                    }
                }
                
                stroke(phenotypeNode.drawcolor);
                strokeWeight(1);

                drawLODCurve(this, currentPhenotype, tempMaxLod);
            }
        }
    }
    
    void mouseAction() {
        if (mouseX > x && mouseY > y && mouseX < x + cWidth && mouseY < y + cHeight - 50 && active && focus && mousePressed && mouseButton == LEFT && chr_ready && current_chr == -1) {
            for (int i = 0; i < chrOffsets.length; i++) {
                if (mouseX > map(chrOffsets[i], 0.0, chrTotal, 0.0, drawWidth - 50 - x) + x) {
                    if (i == chrOffsets.length - 1) {
                        current_chr = i;
                    } else if (mouseX < map(chrOffsets[i+1], 0.0, chrTotal, 0.0, drawWidth - 50 - x) + x) {
                        current_chr = i;
                    }
                }
             }
        }
    }
    
    void nextChr() {
        if (tabs.currentpage != 0) {
            return;
        }
        
        if (current_chr > -1 && current_chr < lastChr()-1) {
            current_chr++;
        }
    }
    
    void prevChr() {
        if (tabs.currentpage != 0) {
            return;
        }
        
        if (current_chr > 0) {
            current_chr--;
        }
    }
    
    void allChr() {
        if (tabs.currentpage != 0) {
            return;
        }
        
        current_chr = -1;
    }
    
    int size() { return 0; }
    
    void pan(PVector vec) {
        if (current_chr == -1) {
            if (vec.x < 0.0) {
                offset -= map(abs(vec.x), 0.0, cWidth, 0.0, chrTotal * zoomFactor);
            } else if (vec.x > 0.0) {
                offset += map(vec.x, 0.0, cWidth, 0.0, chrTotal * zoomFactor);
            }
        }
        
        if (offset > 0.0) {
            offset = 0.0;
        } else if (map(zoomFactor * (chrTotal - abs(offset)), 0.0, chrTotal * zoomFactor, 0.0, cWidth) <= 0) {
            //offset = -((chrTotal - offset) * cWidth) / (chrTotal * zoomFactor);
        }
    }
    
    void panStart(int ID) {
        panId = ID;
    }
    
    void panEnd(int ID) {
        panId = -1;
    }
}
