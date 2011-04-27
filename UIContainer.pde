class UIContainer extends UIComponent {
    boolean ready = true;
    ArrayList<UIComponent> components;
    
    UIContainer() {
        super(); 
        components = new ArrayList<UIComponent>();
    }
    
    void update() {
        updateComponents();
    }
    
    void updateComponents() {
        for (int i = 0; i < size(); i++) {
            ((UIComponent)this.get(i)).active = active;
            ((UIComponent)this.get(i)).update();
            if (! focus) ((UIComponent)this.get(i)).focus = false;
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
                if (((UIComponent)this.get(k)).focus) {
                    index = k;
                    ((UIComponent)this.get(k)).focus = false;
                    if (k + 1 < size())
                        ((UIComponent)this.get(k+1)).focus = true;
                    //else ((UIComponent)this.get(0)).focus = true;
                    break;
                }
            }
            if (index == -1 && size() > 0) ((UIComponent)this.get(0)).focus = true;
        } else
            for (int k = 0; k < size(); k++) {
                if (((UIComponent)this.get(k)).focus && ((UIComponent)this.get(k)).active)
                    ((UIComponent)this.get(k)).keyAction(c, i, j);
        }
    }
    
    int size() {
        return components.size();
    }
    
    boolean add(UIComponent newComponent) {
        return components.add(newComponent);
    }
    
    UIComponent remove(int index) {
        return components.remove(index);
    }
    
    void add(int index, UIComponent newComponent) {
        components.add(index, newComponent);
    }
    
    UIComponent get(int index) {
        return components.get(index);
    }
}
