class LODDisplay implements p_component {
  boolean focus = false, active = true, dragReady = true, dragging = false, chr_ready = true;
  double x = 100.0, y = 50.0, legendX, legendY, legendW, legendH;
  PFont font = createFont("Arial", 24, true), legendFont = createFont("Arial", 16, true), smallFont = createFont("Arial", 12, true);
  float legendOffsetX = -1, legendOffsetY = -1, legendA = 0x00, maxOffset = -1.0;
  int current_chr = -1;
  LODDisplay() {
    legendX = width-400.0;
    legendY = 250.0;
  }
  
  void update() {
    findMax();
    if (current_chr > lastChr()-1) current_chr = -1;
    textFont(font);
    strokeWeight(2);
    stroke(0x00);
    line((float)x, (float)y, (float)x, height-100);
    line((float)x, height-100, width-50, height-100);
    fill(0x00);
    //double current_x = 0;
    if (current_chr == -1)
      for (int i = 0; i < 20; i++) {
        //if (i == 19) text("X", (float)(x+current_x-(textWidth("X")/2.0)), height-64);
        //else text(str(i+1), (float)(x+current_x-(textWidth(str(i+1))/2.0)), height-64);
        //line((float)(x+current_x), height-100, (float)(x+current_x), height-84);
        //current_x += map(chr_lengths[i], 0.0, chr_total, 0.0, width-150);
        float pos = map(chr_offsets[i]+(chr_lengths[i]/2.0), 0.0, chr_total, 0.0, width-150);
        if (i == 19) text("X", (float)x+pos-(textWidth("X")/2.0), height-64);
        else text(str(i+1), (float)x+pos-(textWidth(str(i+1))/2.0), height-64);
        line((float)x+pos, height-100, (float)x+pos, height-84);
      }
    else for (int i = 1; i <= 4; i++) {
      int value = round((i*ceil(maxOffset))/4.0);
      float x_off = map(value, 0.0, ceil(maxOffset), 0.0, width-150);
      text(str(value)+((i == 1) ? "cM" : ""), (float)x+x_off-(textWidth(str(value)+((i == 1) ? "cM" : ""))/2.0), height-64);
      line((float)x+x_off, height-100, (float)x+x_off, height-84);
    } if (maxLod != -1.0) {
      //line((float)x, (float)y, (float)x-16, (float)y);
      //text(str(top), (float)x-16-textWidth(str(top)), (float)y+12);
      //text("0", (float)x-16-textWidth("0"), (float)height-88);
      //line((float)x, height-100, (float)x-16, height-100);
      int m = ceil(maxLod);
      if (maxLod < 1.0) {
        m = 1;
        float y_off = map(m, 0.0, m, 0.0, height-150);
        text("1", (float)x-16-textWidth("1"), (float)height-y_off-88);
        line((float)x, height-y_off-100, (float)x-16, height-y_off-100);
        y_off = map(0, 0.0, m, 0.0, height-150);
        text("0", (float)x-16-textWidth("0"), (float)height-y_off-88);
        line((float)x, height-y_off-100, (float)x-16, height-y_off-100);
      } else {
        for (int i = 0; i <= 4; i++) {
          int value = round((i*m)/4.0);
          float y_off = map(value, 0.0, m, 0.0, height-150);
          text(str(value), (float)x-16-textWidth(str(value)), (float)height-y_off-88);
          line((float)x, height-y_off-100, (float)x-16, height-y_off-100);
        }
      }
      strokeWeight(1);
      fill(0x00);
      //text("test", (float)legendX + 2.0, (float)legendY + 16.0);
      int[] colors = new int[0];
      String[] names = new String[0];
      float maxLen = -1.0, autoLower = 1.5, autoUpper = 3.0;
      try {
        autoLower = float(((p_text)texts.get(0)).getText());
        autoUpper = float(((p_text)texts.get(1)).getText());
      } catch (Exception error3) {
        println("EXCEPTION:");
        println(error3.getLocalizedMessage());
      }
      for (int i = 0; i < phenos.size(); i++) {
        for (int j = 0; j < ((p_treenode)filetree.get(i)).size(); j++) {
          Phenotype p = ((Parent_File)phenos.get(i)).get(j);
          p_treenode tn = ((p_treenode)((p_treenode)filetree.get(i)).get(j));
          if (tn.checked) {
            textFont(legendFont);
            names = append(names, p.name+" ("+((p_treenode)filetree.get(i)).title+")");
            colors = append(colors, tn.drawcolor);
            if (textWidth(p.name+" ("+((p_treenode)filetree.get(i)).title+")") > maxLen) maxLen = textWidth(p.name+" ("+((p_treenode)filetree.get(i)).title+")");
            fill(0xAA);
            strokeWeight(1);
            textFont(font);
            if (current_chr != -1) text("chromosome "+((current_chr == 19) ? "X" : (current_chr+1)), (float)x+2, (float)y-4);
            stroke(tn.drawcolor, 0x7F);
            fill(tn.drawcolor, 0x7F);
            strokeWeight(3);
            if (p.useDefaults) {
              p.Aupper = autoUpper;
              p.Alower = autoLower;
            } if (p.useXDefaults) {
              p.Xupper = autoUpper;
              p.Xlower = autoLower;
            }
            float y_offU = map(p.Aupper, 0.0, m, 0.0, height-150);
            float y_offL = map(p.Alower, 0.0, m, 0.0, height-150);
            float y_offXU = map(p.Xupper, 0.0, m, 0.0, height-150);
            float y_offXL = map(p.Xlower, 0.0, m, 0.0, height-150);
            textFont(smallFont);
            if (current_chr == -1) {
              float endX = (p.Aupper == p.Xupper && p.Alower == p.Xlower) ? width-50 : map(chr_offsets[chr_offsets.length-1], 0.0, chr_total, (float)x, width-50);
              for (float xp = (float)x; xp < endX-10; xp += 20.0) {
                if (p.Aupper <= m) line(xp, height-y_offU-(float)y-50.0, xp+10.0, height-y_offU-(float)y-50.0);
                if (p.Alower <= m) line(xp, height-y_offL-(float)y-50.0, xp+10.0, height-y_offL-(float)y-50.0);
              } if (p.Aupper != p.Xupper || p.Alower != p.Xlower) {
                for (float xp = endX; xp < width-60; xp += 20.0) {
                  if (p.Xupper <= m) line(xp, height-y_offXU-(float)y-50.0, xp+10.0, height-y_offXU-(float)y-50.0);
                  if (p.Xlower <= m) line(xp, height-y_offXL-(float)y-50.0, xp+10.0, height-y_offXL-(float)y-50.0);
                }
                if (p.Xupper <= m) text("a="+(round(p.Xupper*100)/100.0), width-50-textWidth("a="+(round(p.Xupper*100)/100.0)), height-y_offXU-(float)y-54.0);
                if (p.Xlower <= m) text("a="+(round(p.Xlower*100)/100.0), width-50-textWidth("a="+(round(p.Xlower*100)/100.0)), height-y_offXL-(float)y-54.0);
                if (p.Aupper <= m) text("a="+(round(p.Aupper*100)/100.0), endX-textWidth("a="+(round(p.Aupper*100)/100.0)), height-y_offU-(float)y-54.0);
                if (p.Alower <= m) text("a="+(round(p.Alower*100)/100.0), endX-textWidth("a="+(round(p.Alower*100)/100.0)), height-y_offL-(float)y-54.0);
              } else {
                if (p.Xupper <= m) text("a="+(round(p.Aupper*100)/100.0), width-50-textWidth("a="+(round(p.Aupper*100)/100.0)), height-y_offXU-(float)y-54.0);
                if (p.Xlower <= m) text("a="+(round(p.Alower*100)/100.0), width-50-textWidth("a="+(round(p.Alower*100)/100.0)), height-y_offXL-(float)y-54.0);
              }
            } else {
              for (float xp = (float)x; xp < width-60; xp += 20.0) {
                if (((current_chr == chr_lengths.length-1) ? p.Xupper : p.Aupper) <= m)
                  line(xp, height-((current_chr == chr_lengths.length-1) ? y_offXU : y_offU)-(float)y-50.0, xp+10.0, height-((current_chr == chr_lengths.length-1) ? y_offXU : y_offU)-(float)y-50.0);
                if (((current_chr == chr_lengths.length-1) ? p.Xlower : p.Alower) <= m)
                  line(xp, height-((current_chr == chr_lengths.length-1) ? y_offXL : y_offL)-(float)y-50.0, xp+10.0, height-((current_chr == chr_lengths.length-1) ? y_offXL : y_offL)-(float)y-50.0);
              }
              if (((current_chr == chr_lengths.length-1) ? p.Xupper : p.Aupper) <= m)
                text("a="+(round(((current_chr == chr_lengths.length-1) ? p.Xupper : p.Aupper)*100)/100.0), 
                  width-50-textWidth("a="+(round(((current_chr == chr_lengths.length-1) ? p.Xupper : p.Aupper)*100)/100.0)), 
                  height-((current_chr == chr_lengths.length-1) ? y_offXU : y_offU)-(float)y-54.0);
              if (((current_chr == chr_lengths.length-1) ? p.Xlower : p.Alower) <= m)
                text("a="+(round(((current_chr == chr_lengths.length-1) ? p.Xlower : p.Alower)*100)/100.0), 
                  width-50-textWidth("a="+(round(((current_chr == chr_lengths.length-1) ? p.Xlower : p.Alower)*100)/100.0)), 
                  height-((current_chr == chr_lengths.length-1) ? y_offXL : y_offL)-(float)y-54.0);
            }
            stroke(tn.drawcolor);
            strokeWeight(1);
            float lastx = map(p.position[0]+chr_offsets[p.chromosome[0]-1], 0.0, chr_total, 0.0, width-150), lasty = map(p.lodscores[0], 0.0, m, 0.0, height-150);
            if (current_chr != -1) lastx = -1.0;
            for (int k = 1; k < p.position.length; k++) {
              try {
                if (current_chr != -1) {
                  if (lastx == -1.0 && p.chromosome[k]-1 == current_chr) {
                    lastx = map(p.position[k], 0.0, ceil(maxOffset), 0.0, width-150);
                    lasty = map(p.lodscores[k], 0.0, m, 0.0, height-150);
                  } else if (p.chromosome[k]-1 == current_chr) {
                    line((float)x+lastx, height-lasty-(float)y-50.0, (float)x+(lastx = map(p.position[k], 0.0, ceil(maxOffset), 0.0, width-150)), height-(lasty = map(p.lodscores[k], 0.0, m, 0.0, height-150))-(float)y-50.0);
                  }
                  continue;
                } if (p.chromosome[k-1] != p.chromosome[k]) {
                  lastx = map(p.position[k]+chr_offsets[p.chromosome[k]-1], 0.0, chr_total, 0.0, width-150);
                  lasty = map(p.lodscores[k], 0.0, m, 0.0, height-150);
                } else line((float)x+lastx, height-lasty-(float)y-50.0, (float)x+(lastx = map(p.position[k]+chr_offsets[p.chromosome[k]-1], 0.0, chr_total, 0.0, width-150)), height-(lasty = map(p.lodscores[k], 0.0, m, 0.0, height-150))-(float)y-50.0);
              } catch (ArrayIndexOutOfBoundsException error) {
                println("EXCEPTION:");
                println(error.getLocalizedMessage());
              }
            }
          }
        }
      }
      if (mouseX > legendX && mouseX < legendX+legendW && mouseY > legendY && mouseY < legendY+legendH && active) {
        legendA += (legendA < 0xFF) ? frameRate/5.0 : 0;
        if (legendA > 0xFF) legendA = 0xFF;
        if (dragReady && mousePressed && mouseButton == LEFT) {
          dragging = true;
          if (legendOffsetX == -1 || legendOffsetY == -1) {
            legendOffsetX = mouseX - (float)legendX;
            legendOffsetY = mouseY - (float)legendY; 
          }
        }
      } else {
        legendA -= (legendA > 0x00) ? frameRate/5.0 : 0;
        if (legendA < 0x00) legendA = 0x00;
      } if (dragging) {
        legendX = mouseX - legendOffsetX;
        legendY = mouseY - legendOffsetY;
        if (legendX < 0) legendX = 0;
        else if (legendX > width-legendW) legendX = width-legendW;
        if (legendY < 0) legendY = 0;
        else if (legendY > height-legendH) legendY = height-legendH;
      } if (!mousePressed || mouseButton != LEFT || !active) {
        legendOffsetX = legendOffsetY = -1;
        dragging = false;
      }
      fill(0x00, 0x2A);
      stroke(0x00, legendA);
      rect((float)legendX, (float)legendY, (float)(legendW=maxLen+18), (float)(legendH=(names.length*16)+4));
      stroke(0x00);
      textFont(legendFont);
      for (int i = 0; i < names.length; i++) {
        fill(colors[i]);
        rect((float)legendX+4.0, (float)legendY+((i+1)*16)-11, 10, 10);
        fill(0x00);
        text(names[i], (float)legendX+16.0, (float)legendY+((i+1)*16));
      }
    }
    if (mouseX > legendX && mouseX < legendX+legendW && mouseY > legendY && mouseY < legendY+legendH && active)
      dragReady = (!mousePressed || mouseButton != LEFT);
    else dragReady = !(mousePressed && mouseButton == LEFT && active);
    if (mouseX > x && mouseY > y && mouseX < width-50 && mouseY < height-100 && active)
      chr_ready = (!mousePressed || mouseButton != LEFT);
    else chr_ready = !(mousePressed && mouseButton == LEFT && active && dragging);
  }
  
