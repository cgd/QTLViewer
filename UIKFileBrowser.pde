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

class UIKFileBrowser extends UIComponent {
    float x = 0.0, y = 0.0, cWidth = 0.0, cHeight = 0.0, panAmount = 0.0;
    String path;
    String pathText[];
    PFont main = createFont("Arial", 48, true);
    int page = 0, panId = -1;
    long lastFrame = -1;
    long lastPan = -1;
    boolean panReady = true;
    
    UIButton open;
    
    UIKFileBrowser(float newX, float newY, float newW, float newH) {
        x = newX;
        y = newY;
        cWidth = newW;
        cHeight = newH;
        path = System.getProperty("user.home").replace("\\", "/");
    }
    
    void update() {
        if (lastPan != -1 && System.currentTimeMillis() - lastPan >= 1000) {
            lastPan = -1;
            panAmount = 0.0;
            panReady = true;
        }
        
        if (ENABLE_KINECT_SIMULATE) {
            if (keyPressed && key == CODED && keyCode == DOWN) {
                page++;
            } else if (keyPressed && key == CODED && keyCode == UP && page > 0) {
                page--;
            }
        }
        
        while (path.indexOf("//") != -1) {
            path = path.replace("//", "/");
        }
        
        textFont(main);
        fill(0x00);
        
        pathText = path.split("/");
        float w;
        int startIndex = 0;
        
        do {
            w = 0.0;
            
            for (int i = startIndex; i < pathText.length; i++) {
                w += textWidth(pathText[i]);
            }
            
            w += 16 * (pathText.length - 1);
            
            if (w >= cWidth) {
                startIndex++;
            }
        } while (w + 8 >= cWidth);
        
        w = 8.0;
        
        strokeWeight(2);
        
        pathText = splice(pathText, "/", 0);
        
        for (int i = startIndex; i < pathText.length - 1; i++) {
            if (i == startIndex) {
                line (x, y + 8, x, y + 56);
            }
            
            String s = pathText[i];
            
            if (s.length() == 0) {
                continue;
            }
            
            if (mouseInRect(this, x + w, y + 8, x + w + textWidth(s) + 8, y + 56)) {
                fill(0x55);
                rect(x + w - 8, y + 8, textWidth(s) + 16, 48);
                fill(0xFF);
                
                if (mousePressedInRect(this, x + w, y + 8, x + w + textWidth(s) + 8, y + 56) && (lastFrame == -1 || frameCount - lastFrame > 1)) {
                    path = "/";
                    
                    for (int j = 1; j <= i; j++) {
                        path += pathText[j] + "/";
                    }
                    
                    page = 0;
                    
                    break;
                }
            }
            
            text(s, x + w, y + 48);
            w += textWidth(s) + 16;
            
            line(x + w - 8, y + 8, x + w - 8, y + 56);
            
            fill(0x00);
        }
        
        fill(0x00);
        
        if (pathText.length > 1) {
            line(x, y + 8, x + w - 8, y + 8);
            line(x, y + 56, x + w - 8, y + 56);
        }
        
        String t = pathText[pathText.length - 1];
        
        if (textWidth(t) + x + w >= cWidth) {
            while (textWidth(t + "...") + x + w >= cWidth && t.length() > 0) {
                t = t.substring(0, t.length() - 1);
            }
            
            t += "...";
        }
        
        text(t, x + w, y + 48);
        
        fill(0xAA);
        rect(x, y + 72, cWidth, cHeight - 72);
        fill(0x00);
        noStroke();
        
        String[] dirs = new File(path).list();
        int maxLines = (int)(cHeight - 72) / 48;
        
        while (ceil((float)dirs.length / maxLines) <= page) {
            page--;
        }
        
        if (page < 0) {
            return;
        }
        
        for (int i = page * maxLines, l = 0; i < dirs.length && l < maxLines; i++, l++) {
            fill(0x00);
            
            if (mouseInRect(this, x, y + 78 + (l * 48), x + cWidth, y + 72 + ((l + 1) * 48))) {
                fill(0x55);
                rect(x, y + 78 + (l * 48) , cWidth, 48);
                fill(0xFF);
                
                if (mousePressedInRect(this, x, y + 78 + (l * 48), x + cWidth, y + 72 + ((l + 1) * 48)) && (lastFrame == -1 || frameCount - lastFrame > 1)) {
                    if(new File(path + "/" + dirs[i]).exists() && new File(path + "/" + dirs[i]).isDirectory()) {
                        path += "/" + dirs[i];
                        page = 0;
                        break;
                    } else if (new File(path + "/" + dirs[i]).exists() && new File(path + "/" + dirs[i]).isFile()) {
                        loadFile(path + "/" + dirs[i]);
                        break;
                    }
                }
            }
            
            String title = dirs[i];
            
            if (textWidth(title) >= cWidth) {
                while (textWidth(title + "...") >= cWidth) {
                    title = title.substring(0, title.length() - 1);
                }
                
                title += "...";
            }
            
            text(title, x + 4, y + 72 + ((l + 1) * 48));
        }
    }
    
    void pan(PVector vec) {
        lastPan = System.currentTimeMillis();
        panAmount += vec.y;

        if (panAmount > 300.0 && panId != -1 && panReady) {
            page++;
            panReady = false;
            panAmount = 0;
        } else if (panAmount < -300.0 && panId != -1 && page > 0 && panReady) {
            page--;
            panReady = false;
            panAmount = 0;
        }
    }
    
    int size() { return 0; }
    
    void panStart(int id) {
        panId = id;
        panReady = true;
    }
    
    void panEnd(int id) {
        panId = -1;
        panReady = true;
    }
}
