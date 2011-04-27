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
    
    /*UIButton(float ex, float why, float doubleu, float aech, String dee) {
        x = ex; y = why; w = doubleu; h = aech; data = dee;
        font = createFont("Arial", 16, true);
    }
        
    button(float ex, float why, float doubleu, float aech, String dee, PFont ef) {
        x = ex; y = why; w = doubleu; h = aech; font = ef;
        font = ef;
    }
    
    void setColors(color newbg, color newborder, color newmouse, color newtext) {
        bg = newbg; border = newborder; mouse = newmouse; textc = newtext;
    }*/
    
    void update() {
        textFont(font);
        cWidth = textWidth(data)+8;
        fill(bg);
        stroke(border);
        if (mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y + cHeight && active) {
            if (!mousePressed || mouseButton != LEFT && active)
                ready = true;
            stroke(mouse);
        } else ready = !(mousePressed && mouseButton == LEFT && active);
        strokeWeight(1);
        rect(x, y, cWidth, cHeight);
        fill(textc);
        text(data, x + 4, y + 18);
    }
    
    void mouseAction() {
        if (mousePressed && mouseButton == LEFT && ready && action != null && active && mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y + cHeight)
            action.doAction();
    }
    void updateComponents() { }
    void keyAction(char k, int c, int mods) {
        if ((key == ENTER || key == RETURN) && active && focus) action.doAction();
    }
    boolean isFocused() { return focus; }
    void setFocus(boolean f) { focus = f; }
    int size() { return 0; }
    void removeComponent(int a, int b) { }
    void addComponent(UIComponent c, int a, int b) { }
    String toString() { return data; }
    void setActive(boolean a) { active = a; }
    boolean isActive() { return active; }
}
