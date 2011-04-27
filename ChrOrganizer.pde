class ChrOrganizer {
    int[] colors, layers;
    Range[] ranges;
    float[] peaks, heights, peakYs;
    Point[] uppers;
    public ChrOrganizer() {
        clear();
    }
    void add(float p, Range r, int c, float ex, float why, float h, float peaky) {
        colors = append(colors, c);
        layers = append(layers, 0);
        ranges = (Range[])append(ranges, r);
        peaks = append(peaks, p);
        Point po = new Point();
        po.setLocation(ex, why);
        uppers = (Point[])append(uppers, po);
        heights = append(heights, h);
        peakYs = append(peakYs, peaky);
    }
    void clear() {
        colors = new int[0];
        layers = new int[0];
        ranges = new Range[0];
        peaks = new float[0];
        uppers = new Point[0];
        heights = new float[0];
        peakYs = new float[0];
    }
    void organize() {
        boolean sorted = false;
        for (int i = 1; i < peaks.length; i++) {
            if (peaks[i] < peaks[i-1]) {
                float t1 = peaks[i]; Range t2 = ranges[i]; color t3 = colors[i]; Point t4 = uppers[i]; float t5 = heights[i]; float t6 = peakYs[i];
                peaks[i] = peaks[i-1]; ranges[i] = ranges[i-1]; colors[i] = colors[i-1]; uppers[i] = uppers[i-1]; heights[i] = heights[i-1]; peakYs[i] = peakYs[i-1];
                peaks[i-1] = t1; ranges[i-1] = t2; colors[i-1] = t3; uppers[i-1] = t4; heights[i-1] = t5; peakYs[i-1] = t6;
                sorted = false;
            } else sorted = true;
            if (!sorted) i = 0;
        }
        layers = new int[0];
        if (peaks.length == 0) return;
        layers = append(layers, 0);
        for (int i = 1; i < peaks.length; i++) {
            boolean canFit = false;
            for (int j = 0; j < layers.length; j++) {
                if (ranges[i].lower > ranges[j].upper || ranges[i].upper < ranges[j].lower) {
                    canFit = true;
                    for (int k = j+1; k < layers.length; k++) {
                        if (layers[k] != layers[j]) continue;
                        if (ranges[i].lower > ranges[k].upper || ranges[i].upper < ranges[k].lower)
                            canFit = true;
                        else { canFit = false; break; }
                    } if (canFit) {
                        layers = append(layers, layers[j]);
                        break;
                    }
                }
            }
            if (!canFit) layers = append(layers, max(layers)+1);
        }
    }
}
