/*
* Copyright (c) 2010 The Jackson Laboratory
*
* This software was developed by Matt Hibbs' Lab at The Jackson
* Laboratory (see http://cbfg.jax.org/).
*
* This is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

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
    
    void panStart(int userId) { }
    
    void panEnd(int userId) { }
    
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
