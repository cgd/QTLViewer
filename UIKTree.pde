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
    UIButton rMax, rMin, gMax, gMin, bMax, bMin;
    
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
        
        rMax = new UIButton(216, 264, "", (drawWidth - 480) / 4.0, 32, 48, new UIAction() {
            public void doAction() {
                if (currentPh != -1) {
                    color c = get(currentFile).get(currentPh).drawcolor;
                    get(currentFile).get(currentPh).drawcolor = color(0xFF, green(c), blue(c));
                }
            }
        });
        
        rMin = new UIButton(216, drawHeight - 248, "", (drawWidth - 480) / 4.0, 32, 48, new UIAction() {
            public void doAction() {
                if (currentPh != -1) {
                    color c = get(currentFile).get(currentPh).drawcolor;
                    get(currentFile).get(currentPh).drawcolor = color(0x00, green(c), blue(c));
                }
            }
        });
        
        gMax = new UIButton(232 + ((drawWidth - 480) / 4.0), 264, "", (drawWidth - 480) / 4.0, 32, 48, new UIAction() {
            public void doAction() {
                if (currentPh != -1) {
                    color c = get(currentFile).get(currentPh).drawcolor;
                    get(currentFile).get(currentPh).drawcolor = color(red(c), 0xFF, blue(c));
                }
            }
        });
        
        gMin = new UIButton(232 + ((drawWidth - 480) / 4.0), drawHeight - 248, "", (drawWidth - 480) / 4.0, 32, 48, new UIAction() {
            public void doAction() {
                if (currentPh != -1) {
                    color c = get(currentFile).get(currentPh).drawcolor;
                    get(currentFile).get(currentPh).drawcolor = color(red(c), 0x00, blue(c));
                }
            }
        });
        
        bMax = new UIButton(248 + ((drawWidth - 480) / 2.0), 264, "", (drawWidth - 480) / 4.0, 32, 48, new UIAction() {
            public void doAction() {
                if (currentPh != -1) {
                    color c = get(currentFile).get(currentPh).drawcolor;
                    get(currentFile).get(currentPh).drawcolor = color(red(c), green(c), 0xFF);
                }
            }
        });
        
        bMin = new UIButton(248 + ((drawWidth - 480) / 2.0), drawHeight - 248, "", (drawWidth - 480) / 4.0, 32, 48, new UIAction() {
            public void doAction() {
                if (currentPh != -1) {
                    color c = get(currentFile).get(currentPh).drawcolor;
                    get(currentFile).get(currentPh).drawcolor = color(red(c), green(c), 0x00);
                }
            }
        });
        
        ryes.setKey(this);
        rno.setKey(this);
        rMax.setKey(this);
        rMin.setKey(this);
        gMax.setKey(this);
        gMin.setKey(this);
        bMax.setKey(this);
        bMin.setKey(this);
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
                
                rMax.active = rMin.active = this.active;
                gMax.active = gMin.active = this.active;
                bMax.active = bMin.active = this.active;
                
                rMax.update();
                rMin.update();
                gMax.update();
                gMin.update();
                bMax.update();
                bMin.update();
                
                noStroke();
                
                fill(0xFF, 0x00, 0x00);
                float rHeight = map(red(super.get(currentFile).get(currentPh).drawcolor), 0, 0xFF, 0, drawHeight - 572);
                rect(216, 312 + drawHeight - 572 - rHeight, (drawWidth - 480) / 4.0, rHeight);
                
                fill(0x00, 0xFF, 0x00);
                float gHeight = map(green(super.get(currentFile).get(currentPh).drawcolor), 0, 0xFF, 0, drawHeight - 572);
                rect(232 + ((drawWidth - 480) / 4.0), 312 + drawHeight - 572 - gHeight, (drawWidth - 480) / 4.0, gHeight);
                
                fill(0x00, 0x00, 0xFF);
                float bHeight = map(blue(super.get(currentFile).get(currentPh).drawcolor), 0, 0xFF, 0, drawHeight - 572);
                rect(248 + ((drawWidth - 480) / 2.0), 312 + drawHeight - 572 - bHeight, (drawWidth - 480) / 4.0, bHeight);
                
                stroke(0x00);
                strokeWeight(2);
                noFill();
                
                rect(216, 312, (drawWidth - 480) / 4.0, drawHeight - 572);
                
                rect(232 + ((drawWidth - 480) / 4.0), 312, (drawWidth - 480) / 4.0, drawHeight - 572);
                
                rect(248 + ((drawWidth - 480) / 2.0), 312, (drawWidth - 480) / 4.0, drawHeight - 572);
                
                fill(super.get(currentFile).get(currentPh).drawcolor);
                noStroke();
                rect(296 + (3 * ((drawWidth - 480) / 4.0)), 312, ((drawWidth - 480) / 4.0) - 64, drawHeight - 572);
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
            
            rMax.mouseAction();
            rMin.mouseAction();
            
            gMax.mouseAction();
            gMin.mouseAction();
            
            bMax.mouseAction();
            bMin.mouseAction();
        }
        
        if (currentPh != -1 && mouseX > 216 && mouseX < 248 + (3 * ((drawWidth - 480) / 4.0)) && mouseY > 312 && mouseY < 312 + drawHeight - 572 && mousePressed && mouseButton == LEFT) {
            if (mouseX > 216 && mouseX < 216 + ((drawWidth - 480) / 4.0)) { // red box
                color c = super.get(currentFile).get(currentPh).drawcolor;
                super.get(currentFile).get(currentPh).drawcolor = color(map(312 + drawHeight - 572 - mouseY, 0, drawHeight - 572, 0, 0xFF), green(c), blue(c));
            } else if (mouseX > 232 + ((drawWidth - 480) / 4.0) && mouseX < 232 + ((drawWidth - 480) / 2.0)) { // green box
                color c = super.get(currentFile).get(currentPh).drawcolor;
                super.get(currentFile).get(currentPh).drawcolor = color(red(c), map(312 + drawHeight - 572 - mouseY, 0, drawHeight - 572, 0, 0xFF), blue(c));
            } else if (mouseX > 248 + ((drawWidth - 480) / 2.0) && mouseX < 248 + (3 * ((drawWidth - 480) / 4.0))) { // blue box
                color c = super.get(currentFile).get(currentPh).drawcolor;
                super.get(currentFile).get(currentPh).drawcolor = color(red(c), green(c), map(312 + drawHeight - 572 - mouseY, 0, drawHeight - 572, 0, 0xFF));
            }
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
