class UITreeNode extends UIComponent {
    String title;
    boolean checked = false, hasChildren = false, expanded = false;
    ArrayList<Boolean> c_expanded;
    color drawcolor = 0x00;
    ArrayList<UITreeNode> items;
    
    UITreeNode(String t) {
        super();
        title = t;
        drawcolor = color(random(256), random(256), random(256));
        items = new ArrayList<UITreeNode>();
    }
    
    UITreeNode(String t, boolean c) {
        super();
        title = t;
        hasChildren = c;
        if (hasChildren) c_expanded = new ArrayList<Boolean>();
        drawcolor = color(random(256), random(256), random(256));
        items = new ArrayList<UITreeNode>();
    }
    
    void add(int i, UITreeNode o) {
        if (hasChildren) {
            c_expanded.add(i, Boolean.FALSE);
        }
        
        if (o instanceof UITreeNode) {
            UITreeNode newnode = (UITreeNode)o;
            String oldname = newnode.title;
            boolean jmp = false;
            int iter = 1;
            
            while (!jmp) { // append (num) to the name if one with that name already exists
                jmp = true;
                for (int j = 0; j < size(); j++) {
                    if (get(j).title.equalsIgnoreCase(newnode.title)) {
                        jmp = false;
                        break;
                    }
                }
                
                if (!jmp) {
                    newnode.title = oldname + "("+(iter++)+")";
                }
            }
            items.add(i, newnode);
        }
        items.add(i, o);
    }
    
    boolean add(UITreeNode o) {
        if (hasChildren) {
            c_expanded.add(Boolean.FALSE);
        }
        
        if (o instanceof UITreeNode) {
            UITreeNode newnode = (UITreeNode)o;
            String oldname = newnode.title;
            boolean jmp = false;
            int iter = 1;
            
            while (!jmp) {
                jmp = true;
                for (int i = 0; i < size(); i++) {
                    if (get(i).title.equalsIgnoreCase(newnode.title)) {
                        jmp = false;
                        break;
                    }
                }
                
                if (!jmp) {
                    newnode.title = oldname + "("+(iter++)+")";
                }
            }
            return items.add(newnode);
        }
        return items.add(o);
    }
    
    UITreeNode remove(int i) {
        if (hasChildren) {
            c_expanded.remove(i);
        }
        
        return items.remove(i);
    }
    
    UITreeNode get(int i) {
        return items.get(i);
    }
    
    Object last() {
        return items.get(size() - 1);
    }
    
    boolean is(String ot) {
        return title.equalsIgnoreCase(ot);
    }
    
    void toggleExpanded() {
        expanded = !expanded;
    }
    
    void toggleChecked() {
        checked = !checked;
    }
    
    int size() {
        return items.size();
    }
}
