class p_radiogroup implements p_component {
    String[] titles;
    int selected;
    float x, y;
    boolean focus, active;
    PFont font = createFont("Arial", 16, true);
    
    p_radiogroup(float ex, float why, String[] t) {
        titles = t;
        selected = 0;
        x = ex; y = why;
    }
    
    void update() {
        textFont(font);
        float offX = -1.0;
        for (String s : titles) if (textWidth(s) > offX) offX = textWidth(s);
        ellipseMode(CORNERS);
        for (int i = 0; i < titles.length; i++) {
            fill(0xFF);
            text(titles[i], x, y+(26*i)+16);
            fill(0x55);
            strokeWeight(2);
            stroke(0x00);
            if (i == selected) fill(0xFF);
            ellipse(x+offX+8, y+(26*i)+2, x+offX+24, y+(26*i)+18);
            if (active && focus && mouseX > x+offX+8 && mouseX < x+offX+24 && mouseY > y+(26*i)+2 && mouseY < y+(26*i)+18 && mousePressed && mouseButton == LEFT) selected = i;
        }
    }
    
    void keyAction(char c, int i, int j) { }
    void mouseAction() { }
    void updateComponents() { }
    boolean isFocused() { return focus; }
    void setFocus(boolean b) { focus = b; }
    void setX(double newx) { }
    void setY(double newy) { y = (float)newy; }
    double getX() { return 0.0; }
    double getY() { return 0.0; }
    String toString() { return ""; }
    void setActive(boolean a) { active = a; }
    boolean isActive() { return active; }
    int size() { return titles.length; }
    void removeComponent(int i, int j) { }
    void addComponent(p_component p, int i, int j) { }
}
