class LODDisplay extends UIComponent {
    boolean dragReady = true, dragging = false, chr_ready = true;
    float legendX, legendY, legendW, legendH;
    PFont font = createFont("Arial", 24, true), legendFont = createFont("Arial", 16, true), smallFont = createFont("Arial", 12, true);
    float legendOffsetX = -1, legendOffsetY = -1, legendA = 0x00, maxOffset = -1.0;
    int current_chr = -1;
    LODDisplay(float newX, float newY, float newWidth, float newHeight) {
        super(newX, newY, newWidth, newHeight);
        legendX = width-400.0;
        legendY = 250.0;
    }
    
    void update() {
        if (cWidth <= 0.0) {
            cWidth = (width - x) + cWidth;
        }
        
        if (cHeight <= 0.0) {
            cHeight = (height - y) + cHeight;
        }
        
        findMax();
        if (current_chr > lastChr()-1) current_chr = -1;
        textFont(font);
        strokeWeight(2);
        stroke(0x00);
        line(x, y, x, (y + cHeight) - 50);
        line(x, (y + cHeight) - 50, x + cWidth, (y + cHeight) - 50);
        fill(0x00);
        strokeWeight(1);
        //double current_x = 0;
        int xNum = chrLengths.length;
        for (int i = 0; i < chrNames.length; i++)
            if (chrNames[i].equalsIgnoreCase("x")) xNum = i;
        if (current_chr == -1)
            for (int i = 0; i < chrLengths.length; i++) {
                //if (i == 19) text("X", (float)(x+current_x-(textWidth("X")/2.0)), height-64);
                //else text(str(i+1), (float)(x+current_x-(textWidth(str(i+1))/2.0)), height-64);
                //line((float)(x+current_x), height-100, (float)(x+current_x), height-84);
                //current_x += map(chrLengths[i], 0.0, chrTotal, 0.0, width-150);
                float pos = map(chrOffsets[i] + (chrLengths[i]/2.0), 0.0, chrTotal, 0.0, cWidth);
                //if (i == chrLengths.length-1) text("X", (float)x+pos-(textWidth("X")/2.0), height-64);
                //else 
                text(chrNames[i], x + pos-(textWidth(chrNames[i])/2.0), (y + cHeight) - 14);
                line(x + pos, (y + cHeight) - 50, x + pos, (y + cHeight) - 34);
            }
        else for (int i = 1; i <= 4; i++) {
            int value = round((i*ceil(maxOffset))/4.0);
            float x_off = map(value, 0.0, ceil(maxOffset), 0.0, cWidth);
            text(str(value) + ((i == 1) ? "cM" : ""), x + x_off-(textWidth(str(value) + ((i == 1) ? "cM" : ""))/2.0), (y + cHeight) - 14);
            line(x + x_off, (y + cHeight) - 50, x + x_off, (y + cHeight) - 34);
        } if (maxLod != -1.0) {
            //line((float)x, (float)y, (float)x-16, (float)y);
            //text(str(top), (float)x-16-textWidth(str(top)), (float)y+12);
            //text("0", (float)x-16-textWidth("0"), (float)height-88);
            //line((float)x, height-100, (float)x-16, height-100);
            int m = ceil(maxLod);
            if (maxLod < 1.0) {
                m = 1;
                float y_off = map(m, 0.0, m, 0.0, cHeight - 50);
                text("1", x - 16 - textWidth("1"), (y + cHeight) - 50 - y_off + 8);
                line(x, (y + cHeight) - 50 - y_off, x - 16, (y + cHeight) - 50 - y_off);
                y_off = map(0, 0.0, m, 0.0, cHeight - 50);
                text("0", x - 16 - textWidth("0"), (y + cHeight) - 50 - y_off + 8);
                line(x, (y + cHeight) - 50 - y_off, x - 16, (y + cHeight) - 50 - y_off);
            } else {
                for (int i = 0; i <= 4; i++) {
                    int value = round((i*m)/4.0);
                    float y_off = map(value, 0.0, m, 0.0, cHeight - 50);
                    text(str(value), x - 16 - textWidth(str(value)), (y + cHeight) - 50 - y_off + 8);
                    line(x, (y + cHeight) - 50 - y_off, x - 16, (y + cHeight) - 50 - y_off);
                }
            }
            strokeWeight(1);
            fill(0x00);
            //text("test", (float)legendX + 2.0, (float)legendY + 16.0);
            int[] colors = new int[0];
            String[] names = new String[0];
            float maxLen = -1.0, autoLower = 1.5, autoUpper = 3.0;
            try {
                autoLower = float(((UITextInput)texts.get(0)).getText());
                autoUpper = float(((UITextInput)texts.get(1)).getText());
            } catch (Exception error3) {
                println("EXCEPTION:");
                println(error3.getLocalizedMessage());
            }
            fill(0xAA);
            strokeWeight(1);
            textFont(font);
            if (current_chr != -1) text("chromosome "+((current_chr == xNum) ? "X" : (current_chr+1)), (float)x+2, (float)y+16);
            for (int i = 0; i < parentFiles.size(); i++) {
                for (int j = 0; j < ((UITreeNode)fileTree.get(i)).size(); j++) {
                    Phenotype p = ((Parent_File)parentFiles.get(i)).get(j);
                    UITreeNode tn = ((UITreeNode)((UITreeNode)fileTree.get(i)).get(j));
                    if (tn.checked) {
                        textFont(legendFont);
                        names = append(names, p.name+" ("+((UITreeNode)fileTree.get(i)).title+")");
                        colors = append(colors, tn.drawcolor);
                        if (textWidth(p.name+" ("+((UITreeNode)fileTree.get(i)).title+")") > maxLen) maxLen = textWidth(p.name+" ("+((UITreeNode)fileTree.get(i)).title+")");
                        stroke(tn.drawcolor, 0x7F);
                        fill(tn.drawcolor, 0x7F);
                        strokeWeight(3);
                        if (p.useDefaults) {
                            p.thresholds[0][0] = autoLower;
                            p.thresholds[0][1] = autoUpper;
                        } if (p.useXDefaults && p.thresholds.length > 1) {
                            p.thresholds[1][0] = autoLower;
                            p.thresholds[1][1] = autoUpper;
                        }
                        float y_offL = map(p.thresholds[0][0], 0.0, m, 0.0, cHeight - 50);
                        float y_offU = map(p.thresholds[0][1], 0.0, m, 0.0, cHeight - 50);
                        float y_offXL = map((p.thresholds.length > 1) ? p.thresholds[1][0] : p.thresholds[0][0], 0.0, m, 0.0, cHeight - 50);
                        float y_offXU = map((p.thresholds.length > 1) ? p.thresholds[1][1] : p.thresholds[0][1], 0.0, m, 0.0, cHeight - 50);
                        textFont(smallFont);
                        if (current_chr == -1) {
                            float endX = (p.thresholds.length > 1 && p.thresholds[0][0] == p.thresholds[1][0] && p.thresholds[0][1] == p.thresholds[1][1]) ? (x + cWidth) : map(chrOffsets[xNum], 0.0, chrTotal, (float)x, (x + cWidth));
                            for (float xp = (float)x; xp < endX-10; xp += 20.0) {
                                if (p.thresholds[0][1] <= m) line(xp, /*height-y_offU-(float)y-50.0*/(y + cHeight)-50-y_offU, xp+10.0, /*height-y_offU-(float)y-50.0*/(y + cHeight)-50-y_offU);
                                if (p.thresholds[0][0] <= m) line(xp, /*height-y_offU-(float)y-50.0*/(y + cHeight)-50-y_offL, xp+10.0, /*height-y_offL-(float)y-50.0*/(y + cHeight)-50-y_offL);
                            } if ((p.thresholds.length > 1 && (p.thresholds[0][0] != p.thresholds[1][0] || p.thresholds[0][1] != p.thresholds[1][1])) || p.thresholds.length > 0) {
                                if (p.thresholds.length > 1) for (float xp = endX; xp < (x + cWidth)-10; xp += 20.0) {
                                    if (p.thresholds[1][0] <= m) line(xp, (y + cHeight)-50-y_offXL, xp+10.0, (y + cHeight)-50-y_offXL);
                                    if (p.thresholds[1][1] <= m) line(xp, (y + cHeight)-50-y_offXU, xp+10.0, (y + cHeight)-50-y_offXU);
                                }
                                if (p.thresholds.length > 1 && p.thresholds[1][1] <= m) text("a="+(round(p.thresholds[1][1]*100)/100.0), (x + cWidth)-textWidth("a="+(round(p.thresholds[1][1]*100)/100.0)), (y + cHeight)-y_offXU-54.0);
                                if (p.thresholds.length > 1 && p.thresholds[1][0] <= m) text("a="+(round(p.thresholds[1][0]*100)/100.0), (x + cWidth)-textWidth("a="+(round(p.thresholds[1][0]*100)/100.0)), (y + cHeight)-y_offXL-54.0);
                                if (p.thresholds[0][1] <= m) text("a="+(round(p.thresholds[0][1]*100)/100.0), endX-textWidth("a="+(round(p.thresholds[0][1]*100)/100.0)), (y + cHeight)-y_offU-54.0);
                                if (p.thresholds[0][0] <= m) text("a="+(round(p.thresholds[0][0]*100)/100.0), endX-textWidth("a="+(round(p.thresholds[0][0]*100)/100.0)), (y + cHeight)-y_offL-54.0);
                            } else {
                                if (p.thresholds.length > 1 && p.thresholds[1][1] <= m) text("a="+(round(p.thresholds[0][1]*100)/100.0), (x + cWidth)-textWidth("a="+(round(p.thresholds[0][1]*100)/100.0)), (y + cHeight)-y_offXU-54.0);
                                if (p.thresholds.length > 1 && p.thresholds[1][0] <= m) text("a="+(round(p.thresholds[0][0]*100)/100.0), (x + cWidth)-textWidth("a="+(round(p.thresholds[0][0]*100)/100.0)), (y + cHeight)-y_offXL-54.0);
                            }
                        } else {
                            for (float xp = (float)x; xp < (x + cWidth)-10; xp += 20.0) {
                                if (((current_chr == xNum && p.thresholds.length > 1) ? p.thresholds[1][1] : p.thresholds[0][1]) <= m)
                                    line(xp, (y + cHeight)-((current_chr == xNum && p.thresholds.length > 1) ? y_offXU : y_offU)-50.0, xp+10.0, (y + cHeight)-((current_chr == xNum && p.thresholds.length > 1) ? y_offXU : y_offU)-50.0);
                                if (((current_chr == xNum    && p.thresholds.length > 1) ? p.thresholds[1][0] : p.thresholds[0][0]) <= m)
                                    line(xp, (y + cHeight)-((current_chr == xNum && p.thresholds.length > 1) ? y_offXL : y_offL)-50.0, xp+10.0, (y + cHeight)-((current_chr == xNum && p.thresholds.length > 1) ? y_offXL : y_offL)-50.0);
                            }
                            if (((current_chr == xNum && p.thresholds.length > 1) ? p.thresholds[1][1] : p.thresholds[0][1]) <= m)
                                text("a="+(round(((current_chr == xNum) ? p.thresholds[1][1] : p.thresholds[0][1])*100)/100.0), 
                                    (x + cWidth)-textWidth("a="+(round(((current_chr == xNum && p.thresholds.length > 1) ? p.thresholds[1][1] : p.thresholds[0][1])*100)/100.0)), 
                                    (y + cHeight)-((current_chr == xNum) ? y_offXU : y_offU)-54.0);
                            if (((current_chr == xNum && p.thresholds.length > 1) ? p.thresholds[1][0] : p.thresholds[0][0]) <= m)
                                text("a="+(round(((current_chr == xNum && p.thresholds.length > 1) ? p.thresholds[1][0] : p.thresholds[0][0])*100)/100.0), 
                                    (x + cWidth)-textWidth("a="+(round(((current_chr == xNum && p.thresholds.length > 1) ? p.thresholds[1][0] : p.thresholds[0][0])*100)/100.0)), 
                                    (y + cHeight)-((current_chr == xNum && p.thresholds.length > 1) ? y_offXL : y_offL)-54.0);
                        }
                        stroke(tn.drawcolor);
                        strokeWeight(1);
                        float lastx = map(p.position[0] + chrOffsets[p.chromosome[0] - 1], 0.0, chrTotal, 0.0, cWidth), lasty = map(p.lodscores[0], 0.0, m, 0.0, cHeight - 50);
                        if (current_chr != -1) lastx = -1.0;
                        for (int k = 1; k < p.position.length; k++) {
                            try {
                                if (current_chr != -1) {
                                    if (lastx == -1.0 && p.chromosome[k]-1 == current_chr) {
                                        lastx = map(p.position[k], 0.0, ceil(maxOffset), 0.0, cWidth);
                                        lasty = map(p.lodscores[k], 0.0, m, 0.0, cHeight - 50);
                                    } else if (p.chromosome[k]-1 == current_chr) {
                                        line(x + lastx, (y + cHeight) - lasty - 50.0, x + (lastx = map(p.position[k], 0.0, ceil(maxOffset), 0.0, cWidth)), (y + cHeight) - (lasty = map(p.lodscores[k], 0.0, m, 0.0, cHeight - 50)) - 50.0);
                                    }
                                    continue;
                                } if (p.chromosome[k-1] != p.chromosome[k]) {
                                    lastx = map(p.position[k] + chrOffsets[p.chromosome[k] - 1], 0.0, chrTotal, 0.0, cWidth);
                                    lasty = map(p.lodscores[k], 0.0, m, 0.0, cHeight - 50);
                                } else line(x + lastx, (y + cHeight) - lasty - 50.0, x + (lastx = map(p.position[k] + chrOffsets[p.chromosome[k] - 1], 0.0, chrTotal, 0.0, cWidth)), (y + cHeight) - (lasty = map(p.lodscores[k], 0.0, m, 0.0, cHeight - 50)) - 50.0);
                            } catch (ArrayIndexOutOfBoundsException error) {
                                println("EXCEPTION:");
                                println(error.getLocalizedMessage());
                            }
                        }
                    }
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
            } if (dragging) {
                legendX = mouseX - legendOffsetX;
                legendY = mouseY - legendOffsetY;
                if (legendX < x) legendX = x;
                else if (legendX > (x + cWidth) - legendW) legendX = (x + cWidth)-legendW;
                if (legendY < y) legendY = y;
                else if (legendY > (y + cHeight) - legendH) legendY = (y + cHeight)-legendH;
            } if (!mousePressed || mouseButton != LEFT || !active) {
                legendOffsetX = legendOffsetY = -1;
                dragging = false;
            }
            fill(0x00, 0x2A);
            stroke(0x00, legendA);
            rect((float)legendX, (float)legendY, (float)(legendW=maxLen+18), (float)(legendH=(names.length*16)+4));
            stroke(0x00);
            textFont(legendFont);
            for (int i = 0; i < names.length; i++) {
                fill(colors[i]);
                rect((float)legendX+4.0, (float)legendY+((i+1)*16)-11, 10, 10);
                fill(0x00);
                text(names[i], (float)legendX+16.0, (float)legendY+((i+1)*16));
            }
        }
        //if (mouseX > legendX && mouseX < legendX+legendW && mouseY > legendY && mouseY < legendY+legendH && active)
            //dragReady = (!mousePressed || mouseButton != LEFT);
        //else
        dragReady = !(mousePressed && mouseButton == LEFT) && active;
        if (mouseX > x && mouseY > y && mouseX < cWidth - 50 && mouseY < height-100 && active)
            chr_ready = (!mousePressed || mouseButton != LEFT);
        else chr_ready = !(mousePressed && mouseButton == LEFT && active && dragging);
    }
    
    void mouseAction() {
        if (mouseX > legendX && mouseX < legendX + legendW && mouseY > legendY && mouseY < legendY + legendH) return;
        if (mouseX > x && mouseY > y && mouseX < x + cWidth && mouseY < y + cHeight - 50 && active && focus && mousePressed && mouseButton == LEFT && !dragging && chr_ready && current_chr == -1) {
                for (int i = 0; i < chrOffsets.length; i++) {
                    if (mouseX > map(chrOffsets[i], 0.0, chrTotal, 0.0, width - 50 - x) + x) {
                        if (i == chrOffsets.length - 1)
                            current_chr = i;
                        else if (mouseX < map(chrOffsets[i+1], 0.0, chrTotal, 0.0, width - 50 - x) + x)
                            current_chr = i;
                    }
             }
        }
    }
    
    void keyAction(char c, int i, int j) {
        if (!keyPressed) return;
        /*if ((key == DELETE || key == BACKSPACE) && j == 64)
            current_chr = -1;
        else if (key == CODED && keyCode == LEFT && j == 64 && current_chr > 0)
            current_chr--;
        else if (key == CODED && keyCode == RIGHT && j == 64 && current_chr > -1 && current_chr < lastChr()-1)
            current_chr++;*/
    }
    
    void nextChr() {
        if (tabs.currentpage != 0) return;
        if (current_chr > -1 && current_chr < lastChr()-1) current_chr++;
        //else current_chr = -1;
    }
    
    void prevChr() {
        if (tabs.currentpage != 0) return;
        if (current_chr > 0) current_chr--;
        //else current_chr = -1;
    }
    
    void allChr() {
        if (tabs.currentpage != 0) return;
        current_chr = -1;
    }
    
    void findMax() {
        maxLod = maxOffset = -1.0;
        for(int i = 0; i < parentFiles.size(); i++) {
            Parent_File pf = (Parent_File)parentFiles.get(i);
            for (int j = 0; j < pf.size(); j++) {
                Phenotype p = pf.get(j);
                if (((UITreeNode)((UITreeNode)fileTree.get(i)).get(j)).checked) {
                    /*for (int k = 0; k < p.lodscores.length; k++) {
                        if (current_chr == -1) { if (p.lodscores[k] > maxLod) maxLod = p.lodscores[k]; }
                        else { 
                            if (p.chromosome[k] == current_chr+1) {
                             if (p.lodscores[k] > maxLod) maxLod = p.lodscores[k];
                             if (p.position[k] > maxOffset) maxOffset = p.position[k];
                            }
                        }*/
                    float m;
                    if (current_chr == -1 && (m = max(p.lodscores)) > maxLod) maxLod = m;
                    else for (int k = 0; k < p.lodscores.length; k++) {
                        if (p.chromosome[k] == current_chr+1) {
                            if (p.lodscores[k] > maxLod) maxLod = p.lodscores[k];
                            if (p.position[k] > maxOffset) maxOffset = p.position[k];
                        }
                    }
                }
            }
        }
        if (maxOffset != -1.0 && maxOffset < chrLengths[current_chr]) maxOffset = chrLengths[current_chr];
    }
    
    int lastChr() {
        int maxChr = -1;
        for(int i = 0; i < parentFiles.size(); i++) {
            Parent_File pf = (Parent_File)parentFiles.get(i);
            for (int j = 0; j < pf.size(); j++) {
                Phenotype p = pf.get(j);
                if (((UITreeNode)((UITreeNode)fileTree.get(i)).get(j)).checked)
                    if (p.chromosome[p.chromosome.length-1] > maxChr) maxChr = p.chromosome[p.chromosome.length-1];
            }
        }
        return maxChr;
    }    
    int size() { return 0; }
}
