class ModeDialog extends Dialog implements ActionListener {
    UIAction callback;
    
    ModeDialog(UIAction _callback) {
        super((Frame)null, "Choose mode", true);
        
        callback = _callback;
        
        setLayout(new GridLayout(2, 2));
        add(new Label("Start in Kinect mode?"));
        add(new Label(""));
        
        Button optYes = new Button("Yes");
        Button optNo = new Button("No");
        optYes.addActionListener(this);
        optNo.addActionListener(this);
        
        add(optYes);
        add(optNo);
        resize(200, 100);
    }
    
    public void actionPerformed(ActionEvent evt) {
        setVisible(false);
        dispose();
        
        if (evt.getActionCommand().equals("Yes")) {
            callback.doAction();
        } else {
        }
    }
    
    public void setVisible(boolean b) {
        if (b) {
            setLocation((getToolkit().getScreenSize().width - getWidth()) / 2, (getToolkit().getScreenSize().height - getHeight()) / 2);
        }
        
        super.setVisible(b);
    }
}
