int lastChr() {
    int maxChr = -1;
    
    for(int i = 0; i < parentFiles.size(); i++) {
        Parent_File parent = (Parent_File)parentFiles.get(i);
        
        for (int j = 0; j < parent.size(); j++) {
            Phenotype p = parent.get(j);
            
            if (((UITreeNode)((UITreeNode)fileTree.get(i)).get(j)).checked && p.chromosome[p.chromosome.length-1] > maxChr) {
                maxChr = p.chromosome[p.chromosome.length-1];
            }
        }
    }
    
    return maxChr;
}

void findMax(LODDisplay display) {
    maxLod = display.maxOffset = -1.0;
    
    for(int i = 0; i < parentFiles.size(); i++) {
        Parent_File parent = (Parent_File)parentFiles.get(i);
        
        for (int j = 0; j < parent.size(); j++) {
            Phenotype currentPhenotype = parent.get(j);
            
            if (((UITreeNode)((UITreeNode)fileTree.get(i)).get(j)).checked) {
                float tempmaxLod;
                
                if (display.current_chr == -1 && (tempmaxLod = max(currentPhenotype.lodscores)) > maxLod) {
                    maxLod = tempmaxLod;
                } else {
                  
                    for (int k = 0; k < currentPhenotype.lodscores.length; k++) {
                      
                        if (currentPhenotype.chromosome[k] == display.current_chr + 1) {
                          
                            if (currentPhenotype.lodscores[k] > maxLod) {
                                maxLod = currentPhenotype.lodscores[k];
                            }
                            
                            if (currentPhenotype.position[k] > display.maxOffset) {
                                display.maxOffset = currentPhenotype.position[k];
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (display.maxOffset != -1.0 && display.maxOffset < chrLengths[display.current_chr]) {
        display.maxOffset = chrLengths[display.current_chr];
    }
}

int drawLODScale(LODDisplay display, float maxLod, int tempMaxLod) {
    if (maxLod < 1.0) {
        tempMaxLod = 1;
        float y_off = map(tempMaxLod, 0.0, tempMaxLod, 0.0, display.cHeight - 50);
        text("1", display.x - 16 - textWidth("1"), (display.y + display.cHeight) - 50 - y_off + 8);
        line(display.x, (display.y + display.cHeight) - 50 - y_off, display.x - 16, (display.y + display.cHeight) - 50 - y_off);
        y_off = map(0, 0.0, tempMaxLod, 0.0, display.cHeight - 50);
        text("0", display.x - 16 - textWidth("0"), (display.y + display.cHeight) - 50 - y_off + 8);
        line(display.x, (display.y + display.cHeight) - 50 - y_off, display.x - 16, (display.y + display.cHeight) - 50 - y_off);
    } else {
        for (int i = 0; i <= 4; i++) {
            int value = round((i*tempMaxLod)/4.0);
            float y_off = map(value, 0.0, tempMaxLod, 0.0, display.cHeight - 50);
            text(str(value), display.x - 16 - textWidth(str(value)), (display.y + display.cHeight) - 50 - y_off + 8);
            line(display.x, (display.y + display.cHeight) - 50 - y_off, display.x - 16, (display.y + display.cHeight) - 50 - y_off);
        }
    }
    
    return tempMaxLod;
}

void drawThresholdLabelsX(LODDisplay display, Phenotype currentPhenotype, float endX, int tempMaxLod) {
    float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
    
    float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    if (currentPhenotype.thresholds.length > 1) {
        for (float i = endX; i < (display.x + display.cWidth) - 10; i += 20.0) {
                              
            if (currentPhenotype.thresholds[1][0] <= tempMaxLod) {
                line(i, (display.y +display. cHeight) - 50 - y_offXL, i + 10.0, (display.y + display.cHeight) - 50 - y_offXL);
            }
            
            if (currentPhenotype.thresholds[1][1] <= tempMaxLod) {
                line(i, (display.y + display.cHeight) - 50 - y_offXU, i + 10.0, (display.y + display.cHeight) - 50 - y_offXU);
            }
        }
    }
                        
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][1] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[1][1]*100)/100.0), (display.x + display.cWidth) - textWidth("a=" + (round(currentPhenotype.thresholds[1][1]*100)/100.0)), (display.y + display.cHeight) - y_offXU - 54.0);
    }
    
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][0] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[1][0]*100)/100.0), (display.x + display.cWidth) - textWidth("a=" + (round(currentPhenotype.thresholds[1][0]*100)/100.0)), (display.y + display.cHeight) - y_offXL - 54.0);
    }
    
    if (currentPhenotype.thresholds[0][1] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[0][1]*100)/100.0), endX - textWidth("a=" + (round(currentPhenotype.thresholds[0][1]*100)/100.0)), (display.y + display.cHeight) - y_offU - 54.0);
    }
    
    if (currentPhenotype.thresholds[0][0] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[0][0]*100)/100.0), endX - textWidth("a=" + (round(currentPhenotype.thresholds[0][0]*100)/100.0)), (display.y + display.cHeight) - y_offL - 54.0);
    }
}

void drawThresholdLabels(LODDisplay display, Phenotype currentPhenotype, int tempMaxLod) {
    float y_offL = map(currentPhenotype.thresholds[0][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offU = map(currentPhenotype.thresholds[0][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    int threshIndex = (currentPhenotype.thresholds.length > 1) ? 1 : 0;
    
    float y_offXL = map(currentPhenotype.thresholds[threshIndex][0], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    float y_offXU = map(currentPhenotype.thresholds[threshIndex][1], 0.0, tempMaxLod, 0.0, display.cHeight - 50);
    
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][1] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[0][1]*100)/100.0), (display.x + display.cWidth) - textWidth("a=" + (round(currentPhenotype.thresholds[0][1]*100)/100.0)), (display.y + display.cHeight) - y_offXU - 54.0);
    }
    
    if (currentPhenotype.thresholds.length > 1 && currentPhenotype.thresholds[1][0] <= tempMaxLod) {
        text("a=" + (round(currentPhenotype.thresholds[0][0]*100)/100.0), (display.x + display.cWidth) - textWidth("a=" + (round(currentPhenotype.thresholds[0][0]*100)/100.0)), (display.y + display.cHeight) - y_offXL - 54.0);
    }
}

boolean thresholdsEqual(float[][] thresholds) {
    return (thresholds[0][0] == thresholds[1][0] && thresholds[0][1] == thresholds[1][1]);
}
