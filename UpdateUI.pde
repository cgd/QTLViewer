/*
* Copyright (c) 2010 The Jackson Laboratory
*
* This software was developed by Matt Hibbs' Lab at The Jackson
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

/**
* This module is a container for methods that draw UI components and handle events.
*/

void updateMenu() {
    // draw the menu, set focus/activity based on whether or not the menu is shown
    if (menuTargetY == -100.0) { // menu is shown
        texts.active = texts.focus = !exiting;
        unitSelect.active = unitSelect.focus = !exiting;
        loadcfg.focus = loadcfg.active = !exiting;
    } else { // menu is hidden
        texts.active = texts.focus = false;
        unitSelect.active = unitSelect.focus = false;
        loadcfg.focus = loadcfg.active = false;
    }
    
    stroke(0xCC);
    fill(0x00, 0x00, 0x00, 0xAA);
    //pushMatrix();
    
    // translate(0.0, menuY, 0);
    menuY += (menuTargetY - menuY) * velocity; // this moves the menu up or down in a non-linear way
    
    if (abs(menuTargetY - menuY) < 0.25) {
        menuY = menuTargetY;
    }

    // draw the menu outline
    beginShape();
    
    for (int i = 0; i < 20; i+=2) {
        vertex(i + 10, (-sin((i * HALF_PI) / 20.0) * 20.0) + drawHeight + menuY);
    }
    
    vertex(75, drawHeight - 20 + menuY);
    
    for (int i = 20; i >= 0; i -= 2) {
        vertex(95 - i, (-sin((abs(i) * HALF_PI) / 20.0) * 20.0) + drawHeight + menuY);
    }
    
    vertex(drawWidth - 10, drawHeight + menuY);
    vertex(drawWidth - 10, drawHeight + 100);
    vertex(10, drawHeight + 100);
    vertex(10, drawHeight);
    endShape();
    
    // update, draw menu components
    fill(0xFF);
    //popMatrix();
    ((UIComponent)texts.get(0)).y = (drawHeight + menuY) + 10;
    ((UIComponent)texts.get(1)).y = (drawHeight + menuY) + 36;
    unitSelect.y = drawHeight + menuY + 10;
    loadcfg.y = drawHeight + menuY + 10;
    texts.update();
    unitSelect.update();
    loadcfg.update();
}

void updateViewArea() {
    // expand/contract fileTree view area
    if (Math.abs(tabs.x - tabsXTarget) < 0.1) {
        if (tabs.x != tabsXTarget) {
            updateGenes = true;
        }
        
        tabs.x = tabsXTarget;
    }
    
    fileTree.cWidth -= (ENABLE_KINECT) ? 0 : (tabs.x - tabsXTarget) * velocity;
    tabs.x -= (tabs.x - tabsXTarget) * velocity;
    ((LODDisplay)tabs.get((ENABLE_KINECT) ? 1 : 0).get(0)).x = tabs.x + 65;
    ((ChrDisplay)tabs.get((ENABLE_KINECT) ? 2 : 1).get(0)).x = tabs.x + 25;
    
    if (tabs.x != tabsXTarget) {
        ((ChrDisplay)tabs.get((ENABLE_KINECT) ? 2 : 1).get(0)).update = true; // update the ChrDisplay if its width has changed
    }
    
    if (!ENABLE_KINECT) {
        // draw triangle for view select
        fill(0x55);
        if (!exiting && mouseX > fileTree.x + fileTree.cWidth && mouseX < tabs.x && mouseY > fileTree.y && mouseY < drawHeight + menuTargetY) {
            fill(0x00);
        }
        
        noStroke();
        pushMatrix();
        translate(tabs.x - 6, drawHeight / 2.0);
        rotate(PI * (tabs.x - 110.0) / (335.0 - 110.0));
        beginShape();
        vertex(3, 0);
        vertex(-3, -(3.0 / cos(PI / 6.0)));
        vertex(-3, (3.0 / cos(PI / 6.0)));
        endShape();
        popMatrix();
    } else {
        tabs.x = 10;
    }
    
    // update focus, activity settings based on whether or not the user is being prompted for exit
    tabs.focus = !exiting && menuTargetY == 0.0;
    tabs.active = !exiting && menuTargetY == 0.0;
    tabs.update();
    
    if (!ENABLE_KINECT) {
        fileTree.focus = !exiting && menuTargetY == 0.0;
        fileTree.active = !exiting && menuTargetY == 0.0;
        
        fileTree.update();
    }
}

