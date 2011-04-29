/**
* The Page class represents a page in a UIHorizontalFolder or UITabFolder.
*/
class UIPage extends UIComponentContainer {
    
    String title;
    int pindex;
    
    UIPage(String t, int i) {
        super();
        title = t;
        pindex = i;
    }
    
    void update() {
        updateComponents();
        for (int i = 0; i < size(); i++) {
            ((UIComponent)this.get(i)).active = this.active;
            ((UIComponent)this.get(i)).focus = this.focus;
        }
    }
    
    void addComponent(UIComponent c, int page, int index) {
        this.add(index, c);
    }
    
    void removeComponent(int page, int index) {
        this.remove(index);
    }
    
    void updateComponents() {
        for (int i = 0; i < size(); i++) {
            ((UIComponent)this.get(i)).update();
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
}
