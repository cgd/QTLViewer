class UIKTree extends UITree {
    PFont title = createFont("Arial", 48, true);
    boolean displayFile = false;
    int currentFile = -1;
    int currentPh = -1;
    int page = 0;
    long lastFrame = -1;
    float panYAmount = 0.0, panXAmount = 0.0;
    int panId = -1;
    UIButton ryes, rno;
    PGraphics hsbGraph;
    
    UIKTree(float newX, float newY, float newWidth, float newHeight, UIListener nodeRemove, UIListener elementRemove) {
        super(newX, newY, newWidth, newHeight, nodeRemove, elementRemove);
        cHeight = newHeight;
        
        ryes = new UIButton((drawWidth / 2.0) - 136, drawHeight / 2.0, "Yes", 128, 64, 48, new UIAction() {
            public void doAction() {
                remove(removeN.eventHeard(currentFile--, 0));
                currentFile = 0;
                
                lastFrame = frameCount;
                displayFile = false;
                mousePressed = false;
                currentPh = -1;
                hasUpdated = true;
                clientFreeMouse();
            }
        });
        
        rno = new UIButton((drawWidth / 2.0) + 8, drawHeight / 2.0, "No", 128, 64, 48, new UIAction() {
            public void doAction() {
                lastFrame = frameCount;
                clientFreeMouse();
                clientKillMouseEvents();
                mousePressed = false;
                displayFile = false;
                currentPh = -1;
            }
        });
        
        ryes.setKey(this);
        rno.setKey(this);
        
        hsbGraph = createGraphics(drawHeight - 572, drawHeight - 572, P2D);
        hsbGraph.beginDraw();
        hsbGraph.noStroke();
        hsbGraph.colorMode(HSB, 255);
        
        for (int i = 0; i < drawHeight - 572; i++) {
            for (int j = 0; j < drawHeight - 572; j++) {
                hsbGraph.stroke(map(i, 0, drawHeight - 572, 0, 255), map(j, 0, drawHeight - 572, 0, 255), 255);
                hsbGraph.point(i, j);
            }
        }
        colorMode(RGB, 255);
        hsbGraph.endDraw();
    }
    
    void update() {
        stroke(0x00);
        strokeWeight(2);
        fill(0xAA);
        textFont(title);
        rect(x, y + 72, cWidth, cHeight);

        if (currentFile >= super.size()) {
            currentFile = super.size() - 1;
        }
        
        if (currentPh != -1 && currentPh >= super.get(currentFile).size()) {
            currentFile = -1;
        } else if (currentFile == -1 && super.size() > 0) {
            currentFile = 0;
        }
        
        if (currentFile != -1) {
            String t = super.get(currentFile).title;
            
            if (textWidth(t) + 16 >= cWidth) {
                while(textWidth(t + "...") + 16 >= cWidth) {
                    t = t.substring(0, t.length() - 1);
                }
                
                t += "...";
            }
            
            noFill();
            if (mouseInRect(this, x, y + 8, x + textWidth(t) + 16, y + 56) && !displayFile && currentPh == -1) {
                fill(0x55);
                rect(x, y + 8, textWidth(t) + 16, 48);
                fill(0xFF);
                
                if (mousePressedInRect(this, x, y + 8, x + textWidth(t) + 16, y + 56) && (lastFrame == -1 || frameCount - lastFrame > 1)) {
                    displayFile = true;
                    lockMouse(this);
                    lastFrame = frameCount;
                }
            } else {
                rect(x, y + 8, textWidth(t) + 16, 48);
                fill(0x00);
            }
            
            text(t, x + 8, y + 48);
            
            int maxLines = (int)(cHeight - 72) / 48;
            
            while (ceil((float)super.get(currentFile).size() / maxLines) <= page) {
                page--;
            }
            
            if (page == -1) {
                return;
            }
            
            strokeWeight(1);
            stroke(0x00);
            
            for (int i = page * maxLines, l = 0; i < super.get(currentFile).size() && l < maxLines; i++, l++) {
                t = super.get(currentFile).get(i).title;
                
                if (textWidth(t) + 52 >= cWidth) {
                    while(textWidth(t + "...") + 52 >= cWidth) {
                        t = t.substring(0, t.length() - 1);
                    }
                    
                    t += "...";
                }
                
                fill(super.get(currentFile).get(i).drawcolor);
                stroke(0x00);
                strokeWeight(1);
                
                rect(x, y + 78 + (l * 48), 48, 48);
                               
                if (super.get(currentFile).get(i).checked) {
                    noStroke();
                    fill(negate(super.get(currentFile).get(i).drawcolor));
                    
                    rect(x + 12, y + 90 + (l * 48), 24, 24);
                }
                
                fill(0x00);
                if (mouseInRect(this, x, y + 78 + (l * 48), x + cWidth, y + 72 + ((l + 1) * 48)) && !displayFile && currentPh == -1) {
                    fill(0x55);
                    noStroke();
                    rect(x + 52, y + 78 + (l * 48), cWidth - 52, 48);
                    stroke(0x00);
                    fill(0xFF);
                    
                    if (mousePressed && mouseButton == RIGHT && mouseX > x && mouseX < x + cWidth && mouseY > y + 72 + (l * 48) + 6 && mouseY < y + 72 + ((l + 1) * 48)) {
                        super.get(currentFile).get(i).checked = true;
                        hasUpdated = true;
                    } else if (mousePressedInRect(this, x, y + 72 + (l * 48) + 6, x + cWidth, y + 72 + ((l + 1) * 48)) && (lastFrame == -1 || frameCount - lastFrame > 1)) {                        
                        currentPh = i;
                        lockMouse(this);
                        lastFrame = frameCount;
                    }
                }
                
                text(t, x + 52, y + 72 + ((l + 1) * 48));
            }
            
            if (displayFile) {
                noStroke();
                fill(0x00, 0xAA);
                rect(0, 0, drawWidth, drawHeight);
                
                fill(0xAA);
                stroke(0x00);
                strokeWeight(2);
                rect(400, 400, drawWidth - 800, drawHeight - 800);
                
                fill(0x00);
                text("Remove file from list?", (drawWidth - textWidth("Remove file from list?")) / 2.0, (drawHeight / 2.0) - 48);
                
                ryes.active = rno.active = this.active;
                ryes.update();
                rno.update();
            } else if (currentPh != -1) {
                noStroke();
                fill(0x00, 0xAA);
                rect(0, 0, drawWidth, drawHeight);
                
                fill(0xAA);
                stroke(0x00);
                strokeWeight(2);
                rect(200, 200, drawWidth - 400, drawHeight - 400);
                
                fill(0x00);
                String title = super.get(currentFile).get(currentPh).title;
                text(title, (drawWidth - textWidth(title)) / 2.0, 248);
                
                noFill();
                rect(264, 312, drawHeight - 572, drawHeight - 572);
                image(hsbGraph, 264, 312);
                
                fill(super.get(currentFile).get(currentPh).drawcolor);
                noStroke();
                rect(drawWidth - 200 - ((drawWidth - 480) / 4.0) - 64, 312, ((drawWidth - 480) / 4.0), drawHeight - 572);
            }
        }
    }
    
    void clientFreeMouse() {
        freeMouse(this);
    }
    
    void clientKillMouseEvents() {
        killMouseEvents(this);
    }
    
    void mouseAction() {
        if (displayFile) {
            if (mousePressed && mouseButton == LEFT && (mouseX < 400 || mouseY < 400 || mouseX > drawWidth - 400 || mouseY > drawHeight - 400) && (lastFrame == -1 || frameCount - lastFrame > 1)) {
                displayFile = false;
                lastFrame = frameCount;
                freeMouse(this);
                blockEvents();
                return;
            }
            
            ryes.mouseAction();
            rno.mouseAction();
        }
        
        if (currentPh != -1) {
            if (mousePressed && mouseButton == LEFT && (mouseX < 200 || mouseY < 200 || mouseX > drawWidth - 200 || mouseY > drawHeight - 200) && (lastFrame == -1 || frameCount - lastFrame > 1)) {
                currentPh = -1;
                lastFrame = frameCount;
                freeMouse(this);
                blockEvents();
                return;
            }
        }
        
        if (currentPh != -1 && mouseX > 264 && mouseY > 312 && mouseX < 264 + drawHeight - 572 && mouseY < 312 + drawHeight - 572) {
            float h = map(mouseX - 264, 0, drawHeight - 572, 0, 255);
            float b = map(mouseY - 312, 0, drawHeight - 572, 0, 255);
            
            colorMode(HSB, 255);
            super.get(currentFile).get(currentPh).drawcolor = color(h, b, 255);
            colorMode(RGB, 255);
        }
    }
    
    void pan(PVector vec) {
        panYAmount += vec.y;
        panXAmount += vec.x;
        
        if (panYAmount > 300.0 && panId != -1) {
            page++;
            panYAmount = 0;
        } else if (panYAmount < -300.0 && panId != -1 && page > 0) {
            page--;
            panYAmount = 0;
        }
        
        if (panXAmount > 200.0 && panId != -1 && currentFile <= size()) {
            currentFile++;
        } else if (panXAmount < -200.0 && panId != -1 && currentFile > 0) {
            currentFile--;
        }
    }
    
    void panStart(int id) {
        panId = id;
    }
    
    void panEnd(int id) {
        panId = -1;
    }
    
    color negate(color c) {
        return color(0xFF - red(c), 0xFF - green(c), 0xFF - blue(c));
    }
    
    void blockEvents() {
    }
}
