/**
* LOD display class.
*
* Draws the LOD curves, relies on Phenotype objects for data.
*/

class LODDisplay extends UIComponent {
  
    boolean dragReady = true, dragging = false, chr_ready = true;
    float legendX, legendY, legendW, legendH;
    PFont font = createFont("Arial", 24, true), legendFont = createFont("Arial", 16, true), smallFont = createFont("Arial", 12, true);
    float legendOffsetX = -1, legendOffsetY = -1, legendA = 0x00, maxOffset = -1.0;
    int current_chr = -1;
    
    LODDisplay(float newX, float newY, float newWidth, float newHeight) {
        super(newX, newY, newWidth, newHeight);
        legendX = width - 400.0;
        legendY = 250.0;
    }
    
    void update() {
        if (cWidth <= 0.0) {
            cWidth = (width - x) + cWidth;
        }
        
        if (cHeight <= 0.0) {
            cHeight = (height - y) + cHeight;
        }
        
        findMax(this);
        
        if (current_chr > lastChr()-1) {
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
                float pos = map(chrOffsets[i] + (chrLengths[i]/2.0), 0.0, chrTotal, 0.0, cWidth);
                text(chrNames[i], x + pos - (textWidth(chrNames[i])/2.0), (y + cHeight) - 14);
                line(x + pos, (y + cHeight) - 50, x + pos, (y + cHeight) - 34);
            }
        } else {
            for (int i = 1; i <= 4; i++) {
                int value = round((i*ceil(maxOffset))/4.0);
                float x_off = map(value, 0.0, ceil(maxOffset), 0.0, cWidth);
                String valueText = str(value), unit = "cM";
                
                if (unitSelect.selected == 1) {
                    unit = "bP";
                    valueText = str(Math.round(unitConverter.centimorgansToBasePairs(current_chr + 1, (double)value)/10000.0)*10000.0);
                }
                
                if (x + x_off + (textWidth(valueText + ((i == 1) ? unit : ""))/2.0) > x + cWidth) {
                    text(valueText + ((i == 1) ? unit : ""), x + 16.0 + cWidth - (textWidth(valueText + ((i == 1) ? unit : ""))), (y + cHeight) - 14);
                } else {
                    text(valueText + ((i == 1) ? unit : ""), x + x_off - (textWidth(valueText + ((i == 1) ? unit : ""))/2.0), (y + cHeight) - 14);
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
        } catch (Exception error3) {
            println("EXCEPTION:");
            println(error3.getLocalizedMessage());
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
                names = append(names, currentPhenotype.name+" ("+((UITreeNode)fileTree.get(i)).title+")");
                colors = append(colors, phenotypeNode.drawcolor);
                
                if (textWidth(currentPhenotype.name+" ("+((UITreeNode)fileTree.get(i)).title+")") > maxLen) { // find maximum phenotype name length
                    maxLen = textWidth(currentPhenotype.name+" ("+((UITreeNode)fileTree.get(i)).title+")");
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
                    
                    for (float xp = x; xp < endX - 10; xp += 20.0) {
                      
                        if (currentPhenotype.thresholds[0][1] <= tempMaxLod) {
                            line(xp, (y + cHeight) - 50 - y_offU, xp + 10.0, (y + cHeight) - 50 - y_offU);
                        }
                        
                        if (currentPhenotype.thresholds[0][0] <= tempMaxLod) {
                            line(xp, (y + cHeight) - 50 - y_offL, xp + 10.0, (y + cHeight) - 50 - y_offL);
                        }
                    }
                    
                    if ((currentPhenotype.thresholds.length > 1 && !thresholdsEqual(currentPhenotype.thresholds)) || currentPhenotype.thresholds.length > 0) {
                        drawThresholdLabelsX(this, currentPhenotype, endX, tempMaxLod);
                    } else {
                        drawThresholdLabels(this, currentPhenotype, tempMaxLod);
                    }
                } else {
                    for (float xp = x; xp < (x + cWidth) - 10; xp += 20.0) {
                        if (((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1]) <= tempMaxLod) {
                            line(xp, (y + cHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXU : y_offU) - 50.0, xp + 10.0, (y + cHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXU : y_offU) - 50.0);
                        }
                        
                        if (((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0]) <= tempMaxLod) {
                            line(xp, (y + cHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL) - 50.0, xp + 10.0, (y + cHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL) - 50.0);
                        }
                    }
                }
                
                stroke(phenotypeNode.drawcolor);
                strokeWeight(1);

                drawLODCurve(this, currentPhenotype, tempMaxLod);
            }
        }
        
        if (mouseX > legendX && mouseX < legendX + legendW && mouseY > legendY && mouseY < legendY + legendH && active) {
            legendA += (legendA < 0xFF) ? frameRate/5.0 : 0;
            if (legendA > 0xFF) legendA = 0xFF;
            if (dragReady && mousePressed && mouseButton == LEFT) {
                dragging = true;
                if (legendOffsetX == -1 || legendOffsetY == -1) {
                    legendOffsetX = mouseX - legendX;
                    legendOffsetY = mouseY - legendY; 
                }
            }
        } else {
            legendA -= (legendA > 0x00) ? frameRate/5.0 : 0;
            if (legendA < 0x00) legendA = 0x00;
        } 
        
        if (dragging) {
            legendX = mouseX - legendOffsetX;
            legendY = mouseY - legendOffsetY;
            
            if (legendX < x) {
                legendX = x;
            } else if (legendX > (x + cWidth) - legendW) {
                legendX = (x + cWidth)-legendW;
            }
            
            if (legendY < y) {
                legendY = y;
            } else if (legendY > (y + cHeight) - legendH) {
                legendY = (y + cHeight)-legendH;
            }
        } 
        
        if (!mousePressed || mouseButton != LEFT || !active) {
            legendOffsetX = legendOffsetY = -1;
            dragging = false;
        }
        
        fill(0x00, 0x2A);
        stroke(0x00, legendA);
        rect(legendX, legendY, (legendW = maxLen + 18), (legendH = (names.length*16) + 4));
        stroke(0x00);
        textFont(legendFont);
        
        for (int i = 0; i < names.length; i++) {
            fill(colors[i]);
            rect(legendX + 4.0, legendY + ((i + 1)*16) - 11, 10, 10);
            fill(0x00);
            text(names[i], legendX + 16.0, legendY + ((i + 1)*16));
        }
        
        dragReady = !(mousePressed && mouseButton == LEFT) && active;
        
        if (mouseX > x && mouseY > y && mouseX < cWidth - 50 && mouseY < height-100 && active) {
            chr_ready = (!mousePressed || mouseButton != LEFT);
        } else {
            chr_ready = !(mousePressed && mouseButton == LEFT && active && dragging);
        }
    }
    
    void mouseAction() {
        if (mouseX > legendX && mouseX < legendX + legendW && mouseY > legendY && mouseY < legendY + legendH) {
            return;
        } else if (mouseX > x && mouseY > y && mouseX < x + cWidth && mouseY < y + cHeight - 50 && active && focus && mousePressed && mouseButton == LEFT && !dragging && chr_ready && current_chr == -1) {
                for (int i = 0; i < chrOffsets.length; i++) {
                    if (mouseX > map(chrOffsets[i], 0.0, chrTotal, 0.0, width - 50 - x) + x) {
                        if (i == chrOffsets.length - 1) {
                            current_chr = i;
                        } else if (mouseX < map(chrOffsets[i+1], 0.0, chrTotal, 0.0, width - 50 - x) + x) {
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
}
