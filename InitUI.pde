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

/**
* This module is a container for methods that set up UI components and chromosome constants.
*/
void initMenuBar() {
    // init menu bar, sub menus, menu items, etc.
    MenuBar menu = new MenuBar();
    
    Menu fileMenu = new Menu("File");
    MenuItem openFileItem = new MenuItem("Open File...", new MenuShortcut(KeyEvent.VK_O));
    // action handling callbacks using anonymous inner classes
    openFileItem.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            openFile();
        }
    });
    
    MenuItem openFolderItem = new MenuItem("Open Folder...", new MenuShortcut(KeyEvent.VK_O, true));
    openFolderItem.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) {
                return;
            }
            
            loadFolder();
        }
    });
    
    MenuItem loadConfigItem = new MenuItem("Load config...", new MenuShortcut(KeyEvent.VK_E));
    loadConfigItem.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if(exiting) {
                return;
            }
            
            loadConfig();
        }
    });
    
    fileMenu.add(openFileItem);
    fileMenu.add(openFolderItem);
    fileMenu.add(new MenuItem("-"));
    fileMenu.add(loadConfigItem);
    
    Menu viewMenu = new Menu("View");
    MenuItem menuup = new MenuItem("Show Menu", new MenuShortcut(KeyEvent.VK_UP));
    menuup.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) {
                return;
            }
            
            menuTargetY = -100.0;
            tabs.focus = false;
        }
    });
    
    MenuItem menudown = new MenuItem("Hide Menu", new MenuShortcut(KeyEvent.VK_DOWN));
    menudown.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) {
                return;
            }
            menuTargetY = 0.0;
            tabs.focus = true;
        }
    });
    
    MenuItem nextchr = new MenuItem("Next Chromosome", new MenuShortcut(KeyEvent.VK_RIGHT));
    nextchr.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting || ((ENABLE_KINECT && tabs.currentpage != 1) || (!ENABLE_KINECT && tabs.currentpage != 0))) {
                return;
            }
            
            loddisplay.nextChr();
        }
    });
    
    MenuItem prevchr = new MenuItem("Previous Chromosome", new MenuShortcut(KeyEvent.VK_LEFT));
    prevchr.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting || ((ENABLE_KINECT && tabs.currentpage != 1) || (!ENABLE_KINECT && tabs.currentpage != 0))) {
                return;
            }
            
            loddisplay.prevChr();
        }
    });
    
    MenuItem showall = new MenuItem("Show All", new MenuShortcut(KeyEvent.VK_BACK_SPACE));
    showall.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting || ((ENABLE_KINECT && tabs.currentpage != 1) || (!ENABLE_KINECT && tabs.currentpage != 0))) {
                return;
            }
            
            loddisplay.allChr();
        }
    });
    
    MenuItem zoomin = new MenuItem("Zoom In", new MenuShortcut(KeyEvent.VK_EQUALS));
    zoomin.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting || ((ENABLE_KINECT && tabs.currentpage != 1) || (!ENABLE_KINECT && tabs.currentpage != 0))) {
                return;
            }
            
            double old = loddisplay.zoomFactor;
            if (loddisplay.zoomFactor > 0.05) {
                loddisplay.zoomFactor -= 0.05;
            } else if (loddisplay.zoomFactor > 0.01) {
                loddisplay.zoomFactor -= 0.01;
            } else {
                loddisplay.zoomFactor -= 0.001;
            }
            
            if (loddisplay.zoomFactor < 0.001) {
                loddisplay.zoomFactor = old;
            } else {
                float visibleLength = (loddisplay.current_chr == -1) ? chrTotal : loddisplay.maxOffset;
                
                if (mouseX > loddisplay.x && mouseX < loddisplay.cWidth + loddisplay.x && mouseY > loddisplay.y && mouseY < loddisplay.cHeight + loddisplay.y) {
                    loddisplay.offset -= map(mouseX - loddisplay.x, 0.0, loddisplay.cWidth, 0.0, (old * visibleLength) - (loddisplay.zoomFactor * visibleLength));
                } else {
                    loddisplay.offset -= ((old * visibleLength) - (loddisplay.zoomFactor * visibleLength)) / 2.0;
                }
            }
        }
    });
    
    MenuItem zoomout = new MenuItem("Zoom Out", new MenuShortcut(KeyEvent.VK_MINUS));
    zoomout.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting || ((ENABLE_KINECT && tabs.currentpage != 1) || (!ENABLE_KINECT && tabs.currentpage != 0))) {
                return;
            }
            
            double old = loddisplay.zoomFactor;
            loddisplay.zoomFactor += 0.05;
            
            if (loddisplay.zoomFactor > 1.0) {
                loddisplay.zoomFactor = old;
            } else {
                float visibleLength = (loddisplay.current_chr == -1) ? chrTotal : loddisplay.maxOffset;
                
                if (mouseX > loddisplay.x && mouseX < loddisplay.cWidth + loddisplay.x && mouseY > loddisplay.y && mouseY < loddisplay.cHeight + loddisplay.y) {
                    loddisplay.offset -= map(mouseX - loddisplay.x, 0.0, loddisplay.cWidth, 0.0, (old * visibleLength) - (loddisplay.zoomFactor * visibleLength));
                } else {
                    loddisplay.offset -= ((old * visibleLength) - (loddisplay.zoomFactor * visibleLength)) / 2.0;
                }
            }
        }
    });
    
    MenuItem zoomreset = new MenuItem("Zoom Reset", new MenuShortcut(KeyEvent.VK_Z));
    zoomreset.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting || ((ENABLE_KINECT && tabs.currentpage != 1) || (!ENABLE_KINECT && tabs.currentpage != 0))) {
                return;
            }
            
            loddisplay.zoomFactor = 1.0;
        }
    });
    
    viewMenu.add(menuup);
    viewMenu.add(menudown);
    viewMenu.add(new MenuItem("-"));
    viewMenu.add(nextchr);
    viewMenu.add(prevchr);
    viewMenu.add(showall);
    viewMenu.add(zoomin);
    viewMenu.add(zoomout);
    viewMenu.add(zoomreset);
    
    menu.add(fileMenu);
    menu.add(viewMenu);
    frame.setMenuBar(menu);
}

