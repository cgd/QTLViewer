abstract class UIComponent {
    boolean active = true, focus = true;
    float x = 0.0, y = 0.0, cWidth = 0.0, cHeight = 0.0;
    
    UIComponent(float newX, float newY, float newWidth, float newHeight) {
      x = newX;
      y = newY;
      cWidth = newWidth;
      cHeight = newHeight;
    }
    
    UIComponent() { }
    
    void mouseAction() { }
    
    void update() { } // override this
    
    void updateComponents() { }
    
    void keyAction(char k, int code, int mods) { }
    
    void addComponent(UIComponent c, int index, int index2) { }
    
    void removeComponent(int index1, int index2) { }
    
    abstract int size();
    
    String toString() { return ""; }
    
    void pan(PVector vec) { }
    
    void zoom(PVector vec) { }
}

abstract class UIComponentContainer extends UIComponent {
    ArrayList<UIComponent> components;
     
    UIComponentContainer() {
        components = new ArrayList<UIComponent>();
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

interface UIAction {
    public void doAction();
}

interface UIListener {
    public int eventHeard(int i, int j);
}
