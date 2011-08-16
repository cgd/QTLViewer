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

class UIRadioGroup extends UIComponent {
    String[] titles;
    int selected;
    boolean focus = true, active = true;
    PFont font = createFont("Arial", 16, true);
    float size = 16.0, spacing;
    color textColor = 0xFF;
    
    UIRadioGroup(float newX, float newY, String[] t) {
        super();
        titles = t;
        selected = 0;
        x = newX;
        y = newY;
    }
    
    UIRadioGroup(float newX, float newY, float newSize, float newSpacing, String[] t) {
        size = newSize;
        x = newX;
        y = newY;
        titles = t;
        spacing = newSpacing;
        
        font = createFont("Arial", newSize, true);
    }
    
    void update() {
        textFont(font);
        float offX = -1.0;
        
        for (String s : titles) {
            if (textWidth(s) > offX) {
                offX = textWidth(s);
            }
        }
        
        ellipseMode(CORNERS);
        
        for (int i = 0; i < titles.length; i++) {
            fill(textColor);
            text(titles[i], x, y + ((10 + size + spacing) * i) + size);
            
            fill(0x33);
            strokeWeight(2);
            stroke(0x00);
            
            if (i == selected) {
                fill(0xAA);
            }
            
            ellipse(x + offX + 8, y + ((10 + size + spacing) * i) + 2, x + offX + 8 + size, y + ((10 + size + spacing) * i) + 2 + size);
            
            if (active && focus && mouseX > x + offX + 8 && mouseX < x + offX + 8 + size && mouseY > y + ((10 + size + spacing) * i) + 2 && mouseY < y + ((10 + size + spacing) * i) + 2 + size && mousePressed && mouseButton == LEFT) {
                selected = i;
            }
        }
    }
    
    int size() {
        return titles.length;
    }
}