void initConstants() {
    unitThreshold = 2000;
    
    // init chr position information, all stored as centimorgans
    chrLengths = new float[20];
    chrNames = new String[chrLengths.length]; // human-readable representations of chromosomes (e.g. "X"->chr 20)
    chrOffsets = new float[chrLengths.length]; // chromosome offset from beginning of genome
    chrMarkerpos = new float[chrLengths.length]; // centromere positions, used in chromsome display
    chrLengths[0] = 112.0;
    chrLengths[1] = 114.0;
    chrLengths[2] = 95.0;
    chrLengths[3] = 84.0;
    chrLengths[4] = 92.0;
    chrLengths[5] = 75.0;
    chrLengths[6] = 74.0;
    chrLengths[7] = 82.0;
    chrLengths[8] = 79.0;
    chrLengths[9] = 82.0;
    chrLengths[10] = 104.0;
    chrLengths[11] = 66.0;
    chrLengths[12] = 80.0;
    chrLengths[13] = 69.0;
    chrLengths[14] = 74.6;
    chrLengths[15] = 72.0;
    chrLengths[16] = 58.0;
    chrLengths[17] = 59.0;
    chrLengths[18] = 57.0;
    chrLengths[19] = 79.44;
    chrOffsets[0] = chrMarkerpos[0] = 0.0;
    chrTotal = chrLengths[0];
    
    for (int i = 1; i < chrLengths.length; i++) {
        chrNames[i - 1] = str(i);
        chrOffsets[i] = chrOffsets[i - 1] + chrLengths[i - 1];
        chrTotal += chrLengths[i];
        chrMarkerpos[i] = 0.0;
    }
    
    chrNames[chrLengths.length-1] = "X";
    
    try {
        MouseMapParser mouseMapParser = new MouseMapParser();
        
        BufferedReader bufferedReader = new BufferedReader(
            new InputStreamReader(createInput("average_SNP.txt")));
                
        unitConverter = mouseMapParser.parseMouseMap(
            MouseMapType.SEX_AVERAGED_MAP,
            bufferedReader);
    } catch (IOException error) {
        error.printStackTrace();
    } catch (NullPointerException error) {
        error.printStackTrace();
    }
    
    new Thread() { // load genes in separate thread, takes a bit of time to load
        public void run() {
            try {
                genes = readGenes(new InputStreamReader(createInput("refFlat.txt")));
            } catch (IOException error) {
                error.printStackTrace();
            }
            
            genesLoaded = true;
        }
    }.start();
}

