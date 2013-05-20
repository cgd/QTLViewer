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

void keyPressed(java.awt.event.KeyEvent event) { // most key events are handled by the MenuBar
    if (key == ESC) {
        if (!ENABLE_KINECT) {
            exiting = !exiting;
            key = 0; // nullify the key, preventing Processing from closing automatically
        }
        
        // if Kinect version, exit
    }
  
    if (exiting) {
        yes.keyAction(key, keyCode, event.getModifiersEx());
        no.keyAction(key, keyCode, event.getModifiersEx());
    } else {
        texts.keyAction(key, keyCode, event.getModifiersEx());
    }
}

void keyReleased(java.awt.event.

KeyEvent event) {
    if (! exiting && tabs.active && tabs.focus) {
        tabs.keyAction(key, keyCode, event.getModifiersEx());
    }
}

void mousePressed() {
    if (mouseX > 10 && mouseX < 95 && mouseY < menuY + drawHeight && mouseY > menuY + drawHeight - 20 && !exiting && !dragging) {
        menuTargetY = (menuY == 0.0) ? -100.0 : 0.0;
        tabs.focus = (menuY == 0.0);
    }
  
    if (!ENABLE_KINECT && !exiting && !dragging && mouseX > fileTree.x + fileTree.cWidth && mouseX < tabs.x && mouseY > fileTree.y && mouseY < drawHeight + menuTargetY && (mouseX < legendX || mouseX > legendX + legendW || mouseY < legendY || mouseY > legendY + legendH)) {
        if (tabsXTarget == 110) {
            tabsXTarget = 335;
        } else {
            tabsXTarget = 110;
        }
    } else if (exiting) {
        yes.mouseAction();
        no.mouseAction();
    } else if (mouseY < drawHeight + menuTargetY && (mouseX < legendX || mouseX > legendX + legendW || mouseY < legendY || mouseY > legendY + legendH)) {
        tabs.mouseAction();
    } else {
        texts.mouseAction();
    }
}

void mouseMoved() {
    if (!exiting && !dragging) {
        tabs.mouseAction();
        texts.mouseAction();
    } else {
        yes.mouseAction();
        no.mouseAction();
    }
}

void mouseReleased() {
    if (!exiting && !dragging) {
        tabs.mouseAction();
        texts.mouseAction();
    } else {
        yes.mouseAction();
        no.mouseAction();
    }
}

boolean mouseInRect(Object o, float x1, float y1, float x2, float y2) {
    if (mouseLock != -1 && mouseLock != o.hashCode()) {
        return false;
    }
    
    if (exiting || users == null) {
        return false;
    }
  
    for (int i = 0; i < users.size(); i++) {
        PVector mouse = users.get(i).cursorPos;
        
        if (mouse.x > x1 && mouse.x < x2 && mouse.y > y1 && mouse.y < y2) {
            return true;
        }
    }
  
    if (ENABLE_KINECT_SIMULATE && mouseX > x1 && mouseX < x2 && mouseY > y1 && mouseY < y2) {
        return true;
    }
    
    return false;
}

boolean mousePressedInRect(Object o, float x1, float y1, float x2, float y2) {
  if (mouseLock != -1 && mouseLock != o.hashCode()) {
      return false;
  }
  
  if (exiting || users == null) {
      return false;
  }

  for (int i = 0; i < users.size(); i++) {
      PVector mouse = users.get(i).cursorPos;
      
      if (mouse.x > x1 && mouse.x < x2 && mouse.y > y1 && mouse.y < y2 && users.get(i).pressed) {
          return true;
      }
  }

  if (ENABLE_KINECT_SIMULATE && mousePressed && mouseButton == LEFT && mouseX > x1 && mouseX < x2 && mouseY > y1 && mouseY < y2) {
      return true;
  }
  
  return false;
}

boolean killMouseEvents(Object o) {
    if (mouseLock != -1 && mouseLock != o.hashCode()) {
        return false;
    }
    
    for (int i = 0; i < users.size(); i++) {
        users.get(i).pressed = false;
    }
    
    return true;
}

void killMouseEvents() {
     for (int i = 0; i < users.size(); i++) {
        users.get(i).pressed = false;
        users.get(i).righthandDown = -1;
        users.get(i).ready = false;
    }
}

boolean lockMouse(Object o) {
    if (mouseLock == -1 || mouseLock == o.hashCode()) {
        mouseLock = o.hashCode();
        return true;
    } else {
        return false;
    }
}

boolean freeMouse(Object o) {
    if (mouseLock == -1 || mouseLock == o.hashCode()) {
        mouseLock = -1;
        return true;
    } else {
        return false;
    }
}

void freeMouse() {
    mouseLock = -1;
}
