class UIRadioGroup extends UIComponent {
    String[] titles;
    int selected;
    boolean focus, active;
    PFont font = createFont("Arial", 16, true);
    
    UIRadioGroup(float newX, float newY, String[] t) {
        super();
        titles = t;
        selected = 0;
        x = newX;
        y = newY;
    }
    
    void update() {
        textFont(font);
        float offX = -1.0;
        for (String s : titles) if (textWidth(s) > offX) offX = textWidth(s);
        ellipseMode(CORNERS);
        
        for (int i = 0; i < titles.length; i++) {
            fill(0xFF);
            text(titles[i], x, y + (26*i) + 16);
            fill(0x55);
            strokeWeight(2);
            stroke(0x00);
            if (i == selected) fill(0xFF);
            ellipse(x + offX + 8, y + (26*i) + 2, x + offX + 24, y + (26*i) + 18);
            
            if (active && focus && mouseX > x + offX + 8 && mouseX < x + offX + 24 && mouseY > y + (26*i) + 2 && mouseY < y + (26*i) + 18 && mousePressed && mouseButton == LEFT) {
                selected = i;
            }
        }
    }
    
    int size() {
        return titles.length;
    }
}
