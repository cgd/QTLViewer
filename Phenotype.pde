/*
* Copyright (c) 2010 The Jackson Laboratory
*
* This software was developed by Matt Hibbs's Lab at The Jackson
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
* Phenotype class: stores all the data for a certain phenotype
*/
class Phenotype {
    float[] lodscores, position, chr_peaks;
    float[][] thresholds;
    Range[] bayesintrange;
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
        useDefaults = useXDefaults = true;
    }
}

class Range {
    float upper, lower;
}

/**
* Parent_File class: stores Phenotypes, represents a set of files loaded by the user
*/
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
        if (! useModelThresholds) {
            return;
        }
        
        for (int i = 0; i < size(); i++) {
            Phenotype p = remove(i);
            p.thresholds = data;
            p.useDefaults = p.useXDefaults = true;
            
            if (data.length > 0) {
                p.useDefaults = false;
            }
            
            if (data.length > 1) {
                p.useXDefaults = false;
            }
            
            add(p);
        }
    }
}
