class UITree extends UITreeNode implements UIComponent {
    
    double x, y, w, h;
    boolean focus = false, active = true, ready = true, hasUpdated = false;
    PFont font;
    UIListener removeN, removeE;
    UITree(double ex, double why, double doubleu, double ach, UIListener n, UIListener e) {
        super("", true);
        x = ex; y = why; w = doubleu; h = ach;
        font = createFont("Arial", 16, true);
        removeN = n;
        removeE = e;
    }
    
    void update() {
        strokeWeight(1);
        fill(0xCC);
        stroke(0x00);
        rect((float)x, (float)y, (float)w, (float)h);
        textFont(font);
        double drawy = y + 16;
        for (int i = 0; i < super.size(); i++) {
            if (drawy > h+y) break;
            fill(0x33);
            stroke(0x00);
            UITreeNode cnode = (UITreeNode)super.get(i);
            String t = cnode.title;
            while (textWidth(t) > w - 48 && t.length() > 0)
                t = t.substring(0, t.length() - 1);
            text(t, (float)x+((cnode.hasChildren) ? 24 : 0), (float)drawy);
            if (mouseX > x+((cnode.hasChildren) ? 24 : 0) && mouseX < x+((cnode.hasChildren) ? 24 : 0)+textWidth(t)+12 && mouseY < drawy && mouseY > drawy-16 && active) {
                strokeWeight(2);
                line((float)x+((cnode.hasChildren) ? 24 : 0)+textWidth(t)+2, (float)drawy-11, (float)x+((cnode.hasChildren) ? 24 : 0)+textWidth(t)+12, (float)drawy-1);
                line((float)x+((cnode.hasChildren) ? 24 : 0)+textWidth(t)+2, (float)drawy-1, (float)x+((cnode.hasChildren) ? 24 : 0)+textWidth(t)+12 , (float)drawy-11);
                strokeWeight(1);
                if (ready && mousePressed && mouseButton == LEFT && mouseX > x+((cnode.hasChildren) ? 24 : 0)+textWidth(t)+2 && mouseX < x+((cnode.hasChildren) ? 24 : 0)+textWidth(t)+12) {
                    ready = false;
                    super.remove(removeN.eventHeard(i--, 0));
                    hasUpdated = true;
                }
            } if (cnode.hasChildren) {
                line((float)x+7, (float)drawy-6, (float)x+17, (float)drawy-6);
                if (!cnode.expanded)
                    line((float)x+12, (float)drawy-11, (float)x+12, (float)drawy-1);
                if (mouseX >= x+7 && mouseX <= x+17 && mouseY >= drawy-11 && mouseY <= drawy-1 && active && ready && mousePressed && mouseButton == LEFT) {
                    ((UITreeNode)super.get(i)).toggleExpanded();
                    ready = false;
                } if (cnode.expanded) {
                    for (int j = 0; j < cnode.size(); j++) {
                        fill(0x33);
                        drawy += 16;
                        if (drawy > h+y) break;
                        UITreeNode bnode = (UITreeNode)cnode.get(j);
                        String t1 = bnode.title;
                        while (textWidth(t1) > w - 72 && t1.length() > 0)
                            t1 = t1.substring(0, t1.length() - 1);
                        text(t1, (float)x+55, (float)drawy);
                        if (!bnode.hasChildren) {
                            if (bnode.checked) fill(0x33);
                            else noFill();
                            rect((float)x+41, (float)drawy-11, 10, 10);
                            if (mouseX > x+12 && mouseX < x+35 && mouseY > drawy-11 && mouseY < drawy-1 && active && ready && mousePressed && mouseButton == LEFT) {
                                Color jc = JColorChooser.showDialog(null, "Choose color", Color.BLACK);
                                if (jc != null) {
                                    bnode.drawcolor = color(jc.getRed(), jc.getGreen(), jc.getBlue(), jc.getAlpha());
                                    hasUpdated = true;
                                }
                                ready = false; 
                            } else if (mouseX > x+55 && mouseX < x+textWidth(t1)+67 && mouseY > drawy-11 && mouseY < drawy-1 && active) {
                                strokeWeight(2);
                                line((float)x+textWidth(t1)+57, (float)drawy-11, (float)x+textWidth(t1)+67, (float)drawy-1);
                                line((float)x+textWidth(t1)+57, (float)drawy-1, (float)x+textWidth(t1)+67, (float)drawy-11);
                                strokeWeight(1);
                                if (ready && mousePressed && mouseButton == LEFT && mouseX > x+textWidth(t1)+57 && mouseX < x+textWidth(t1)+67) {
                                    ((UITreeNode)super.get(i)).remove(removeE.eventHeard(i, j--));
                                    hasUpdated = true;
                                    ready = false;
                                }
                            } else if (mouseX > x+31 && mouseX < x+49 && mouseY > drawy-11 && mouseY < drawy-1 && active && ready && mousePressed && mouseButton == LEFT) {
                                ((UITreeNode)cnode.get(j)).toggleChecked();
                                hasUpdated = true;
                                ready = false;
                            }    
                            fill(bnode.drawcolor);
                            rect((float)x+12, (float)drawy-11, 23, 10);
                        }
                    } 
                } drawy += 16;
            }
        }
        if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
            if (!mousePressed || mouseButton != LEFT && active) ready = true;
        } else ready = !(mousePressed && mouseButton == LEFT && active);
    }
    
    boolean hasUpdated() {
        if (hasUpdated) {
            hasUpdated = false;
            return true;
        } else return false;
    }
    
    void mouseAction() {
        
    }
    
    void keyAction(char c, int i, int j) {
    }
    void updateComponents() { }
    boolean isFocused() { return focus; }
    void setFocus(boolean f) { focus = f; }
    void removeComponent(int a, int b) { }
    void addComponent(UIComponent c, int a, int b) { }
    String toString() { return ""; }
    void setActive(boolean a) { active = a; }
    boolean isActive() { return active; }
    double getX() { return x; }
    double getY() { return y; }
    void setX(double newx) { x = newx; }
    void setY(double newy) { y = newy; }
}
