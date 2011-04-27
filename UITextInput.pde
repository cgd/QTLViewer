class UITextInput extends UIComponent {
    float dx;
    String data, label;
    PFont font = createFont("Arial", 16, true);
    boolean ready = true, focus = false, active = true;

    UITextInput(float newX, float newY, float desiredX, float newWidth, String el) {
        label = el;
        x = newX;
        y = newY;
        cWidth = newWidth;
        data = "";
        dx = desiredX;
    }
    
    UITextInput(float newX, float newY, float newWidth, String el) {
        label = el;
        x = newX;
        y = newY;
        cWidth = newWidth;
        data = "";
        dx = -1.0;
    }
    
    void update() {
        textFont(font);
        fill(0xFF);
        text(label, x, y + 16);
        if (!active) focus = false;
        if (focus) stroke(0xFF);
        else stroke(0x00);
        fill(0x55);
        while (textWidth(data) > cWidth - 6 && data.length() > 0)
            data = data.substring(0, data.length() - 1);
        if (dx == -1) {
            rect(x + 2 + textWidth(label), y, cWidth, 20);
            fill(0xFF);
            if (focus) text(data + "|", x + 6 + textWidth(label), y + 16);
            else text(data, x+6+textWidth(label), y + 16);
            /*if (active && mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y+20)
                cursor(TEXT);
            else cursor(ARROW);*/
        } else {
            rect(dx, y, cWidth, 20);
            fill(0xFF);
            if (focus) text(data+"|", dx + 4, y + 16);
            else text(data, dx + 4, y + 16);
            /*if (active && mouseX > dx && mouseX < dx + cWidth && mouseY > y && mouseY < y+20)
                cursor(TEXT);
            else cursor(ARROW);*/
        }
    }
    
    void mouseAction() {
        if (mousePressed && mouseButton == LEFT) {
            if (active && dx == -1 && mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y+20)
                focus = true;
            else if (active && mouseX > dx && mouseX < dx + cWidth && mouseY > y && mouseY < y+20)
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
    int size() { return 0; }
}
