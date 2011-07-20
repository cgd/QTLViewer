class UIRadioGroup extends UIComponent {
    String[] titles;
    int selected;
    boolean focus, active;
    PFont font = createFont("Arial", 16, true);
    float size = 16.0, spacing;
    
    UIRadioGroup(float newX, float newY, String[] t) {
        super();
        titles = t;
        selected = 0;
        x = newX;
        y = newY;
    }
    
    UIRadioGroup(float newX, float newY, float newSize, float newSpacing, String[] t) {
        size = newSize;
        x = newX;
        y = newY;
        titles = t;
        spacing = newSpacing;
        
        font = createFont("Arial", newSize, true);
    }
    
    void update() {
        textFont(font);
        float offX = -1.0;
        
        for (String s : titles) {
            if (textWidth(s) > offX) {
                offX = textWidth(s);
            }
        }
        
        ellipseMode(CORNERS);
        
        for (int i = 0; i < titles.length; i++) {
            fill(0xFF);
            text(titles[i], x, y + ((10 + size + spacing) * i) + size);
            
            fill(0x55);
            strokeWeight(2);
            stroke(0x00);
            
            if (i == selected) {
                fill(0xFF);
            }
            
            ellipse(x + offX + 8, y + ((10 + size + spacing) * i) + 2, x + offX + 8 + size, y + ((10 + size + spacing) * i) + 2 + size);
            
            if (active && focus && mouseX > x + offX + 8 && mouseX < x + offX + 8 + size && mouseY > y + ((10 + size + spacing) * i) + 2 && mouseY < y + ((10 + size + spacing) * i) + 2 + size && mousePressed && mouseButton == LEFT) {
                selected = i;
            }
        }
    }
    
    int size() {
        return titles.length;
    }
}
