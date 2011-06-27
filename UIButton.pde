class UIButton extends UIComponent {
    String data;
    PFont font = createFont("Arial", 16, true);
    color bg = color(0xCC), border = color(0xFF), mouse = color(0x99), textc = color(0x33);
    boolean ready = true;
    UIAction action = null;
    
    UIButton(float newX, float newY, String newData, UIAction newAction) {
        super();
        x = newX; 
        y = newY; 
        cWidth = textWidth(newData); 
        cHeight = 25;
        data = newData;
        action = newAction;
    }

    void update() {
        textFont(font);
        cWidth = textWidth(data) + 8;
        fill(bg);
        stroke(border);
        
        if (mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y + cHeight && active) {
            if (!mousePressed || mouseButton != LEFT && active) {
                ready = true;
            }
            
            stroke(mouse);
        } else {
            ready = !(mousePressed && mouseButton == LEFT && active);
        }
        
        strokeWeight(1);
        rect(x, y, cWidth, cHeight);
        fill(textc);
        text(data, x + 4, y + 18);
    }
    
    void mouseAction() {
        if (mousePressed && mouseButton == LEFT && ready && action != null && active && mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y + cHeight) {
            action.doAction();
        }
    }
    
    void keyAction(char k, int c, int mods) {
        if ((k == ENTER || k == RETURN) && active && focus) {
            action.doAction();
        }
    }

    int size() { return 0; }
}
