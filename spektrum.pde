import controlP5.*;
import rtlspektrum.Rtlspektrum;
import java.io.FileWriter;           // added by Dave N 24 Aug 2017
import java.util.*;


Rtlspektrum spektrumReader;
ControlP5 cp5;

int startFreq = 88000000;
int stopFreq = 108000000;
int binStep = 1000;
int vertCursorFreq = 88000000;

int scaleMin = -110;
int scaleMax = 40;

ListBox deviceDropdown;
DropdownList gainDropdown;

String[] devices;
int[] gains;

int relMode = 0;

double minFrequency;
double minValue;
double minScaledValue;

double maxFrequency;
double maxValue;
double maxScaledValue;

boolean minmaxDisplay = false;
boolean sweepDisplay = false;

class DataPoint {
  public int x;
  public double yMin = 0;
  public double yMax = 0;
  public double yAvg = 0;
}

//========= added by Dave N
Table table;
String fileName = "config.csv";  // config file used to save and load program setting like frequency etc.
boolean setupDone = false;
boolean frozen = true;
boolean vertCursor = false;
float minMaxTextX = 10;
float minMaxTextY = 560;
boolean overGraph = false;
boolean mouseDragLock = false;
int lastMouseX;
color buttonColor = color(127,127,127);
boolean drawSampleToggle=false;
boolean vertCursorToggle=true;
//=========================

void MsgBox( String Msg, String Title ){
  // Messages 
  javax.swing.JOptionPane.showMessageDialog ( null, Msg, Title, javax.swing.JOptionPane.ERROR_MESSAGE  );
}

void setupStartControls(){
  int x, y;
  int width = 170;

  x = 15;
  y = 35;

  deviceDropdown = cp5.addListBox("deviceDropdown")
                  .setBarHeight(20)
                  .setItemHeight(20)
                  .setPosition(x, y)
                  .setSize(width, 80);
 
  deviceDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Select device");
  
  for (int i=0; i<devices.length; i++){
    deviceDropdown.addItem(devices[i], i);
  } 
}

