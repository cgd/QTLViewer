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

class UITabFolder extends UIComponent {
    
    float xLowerMargin, yLowerMargin;
    PFont sfont;
    boolean ready = true;
    int currentpage = 0;
    ArrayList<UIPage> pages;
    
    UITabFolder(float newX, float newY, float newxLowerMargin, float newyLowerMargin, String[] titles) {
        x = newX;
        y = newY;
        xLowerMargin = newxLowerMargin;
        yLowerMargin = newyLowerMargin;
        cWidth = drawWidth - xLowerMargin - x;
        cHeight = drawHeight - yLowerMargin - y;
        sfont = createFont("Arial", (ENABLE_KINECT) ? 24 : 16, true);
        pages = new ArrayList<UIPage>();
        
        for (int i = 0; i < titles.length; i++) {
            this.add(new UIPage(titles[i], i));
        }
    }
    
    void addComponent(UIComponent c, int page, int index) {
        this.get(page).addComponent(c, page, index);
    }
    
    void removeComponent(int page, int index) {
        this.get(page).removeComponent(page, index);
    }
    
    void update() {
        stroke(0x00);
        fill(0xFF);
        float xOff = 0.0;
        textFont(sfont);
        
        if (!mousePressed) {
            ready = true;
        } else if (!(mouseY < y && mouseY > y - ((ENABLE_KINECT) ? 40 : 20) && mouseX > x && mouseX < drawWidth - xLowerMargin)) {
            ready = false;
        }
        
        for (int j = 0; j < size(); j++) {
            color c_text = 0xCC, c_tab = 0x55;
            
            if (ready && focus && active && mouseX > xOff + x && mouseX < xOff + x + textWidth(get(j).title) + 40.0 && mouseY < y && mouseY > y - ((ENABLE_KINECT) ? 40 : 20)) {
                if (mousePressed && mouseButton == LEFT) {
                    currentpage = j;
                } else {
                    c_text = 0xDD;
                    c_tab = 0x44;
                }
            }
            
            this.get(j).focus = (this.focus && j == currentpage);
            this.get(j).active = (this.active && j == currentpage);
            
            if (currentpage == j) {
                c_tab = 0xFF;
            }
            
            float tabHeight = (ENABLE_KINECT) ? 30.0 : 20.0;
            
            fill(c_tab);
            beginShape();
            vertex(xOff + x, y);
            
            for (int i = 0; i < 20; i += 2) {
                vertex(xOff + i + x, y + (-sin((i * HALF_PI) / 20.0) * tabHeight));
            }
            
            for (int i = 20; i >= 0; i -= 2) {
                vertex(xOff + 40.0 + x + textWidth(get(j).title) - i, y + (-sin((abs(i) * HALF_PI) / 20.0) * tabHeight));
            }
            
            if (currentpage == j) {
                vertex(drawWidth - xLowerMargin, y);
                vertex(drawWidth - xLowerMargin, drawHeight - yLowerMargin);
                vertex(x, drawHeight - yLowerMargin);
                vertex(x, y);
            }
            
            endShape();
            
            if (currentpage == j) {
                c_text = 0x00;
            }
            
            fill(c_text);
            
            text(get(j).title, xOff + 20.0 + x, y - 4.0);
            xOff += 40.0 + textWidth(get(j).title);
        }
        
        cWidth = drawWidth - xLowerMargin - x;
        cHeight = drawHeight - yLowerMargin - y;
        
        get(currentpage).update();
    }
    
    void mouseAction() {
        for (int i = 0; i < get(currentpage).size(); i++) {
            this.get(currentpage).get(i).mouseAction();
        }
    }
    
    void keyAction(char k, int c, int mods) {
        for (int i = 0; i < get(currentpage).size(); i++) {
            this.get(currentpage).get(i).keyAction(k, c, mods);
        }
    }
    
    void add(UIPage component) {
        pages.add(component);
    }
    
    UIPage get(int index) {
        return pages.get(index);
    }
    
    int size() {
        return pages.size();
    }
    
    void nextPage() {
        if (currentpage == (size() - 1)) {
            return;
        }
        
        currentpage++;
    }
    
    void prevPage() {
        if (currentpage == 0) {
            return;
        }
        
        currentpage--;
    }
}
