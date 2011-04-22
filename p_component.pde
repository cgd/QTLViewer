interface p_component {
    
    void mouseAction();
    
    void update(); // override this
    
    void updateComponents();
    
    void keyAction(char k, int code, int mods);
    
    void setFocus(boolean focus);
    
    boolean isFocused();
    
    void setActive(boolean active);
    
    boolean isActive();
    
    void addComponent(p_component c, int index, int index2);
    
    void removeComponent(int index1, int index2);
    
    int size();
    
    double getX();
    
    double getY();
    
    void setX(double newx);
    
    void setY(double newy);
    
    String toString();
}
