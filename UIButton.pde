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

class UIButton extends UIComponent {
    String data;
    float fsize;
    PFont font = createFont("Arial", fsize = 16, true);
    color bg = color(0xCC), border = color(0xFF), mouse = color(0x99), textc = color(0x33);
    boolean ready = true, custom = false;
    UIAction action = null;
    Object key = null;
    UIButton(float newX, float newY, String newData, UIAction newAction) {
        super();
        x = newX; 
        y = newY; 
        cWidth = textWidth(newData); 
        cHeight = 25;
        data = newData;
        action = newAction;
    }
    
    UIButton(float newX, float newY, String newData, float newW, float newH, float fontSize, UIAction newAction) {
        super();
        x = newX;
        y = newY;
        cWidth = newW;
        cHeight = newH;
        data = newData;
        action = newAction;
        font = createFont("Arial", fsize = fontSize, true);
        custom = true;
    }

    void update() {
        textFont(font);
        
        if (!custom) {
            cWidth = textWidth(data) + 8;
        }
        
        fill(bg);
        stroke(border);
        
        if (((mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y + cHeight) || mouseInRect((key == null) ? this : key, x, y, x + cWidth, y + cHeight)) && active) {
            if (!mousePressed || mouseButton != LEFT && active) {
                ready = true;
            }
            
            stroke(mouse);
        } else {
            ready = !(mousePressed && mouseButton == LEFT && active);
        }
        
        strokeWeight(1);
        rect(x, y, cWidth, cHeight);
        fill(textc);
        text(data, x + ((cWidth - textWidth(data)) / 2.0), y + ((cHeight - fsize) / 2.0) + fsize - 4);
    }
    
    void setKey(Object o) {
        key = o;
    }
    
    void mouseAction() {
        if (mousePressed && mouseButton == LEFT && ready && action != null && active && mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y + cHeight) {
            action.doAction();
        }
    }
    
    void keyAction(char k, int c, int mods) {
        if ((k == ENTER || k == RETURN) && active && focus) {
            action.doAction();
        }
    }

    int size() { return 0; }
}
