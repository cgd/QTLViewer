class p_button implements p_component {
  float w, h;
  double x, y;
  String data;
  PFont font = createFont("Arial", 16, true);
  color bg = color(0xCC);
  color border = color(0xFF);
  color mouse = color(0x99);
  color textc = color(0x33);
  boolean ready = true, focus = false, active = true;
  p_action action = null;
  
  p_button(float ex, float why, String dee, p_action aye) {
    x = ex; y = why; w = textWidth(dee); h = 25; data = dee;
    action = aye;
  }
  
  /*p_button(float ex, float why, float doubleu, float aech, String dee) {
    x = ex; y = why; w = doubleu; h = aech; data = dee;
    font = createFont("Arial", 16, true);
  }
    
  button(float ex, float why, float doubleu, float aech, String dee, PFont ef) {
    x = ex; y = why; w = doubleu; h = aech; font = ef;
    font = ef;
  }
  
  void setColors(color newbg, color newborder, color newmouse, color newtext) {
    bg = newbg; border = newborder; mouse = newmouse; textc = newtext;
  }*/
  
  double getX() { return x; }
  double getY() { return y; }
  void setX(double newx) { x = newx; }
  void setY(double newy) { y = newy; }
  
  void update() {
    textFont(font);
    w = textWidth(data)+8;
    fill(bg);
    stroke(border);
    if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h && active) {
      if (!mousePressed || mouseButton != LEFT && active)
        ready = true;
      stroke(mouse);
    } else ready = !(mousePressed && mouseButton == LEFT && active);
    strokeWeight(1);
    rect((float)x, (float)y, w, h);
    fill(textc);
    text(data, (float)x+4, (float)y+18);
  }
  
  void mouseAction() {
    if (mousePressed && mouseButton == LEFT && ready && action != null && active && mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h)
      action.doAction();
  }
  void updateComponents() { }
  void keyAction(char k, int c, int mods) {
    if ((key == ENTER || key == RETURN) && active && focus) action.doAction();
  }
  boolean isFocused() { return focus; }
  void setFocus(boolean f) { focus = f; }
  int size() { return 0; }
  void removeComponent(int a, int b) { }
  void addComponent(p_component c, int a, int b) { }
  String toString() { return data; }
  void setActive(boolean a) { active = a; }
  boolean isActive() { return active; }
}
