class p_container extends ArrayList<p_component> implements p_component {
    boolean ready = true, focus = false, active = true;
    
    p_container() {
     super(); 
    }
    
    void update() {
        updateComponents();
    }
    
    void updateComponents() {
        for (int i = 0; i < size(); i++) {
            ((p_component)this.get(i)).setActive(active);
            ((p_component)this.get(i)).update();
            if (! focus) ((p_component)this.get(i)).setFocus(false);
        }
    }
    
    void addComponent(p_component c, int page, int index) {
        this.add(index, c);
    }
    
    void removeComponent(int page, int index) {
        this.remove(index);
    }
    
    void mouseAction() {
        if (active && focus)
            for (int i = 0; i < size(); i++)
                ((p_component)this.get(i)).mouseAction();
    }
    
    void keyAction(char c, int i, int j) {
        if (focus && active && (c == TAB || c == ENTER || c == RETURN)) {
            int index = -1;
            for (int k = 0; k < size(); k++) {
                if (((p_component)this.get(k)).isFocused()) {
                    index = k;
                    ((p_component)this.get(k)).setFocus(false);
                    if (k + 1 < size())
                        ((p_component)this.get(k+1)).setFocus(true);
                    //else ((p_component)this.get(0)).setFocus(true);
                    break;
                }
            }
            if (index == -1 && size() > 0) ((p_component)this.get(0)).setFocus(true);
        } else
            for (int k = 0; k < size(); k++) {
                if (((p_component)this.get(k)).isFocused() && ((p_component)this.get(k)).isActive())
                    ((p_component)this.get(k)).keyAction(c, i, j);
        }
    }
    
    boolean isFocused() { return focus; }
    void setFocus(boolean f) { focus = f; }
    void setX(double newx) { }
    void setY(double newy) { }
    double getX() { return 0.0; }
    double getY() { return 0.0; }
    String toString() { return ""; }
    void setActive(boolean a) { active = a; }
    boolean isActive() { return active; }
}