void updateLegend() { 
    textFont(legendFont);
    
    String[] names = new String[0];
    String[] files = new String[0];
    int[] colors = new int[0];
    float maxLen = -1.0;
    
        
    for (int i = 0; i < fileTree.size(); i++) {
        for (int j = 0; j < fileTree.get(i).size(); j++) {
            if (fileTree.get(i).get(j).checked) {
                names = (String[])append(names, fileTree.get(i).get(j).title);
                files = (String[])append(files, fileTree.get(i).title);
                
                if (textWidth(fileTree.get(i).get(j).title + " (" + fileTree.get(i).title + ")") > maxLen) {
                    maxLen = textWidth(fileTree.get(i).get(j).title + " (" + fileTree.get(i).title + ")");
                }
                
                colors = append(colors, fileTree.get(i).get(j).drawcolor);
            }
        }
    }
    
    if (names.length == 0 || colors.length == 0) {
        return;
    }
    
    if (ENABLE_KINECT) {
        strokeWeight(1);
        stroke(0x00);
        if (tabs.currentpage == 1 || tabs.currentpage == 2 || tabs.currentpage == 3) {
            for (int i = 0; i < names.length; i++) {
                fill(colors[i]);
                rect(drawWidth + 4, 4 + (i * 32), 32, 32);
                
                String _name = names[i];
                
                if (textWidth(_name) >= width - drawWidth - 10) {
                    while (textWidth(_name + "...") >= width - drawWidth - 10) {
                        _name = _name.substring(0, _name.length() - 1);
                    }
                    
                    _name += "...";
                }
                
                fill(0x00);
                text(_name, drawWidth + 38, (i + 1) * 32);
            }
        }

        return;
    }
    
    if (mouseX > legendX && mouseX < legendX + legendW && mouseY > legendY && mouseY < legendY + legendH && !exiting) {
        legendBorder += (legendBorder < 0xFF) ? frameRate / 5.0 : 0;
                
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
        legendBorder -= (legendBorder > 0x00) ? frameRate / 5.0 : 0;
        
        if (legendBorder < 0x00) {
            legendBorder = 0x00;
        }
    }
    
    if (dragging) {
        legendX = mouseX - legendOffsetX;
        legendY = mouseY - legendOffsetY;
    }
    
    if (legendX < tabs.x) {
        legendX = tabs.x;
    } else if (legendX > (tabs.x + tabs.cWidth) - legendW) {
        legendX = (tabs.x + tabs.cWidth) - legendW;
    }
    
    if (legendY < tabs.y) {
        legendY = tabs.y;
    } else if (legendY > (tabs.y + tabs.cHeight) - legendH) {
        legendY = (tabs.y + tabs.cHeight) - legendH;
    }
    
    if (!mousePressed || mouseButton != LEFT) {
        legendOffsetX = legendOffsetY = -1;
        dragging = false;
    }
    
    fill(0x00, 0x2A);
    stroke(0x00, legendBorder);
    rect(legendX, legendY, (legendW = maxLen + 18), (legendH = (names.length * 16) + 4));
    stroke(0x00);
    
    for (int i = 0; i < names.length; i++) {
        fill(colors[i]);
        rect(legendX + 4, legendY+((i + 1) * 16) - 11, 10, 10);
        fill(0x00);
        text(names[i] + " (" + files[i] + ")", legendX + 16, legendY + ((i + 1) * 16));
    }
    
    if (mouseX > legendX && mouseX < legendX + legendW && mouseY > legendY && mouseY < legendY + legendH) {
        dragReady = (!mousePressed || mouseButton != LEFT);
    } else {
        dragReady = !(mousePressed && mouseButton == LEFT);
    }
    
    if (mouseX > tabs.x && mouseY > tabs.y && mouseX < drawWidth - 50 && mouseY < drawHeight - 100) {
        loddisplay.chr_ready = chrdisplay.chr_ready = (mousePressed || mouseButton != LEFT);
    } else {
        loddisplay.chr_ready = chrdisplay.chr_ready = !(mouseButton == LEFT && dragging);
    }
}
