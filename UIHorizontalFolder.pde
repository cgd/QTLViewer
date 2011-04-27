class UIHorizontalFolder extends UIComponent {
    
    int currentpage = 0;
    float tx = 0.0, tz = 0.0, v = 0.1, target = 0.0, ztarget = 0.0;
    boolean prevready = true, nextready = true, focus = true, active = true;
    PFont main = createFont("Arial", 24, true);
    ArrayList<UIPage> pages;
    UIHorizontalFolder(float xmargin, float ymargin, int current, String[] titles) {
        super();
        x = xmargin;
        y = ymargin;
        currentpage = current;
        target = -(current * width);
        tx = -(current * width);
        pages = new ArrayList<UIPage>();
        for (int i = 0; i < titles.length; i++)
            this.add(new UIPage(titles[i], i));
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
    
    void addComponent(UIComponent c, int page, int index) {
        this.get(page).addComponent(c, page, index);
    }
    
    void removeComponent(int page, int index) {
        this.get(page).removeComponent(page, index);
    }
    
    void mouseAction() {
        if (tz != 0.0)
            return;
        this.get(currentpage).mouseAction();
    }
    
    void keyAction(char k, int c, int mods) {
        if (tz != 0.0 && (c == ENTER || c == RETURN)) zoomIn();
        else this.get(currentpage).keyAction(k, c, mods);
    }
    
    void updateComponents() {
    }
    
    void update() {
        stroke(0x00);
        fill(0xFF);
        pushMatrix();
        translate(tx, 0, tz);
        tx += (target - tx) * v;
        tz += (ztarget - tz) * v;
        if (Math.abs(target - tx) < 0.125) tx = target;
        if (Math.abs(ztarget - tz) < 0.125) tz = ztarget;
        for (int i = 0; i < size(); i++) {
            strokeWeight((i == currentpage) ? 2 : 1);
            rect((x + (i * width)), y, (width-(x*2.0)), (height-(y*2.0)));
        }
        for (int i = 0; i < size(); i++) {
            ((UIPage)this.get(i)).focus = (i == currentpage && tz > -5.0 && focus);
            ((UIPage)this.get(i)).active = (i == currentpage && tz > -5.0 && active);
            //((UIPage)this.get(i)).update();
        }
        ((UIPage)this.get(currentpage)).update();
        fill(0x55);
        textFont(main);
        for (int i = 0; i < size(); i++) 
            text(this.get(i).toString(), ((i*width)+x), 18, 0);
        popMatrix();
        noStroke();
        
        if (currentpage != (size() - 1)) {
            fill(0x55);
            if (mouseX < width-15 && mouseX > width-50 && mouseY > height-21.25 && mouseY < height-6.25 && focus) {
                fill(0x00);
                if (!mousePressed || mouseButton != LEFT) nextready = true;
                if (mousePressed && mouseButton == LEFT && nextready) { nextPage(); nextready = false; }
            } else nextready = !(mousePressed && mouseButton == LEFT);
            beginShape();
            vertex(width-50, height-17.5);
            vertex(width-25, height-17.5);
            vertex(width-25, height-21.25);
            vertex(width-15, height-13.75);
            vertex(width-25, height-6.25);
            vertex(width-25, height-10);
            vertex(width-50, height-10);
            endShape();
        }
        
        if (currentpage != 0) {
            fill(0x55);
            if (mouseX < width-60 && mouseX > width-95 && mouseY > height-21.25 && mouseY < height-6.25 && focus) {
                fill(0x00);
                if (!mousePressed || mouseButton != LEFT) prevready = true;
                if (mousePressed && mouseButton == LEFT && prevready) { prevPage(); prevready = false; }
            } else prevready = !(mousePressed && mouseButton == LEFT);
            beginShape();
            vertex(width-60, height-17.5);
            vertex(width-85, height-17.5);
            vertex(width-85, height-21.25);
            vertex(width-95, height-13.75);
            vertex(width-85, height-6.25);
            vertex(width-85, height-10);
            vertex(width-60, height-10);
            endShape();
        }
        
        noFill();
        strokeWeight(1);
        stroke(0x00);
        rect((width/2.0)-100, (height-x)+2, 200, x-4);
        float smallx =- map(tx, 0.0, -(width * (size())), 0, -200);
        float smallw = (200.0/size());
        rect(smallx+((width/2.0)-100), (height-x)+4, smallw, x-8);
    }
    
    void goPage(int index) {
        target = -(index * width);
        currentpage = index;
    }
    
    void nextPage() {
        if (currentpage == (size() - 1)) return;
        currentpage++;
        target = -(currentpage * width);
    }
    
    void prevPage() {
        if (currentpage == 0) return;
        currentpage--;
        target = -(currentpage * width);
    }
    
    void zoomOut() {
        ztarget -= 250.0;
    }
    
    void zoomIn() {
        ztarget = 0.0;
    }
    
    boolean isZoomed() { return ztarget <= -250.0; }
}
