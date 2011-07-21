class UIKSpinner extends UIComponent {
    float value, size;
    PFont main;
    Object key;
    String title;
    color textColor = color(0xFF);
    UIButton up, down;
    
    UIKSpinner(float newX, float newY, float newSize, float newValue, String newT) {
        x = newX;
        y = newY;
        main = createFont("Arial", size = newSize, true);
        value = newValue;
        title = newT;
        
        up = new UIButton(0, y + size + 16, "+", size + 16, size + 16, size, new UIAction() {
            public void doAction() {
                inc();
            }
        });
        
        down = new UIButton(0, y + size + 16, "-", size + 16, size + 16, size, new UIAction() {
            public void doAction() {
                dec();
            }
        });
    }
    
    void update() {
        fill(textColor);
        textFont(main);
        
        text(title, x, y + size);
        text(str(value), x + ((textWidth(title) - textWidth(str(value))) / 2.0), y + (2 * size) + 16);
        
        up.x = x + ((textWidth(title) - textWidth(str(value))) / 2.0) - size - 32;
        down.x = x + ((textWidth(title) + textWidth(str(value))) / 2.0) + 16;
        
        up.update();
        down.update();
    }
    
    void setKey(Object o) {
        key = o;
        up.setKey(o);
        down.setKey(o);
    }
    
    void mouseAction() {
        up.mouseAction();
        down.mouseAction();
    }
    
    void inc() {
        value += 0.1;
    }
    
    void dec() {
        value -= 0.1;
    }
    
    float getWidth() {
        textFont(main);
        return textWidth(title);
    }
    
    int size() { return 0; }
}
