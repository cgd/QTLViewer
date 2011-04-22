class Phenotype {
    float[] lodscores, position, chr_peaks;
    float[][] thresholds;
    Range[] bayesintrange;
    //float Aupper, Alower, Xupper, Xlower;
    int[] chromosome, chr_chrs;
    boolean useDefaults, useXDefaults;
    String name;
    Phenotype(String n) {
        name = n;
        bayesintrange = new Range[0];
        lodscores = new float[0];
        position = new float[0];
        chromosome = new int[0];
        chr_chrs = new int[0];
        chr_peaks = new float[0];
        thresholds = new float[][] { { 1.5, 3.0 } };
        //Aupper = Xupper = 3.0;
        //Alower = Xlower = 1.5;
        useDefaults = useXDefaults = true;
    }
}

class Range {
    float upper, lower;
}

class Parent_File extends ArrayList<Phenotype> {
    String name;
    boolean useModelThresholds = false;
    float[][] data;
    Parent_File(String n) {
        super();
        name = n;
    }
    
    Phenotype get(int i) {
        return (Phenotype)super.get(i);
    }
    
    boolean add(Phenotype p) {
        return super.add(p);
    }
    
    void add(int i, Phenotype p) {
        super.add(i, p);
    }
    
    void update() {
        if (! useModelThresholds) return;
        for (int i = 0; i < size(); i++) {
            Phenotype p = remove(i);
            p.thresholds = data;
            p.useDefaults = p.useXDefaults = true;
            if (data.length > 0) p.useDefaults = false;
            if (data.length > 1) p.useXDefaults = false;
            add(p);
        }
    }
}
