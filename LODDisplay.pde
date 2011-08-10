/**
* LOD display class.
*
* Draws the LOD curves, relies on Phenotype objects for data.
*/

class LODDisplay extends UIComponent {
  
    boolean chr_ready = true, dragging = false;
    PFont font = createFont("Arial", 24, true), smallFont = createFont("Arial", 12, true);
    float maxOffset = -1.0;
    float zoomFactor = 1.0;
    float oldzoomFactor = 1.0;
    float offset = 0.0; // measured in cM
    float velocity = 0.0, lastVelocity = 0.0;
    float gravity = 0.95;
    int current_chr = -1, panId = -1;
    float plotHeight = 0;
    Point firstMousePos = new Point(-1, -1);
    
    LODDisplay(float newX, float newY, float newWidth, float newHeight) {
        super(newX, newY, newWidth, newHeight);
        plotHeight = cHeight - 200;
    }
    
    void update() {
        if (zoomFactor > 1.0) {
            zoomFactor = 1.0;
        } else if (zoomFactor <= 0.01) {
            zoomFactor = 0.01;
        }

        if (!ENABLE_KINECT && dragging) {
            velocity = mouseX - pmouseX;
        }

        if (abs(velocity) < 1.0 || exiting || !focus || !active) {
            velocity = 0.0;
        }
        
        if (current_chr == -1) {
            if (velocity < 0.0) {
                offset -= map(abs(velocity), 0.0, cWidth, 0.0, chrTotal * zoomFactor);
            } else if (velocity > 0.0) {
                offset += map(velocity, 0.0, cWidth, 0.0, chrTotal * zoomFactor);
            }
        } else {
            if (velocity < 0.0) {
                offset -= map(abs(velocity), 0.0, cWidth, 0.0, chrLengths[current_chr] * zoomFactor);
            } else if (velocity > 0.0) {
                offset += map(velocity, 0.0, cWidth, 0.0, chrLengths[current_chr] * zoomFactor);
            }
        }
        
        velocity *= gravity;
        
        if (offset > 0.0) {
            offset = 0.0;
        }   
        
        if (current_chr == -1 && map(offset + chrTotal, 0.0, zoomFactor * chrTotal, 0.0, cWidth) < cWidth) {
            offset = (zoomFactor * chrTotal) - chrTotal;
        } else if (current_chr != -1 && map(offset + maxOffset, 0.0, zoomFactor * maxOffset, 0.0, cWidth) < cWidth) {
            offset = (zoomFactor * maxOffset) - maxOffset;
        }
        
        findMax(this);
        
        if (current_chr > lastChr() - 1) {
            current_chr = -1;
        }
        
        textFont(font);
        strokeWeight(2);
        stroke(0x00);
        line(x, y, x, (y + plotHeight) - 50);
        line(x, y + plotHeight - 50, x + cWidth, y + plotHeight - 50);
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
                
                text(chrNames[i], x + pos - (textWidth(chrNames[i]) / 2.0), y + plotHeight - 14);
                line(x + pos, y + plotHeight - 50, x + pos, y + plotHeight - 34);
            }
        } else {
            for (int i = 1; i <= 4; i++) {
                int value = round((i * ceil(maxOffset)) / 4.0);
                float x_off = map(offset + value, 0.0, zoomFactor * ceil(maxOffset), 0.0, cWidth);
                String valueText = str(value), unit = "cM";
                
                if (unitSelect.selected == 1) {
                    unit = "bP";
                    valueText = str(Math.round(unitConverter.centimorgansToBasePairs(current_chr + 1, (double)value) / 10000.0) * 10000.0);
                }
                
                if (x_off + (textWidth(valueText + ((i == 1) ? unit : "")) / 2.0) > cWidth || x_off + (textWidth(valueText + ((i == 1) ? unit : "")) / 2.0) < 30.0) {
                    continue;
                    //text(valueText + ((i == 1) ? unit : ""), x + 16 + cWidth - (textWidth(valueText + ((i == 1) ? unit : ""))), (y + plotHeight) - 14);
                } else {
                    text(valueText + ((i == 1) ? unit : ""), x + x_off - (textWidth(valueText + ((i == 1) ? unit : "")) / 2.0), (y + plotHeight) - 14);
                }
                
                line(x + x_off, (y + plotHeight) - 50, x + x_off, (y + plotHeight) - 34);
            }
        }
        
        drawGenes(this);

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
                
                float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, plotHeight - 50);
                float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, plotHeight - 50);
                
                int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
                
                float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, plotHeight - 50);
                float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, plotHeight - 50);
                
                textFont(smallFont);
                
                stroke(phenotypeNode.drawcolor, 0x7F);
                fill(phenotypeNode.drawcolor, 0x7F);
                strokeWeight(3);
                
                if (current_chr == -1) {
                    float endX = -1.0;
                    
                    if ((currentPhenotype.thresholds.length > 1 && thresholdsEqual(currentPhenotype.thresholds))) {
                        endX = x + cWidth;
                    } else {
                        endX = map(offset + chrOffsets[xNum], 0.0, zoomFactor * chrTotal, x, x + cWidth);
                    }
                    
                    if ((currentPhenotype.thresholds.length > 1 && !thresholdsEqual(currentPhenotype.thresholds)) || currentPhenotype.thresholds.length > 0) {
                        drawThresholdLabelsX(this, currentPhenotype, endX, tempMaxLod);
                    } else {
                        drawThresholdLabels(this, currentPhenotype, tempMaxLod);
                    }
                } else {
                    for (float xp = x; xp < x + cWidth - 10; xp += 20.0) {
                        if (((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1]) <= tempMaxLod) {
                            line(xp, (y + plotHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXU : y_offU) - 50.0, xp + 10.0, (y + plotHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXU : y_offU) - 50.0);
                        }
                        
                        if (((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0]) <= tempMaxLod) {
                            line(xp, (y + plotHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL) - 50.0, xp + 10.0, (y + plotHeight) - ((current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL) - 50.0);
                        }
                    }
                                            
                    float upperThresh = (current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][1] : currentPhenotype.thresholds[0][1];
                    float upperOffset = (current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXU : y_offU;
                    float lowerThresh = (current_chr == xNum && currentPhenotype.thresholds.length > 1) ? currentPhenotype.thresholds[1][0] : currentPhenotype.thresholds[0][0];
                    float lowerOffset = (current_chr == xNum && currentPhenotype.thresholds.length > 1) ? y_offXL : y_offL;
                    
                    float roundedUpper = round(upperThresh*100)/100.0;
                    float roundedLower = round(lowerThresh*100)/100.0;
                    
                    if (upperThresh < tempMaxLod) {
                        text("a=" + roundedUpper, (x + cWidth) - textWidth("a=" + roundedUpper), (y + plotHeight) - upperOffset - 54.0);
                    }
                    
                    if (lowerThresh < tempMaxLod) {
                        text("a=" + roundedLower, (x + cWidth) - textWidth("a=" + roundedLower), (y + plotHeight) - lowerOffset - 54.0);
                    }
                }
                
                stroke(phenotypeNode.drawcolor);
                strokeWeight(1);

                drawLODCurve(this, currentPhenotype, tempMaxLod);
            }
        }
    }
    
    void mouseAction() {
        if (!mousePressed && mouseX == firstMousePos.x && mouseY == firstMousePos.y) {
            firstMousePos.x = firstMousePos.y = -1;
            
            if (!(keyPressed && key == CODED && keyCode == 157) && mouseX > x && mouseY > y && mouseX < x + cWidth && mouseY < y + plotHeight - 50 && active && focus && mouseButton == LEFT && current_chr == -1 && maxLod != -1.0) {
                for (int i = 0; i < chrOffsets.length; i++) {
                    if (mouseX > map(offset + chrOffsets[i], 0.0, zoomFactor * chrTotal, 0.0, drawWidth - 50 - x) + x) {
                        if (i == chrOffsets.length - 1) {
                            current_chr = i;
                        } else if (mouseX < map(offset + chrOffsets[i + 1], 0.0, zoomFactor * chrTotal, 0.0, drawWidth - 50 - x) + x) {
                            current_chr = i;
                        }
                    }
                }
                            
                offset = 0.0;
                zoomFactor = 1.0;
            }
        } else if (!mousePressed) {
            firstMousePos.x = firstMousePos.y = -1;
        } else if (mousePressed && (firstMousePos.x < 0 || firstMousePos.y < 0)) {
            firstMousePos.x = mouseX;
            firstMousePos.y = mouseY;
            
        }
        
        dragging = mousePressed;
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
        lastVelocity = vec.x;
        
        if (abs(vec.x) < 5.0) {
            velocity = lastVelocity = 0.0;
        }
        
        lastVelocity = vec.x;
        
        if (current_chr == -1) {
            if (vec.x < 0.0) {
                offset -= map(abs(vec.x), 0.0, cWidth, 0.0, chrTotal * zoomFactor);
            } else if (vec.x > 0.0) {
                offset += map(vec.x, 0.0, cWidth, 0.0, chrTotal * zoomFactor);
            }
        } else {
            if (vec.x < 0.0) {
                offset -= map(abs(vec.x), 0.0, cWidth, 0.0, chrLengths[current_chr] * zoomFactor);
            } else if (vec.x > 0.0) {
                offset += map(vec.x, 0.0, cWidth, 0.0, chrLengths[current_chr] * zoomFactor);
            }
        }
        
        if (offset > 0.0) {
            offset = 0.0;
        } else if (current_chr == -1 && map(offset + chrTotal, 0.0, zoomFactor * chrTotal, 0.0, cWidth) < cWidth) {
            offset = (zoomFactor * chrTotal) - chrTotal;
        }
        
        if (vec.y > 100.0 && current_chr != -1) {
            current_chr = -1;
            zoomFactor = 1.0;
            offset = 0.0;
        }
    }
    
    void panStart(int ID) {
        panId = ID;
    }
    
    void panEnd(int ID) {
        panId = -1;
        
        velocity = lastVelocity;
        
        if (abs(lastVelocity) < 5.0) {
            velocity = 0.0;
        }
        
        lastVelocity = 0.0;
    }
}
