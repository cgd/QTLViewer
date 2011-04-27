class UITabFolder extends UIHorizontalFolder {
    
    float xl, yl;
    PFont sfont;
    UITabFolder(float xmargin, float ymargin, float xLowerMargin, float yLowerMargin, String[] titles) {
        super(xmargin, ymargin, 0, titles);
        xl = xLowerMargin;
        yl = yLowerMargin;
        sfont = createFont("Arial", 16, true);
    }
    
    void update() {
        stroke(0x00);
        fill(0xFF);
        //rect((float)x, (float)y, width-(float)(x+xl), height-(float)(y+yl));
        float xOff = 0.0;
        textFont(sfont);
        for (int j = 0; j < size(); j++) {
            int c_text = 0xCC, c_tab = 0x55;
            if (focus && active && mouseX > xOff + x && mouseX < xOff + x + textWidth(get(j).title) + 40.0 && mouseY < y && mouseY > y - 20) {
                if (mousePressed && mouseButton == LEFT) currentpage = j;
                else {
                    c_text = 0xDD; c_tab = 0x44;
                }
            }
            super.get(j).focus = (this.focus && j == currentpage);
            super.get(j).active = (this.active && j == currentpage);
            if (currentpage == j)
                c_tab = 0xFF;
            fill(c_tab);
            beginShape();
            //vertex((float)x, (float)y);
            vertex(xOff + x, y);
            for (int i = 0; i < 20; i+=2)
                vertex(xOff + i + x, y + (-sin((i*HALF_PI)/20.0)*20.0));
            //vertex(xOff+textWidth(get(j).title)+(float)x+20.0, (float)y-20);
            for (int i = 20; i >= 0; i -= 2)
                vertex(xOff + 40.0 + x + textWidth(get(j).title) - i, y + (-sin((abs(i)*HALF_PI)/20.0)*20.0));
            if (currentpage == j) {
                vertex(width - xl, y);
                vertex(width-xl, height - yl);
                vertex(x, height - yl);
                vertex(x, y);
            }
            endShape();
            if (currentpage == j) c_text = 0x00;
            fill(c_text);
            text(get(j).title, xOff+20.0+(float)x, (float)y-4.0);
            xOff += 40.0+textWidth(get(j).title);
        }
        get(currentpage).update();
    }
    
    void mouseAction() {
        for (int i = 0; i < get(currentpage).size(); i++)
            super.get(currentpage).get(i).mouseAction();
    }
    
    void keyAction(char k, int c, int mods) {
        for (int i = 0; i < get(currentpage).size(); i++)
            super.get(currentpage).get(i).keyAction(k, c, mods);
    }
    
    UIPage get(int index) {
        return super.get(index);
    }
}
