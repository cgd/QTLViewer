/**
* This module is a container for methods that draw UI components and handle events.
*/

void updateMenu() {
    // draw the menu, set focus/activity based on whether or not the menu is shown
    stroke(0xCC);
    fill(0x00, 0x00, 0x00, 0xAA);
    pushMatrix();
    
    if (menuTargetY == -100.0) { // menu is shown
        texts.active = !exiting;
        texts.focus = !exiting;
        unitSelect.active = !exiting;
        unitSelect.focus = !exiting;
        loadcfg.focus = !exiting;
        loadcfg.active = !exiting;
    } else { // menu is hidden
        texts.active = false;
        texts.focus = false;
        unitSelect.active = false;
        unitSelect.focus = false;
        loadcfg.focus = false;
        loadcfg.active = false;
    }
    
    translate(0.0, menuY, 0);
    menuY += (menuTargetY - menuY) * velocity; // this moves the menu up or down in a non-linear way
    
    if (abs(menuTargetY - menuY) < 0.25) {
        menuY = menuTargetY;
    }

    // draw the menu outline
    beginShape();
    
    for (int i = 0; i < 20; i+=2) {
        vertex(i+10, (-sin((i*HALF_PI)/20.0)*20.0)+height);
    }
    
    vertex(75, height-20);
    
    for (int i = 20; i >= 0; i -= 2) {
        vertex(95-i, (-sin((abs(i)*HALF_PI)/20.0)*20.0)+height);
    }
    
    vertex(width-10, height);
    vertex(width-10, height+100);
    vertex(10, height+100);
    vertex(10, height);
    endShape();
    
    // update, draw menu components
    fill(0xFF);
    popMatrix();
    ((UIComponent)texts.get(0)).y = (height+menuY)+10;
    ((UIComponent)texts.get(1)).y = (height+menuY)+36;
    unitSelect.y = height+menuY+10;
    loadcfg.y = height+menuY+10;
    texts.update();
    unitSelect.update();
    loadcfg.update();
}

void updateViewArea() {
    // expand/contract fileTree view area
    if (Math.abs(tabs.x - tabsXTarget) < 0.1) {
        tabs.x = tabsXTarget;
    }
    
    fileTree.cWidth -= (tabs.x - tabsXTarget) * velocity;
    tabs.x -= (tabs.x - tabsXTarget) * velocity;
    ((LODDisplay)tabs.get(0).get(0)).x = tabs.x + 65;
    ((LODDisplay)tabs.get(0).get(0)).cWidth = -35;
    ((ChrDisplay)tabs.get(1).get(0)).x = tabs.x + 25;
    ((ChrDisplay)tabs.get(1).get(0)).cWidth = -35;
    
    if (tabs.x != tabsXTarget) {
        ((ChrDisplay)tabs.get(1).get(0)).update = true; // update the ChrDisplay if its width has changed
    }
    
    // draw triangle for view select
    fill(0x55);
    if (!exiting && mouseX > fileTree.x + fileTree.cWidth && mouseX < tabs.x && mouseY > fileTree.y && mouseY < height + menuTargetY) {
        fill(0x00);
    }
    
    noStroke();
    pushMatrix();
    translate(tabs.x - 6, height/2.0);
    rotate(PI * (tabs.x - 110.0)/(335.0 - 110.0));
    beginShape();
    vertex(3.0, 0);
    vertex(-3.0, -(3.0/cos(PI/6.0)));
    vertex(-3.0, (3.0/cos(PI/6.0)));
    endShape();
    popMatrix();
    
    // update focus, activity settings based on whether or not the user is being prompted for exit
    tabs.focus = !exiting && menuTargetY == 0.0;
    tabs.active = !exiting && menuTargetY == 0.0;
    tabs.update();
    fileTree.focus = !exiting && menuTargetY == 0.0;
    fileTree.active = !exiting && menuTargetY == 0.0;
    fileTree.update();
}
