class UIListbox extends ArrayList<String> implements UIComponent {
    
    double x, y, w, h;
    String data;
    PFont font;
    boolean focus = false, active = true, ready = true;
    ArrayList<Boolean> selected;
    int keyc = 0, firsti = -1, lasti = -1;
    
    UIListbox(double ex, double why, double doubleu, double ach, String title) {
        super();
        selected = new ArrayList<Boolean>();
        data = title; x = ex; y = why; w = doubleu; h = ach;
        font = createFont("Arial", 16, true);
    }
    
    void update() {
        strokeWeight(1);
        fill(0xCC);
        stroke(0x00);
        rect((float)x, (float)y, (float)w, (float)h);
        textFont(font);
        for (int i = 0; i < size(); i++) {
            String d = (String)get(i);
            while (textWidth(d) > w-4)
                d = d.substring(0, d.length()-2);
            fill(0x00);
            noStroke();
            if (mouseX > x && mouseX < x+w && mouseY > (i*16)+y+2 && mouseY < (i+1)*16+y+2 && active && mousePressed && mouseButton == LEFT && ready) {
                    if (keyPressed && keyc == 157) {
                        selected.set(i, Boolean.valueOf(!((Boolean)selected.get(i)).booleanValue()));
                        if (firsti == -1) firsti = lasti = i;
                    } else if (keyPressed && keyc == SHIFT && firsti != -1 && i != lasti && firsti != i) {
                        lasti = i;
                        for (int j = 0; j < selected.size(); j++)
                            selected.set(j, Boolean.valueOf(inRange(firsti, i, j)));
                    } else if (keyPressed && keyc == SHIFT && (i == lasti || i == firsti)) {
                        for (int j = 0; j < selected.size(); j++)
                            selected.set(j, Boolean.valueOf(j == (firsti = lasti = i)));
                    } else for (int j = 0; j < selected.size(); j++)
                        selected.set(j, Boolean.valueOf(j == (firsti = lasti = i)));
                    ready = false;
            } if (((Boolean)selected.get(i)).booleanValue()) {
                fill(0x33);
                rect((float)x, (i*16)+(float)y+2, (float)w, 16);
                fill(0xDD);
            }
            text(d, (float)x+2, ((i+1)*16)+(float)y);
            boolean alloff = false;
            for (int j = 0; j < selected.size(); j++)
                if (!(alloff = !((Boolean)selected.get(j)).booleanValue())) break;
            if (alloff) firsti = -1;
        }
        if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
            if (!mousePressed || mouseButton != LEFT && active) ready = true;
        } else ready = !(mousePressed && mouseButton == LEFT && active);
    }
    
    void mouseAction() {
        
    }
    
    void keyAction(char k, int c, int mods) {
        keyc = c; // command = 157
    }
    
    void add(int i, String o) {
        selected.add(i, Boolean.valueOf(false));
        super.add(i, o);
    }
    
    boolean add(String o) {
        selected.add(Boolean.valueOf(false));
        return(super.add(o));
    }
    
    String remove(int i) {
        selected.remove(i);
        return super.remove(i);
    }
    
    void up() {
        int sindex = -1;
        for (int i = 0; i < selected.size(); i++) {
            if ((Boolean)selected.get(i)    && sindex == -1)
                sindex = i;
            else if (i != sindex)
                selected.set(i, Boolean.FALSE);
        }
        if (sindex == -1 || sindex == 0) return;
        this.add(sindex - 1, this.remove(sindex));
        selected.add(sindex - 1, true);
    }
    
    void down() {
        int sindex = -1;
        for (int i = 0; i < selected.size(); i++) {
            if ((Boolean)selected.get(i) && sindex == -1)
                sindex = i;
            else if (i != sindex)
                selected.set(i, Boolean.FALSE);
        }
        if (sindex == -1 || sindex == this.size() - 1) return;
        this.add(sindex + 1, this.remove(sindex));
        selected.add(sindex + 1, true);
    }
    
    void updateComponents() { }
    boolean isFocused() { return focus; }
    void setFocus(boolean f) { focus = f; }
    void removeComponent(int a, int b) { }
    void addComponent(UIComponent c, int a, int b) { }
    String toString() { return data; }
    void setActive(boolean a) { active = a; }
    boolean isActive() { return active; }
    double getX() { return x; }
    double getY() { return y; }
    void setX(double newx) { x = newx; }
    void setY(double newy) { y = newy; }
    boolean inRange(int one, int two, int val) {
        if (one > two) return (val >= two && val <= one);
        else if (two > one) return (val <= two && val >= one);
        return false;
    }
}
