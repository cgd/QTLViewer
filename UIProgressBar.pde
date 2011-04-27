class UIProgressBar extends UIComponent {
    float v;
    int type;
    
    UIProgressBar(float newX, float newY, float newWidth, float newHeight) {
        super(newX, newY, newWidth, newHeight);
        type = 0;
        v = 0.0;
    }
    
    void update() {
        strokeWeight(1);
        noFill();
        stroke(0x00);
        rect(x, y, cWidth, cHeight);
        fill(0x55);
        noStroke();
        if (type == 1) { // vertical
            float ph = map((float)v, 0, 1.0, 0, cHeight);
            rect(x, y + cHeight - ph, cWidth, ph);
        } else { // horizontal
            
        }
    }
    
    void setHorizontal() { type = 0; }
    void setVertical() { type = 1; }
    void setValue(float newval) { v = newval; update(); }
    int size() { return 0; }
}
