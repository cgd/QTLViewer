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
            if (exiting) {
                return;
            }
            
            loddisplay.nextChr();
        }
    });
    MenuItem prevchr = new MenuItem("Previous Chromosome", new MenuShortcut(KeyEvent.VK_LEFT));
    prevchr.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) {
                return;
            }
            
            loddisplay.prevChr();
        }
    });
    MenuItem showall = new MenuItem("Show All", new MenuShortcut(KeyEvent.VK_BACK_SPACE));
    showall.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) {
                return;
            }
            
            loddisplay.allChr();
        }
    });
    
    viewMenu.add(menuup);
    viewMenu.add(menudown);
    viewMenu.add(new MenuItem("-"));
    viewMenu.add(nextchr);
    viewMenu.add(prevchr);
    viewMenu.add(showall);
    
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
        chrNames[i-1] = str(i);
        chrOffsets[i] = chrOffsets[i-1] + chrLengths[i-1];
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
    }
}

void initMenu() {
    // set up menu
    UITextInput upperDefault, lowerDefault;
    upperDefault = new UITextInput(14, 0, 200, 50, "Default upper threshold");
    upperDefault.setText("3.0");
    lowerDefault = new UITextInput(14, 0, 200, 50, "Default lower threshold");
    lowerDefault.setText("1.5");
    
    String[] groupNames = {"Centimorgans", "Base pairs"};
    unitSelect = new UIRadioGroup(275, height, groupNames);
    
    loadcfg = new UIButton(425, height, "Load config", new UIAction() {
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
            if (loddisplay.current_chr != -1 && !exiting && tabs.currentpage == 0 && mouseX > tabsXTarget && tabs.focus && tabs.active) {
                // negative = left, positive = right
                if (e.getModifiers() == 1 && e.getWheelRotation() < 0 && (frameCount - lastFrame) > 8) { // 8 means no more than 60/8 switches per second (FPS is 60)
                    loddisplay.prevChr();
                    lastFrame = frameCount;
                } else if (e.getModifiers() == 1 && e.getWheelRotation() > 0 && (frameCount - lastFrame) > 8) {
                    loddisplay.nextChr();
                    lastFrame = frameCount;
                } else if (e.getModifiers() == 0 && e.getWheelRotation() < -5) { // -5 is threshold for scrolling up
                    loddisplay.allChr();
                    lastFrame = frameCount;
                    return;
                }
            }
            
            if ((mouseX < tabsXTarget || loddisplay.current_chr == -1 || tabs.currentpage != 0) && e.getModifiers() == 1 && !exiting) {
                if (e.getWheelRotation() < 0) {
                  tabsXTarget = 110; // X coordinate
                } else if (e.getWheelRotation() > 0) {
                  tabsXTarget = 335;
                }
            }
            
            if (menuTargetY < 0.0 && !exiting && e.getModifiers() == 0 && e.getWheelRotation() > 5) {
                menuTargetY = 0.0;
            }
            
            // wait 1/2 second for mouse movement to cease
            if (menuTargetY > -100.0 && !exiting && e.getModifiers() == 0 && e.getWheelRotation() < -5 && (frameCount - lastFrame) > 30) {
                menuTargetY = -100.0;
            }
        }
    });
}