void initMenu() {
    // set up menu
    upperDefault = new UITextInput(14, 0, 200, 50, "Default upper threshold");
    upperDefault.setText("3.0");
    lowerDefault = new UITextInput(14, 0, 200, 50, "Default lower threshold");
    lowerDefault.setText("1.5");
    
    if (!ENABLE_KINECT) {
        unitSelect = new UIRadioGroup(275, drawHeight, new String[] {"Centimorgans", "Base pairs"});
    }
    
    loadcfg = new UIButton(425, drawHeight, "Load config", new UIAction() {
        public void doAction() {
            if (exiting) {
                return;
            }
            
            loadConfig();
        }
    });
    
    texts = new UIContainer();
    texts.add(lowerDefault);
    texts.add(upperDefault);
    texts.add(loadcfg);
    
    menuY = menuTargetY = 0.0;
}

void initMouseWheelListener() {
    // add scoll capability for LOD display -- new feature
    frame.addMouseWheelListener(new MouseWheelListener() {
        public void mouseWheelMoved(MouseWheelEvent e) {
            // side scroll: e.getModifiers is 1  
            if (!exiting && tabs.currentpage == 0 && mouseX > tabsXTarget && tabs.focus && tabs.active) {
                // negative = left, positive = right
                if (e.getModifiers() == 1) { // 8 means no more than 60/8 switches per second (FPS is 60)
                    float realWidth = loddisplay.cWidth;
                    
                    if (realWidth < 0.0) {
                        realWidth = (drawWidth - loddisplay.x) + loddisplay.cWidth;
                    }
                    
                    if (e.getScrollType() == MouseWheelEvent.WHEEL_UNIT_SCROLL) {
                        loddisplay.offset += map(e.getUnitsToScroll(), 0.0, realWidth, 0.0, (loddisplay.current_chr == -1) ? loddisplay.zoomFactor * chrTotal : loddisplay.zoomFactor * loddisplay.maxOffset);
                    }
                } else if (keyPressed && key == CODED && keyCode == 157) { // command key down
                    float visibleLength = (loddisplay.current_chr == -1) ? chrTotal : loddisplay.maxOffset;
                    double old = loddisplay.zoomFactor;
                    
                    if (e.getScrollType() == MouseWheelEvent.WHEEL_UNIT_SCROLL) {
                        loddisplay.zoomFactor += e.getUnitsToScroll() / 100.0;
                        
                        if (loddisplay.zoomFactor < 0.01) {
                            loddisplay.zoomFactor = loddisplay.oldzoomFactor;
                        } else if (loddisplay.zoomFactor > 1.0) {
                            loddisplay.zoomFactor = loddisplay.oldzoomFactor;
                        } else {
                            loddisplay.offset -= map(mouseX - loddisplay.x, 0.0, loddisplay.cWidth, 0.0, (float)((old * visibleLength) - (loddisplay.zoomFactor * visibleLength)));
                            loddisplay.oldzoomFactor = loddisplay.zoomFactor;
                        }
                    }
                } else if (e.getWheelRotation() < -5) { // -5 is threshold for scrolling up
                    loddisplay.allChr();
                }
            }
        }
    });
}
