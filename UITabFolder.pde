class UITabFolder extends UIHorizontalFolder {
    
    double xl, yl;
    PFont sfont;
    UITabFolder(double xmargin, double ymargin, double xlm, double ylm, String[] titles) {
        super(xmargin, ymargin, titles.length, 0, titles);
        xl = xlm; yl = ylm;
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
            if (focus && active && mouseX > xOff+x && mouseX < xOff+x+textWidth(get(j).title)+40.0 && mouseY < (float)y && mouseY > (float)y-20) {
                if (mousePressed && mouseButton == LEFT) currentpage = j;
                else {
                    c_text = 0xDD; c_tab = 0x44;
                }
            }
            get(j).setFocus(this.focus && j == currentpage);
            get(j).setActive(this.active && j == currentpage);
            if (currentpage == j)
                c_tab = 0xFF;
            fill(c_tab);
            beginShape();
            //vertex((float)x, (float)y);
            vertex(xOff+(float)x, (float)y);
            for (int i = 0; i < 20; i+=2)
                vertex(xOff+i+(float)x, (float)y+(-sin((i*HALF_PI)/20.0)*20.0));
            //vertex(xOff+textWidth(get(j).title)+(float)x+20.0, (float)y-20);
            for (int i = 20; i >= 0; i -= 2)
                vertex(xOff+40.0+(float)x+textWidth(get(j).title)-i, (float)y+(-sin((abs(i)*HALF_PI)/20.0)*20.0));
            if (currentpage == j) {
                vertex(width-(float)xl, (float)y);
                vertex(width-(float)xl, height-(float)yl);
                vertex((float)x, height-(float)yl);
                vertex((float)x, (float)y);
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
            get(currentpage).get(i).mouseAction();
    }
    
    void keyAction(char k, int c, int mods) {
        for (int i = 0; i < get(currentpage).size(); i++)
            get(currentpage).get(i).keyAction(k, c, mods);
    }
}
