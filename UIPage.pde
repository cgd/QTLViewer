/*
* Copyright (c) 2010 The Jackson Laboratory
*
* This software was developed by Matt Hibbs's Lab at The Jackson
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