  void mouseAction() {
    if (mouseX > legendX && mouseX < legendX+legendW && mouseY > legendY && mouseY < legendY+legendH) return;
    if (mouseX > x && mouseY > y && mouseX < width-50 && mouseY < height-100 && active && mousePressed && mouseButton == LEFT && !dragging && chr_ready && current_chr == -1) {
        for (int i = 0; i < chr_offsets.length; i++) {
          if (mouseX > map(chr_offsets[i], 0.0, chr_total, 0.0, width-150)+x) {
            if (i == chr_offsets.length - 1)
              current_chr = i;
            else if (mouseX < map(chr_offsets[i+1], 0.0, chr_total, 0.0, width-150)+x)
              current_chr = i;
          }
       }
    }
  }
  
  void keyAction(char c, int i, int j) {
    if (!keyPressed) return;
    /*if ((key == DELETE || key == BACKSPACE) && j == 64)
      current_chr = -1;
    else if (key == CODED && keyCode == LEFT && j == 64 && current_chr > 0)
      current_chr--;
    else if (key == CODED && keyCode == RIGHT && j == 64 && current_chr > -1 && current_chr < lastChr()-1)
      current_chr++;*/
  }
  
  void nextChr() {
    if (folder.currentpage != 1) return;
    if (current_chr > -1 && current_chr < lastChr()-1) current_chr++;
    else current_chr = -1;
  }
  
