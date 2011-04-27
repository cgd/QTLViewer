class UIListbox extends UIComponent  {
    String data;
    PFont font;
    boolean ready = true;
    ArrayList<String> keys;
    ArrayList<Boolean> values;
    int keyc = 0, firsti = -1, lasti = -1;
    
    UIListbox(float newX, float newY, float newWidth, float newHeight, String title) {
        super(newX, newY, newWidth, newHeight);
        data = title;
        font = createFont("Arial", 16, true);
        keys = new ArrayList<String>();
        values = new ArrayList<Boolean>();
    }
    
    String get(int index) {
        return keys.get(index);
    }
    
    int size() {
        return keys.size();
    }
    
    void update() {
        strokeWeight(1);
        fill(0xCC);
        stroke(0x00);
        rect(x, y, cWidth, cHeight);
        textFont(font);
        for (int i = 0; i < size(); i++) {
            String d = get(i);
            while (textWidth(d) > cWidth - 4)
                d = d.substring(0, d.length() - 2);
            fill(0x00);
            noStroke();
            if (mouseX > x && mouseX < x + cWidth && mouseY > (i*16)+y+2 && mouseY < (i+1)*16+y+2 && active && mousePressed && mouseButton == LEFT && ready) {
                    if (keyPressed && keyc == 157) {
                        values.set(i, Boolean.valueOf(!values.get(i).booleanValue()));
                        if (firsti == -1) firsti = lasti = i;
                    } else if (keyPressed && keyc == SHIFT && firsti != -1 && i != lasti && firsti != i) {
                        lasti = i;
                        for (int j = 0; j < size(); j++) {
                            values.set(j, Boolean.valueOf(inRange(firsti, i, j)));
                        }
                    } else if (keyPressed && keyc == SHIFT && (i == lasti || i == firsti)) {
                        for (int j = 0; j < size(); j++) {
                            values.set(j, Boolean.valueOf(j == (firsti = lasti = i)));
                        }
                    } else {
                        for (int j = 0; j < size(); j++) {
                            values.set(j, Boolean.valueOf(j == (firsti = lasti = i)));
                        }
                    }
                    ready = false;
            } if (values.get(i).booleanValue()) {
                fill(0x33);
                rect(x, (i*16) + y + 2, cWidth, 16);
                fill(0xDD);
            }
            text(d, x + 2, ((i + 1)*16) + y);
            boolean alloff = false;
            for (int j = 0; j < size(); j++) {
                if (!(alloff = !values.get(j).booleanValue())) break;
            }
            if (alloff) firsti = -1;
        }
        if (mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y + cHeight) {
            if (!mousePressed || mouseButton != LEFT && active) ready = true;
        } else ready = !(mousePressed && mouseButton == LEFT && active);
    }
    
    void keyAction(char k, int c, int mods) {
        keyc = c; // command = 157
    }
    
    void add(int i, String o) {
        values.add(i, Boolean.valueOf(false));
        keys.add(i, o);
    }
    
    boolean add(String o) {
        values.add(Boolean.valueOf(false));
        return(keys.add(o));
    }
    
    String remove(int i) {
        values.remove(i);
        return keys.remove(i);
    }
    
    void up() {
        int sindex = -1;
        for (int i = 0; i < size(); i++) {
            if (values.get(i) && sindex == -1)
                sindex = i;
            else if (i != sindex)
                values.set(i, Boolean.FALSE);
        }
        if (sindex == -1 || sindex == 0) return;
        keys.add(sindex - 1, keys.remove(sindex));
        values.add(sindex - 1, true);
    }
    
    void down() {
        int sindex = -1;
        for (int i = 0; i < size(); i++) {
            if (values.get(i) && sindex == -1)
                sindex = i;
            else if (i != sindex)
                values.set(i, Boolean.FALSE);
        }
        if (sindex == -1 || sindex == this.size() - 1) return;
        keys.add(sindex + 1, keys.remove(sindex));
        values.add(sindex + 1, true);
    }
    
    boolean inRange(int one, int two, int val) {
        if (one > two) return (val >= two && val <= one);
        else if (two > one) return (val <= two && val >= one);
        return false;
    }
}
