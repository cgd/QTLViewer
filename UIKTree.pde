class UIKTree extends UITree {
    PFont title = createFont("Arial", 48, true);
    boolean displayFile = false;
    int currentFile = -1;
    int currentPh = -1;
    
    UIKTree(float newX, float newY, float newWidth, float newHeight, UIListener nodeRemove, UIListener elementRemove) {
        super(newX, newY, newWidth, newHeight, nodeRemove, elementRemove);
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
        }
        
        if (currentFile != -1) {
            if (super.size() > 0) {
                currentFile = 0;
            }
            
            String t = super.get(currentFile).title;
            
            if (textWidth(t) + 16 >= cWidth) {
                while(textWidth(t + "...") + 16 >= cWidth) {
                    t = t.substring(0, t.length() - 1);
                }
                
                t += "...";
            }
            
            text(t, x + 4, y + 48);
            
            line(x - 8, y + 8, x - 8, y + 56);
            line(x + textWidth(t) + 8, y + 8, x + textWidth(t) + 8, y + 56);
            line(x - 8, y + 8, x + textWidth(t) + 8, y + 8);
            line(x - 8, y + 56, x + textWidth(t) + 8, y + 56);
        }
    }
}
