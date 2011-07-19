class UIKTree extends UITree {
    PFont title = createFont("Arial", 48, true);
    boolean displayFile = false;
    int currentFile = -1;
    int currentPh = -1;
    int page = 0;
    UIButton ryes, rno;
    UIButton rMax, rMin, gMax, gMin, bMax, bMin;
    UIButton enable;
    
    UIKTree(float newX, float newY, float newWidth, float newHeight, UIListener nodeRemove, UIListener elementRemove) {
        super(newX, newY, newWidth, newHeight, nodeRemove, elementRemove);
        
        ryes = new UIButton((drawWidth / 2.0) - 136, drawHeight / 2.0, "Yes", 128, 64, 48, new UIAction() {
            public void doAction() {
                if (displayFile) {
                    remove(removeN.eventHeard(currentFile--, 0));
                    currentFile = 0;
                } else if (currentPh != -1) {
                    get(currentFile).remove(removeE.eventHeard(currentFile, currentPh--));
                    page = 0;
                }
                
                displayFile = false;
                mousePressed = false;
                currentPh = -1;
                hasUpdated = true;
                clientFreeMouse();
            }
        });
        
        rno = new UIButton((drawWidth / 2.0) + 8, drawHeight / 2.0, "No", 128, 64, 48, new UIAction() {
            public void doAction() {
                mousePressed = false;
                displayFile = false;
                currentPh = -1;
                clientFreeMouse();
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
        
        enable = new UIButton(264 + (3 * ((drawWidth - 480) / 4.0)), 480, "Enable", (drawWidth - 480) / 4.0, 64, 48, new UIAction() {
            public void doAction() {
                if (currentPh != -1) {
                    if (enable.data.toLowerCase().startsWith("e")) {
                        get(currentFile).get(currentPh).checked = true;
                        enable.data = "Disable";
                    } else if (enable.data.toLowerCase().startsWith("d")) {
                        get(currentFile).get(currentPh).checked = false;
                        enable.data = "Enable";
                    }
                }
                
                mousePressed = false;
            }
        });
    }
    
    void update() {
        stroke(0x00);
        strokeWeight(2);
        fill(0xAA);
        textFont(title);
        rect(x, y + 72, cWidth, cHeight);
        
        if (currentFile >= super.size()) {
            currentFile = -1;
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
                
                if (mousePressedInRect(this, x, y + 8, x + textWidth(t) + 16, y + 56)  && !displayFile && currentPh == -1) {
                    rno.data = "No";
                    rno.x = (drawWidth / 2.0) + 8;
                    rno.y = drawHeight / 2.0;
                    rno.cWidth = 128;
                    
                    ryes.data = "Yes";
                    ryes.x = (drawWidth / 2.0) - 136;
                    ryes.y = drawHeight / 2.0;
                    ryes.cWidth = 128;
                    
                    displayFile = true;
                    lockMouse(this);
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
                
                if (super.get(currentFile).get(i).checked) {
                    strokeWeight(2);
                } else {
                    noStroke();
                }
                
                rect(x, y + 78 + (l * 48), 48, 48);
                fill(0x00);
                if (mouseInRect(this, x, y + 78 + (l * 48), x + cWidth, y + 72 + ((l + 1) * 48)) && !displayFile && currentPh == -1) {
                    fill(0x55);
                    noStroke();
                    rect(x + 52, y + 78 + (l * 48), cWidth - 52, 48);
                    stroke(0x00);
                    fill(0xFF);
                    
                    if (mousePressedInRect(this, x, y + 72 + (l * 48) + 6, x + cWidth, y + 72 + ((l + 1) * 48)) && !displayFile && currentPh == -1) {
                        rno.data = "Accept";
                        rno.x = 264 + (3 * ((drawWidth - 480) / 4.0));
                        rno.y = 312;
                        rno.cWidth = (drawWidth - 480) / 4.0;
                        
                        ryes.data = "Remove";
                        ryes.x = 264 + (3 * ((drawWidth - 480) / 4.0));
                        ryes.y = 392;
                        ryes.cWidth = (drawWidth - 480) / 4.0;
                        
                        enable.data = (super.get(currentFile).get(i).checked) ? "Disable" : "Enable";
                        
                        currentPh = i;
                        lockMouse(this);
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
                
                ryes.active = rno.active = this.active;
                rMax.active = rMin.active = this.active;
                gMax.active = gMin.active = this.active;
                bMax.active = bMin.active = this.active;
                enable.active = this.active;
                
                ryes.update();
                rno.update();
                rMax.update();
                rMin.update();
                gMax.update();
                gMin.update();
                bMax.update();
                bMin.update();
                enable.update();
                
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
            }
        }
    }
    
    void clientFreeMouse() {
        freeMouse(this);
    }
    
    void mouseAction() {
        ryes.mouseAction();
        rno.mouseAction();
        
        rMax.mouseAction();
        rMin.mouseAction();
        
        gMax.mouseAction();
        gMin.mouseAction();
        
        bMax.mouseAction();
        bMin.mouseAction();
        
        enable.mouseAction();
        
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
}
