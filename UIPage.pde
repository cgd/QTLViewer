class p_page extends ArrayList<UIComponent> implements UIComponent {
    
    boolean focus = false, active = false;
    String title;
    int pindex;
    
    p_page(String t, int i) {
        super();
        title = t;
        pindex = i;
    }
    
    boolean isFocused() { return focus; }
    void setFocus(boolean f) { focus = f; }
    
    void update() {
        updateComponents();
        for (int i = 0; i < size(); i++)
            ((UIComponent)this.get(i)).setActive(this.active);
    }
    
    void addComponent(UIComponent c, int page, int index) {
        this.add(index, c);
    }
    
    void removeComponent(int page, int index) {
        this.remove(index);
    }
    
    void updateComponents() {
        for (int i = 0; i < size(); i++) {
            //pushMatrix();
            //translate(width * pindex, 0, 0);
            ((UIComponent)this.get(i)).update();
            //popMatrix();
        }
    }
    
    void mouseAction() {
        for (int i = 0; i < this.size(); i++)
            ((UIComponent)this.get(i)).mouseAction();
    }
    
    void keyAction(char k, int c, int mods) {
        for (int i = 0; i < this.size(); i++)
            ((UIComponent)this.get(i)).keyAction(k, c, mods);
    }
    
    void setX(double newx) { }
    void setY(double newy) { }
    double getX() { return 0.0; }
    double getY() { return 0.0; }
    String toString() { return title; }
    void setActive(boolean a) { active = a; }
    boolean isActive() { return active; }
}
