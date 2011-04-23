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
            if (exiting) return;
            loadFolder();
        }
    });
    MenuItem loadConfigItem = new MenuItem("Load config...", new MenuShortcut(KeyEvent.VK_E));
    loadConfigItem.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if(exiting) return;
            loadConfig();
        }
    });
    
    fileMenu.add(openFileItem);
    fileMenu.add(openFolderItem);
    fileMenu.add(new MenuItem("-"));
    fileMenu.add(loadConfigItem);
    
    Menu viewMenu = new Menu("View");
    MenuItem menuup = new MenuItem("Show Menu", new MenuShortcut(KeyEvent.VK_UP, true));
    menuup.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            menuTargetY = -100.0;
        }
    });
    MenuItem menudown = new MenuItem("Hide Menu", new MenuShortcut(KeyEvent.VK_DOWN, true));
    menudown.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            menuTargetY = 0.0;
        }
    });
    MenuItem nextchr = new MenuItem("Next Chromosome", new MenuShortcut(KeyEvent.VK_PERIOD));
    nextchr.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            loddisplay.nextChr();
        }
    });
    MenuItem prevchr = new MenuItem("Previous Chromosome", new MenuShortcut(KeyEvent.VK_COMMA));
    prevchr.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
            loddisplay.prevChr();
        }
    });
    MenuItem showall = new MenuItem("Show All", new MenuShortcut(KeyEvent.VK_BACK_SPACE));
    showall.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
            if (exiting) return;
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
    // init chr position information, all stored as centimorgans
    chrLengths = new float[20];
    chrNames = new String[chrLengths.length]; // human-readable representations of chromosomes (e.g. "X"->chr 20)
    chrOffsets = new float[chrLengths.length]; // chromosome offset from beginning of genome
    chrMarkerpos = new float[chrLengths.length]; // marker positions, used in chromsome display
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
}

void initMenu() {
    // set up menu
    p_textinput upperDefault, lowerDefault;
    upperDefault = new p_textinput(14, 0, 200, 50, "Default upper threshold");
    upperDefault.setText("3.0");
    lowerDefault = new p_textinput(14, 0, 200, 50, "Default lower threshold");
    lowerDefault.setText("1.5");
    
    String[] groupNames = {"Centimorgans", "Base pairs"};
    unitSelect = new p_radiogroup(275, height, groupNames);
    
    loadcfg = new p_button(425, height, "Load config", new p_action() {
        public void doAction() {
            loadConfig();
        }
    });
    
    texts = new p_container();
    texts.add(lowerDefault);
    texts.add(upperDefault);
    
    menuY = menuTargetY = 0.0;
}
