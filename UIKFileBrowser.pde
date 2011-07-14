class UIKFileBrowser extends UIComponent {
    float x = 0.0, y = 0.0, cWidth = 0.0, cHeight = 0.0;
    String path;
    String pathText[];
    PFont main = createFont("Arial", 48, true);
    int page = 0;
    
    UIButton open;
    
    UIKFileBrowser(float newX, float newY, float newW, float newH) {
        x = newX;
        y = newY;
        cWidth = newW;
        cHeight = newH;
        path = System.getProperty("user.home").replace("\\", "/");
    }
    
    void update() {
        textFont(main);
        fill(0x00);
        
        pathText = path.split("/");
        float w;
        
        do {
            w = 0.0;
            
            for (int i = 0; i < pathText.length; i++) {
                w += textWidth(pathText[i]);
            }
            
            w += 16 * (pathText.length - 1);
            
            if (w >= cWidth) {
                pathText = subset(pathText, 1);
            }
        } while (w + 8 >= cWidth);
        
        w = 8.0;
        
        strokeWeight(2);
        
        pathText = splice(pathText, "/", 0);
        
        for (int i = 0; i < pathText.length - 1; i++) {
            if (i == 0) {
                line (x, y + 8, x, y + 56);
            }
            
            String s = pathText[i];
            
            if (s.length() == 0) {
                continue;
            }
            
            if (mouseInRect(x + w, y + 8, x + w + textWidth(s) + 8, y + 56)) {
                fill(0x55);
                rect(x + w - 8, y + 8, textWidth(s) + 16, 48);
                fill(0xFF);
                
                if (mousePressedInRect(x + w, y + 8, x + w + textWidth(s) + 8, y + 56)) {
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
        
        text(pathText[pathText.length - 1], x + w, y + 48);
        
        fill(0xAA);
        rect(x, y + 72, cWidth, cHeight - 72);
        fill(0x00);
        noStroke();
        
        String[] dirs = new File(path).list();
        int maxLines = (int)(cHeight - 72) / 48;
        
        if (ceil((float)dirs.length / maxLines) < page) {
            page = 0;
        }
        
        for (int i = page * maxLines, l = 0; i < dirs.length && l < maxLines; i++, l++) {
            fill(0x00);
            if (mouseInRect(x, y + 72 + (l * 48) + 6, x + cWidth, y + 72 + ((l + 1) * 48))) {
                fill(0x55);
                rect(x, y + 72 + (l * 48) + 6, cWidth, 48);
                fill(0xFF);
                
                if (mousePressedInRect(x, y + 72 + (l * 48) + 6, x + cWidth, y + 72 + ((l + 1) * 48))) {
                    if(new File(path + dirs[i]).exists() && new File(path + dirs[i]).isDirectory()) {
                        path += dirs[i];
                        break;
                    } else if (new File(path + dirs[i]).exists() && new File(path + dirs[i]).isDirectory()) {
                        loadFile(path + dirs[i]);
                        break;
                    }
                }
            }
            
            text(dirs[i], x + 4, y + 72 + ((l + 1) * 48));
        }
    }
    
    void pan(PVector vec) {
        if (vec.y > 50.0) {
            page++;
        } else if (vec.y < -50.0 && page > 0) {
            page--;
        }
    }
    
    int size() { return 0; }
}
