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

class UITextInput extends UIComponent {
    float dx;
    String data, label;
    PFont font = createFont("Arial", 16, true);
    boolean ready = true;

    UITextInput(float newX, float newY, float desiredX, float newWidth, String el) {
        label = el;
        x = newX;
        y = newY;
        cWidth = newWidth;
        data = "";
        dx = desiredX;
    }
    
    UITextInput(float newX, float newY, float newWidth, String el) {
        label = el;
        x = newX;
        y = newY;
        cWidth = newWidth;
        data = "";
        dx = -1.0;
    }
    
    void update() {
        textFont(font);
        fill(0xFF);
        text(label, x, y + 16);
        
        if (!active) {
            focus = false;
        }
        
        if (focus) {
            stroke(0xFF);
        } else {
            stroke(0x00);
        }
        
        fill(0x55);
        
        while (textWidth(data) > cWidth - 6 && data.length() > 0) {
            data = data.substring(0, data.length() - 1);
        }
        
        if (dx == -1) {
            rect(x + 2 + textWidth(label), y, cWidth, 20);
            fill(0xFF);
            
            if (focus) {
                text(data + "|", x + 6 + textWidth(label), y + 16);
            } else {
                text(data, x+6+textWidth(label), y + 16);
            }
        } else {
            rect(dx, y, cWidth, 20);
            fill(0xFF);
            
            if (focus) {
                text(data+"|", dx + 4, y + 16);
            } else {
                text(data, dx + 4, y + 16);
            }
        }
    }
    
    void mouseAction() {
        if (mousePressed && mouseButton == LEFT) {
            if (active && dx == -1 && mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y+20) {
                focus = true;
            } else if (active && mouseX > dx && mouseX < dx + cWidth && mouseY > y && mouseY < y+20) {
                focus = true;
            } else {
                focus = false;
            }
        }
    }
    
    void keyAction(char c, int i, int j) {
        if (active && focus && c != CODED) {
            if (c == BACKSPACE && data.length() > 0) {
                data = data.substring(0, data.length()-1);
            } else if (c != ESC && c != DELETE && c != RETURN && c != ENTER) {
                data += c;
            }
        }
    }
    
    void setText(String s) {
        data = s;
    }
    
    String getText() {
        return data;
    }
    
    int size() { return 0; }
}