  void prevChr() {
    if (folder.currentpage != 1) return;
    if (current_chr > 0) current_chr--;
    else current_chr = -1;
  }
  
  void allChr() {
    if (folder.currentpage != 1) return;
    current_chr = -1;
  }
  
  void findMax() {
    maxLod = maxOffset = -1.0;
    for(int i = 0; i < phenos.size(); i++) {
      Parent_File pf = (Parent_File)phenos.get(i);
      for (int j = 0; j < pf.size(); j++) {
        Phenotype p = pf.get(j);
        if (((p_treenode)((p_treenode)filetree.get(i)).get(j)).checked) {
          /*for (int k = 0; k < p.lodscores.length; k++) {
            if (current_chr == -1) { if (p.lodscores[k] > maxLod) maxLod = p.lodscores[k]; }
            else { 
              if (p.chromosome[k] == current_chr+1) {
               if (p.lodscores[k] > maxLod) maxLod = p.lodscores[k];
               if (p.position[k] > maxOffset) maxOffset = p.position[k];
              }
            }*/
          float m;
          if (current_chr == -1 && (m = max(p.lodscores)) > maxLod) maxLod = m;
          else for (int k = 0; k < p.lodscores.length; k++) {
            if (p.chromosome[k] == current_chr+1) {
              if (p.lodscores[k] > maxLod) maxLod = p.lodscores[k];
              if (p.position[k] > maxOffset) maxOffset = p.position[k];
            }
          }
        }
      }
    }
    if (maxOffset != -1.0 && maxOffset < chr_lengths[current_chr]) maxOffset = chr_lengths[current_chr];
  }
  
  int lastChr() {
    int maxChr = -1;
    for(int i = 0; i < phenos.size(); i++) {
      Parent_File pf = (Parent_File)phenos.get(i);
      for (int j = 0; j < pf.size(); j++) {
        Phenotype p = pf.get(j);
        if (((p_treenode)((p_treenode)filetree.get(i)).get(j)).checked)
          if (p.chromosome[p.chromosome.length-1] > maxChr) maxChr = p.chromosome[p.chromosome.length-1];
      }
    }
    return maxChr;
  }  
  int size() { return 0; }
  void addComponent(p_component p) { }
  void addComponent(p_component p, int i, int j) { }
  void removeComponent(int index1, int index2) { }
  void updateComponents() { }
  boolean isFocused() { return focus; }
  void setFocus(boolean f) { focus = f; }
  void setX(double newx) { }
  void setY(double newy) { }
  double getX() { return 0.0; }
  double getY() { return 0.0; }
  String toString() { return ""; }
  void setActive(boolean a) { active = a; }
  boolean isActive() { return active; }
}