void setupControls(){
  int x, y;
  int width = 170;

  x = 15;
  y = 35;

  cp5.addTextfield("startFreqText")
    .setPosition(x, y)
    .setSize(width, 20)
    .setText(str(startFreq))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Start frequency [Hz]")    
    ;

  y += 40;

  cp5.addTextfield("stopFreqText")
    .setPosition(x, y)
    .setSize(width, 20)
    .setText(str(stopFreq))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("End frequency [Hz]")
    ;

  y += 40;

  cp5.addTextfield("binStepText")
    .setPosition(x, y)
    .setSize((width - 10)/2, 20)
    .setText(str(binStep))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Bin size [Hz]")
    ;
    
  // toggle for how samples are shown - line / dots
  cp5.addToggle("drawSampleToggle")
     .setPosition((width - 10)/2 + 50,y)
     .setSize(20,20)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Line/Dots")
     ;
     
  y += 40;

  cp5.addTextfield("vertCursorFreqText")
    .setPosition(x, y)
    .setSize((width - 10)/2, 20)
    .setText(str(vertCursorFreq))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Red Cursor")  
    ;
  
  // toggle vertical sursor on or off
  cp5.addToggle("vertCursorToggle")
   .setPosition((width - 10)/2 + 50,y)
   .setSize(20,20)
   .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("On/Off")
   ;
  
  y += 30;

  cp5.addButton("setRange")
    .setValue(0)
    .setPosition(x+width/4, y)
    .setSize(width/2, 20)
    .setColorBackground(buttonColor)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set range")
    ;


  y += 50;

  cp5.addTextfield("scaleMinText")
    .setPosition(x, y)
    .setSize((width - 10) / 2, 20)
    .setText(str(scaleMin))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Lower")
    ;

  cp5.addTextfield("scaleMaxText")
    .setPosition((width - 10) / 2 + 24, y)
    .setSize((width - 10) / 2, 20)
    .setText(str(scaleMax))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Upper")
    ;

  
  y += 30;

  cp5.addButton("setScale")
    .setValue(0)
    .setPosition(x+width/4, y)
    .setSize(width/2, 20)
    .setColorBackground(buttonColor)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set scale")
    ;
    
  y += 30;
  
  cp5.addButton("autoScale")
    .setValue(0)
    .setPosition(x+width/4, y)
    .setSize(width/2, 20)
    .setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Auto scale")
    ;
    
 
    
  y += 40;
  
  cp5.addToggle("offsetToggle")
     .setPosition(x, y)
     .setSize(20,20)
     .setValue(false)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Offset tunning")
     ;  

  cp5.addToggle("minmaxToggle")
     .setPosition(x + 70, y)
     .setSize(20,20)
     .setValue(false)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Min/Max")
     ;  

  cp5.addToggle("sweepToggle")
     .setPosition(x + 140, y)
     .setSize(20,20)
     .setValue(false)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Sweep")
     ;  
    
  y += 30;
  
  cp5.addTextlabel("label")
                    .setText("GAIN")
                    .setPosition(x, y);
  
  y += 15;
  
  gainDropdown = cp5.addDropdownList("gainDropdown")
                    .setBarHeight(20)
                    .setItemHeight(20)
                    .setPosition(x, y)
                    .setSize(width, 80)
                    ;
  
  gainDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("");
  
  for (int i=0; i<gains.length; i++){
    gainDropdown.addItem(str(gains[i]), gains[i]);
  }
  
  gainDropdown.setValue(0);
  gainDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText(str(gains[0]));
 
  y += 100;  

  cp5.addButton("toggleRelMode")
    .setValue(0)
    .setPosition(x+width/4, y)
    .setSize(width/2, 20)
    .setColorBackground(buttonColor)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Relative mode")
    ;
  
  y += 30;  
 
  cp5.addButton("freezeDisplay")
    .setValue(0)
    .setPosition(x+width/4, y)
    .setSize(width/2, 20)
    .setColorBackground(buttonColor)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Pause")
    ;
        
  y += 30;
  
  cp5.addButton("exitProgram")
    .setValue(0)
    .setPosition(x+width/4, y)
    .setSize(width/2, 20)
    .setColorBackground(buttonColor)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Exit")
    ;
    
 
  println("Reached end of setupControls.");
}

public void offsetToggle(int theValue){
  if(setupDone){
    if(theValue > 0){
      spektrumReader.setOffsetTunning(true);
    }else{
      spektrumReader.setOffsetTunning(false);
    }
  }
}

public void minmaxToggle(int theValue){
  if(setupDone){
    if(theValue > 0){
      minmaxDisplay = true;
    }else{
      minmaxDisplay = false;
    }
  }
}

public void sweepToggle(int theValue){
  if(setupDone){
    if(theValue > 0){
      sweepDisplay = true;
    }else{
      sweepDisplay = false;
    }
  }
}


public void setRange(int theValue){
  try{
    startFreq = parseInt(cp5.get(Textfield.class,"startFreqText").getText());
    stopFreq = parseInt(cp5.get(Textfield.class,"stopFreqText").getText());
    binStep = parseInt(cp5.get(Textfield.class,"binStepText").getText());
    vertCursorFreq = parseInt(cp5.get(Textfield.class,"vertCursorFreqText").getText());
  }catch(Exception e){
    println("setRange exception.");
    return;
  }
  
  if(startFreq == 0 || stopFreq <= startFreq || binStep < 1) return;  
  
  //============ added by Dave N 24 Aug 2017
  saveConfig();
  //============================
  
  relMode = 0;
  spektrumReader.clearFrequencyRange();
  spektrumReader.setFrequencyRange(startFreq, stopFreq, binStep);
  spektrumReader.startAutoScan();
}

