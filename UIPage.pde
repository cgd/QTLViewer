class UIPage extends UIComponent {
    
    String title;
    int pindex;
    ArrayList<UIComponent> components;
    
    UIPage(String t, int i) {
        super();
        title = t;
        pindex = i;
        components = new ArrayList<UIComponent>();
    }
    
    boolean isFocused() { return focus; }
    void setFocus(boolean f) { focus = f; }
    
    void update() {
        updateComponents();
        for (int i = 0; i < size(); i++)
            ((UIComponent)this.get(i)).active = this.active;
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
    
    UIComponent get(int index) {
        return components.get(index);
    }
    
    boolean add(UIComponent newComponent) {
        return components.add(newComponent);
    }
    
    void add(int newIndex, UIComponent newComponent) {
        components.add(newIndex, newComponent);
    }
    
    void remove(int index) {
        components.remove(index);
    }
    
    int size() {
        return components.size();
    }
}
