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
}

interface UIAction {
    public void doAction();
}

interface UIListener {
    public int eventHeard(int i, int j);
}
