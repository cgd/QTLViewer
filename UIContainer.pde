class UIContainer extends ArrayList<UIComponent> implements UIComponent {
    boolean ready = true, focus = false, active = true;
    
    UIContainer() {
     super(); 
    }
    
    void update() {
        updateComponents();
    }
    
    void updateComponents() {
        for (int i = 0; i < size(); i++) {
            ((UIComponent)this.get(i)).setActive(active);
            ((UIComponent)this.get(i)).update();
            if (! focus) ((UIComponent)this.get(i)).setFocus(false);
        }
    }
    
    void addComponent(UIComponent c, int page, int index) {
        this.add(index, c);
    }
    
    void removeComponent(int page, int index) {
        this.remove(index);
    }
    
    void mouseAction() {
        if (active && focus)
            for (int i = 0; i < size(); i++)
                ((UIComponent)this.get(i)).mouseAction();
    }
    
    void keyAction(char c, int i, int j) {
        if (focus && active && (c == TAB || c == ENTER || c == RETURN)) {
            int index = -1;
            for (int k = 0; k < size(); k++) {
                if (((UIComponent)this.get(k)).isFocused()) {
                    index = k;
                    ((UIComponent)this.get(k)).setFocus(false);
                    if (k + 1 < size())
                        ((UIComponent)this.get(k+1)).setFocus(true);
                    //else ((UIComponent)this.get(0)).setFocus(true);
                    break;
                }
            }
            if (index == -1 && size() > 0) ((UIComponent)this.get(0)).setFocus(true);
        } else
            for (int k = 0; k < size(); k++) {
                if (((UIComponent)this.get(k)).isFocused() && ((UIComponent)this.get(k)).isActive())
                    ((UIComponent)this.get(k)).keyAction(c, i, j);
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
