class UITreeNode extends ArrayList<UITreeNode> {
    String title;
    boolean checked = false, hasChildren = false, expanded = false;
    ArrayList<Boolean> c_expanded;
    color drawcolor = 0x00;
    UITreeNode(String t) {
        super();
        title = t;
        drawcolor = color(random(256), random(256), random(256));
    }
    
    UITreeNode(String t, boolean c) {
        super();
        title = t;
        hasChildren = c;
        if (hasChildren) c_expanded = new ArrayList<Boolean>();
        drawcolor = color(random(256), random(256), random(256));
    }
    
    void add(int i, UITreeNode o) {
        if (hasChildren) c_expanded.add(i, Boolean.FALSE);
        if (o instanceof UITreeNode) {
            UITreeNode newnode = (UITreeNode)o;
            String oldname = newnode.title;
            boolean jmp = false;
            int iter = 1;
            while (!jmp) {
                jmp = true;
                for (int j = 0; j < super.size(); j++)
                    if (((UITreeNode)super.get(j)).title.equalsIgnoreCase(newnode.title)) {
                        jmp = false;
                        break;
                    }
                if (!jmp) newnode.title = oldname + "("+(iter++)+")";
            }
            super.add(i, newnode);
        }
        super.add(i, o);
    }
    
    boolean add(UITreeNode o) {
        if (hasChildren) c_expanded.add(Boolean.FALSE);
        if (o instanceof UITreeNode) {
            UITreeNode newnode = (UITreeNode)o;
            String oldname = newnode.title;
            boolean jmp = false;
            int iter = 1;
            while (!jmp) {
                jmp = true;
                for (int i = 0; i < super.size(); i++)
                    if (((UITreeNode)super.get(i)).title.equalsIgnoreCase(newnode.title)) {
                        jmp = false;
                        break;
                    }
                if (!jmp) newnode.title = oldname + "("+(iter++)+")";
            }
            return super.add(newnode);
        }
        return super.add(o);
    }
    
    UITreeNode remove(int i) {
        if (hasChildren) c_expanded.remove(i);
        return super.remove(i);
    }
    
    Object last() {
        return super.get(super.size() - 1);
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
}
