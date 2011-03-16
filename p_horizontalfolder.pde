class p_horizontalfolder extends ArrayList<p_page> implements p_component {
  
  int pages = 0, currentpage = 0;
  double tx = 0.0, tz = 0.0, v = 0.1, x, y, target = 0.0, ztarget = 0.0;
  boolean prevready = true, nextready = true, focus = true, active = true;
  PFont main = createFont("Arial", 24, true);
  
  p_horizontalfolder(double xmargin, double ymargin, int ps, int current, String[] titles) {
    super();
    x = xmargin;
    y = ymargin;
    pages = ps;
    currentpage = current;
    target = -(current * width);
    tx = -(current * width);
    for (int i = 0; i < ps; i++)
      this.add(new p_page(titles[i], i));
  }
  
  void addComponent(p_component c, int page, int index) {
    ((p_page)this.get(page)).addComponent(c, page, index);
  }
  
  void removeComponent(int page, int index) {
    ((p_page)this.get(page)).removeComponent(page, index);
  }
  
  void mouseAction() {
    if (tz != 0.0)
      return;
    ((p_page)this.get(currentpage)).mouseAction();
  }
  
  void keyAction(char k, int c, int mods) {
    if (tz != 0.0 && (c == ENTER || c == RETURN)) zoomIn();
    else ((p_page)this.get(currentpage)).keyAction(k, c, mods);
  }
  
  void updateComponents() {
  }
  
  void update() {
    stroke(0x00);
    fill(0xFF);
    pushMatrix();
    translate((float)tx, 0, (float)tz);
    tx += (target - tx) * v;
    tz += (ztarget - tz) * v;
    if (Math.abs(target - tx) < 0.125) tx = target;
    if (Math.abs(ztarget - tz) < 0.125) tz = ztarget;
    for (int i = 0; i < pages; i++) {
      strokeWeight((i == currentpage) ? 2 : 1);
      rect((float)(x + (i * width)), (float)y, (float)(width-(x*2.0)), (float)(height-(y*2.0)));
    }
    for (int i = 0; i < pages; i++) {
      ((p_page)this.get(i)).setFocus(i == currentpage && tz > -5.0 && focus);
      ((p_page)this.get(i)).setActive(i == currentpage && tz > -5.0 && active);
      //((p_page)this.get(i)).update();
    }
    ((p_page)this.get(currentpage)).update();
    fill(0x55);
    textFont(main);
    for (int i = 0; i < pages; i++) 
      text(((p_page)this.get(i)).toString(), (float)((i*width)+x), 18, 0);
    popMatrix();
    noStroke();
    
    if (currentpage != (pages - 1)) {
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
    rect((float)(width/2.0)-100, (float)(height-x)+2, 200, (float)x-4);
    float smallx =- map((float)tx, 0.0, -(width * (pages)), 0, -200);
    float smallw = (200.0/pages);
    rect((float)smallx+((width/2.0)-100), (float)(height-x)+4, (float)smallw, (float)x-8);
  }
  
  void goPage(int index) {
    target = -(index * width);
    currentpage = index;
  }
  
  void nextPage() {
    if (currentpage == (pages - 1)) return;
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
  
  boolean isFocused() { return focus; }
  void setFocus(boolean b) { focus = b; }
  void setX(double newx) { }
  void setY(double newy) { }
  double getX() { return 0.0; }
  double getY() { return 0.0; }
  String toString() { return ""; }
  boolean isZoomed() { return ztarget <= -250.0; }
  void setActive(boolean a) { active = a; }
  boolean isActive() { return active; }
}
