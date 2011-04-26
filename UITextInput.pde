class UITextInput implements UIComponent {
    double w, x, y, dx;
    String data, label;
    PFont font = createFont("Arial", 16, true);
    boolean ready = true, focus = false, active = true;

    UITextInput(double ex, double why, double desiredX, double doubleu, String el) {
        label = el;
        x = ex;
        y = why;
        w = doubleu;
        data = "";
        dx = desiredX;
    }
    
    UITextInput(double ex, double why, double doubleu, String el) {
        label = el;
        x = ex;
        y = why;
        w = doubleu;
        data = "";
        dx = -1.0;
    }
    
    void update() {
        textFont(font);
        fill(0xFF);
        text(label, (float)x, (float)y+16);
        if (!active) focus = false;
        if (focus) stroke(0xFF);
        else stroke(0x00);
        fill(0x55);
        while (textWidth(data) > w-6 && data.length() > 0)
            data = data.substring(0, data.length()-1);
        if (dx == -1) {
            rect((float)x+2+textWidth(label), (float)y, (float)w, 20);
            fill(0xFF);
            if (focus) text(data+"|", (float)x+6+textWidth(label), (float)y+16);
            else text(data, (float)x+6+textWidth(label), (float)y+16);
            /*if (active && mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+20)
                cursor(TEXT);
            else cursor(ARROW);*/
        } else {
            rect((float)dx, (float)y, (float)w, 20);
            fill(0xFF);
            if (focus) text(data+"|", (float)dx+4, (float)y+16);
            else text(data, (float)dx+4, (float)y+16);
            /*if (active && mouseX > dx && mouseX < dx+w && mouseY > y && mouseY < y+20)
                cursor(TEXT);
            else cursor(ARROW);*/
        }
    }
    
    void mouseAction() {
        if (mousePressed && mouseButton == LEFT) {
            if (active && dx == -1 && mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+20)
                focus = true;
            else if (active && mouseX > dx && mouseX < dx+w && mouseY > y && mouseY < y+20)
                focus = true;
            else focus = false;
        }
    }
    
    void keyAction(char c, int i, int j) {
        if (active && focus && c != CODED) {
            if (key == BACKSPACE && data.length() > 0)
                data = data.substring(0, data.length()-1);
            else if (key != ESC && key != DELETE && key != RETURN && key != ENTER)
                data += c;
        }
    }
    
    void setText(String s) { data = s; }
    String getText() { return data; }
    double getX() { return x; }
    double getY() { return y; }
    void setX(double newx) { x = newx; }
    void setY(double newy) { y = newy; }
    boolean isFocused() { return focus; }
    void setFocus(boolean f) { focus = f; }
    int size() { return 0; }
    void removeComponent(int a, int b) { }
    void addComponent(UIComponent c, int a, int b) { }
    String toString() { return data; }
    void setActive(boolean a) { active = a; }
    boolean isActive() { return active; }
    void updateComponents() { }
}