public void setScale(int theValue){
  try{
    scaleMin = parseInt(cp5.get(Textfield.class,"scaleMinText").getText());
    scaleMax = parseInt(cp5.get(Textfield.class,"scaleMaxText").getText());
  }catch(Exception e){
    return;
  }
  //============ added by Dave N 24 Aug 2017
  saveConfig();
  //============================
}

public void autoScale(int theValue){
  if(setupDone){
   if(minmaxDisplay){
    scaleMin = (int)(minValue - abs((float)minValue*0.1));
    scaleMax = (int)(maxValue + abs((float)maxValue*0.1));     
   }else{
    scaleMin = (int)(minScaledValue - abs((float)minScaledValue*0.1));
    scaleMax = (int)(maxScaledValue + abs((float)maxScaledValue*0.1));
   }
   cp5.get(Textfield.class,"scaleMinText").setText(str(scaleMin));
   cp5.get(Textfield.class,"scaleMaxText").setText(str(scaleMax));
  }
}

public void toggleRelMode(int theValue){
  if(setupDone){
    relMode++;
    if(relMode > 2){ relMode = 0; }
  }
}

public void deviceDropdown(int theValue){  
  deviceDropdown.hide();
  spektrumReader = new Rtlspektrum(theValue);
  int status = spektrumReader.openDevice();
  
  //============ Function calls added by Dave N
  makeConfig();  // create config file if it is not found.
  loadConfig();
  //============================
  
  if(status < 0){
    MsgBox("Can't open rtl-sdr device.","Spektrum");
    exit();
    return;
  }
  
  gains = spektrumReader.getGains();

  setupControls();
  relMode = 0;
  
  setupDone = true;  
}

public void gainDropdown(int theValue){  
  spektrumReader.setGain(gains[theValue]);
}

void setup(){
  size(1200, 750);  // Size should be the first statement
  if (frame != null){
    surface.setResizable(true);
  }  

  devices = Rtlspektrum.getDevices();
  for (String dev : devices){
    println(dev);
  }
  
  cp5 = new ControlP5(this);
  
  setupStartControls();
  println("Reached end of setup.");
}

void stop(){
  spektrumReader.stopAutoScan();
} 

