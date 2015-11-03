DataPoint[] reduceBuffer(double[] buffer, int length) {
  DataPoint[] ret = new DataPoint[length];
  float step = (float)length / (float)buffer.length;

  int oldIndex = 0;
  float position = 0;

  double minValue = Double.POSITIVE_INFINITY;
  double maxValue = Double.NEGATIVE_INFINITY;
  int count = 0;
  double sum = 0;

  int sourcePos = 0;

  while (position < length) {
    if (oldIndex != (int)position) {
      DataPoint dp = new DataPoint();
      dp.x = (int)position - 1;
      dp.yMin = minValue;
      dp.yMax = maxValue;
      dp.yAvg = (double)sum / (double)count;
      ret[oldIndex] = dp;

      sum = 0;
      count = 0;
      minValue = Double.POSITIVE_INFINITY;
      maxValue = Double.NEGATIVE_INFINITY;

      oldIndex = (int)position;
      continue;
    }

    if (sourcePos < buffer.length) {
      if (buffer[sourcePos] < minValue && buffer[sourcePos] != Double.NEGATIVE_INFINITY) { 
        minValue = buffer[sourcePos];
      }
      if (buffer[sourcePos] > maxValue) { 
        maxValue = buffer[sourcePos];
      }

      if (buffer[sourcePos] > Double.NEGATIVE_INFINITY  && buffer[sourcePos] != Double.POSITIVE_INFINITY) {
        sum += buffer[sourcePos];
        count++;
      }
    }
    position += step;
    sourcePos++;
  }

  return ret;
}

DataPoint[] scaleBufferX(double[] buffer) {
  double[] xscale = new double[graphWidth()];
  DataPoint[] ret;
  
  if(buffer == null) return new DataPoint[0];

  if (graphWidth() < buffer.length) {
    ret = reduceBuffer(buffer, graphWidth());
  } else {
    ret = new DataPoint[buffer.length];
    float step = graphWidth() / (float)buffer.length;

    for (int i = 0; i < buffer.length; i++) {
      DataPoint dp = new DataPoint();
      dp.x = (int)((float)i * step);
      dp.yMin = buffer[i];
      dp.yMax = buffer[i];
      dp.yAvg = buffer[i];
      ret[i] = dp;
    }
  }

  return ret;
}