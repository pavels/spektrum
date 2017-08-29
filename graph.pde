int graphWidth() {
  return width - 255;
}

int graphX() {
  return 230;
}

int graphHeight() {
  return height - 50;
}

int graphY() {
  return 25;
}

void graphDrawLine(int x1, int y1, int x2, int y2, int lineColor, float alpha) {
// this rtn draws the frequency trace on the screen ===========
  stroke(lineColor, alpha);
  line(x1 + graphX(), graphHeight() - y1 + graphY(), x2 + graphX(), graphHeight() - y2 + graphY());
}

void drawGraphMatt(double minValue, double maxValue, int minFreq, int maxFreq) {
// This rtn draws the grid on the screen ======================
  int pixelSpacing = 50;

  int verticals = (graphWidth() / pixelSpacing  / 5) * 5; 
  int horizontals = (graphHeight() / pixelSpacing / 5) * 5;

  verticals = verticals == 0 ? 1 : verticals;
  horizontals = horizontals == 0 ? 1 : horizontals;

  float verticalSpacing = graphWidth() / (float)verticals;
  float horizontalSpacing = graphHeight() / (float)horizontals;

  double xStep = (maxFreq - minFreq) / verticals / 10000.0;
  double xPos = minFreq / 10000.0;

  double yStep = (maxValue - minValue) / horizontals;
  double yPos = maxValue;

  stroke(#A7A7A7);
  fill(#A7A7A7);

  for (int i = 0; i<=verticals; i++) {
    line(graphX() + i * verticalSpacing, graphY(), graphX() + i * verticalSpacing, graphY() + graphHeight());
    textAlign(CENTER); 
    text(round((float)xPos) / 100.0 + "", graphX() + i * verticalSpacing, graphY() + graphHeight() + 20);
    xPos += xStep;
  }

  for (int i = 0; i<=horizontals; i++) {
    line(graphX(), graphY() + i * horizontalSpacing, graphX() + graphWidth(), graphY() + i * horizontalSpacing);
    textAlign(RIGHT); 
    text(round((float)yPos) + "", graphX() - 5, graphY() + i * horizontalSpacing + 4);
    yPos -= yStep;
  }  

}