void draw(){
  background(color(#222324));
  
  if(!setupDone){    
    return;
  }

  if(relMode == 1){
    cp5.get(Button.class,"toggleRelMode").getCaptionLabel().setText("Set relative");
    spektrumReader.setRelativeMode(Rtlspektrum.RelativeModeType.RECORD);
  }else if(relMode == 2){
    cp5.get(Button.class,"toggleRelMode").getCaptionLabel().setText("Cancel relative");
    spektrumReader.setRelativeMode(Rtlspektrum.RelativeModeType.RELATIVE);
  }else{
    cp5.get(Button.class,"toggleRelMode").getCaptionLabel().setText("Relative mode");
    spektrumReader.setRelativeMode(Rtlspektrum.RelativeModeType.NONE);
  }

  double[] buffer = spektrumReader.getDbmBuffer();
  
  minValue = Double.POSITIVE_INFINITY;
  minScaledValue = Double.POSITIVE_INFINITY;
  
  maxValue = Double.NEGATIVE_INFINITY;
  maxScaledValue = Double.NEGATIVE_INFINITY;
  
  for(int i = 0;i<buffer.length;i++){
    if(minValue > buffer[i] && buffer[i] != Double.NEGATIVE_INFINITY){
      minFrequency = startFreq + i * binStep;
      minValue = buffer[i];
    }

    if(maxValue < buffer[i] && buffer[i] != Double.POSITIVE_INFINITY){
      maxFrequency = startFreq + i * binStep;
      maxValue = buffer[i];
    }
  }

  DataPoint[] scaledBuffer = scaleBufferX(buffer);
  
  for(int i = 0;i<scaledBuffer.length;i++){
      if(scaledBuffer[i] == null) continue;
      
      if(minScaledValue > scaledBuffer[i].yAvg){
        minScaledValue = scaledBuffer[i].yAvg;
      }
      
      if(maxScaledValue < scaledBuffer[i].yAvg){
        maxScaledValue = scaledBuffer[i].yAvg;
      }
  }

  drawGraphMatt(scaleMin, scaleMax, startFreq, stopFreq);  

  double scaleFactor = (double)graphHeight() / (scaleMax - scaleMin);
  DataPoint lastPoint = null;

  for (int i = 0; i < scaledBuffer.length; i++){
    DataPoint point = scaledBuffer[i];
    if (point == null) continue;

    if (lastPoint != null){
      graphDrawLine(lastPoint.x, (int)((lastPoint.yAvg - scaleMin) * scaleFactor), point.x, (int)((point.yAvg - scaleMin) * scaleFactor), #fcf400, 255);
      
      if(minmaxDisplay){
        graphDrawLine(lastPoint.x, (int)((lastPoint.yMin - scaleMin) * scaleFactor), point.x, (int)((point.yMin - scaleMin) * scaleFactor), #C23B22, 255);
        graphDrawLine(lastPoint.x, (int)((lastPoint.yMax - scaleMin) * scaleFactor), point.x, (int)((point.yMax - scaleMin) * scaleFactor), #03C03C, 255);
      }
    }
    
    lastPoint = point;
  }
  fill(#222324);
  stroke(#D5921F);
  
  textAlign(LEFT); 
  fill(#C23B22);
  text("Min: " + String.format("%.2f", minFrequency / 1000) + "kHz " + String.format("%.2f", minValue) + "dB", minMaxTextX +5, minMaxTextY+20);
  fill(#03C03C);
  text("Max: " + String.format("%.2f", maxFrequency / 1000) + "kHz " + String.format("%.2f", maxValue) + "dB", minMaxTextX+5, minMaxTextY+40);
 
  if(vertCursorToggle){
    setVertCursor();
    drawVertCursor();
  }
  
  if(sweepDisplay){
    int scanPos = (int)(((float)graphWidth() / (float)buffer.length) * (float)spektrumReader.getScanPos());
    sweep(scanPos, #FFFFFF, 64);
  }
}
// end of draw rtn =============================================

void freezeDisplay(){
//================ added by DJN 26 Aug 2017
  if (frozen){
    frozen = false;
    cp5.get(Button.class,"freezeDisplay").getCaptionLabel().setText("Pause");
    loop();
    println("Display unfrozen.");
  }else{
    frozen = true;
    cp5.get(Button.class,"freezeDisplay").getCaptionLabel().setText("Run");
    noLoop();
    println("Display frozen."); 
  }
}


void exitProgram(){
  //================ added by DJN 24 Aug 2017
  println("Exit program rtn."); 
  if(setupDone)  exit();
}

void loadConfig(){
  //================ Function added by DJN 24 Aug 2017
  table = loadTable(fileName, "header");
  startFreq = table.getInt(0, "startFreq");
  stopFreq = table.getInt(0, "stopFreq");
  binStep = table.getInt(0, "binStep");
  scaleMin = table.getInt(0, "scaleMin");
  scaleMax = table.getInt(0, "scaleMax");
  vertCursorFreq = table.getInt(0, "vertCursorFreq");
  println("Config table " + fileName + " loaded."); 
  println("startFreq = " + startFreq + " stopFreq = " + stopFreq + " binStep = " + binStep + " scaleMin = " + scaleMin + " scaleMax = ", scaleMax + " vertCusorFreq = " + vertCursorFreq);
} 
  
void saveConfig(){
  //================ Function added by DJN 24 Aug 2017
  // Note: saveTable fails if file is being backed up at time saveTable is run! 
  
  table.setInt(0, "startFreq", startFreq);
  table.setInt(0, "stopFreq",stopFreq);
  table.setInt(0, "binStep", binStep);
  table.setInt(0, "scaleMin", scaleMin);
  table.setInt(0, "scaleMax", scaleMax);
  table.setInt(0, "vertCursorFreq",vertCursorFreq);
  saveTable(table, fileName, "csv");
  //println("startFreq = " + startFreq + " stopFreq = " + stopFreq + " binStep = " + binStep + " scaleMin = " + scaleMin + " scaleMax = ", scaleMax + " vertCusorFreq = " + vertCursorFreq);
  println("Config table " + fileName + " saved.");
}
 
void makeConfig(){
  //================ function added by DJN 24 Aug 2017
  FileWriter fw= null;
  File file =null;
  
  println("File " + dataPath(fileName));

  try {
    file=new File(dataPath(fileName));
    if(file.exists()){
      println("File " + dataPath(fileName) + " exists.");
    }else{
      // Recreate missing config file
      file.createNewFile();
      fw = new FileWriter(file);
      // Write column headers to new config file
      fw.write("startFreq,stopFreq,binStep,scaleMin,scaleMax,vertCursorFreq\n");
      // Write initial default values to new config file
      fw.write(startFreq + "," + stopFreq + "," + binStep + "," + scaleMin + "," + scaleMax + "," + vertCursorFreq);
      fw.flush();
      fw.close();
      println(dataPath(fileName) +  " created succesfully");
    }
  } 
  catch(IOException e){
      e.printStackTrace();
  }
 
  println("Reached end of makeconfig");
}
  
void setVertCursor(){
  // draw a vertical cursor line on the graph ================================
  if (vertCursorFreq < startFreq ){
    vertCursorFreq = startFreq;
    updateVertCursorText();
  }else if(vertCursorFreq > stopFreq){
    vertCursorFreq = stopFreq;
    updateVertCursorText();  
  }
      
  if(mouseDragLock){
    updateVertCursorText();
  }
}
//==============================================
void updateVertCursorText (){
  cp5.get(Textfield.class,"vertCursorFreqText").setText(str(vertCursorFreq));
}

//==============================================
void drawVertCursor(){  
  float xBand = (stopFreq - startFreq); 
  float xCur = (vertCursorFreq - startFreq);
  float xPlot = (xCur/xBand)* (graphWidth() + 230 - graphX());  // adjust cursor scale here!
  stroke(#FF0000);
  fill(#FF0000);
  line(graphX()+ xPlot, graphY(), graphX()+ xPlot, graphY()+graphHeight());
  //println("Bandwidth=" + xBand+ " cursor freq=" + vertCursorFreq +  " xCur=" + xCur + " Cursor =" + xPlot);
  textAlign(CENTER);
  text(numToStr(vertCursorFreq)  + " Hz", graphX() + xPlot, graphY()  - 10);
}

// ====================================================================

String numToStr(int inNum){
  // Convert number to string with commas  
  String outStr = nfc(inNum);
  return outStr;
} 
  
//============== Move the red vertical cursor===============================================  

void mousePressed(){
  // Test if the mouse over graph
  int thisMouseX = mouseX;
  if (thisMouseX >= graphX() && thisMouseX <= graphWidth() + graphX() +1){ //<>//
    mouseDragLock = true; 
    int clickFreq = startFreq + hzPerPixel() * (thisMouseX - graphX());
    vertCursorFreq = clickFreq;
    lastMouseX = mouseX;
    //println("clickFreq = " + clickFreq);  
  }
}

void mouseDragged(){
  if(mouseDragLock){
    int thisMouseX = mouseX;
    vertCursorFreq = vertCursorFreq + (thisMouseX - lastMouseX) * hzPerPixel();
    vertCursorFreq = round(vertCursorFreq/binStep) * binStep; // only allow frequency of multiples of binStep
    lastMouseX = thisMouseX;
  }
}

void mouseReleased(){
  mouseDragLock = false;
  lastMouseX = 0;
}