class UIKTree extends UITree {
    PFont title = createFont("Arial", 48, true);
    boolean displayFile = false;
    int currentFile = -1;
    int currentPh = -1;
    int page = 0;
    UIButton ryes, rno;
    
    UIKTree(float newX, float newY, float newWidth, float newHeight, UIListener nodeRemove, UIListener elementRemove) {
        super(newX, newY, newWidth, newHeight, nodeRemove, elementRemove);
        
        ryes = new UIButton((drawWidth / 2.0) - 136, drawHeight / 2.0, "Yes", 128, 64, 48, new UIAction() {
            public void doAction() {
                displayFile = false;
                remove(removeN.eventHeard(currentFile--, 0));
                currentFile = 0;
                hasUpdated = true;
                clientFreeMouse();
            }
        });
        
        rno = new UIButton((drawWidth / 2.0) + 8, drawHeight / 2.0, "No", 128, 64, 48, new UIAction() {
            public void doAction() {
                displayFile = false;
                clientFreeMouse();
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
                
                if (mousePressedInRect(this, x, y + 8, x + textWidth(t) + 16, y + 56)) {
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
                rect(x, y + 78 + (l * 48), 48, 48);
                fill(0x00);
                if (mouseInRect(this, x, y + 78 + (l * 48), x + cWidth, y + 72 + ((l + 1) * 48)) && !displayFile && currentPh == -1) {
                    fill(0x55);
                    noStroke();
                    rect(x + 52, y + 78 + (l * 48), cWidth - 52, 48);
                    stroke(0x00);
                    fill(0xFF);
                    
                    if (mousePressedInRect(this, x, y + 72 + (l * 48) + 6, x + cWidth, y + 72 + ((l + 1) * 48))) {
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
                
                ryes.active = this.active;
                rno.active = this.active;
                ryes.update();
                rno.update();
            }
        }
    }
    
    void clientFreeMouse() {
        freeMouse(this);
    }
    
    void mouseAction() {
        ryes.mouseAction();
        rno.mouseAction();
    }
}
