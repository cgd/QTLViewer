class p_progressbar implements p_component {
  double x, y, w, h, v;
  boolean active = true;
  int type;
  
  p_progressbar(double ex, double why, double doubleu, double ach) {
    x = ex; y = why; w = doubleu; h = ach; type = 0; v = 0.0;
  }
  
  void update() {
    strokeWeight(1);
    noFill();
    stroke(0x00);
    rect((float)x, (float)y, (float)w, (float)h);
    fill(0x55);
    noStroke();
    if (type == 1) { // vertical
      double ph = map((float)v, 0, 1.0, 0, (float)h);
      rect((float)x, (float)(y + h - ph), (float)w, (float)ph);
    } else { // horizontal
      
    }
  }
  
  void setHorizontal() { type = 0; }
  void setVertical() { type = 1; }
  void setValue(double newval) { v = newval; update(); }
  int size() { return 0; }
  void removeComponent(int i, int j) { }
  void addComponent(p_component c) { }
  void addComponent(p_component c, int i, int j) { }
  void updateComponents() { }
  void mouseAction() { }
  void keyAction(char c, int i, int j) { }
  boolean isFocused() { return false; }
  void setFocus(boolean f) { }
  void setX(double newx) { }
  void setY(double newy) { }
  double getX() { return 0.0; }
  double getY() { return 0.0; }
  String toString() { return ""; }
  void setActive(boolean a) { active = a; }
  boolean isActive() { return active; } 
}
