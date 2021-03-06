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

class UITree extends UITreeNode {
    
    boolean ready = true, hasUpdated = false;
    PFont font;
    UIListener removeN, removeE;
    
    UITree(float newX, float newY, float newWidth, float newHeight, UIListener nodeRemove, UIListener elementRemove) {
        super("", true);
        x = newX;
        y = newY;
        cWidth = newWidth;
        cHeight = newHeight;
        font = createFont("Arial", 16, true);
        removeN = nodeRemove;
        removeE = elementRemove;
    }
    
    void update() {
        strokeWeight(1);
        fill(0xCC);
        stroke(0x00);
        rect(x, y, cWidth, cHeight);
        textFont(font);
        float drawy = y + 16;
        
        for (int i = 0; i < size(); i++) {
            if (drawy > y + cHeight) {
                break;
            }
            
            fill(0x33);
            stroke(0x00);
            UITreeNode cnode = (UITreeNode)super.get(i);
            String t = cnode.title;
            
            while (textWidth(t) > cWidth - 48 && t.length() > 0) {
                t = t.substring(0, t.length() - 1);
            }
            
            text(t, x + ((cnode.hasChildren) ? 24 : 0), drawy);
            
            if (mouseX > x + ((cnode.hasChildren) ? 24 : 0) && mouseX < x + ((cnode.hasChildren) ? 24 : 0) + textWidth(t) + 12 && mouseY < drawy && mouseY > drawy - 16 && active) {
                strokeWeight(2);
                line(x + ((cnode.hasChildren) ? 24 : 0) + textWidth(t) + 2, drawy - 11, x + ((cnode.hasChildren) ? 24 : 0) + textWidth(t) + 12, drawy - 1);
                line(x + ((cnode.hasChildren) ? 24 : 0) + textWidth(t) + 2, drawy - 1, x + ((cnode.hasChildren) ? 24 : 0) + textWidth(t) + 12 , drawy - 11);
                strokeWeight(1);
                
                if (ready && mousePressed && mouseButton == LEFT && mouseX > x + ((cnode.hasChildren) ? 24 : 0) + textWidth(t) + 2 && mouseX < x + ((cnode.hasChildren) ? 24 : 0) + textWidth(t) + 12) {
                    ready = false;
                    super.remove(removeN.eventHeard(i--, 0));
                    hasUpdated = true;
                }
            } if (cnode.hasChildren) {
                line(x + 7, drawy - 6, x + 17, drawy - 6);
                
                if (!cnode.expanded) {
                    line(x + 12, drawy - 11, x + 12, drawy - 1);
                }
                
                if (mouseX >= x+7 && mouseX <= x+17 && mouseY >= drawy-11 && mouseY <= drawy-1 && active && ready && mousePressed && mouseButton == LEFT) {
                    get(i).toggleExpanded();
                    ready = false;
                }
                
                if (cnode.expanded) {
                    for (int j = 0; j < cnode.size(); j++) {
                        fill(0x33);
                        drawy += 16;
                        
                        if (drawy > y + cHeight) {
                            break;
                        }
                        
                        UITreeNode bnode = (UITreeNode)cnode.get(j);
                        String _title = bnode.title;
                        
                        while (textWidth(_title) > cWidth - 72 && _title.length() > 0) {
                            _title = _title.substring(0, _title.length() - 1);
                        }
                        
                        text(_title, x + 55, drawy);
                        
                        if (!bnode.hasChildren) {
                            if (bnode.checked) {
                                fill(0x33);
                            } else {
                                noFill();
                            }
                            
                            rect(x + 41, drawy - 11, 10, 10);
                            
                            if (mouseX > x + 12 && mouseX < x + 35 && mouseY > drawy - 11 && mouseY < drawy - 1 && active && ready && mousePressed && mouseButton == LEFT) {
                                Color jc = JColorChooser.showDialog(null, "Choose color", Color.BLACK);
                                
                                if (jc != null) {
                                    bnode.drawcolor = color(jc.getRed(), jc.getGreen(), jc.getBlue(), jc.getAlpha());
                                    hasUpdated = true;
                                }
                                
                                ready = false; 
                            } else if (mouseX > x + 55 && mouseX < x + textWidth(_title) + 67 && mouseY > drawy - 11 && mouseY < drawy - 1 && active) {
                              
                                strokeWeight(2);
                                line(x + textWidth(_title) + 57, drawy - 11, x + textWidth(_title) + 67, drawy - 1);
                                line(x + textWidth(_title) + 57, drawy - 1, x + textWidth(_title) + 67, drawy - 11);
                                strokeWeight(1);
                                
                                if (ready && mousePressed && mouseButton == LEFT && mouseX > x + textWidth(_title) + 57 && mouseX < x + textWidth(_title) + 67) {
                                    get(i).remove(removeE.eventHeard(i, j--));
                                    hasUpdated = true;
                                    ready = false;
                                }
                            } else if (mouseX > x + 31 && mouseX < x + 49 && mouseY > drawy - 11 && mouseY < drawy - 1 && active && ready && mousePressed && mouseButton == LEFT) {
                                cnode.get(j).toggleChecked();
                                hasUpdated = true;
                                ready = false;
                            } 
                            
                            fill(bnode.drawcolor);
                            rect(x + 12, drawy - 11, 23, 10);
                        }
                    } 
                }
                
                drawy += 16;
            }
        }
        
        if (mouseX > x && mouseX < x + cWidth && mouseY > y && mouseY < y + cHeight) {
            if (!mousePressed || mouseButton != LEFT && active) {
                ready = true;
            }
        } else {
            ready = !(mousePressed && mouseButton == LEFT && active);
        }
    }
    
    boolean hasUpdated() {
        if (hasUpdated) {
            hasUpdated = false;
            return true;
        } else {
            return false;
        }
    }
}
