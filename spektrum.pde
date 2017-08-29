import controlP5.*;
import rtlspektrum.Rtlspektrum;
import java.io.FileWriter;           // added by Dave N 24 Aug 2017

Rtlspektrum spektrumReader;
ControlP5 cp5;

int startFreq = 88000000;
int stopFreq = 108000000;
int binStep = 1000;

int scaleMin = -110;
int scaleMax = 40;

DropdownList gainDropdown;

int[] gains;

int relMode = 0;
double[] relBuffer;

double minFrequency;
double minValue;
double minScaledValue;

double maxFrequency;
double maxValue;
double maxScaledValue;

boolean minmaxDisplay = false;

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
float minMaxTextX = 10;
float minMaxTextY = 560;
//=========================

void MsgBox( String Msg, String Title ){
  // Messages 
  javax.swing.JOptionPane.showMessageDialog ( null, Msg, Title, javax.swing.JOptionPane.ERROR_MESSAGE  );
}

void setupControls() {
  int x, y;
  int width = 170;

  x = 15;
  y = 35;

  cp5 = new ControlP5(this);

  cp5.addTextfield("startFreqText")
    .setPosition(x, y)
    .setSize(width, 20)
    .setText(str(startFreq))
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Start frequency [Hz]")    
    ;

  y += 40;

  cp5.addTextfield("stopFreqText")
    .setPosition(x, y)
    .setSize(width, 20)
    .setText(str(stopFreq))
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("End frequency [Hz]")
    ;

  y += 40;

  cp5.addTextfield("binStepText")
    .setPosition(x, y)
    .setSize(width, 20)
    .setText(str(binStep))
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Bin size [Hz]")
    ;

  y += 30;

  cp5.addButton("setRange")
    .setValue(0)
    .setPosition(x, y)
    .setSize(width, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set range")
    ;

  y += 50;

  cp5.addTextfield("scaleMinText")
    .setPosition(x, y)
    .setSize((width - 10) / 2, 20)
    .setText(str(scaleMin))
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Lower")
    ;

  cp5.addTextfield("scaleMaxText")
    .setPosition((width - 10) / 2 + 24, y)
    .setSize((width - 10) / 2, 20)
    .setText(str(scaleMax))
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Upper")
    ;

  y += 30;

  cp5.addButton("setScale")
    .setValue(0)
    .setPosition(x, y)
    .setSize(width, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set scale")
    ;
    
  y += 30;
  
  cp5.addButton("autoScale")
    .setValue(0)
    .setPosition(x, y)
    .setSize(width, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Auto scale")
    ;
    
 
    
  y += 40;
  
  cp5.addToggle("offsetToggle")
     .setPosition(x, y)
     .setSize(50,10)
     .setValue(false)
     .setMode(ControlP5.SWITCH)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Offset tunning")
     ;  

  cp5.addToggle("minmaxToggle")
     .setPosition(x + 70, y)
     .setSize(50,10)
     .setValue(false)
     .setMode(ControlP5.SWITCH)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Min/Max")
     ;  

    
  y += 20;
  
  cp5.addTextlabel("label")
                    .setText("GAIN")
                    .setPosition(x, y);
  
  y += 15;
  
  gainDropdown = cp5.addDropdownList("gainDropdown")
                    .setBarHeight(20)
                    .setItemHeight(20)
                    .setPosition(x, y)
                    .setSize(width, 80);
  
  gainDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("");
  
  for (int i=0; i<gains.length; i++) {
    gainDropdown.addItem(str(gains[i]), gains[i]);
  }
  
  gainDropdown.setValue(0);
  gainDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText(str(gains[0]));
 
  y += 100;  

  cp5.addButton("toggleRelMode")
    .setValue(0)
    .setPosition(x, y)
    .setSize(width, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Relative mode");
  y += 30;  
 
  cp5.addButton("freezeDisplay")
    .setValue(0)
    .setPosition(x, y)
    .setSize(width, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Pause");
    
 y += 30;
  
  cp5.addButton("exitProgram")
    .setValue(0)
    .setPosition(x, y)
    .setSize(width, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Exit");
    
 
    println("Reached end of setupControls.");
}

public void offsetToggle(int theValue) {
  if(frameCount >1){
    if(theValue > 0){
      spektrumReader.setOffsetTunning(true);
    }else{
      spektrumReader.setOffsetTunning(false);
    }
  }
}

public void minmaxToggle(int theValue) {
  if(frameCount >1){
    if(theValue > 0){
      minmaxDisplay = true;
    }else{
      minmaxDisplay = false;
    }
  }
}

public void setRange(int theValue) {
  try{
    startFreq = parseInt(cp5.get(Textfield.class,"startFreqText").getText());
    stopFreq = parseInt(cp5.get(Textfield.class,"stopFreqText").getText());
    binStep = parseInt(cp5.get(Textfield.class,"binStepText").getText());
  }catch(Exception e){
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

public void setScale(int theValue) {
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

public void autoScale(int theValue) {
  if(frameCount >1){
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

public void toggleRelMode(int theValue) {
  if(frameCount >1){
    relMode++;
    if(relMode > 2) { relMode = 0; }
  }
}


public void gainDropdown(int theValue){
  spektrumReader.setGain(gains[theValue]);
}

void setup() {
  size(1200, 750);  // Size should be the first statement
  if (frame != null) {
    surface.setResizable(true);
  }  

    //============ Function calls added by Dave N
    makeConfig();  // create config file if it is not found.
    loadConfig();
    //============================
    
  spektrumReader = new Rtlspektrum(0);
  int status = spektrumReader.openDevice();
  
  if(status < 0){
    MsgBox("Can't open rtl-sdr device.","Spektrum");
    exit();
    return;
  }
  
  gains = spektrumReader.getGains();

  setupControls();
  relMode = 0;
   setupDone = true;
    
    println("Reached end of setup.");
}

void stop() {
  spektrumReader.stopAutoScan();
} 



void draw() {
  background(color(#222324));

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

  for (int i = 0; i < scaledBuffer.length; i++) {
    DataPoint point = scaledBuffer[i];
    if (point == null) continue;

    if (lastPoint != null) {
      graphDrawLine(lastPoint.x, (int)((lastPoint.yAvg - scaleMin) * scaleFactor), point.x, (int)((point.yAvg - scaleMin) * scaleFactor), #D5921F, 255);
      
      if(minmaxDisplay){
        graphDrawLine(lastPoint.x, (int)((lastPoint.yMin - scaleMin) * scaleFactor), point.x, (int)((point.yMin - scaleMin) * scaleFactor), #C23B22, 255);
        graphDrawLine(lastPoint.x, (int)((lastPoint.yMax - scaleMin) * scaleFactor), point.x, (int)((point.yMax - scaleMin) * scaleFactor), #03C03C, 255);
      }

    }
    
    lastPoint = point;
  }
fill(#222324);
  stroke(#D5921F);
  // rect(minMaxTextX, minMaxTextY, 180, 50); // Leave the rect out!
  
  textAlign(LEFT); 
  fill(#C23B22);
  text("Min: " + String.format("%.2f", minFrequency / 1000) + "kHz " + String.format("%.2f", minValue) + "dB", minMaxTextX +5, minMaxTextY+20);
  fill(#03C03C);
  text("Max: " + String.format("%.2f", maxFrequency / 1000) + "kHz " + String.format("%.2f", maxValue) + "dB", minMaxTextX+5, minMaxTextY+40);
 
}


void freezeDisplay() {
//================ added by DJN 26 Aug 2017
  if (frozen) {
    frozen = false;
    cp5.get(Button.class,"freezeDisplay").getCaptionLabel().setText("Pause");loop();
    println("Display unfrozen.");
  }
  else {
    frozen = true;
    cp5.get(Button.class,"freezeDisplay").getCaptionLabel().setText("Run");loop();
    noLoop();
    println("Display frozen."); 
  }
}


void exitProgram() {
//================ added by DJN 24 Aug 2017
  println("Exit program rtn."); 
//  MsgBox("Exiting program.", "Exit");
   if(setupDone)  exit();
}

void loadConfig() {
//================ Function added by DJN 24 Aug 2017

    table = loadTable(fileName, "header");
    startFreq = table.getInt(0, "startFreq");
    stopFreq = table.getInt(0, "stopFreq");
    binStep = table.getInt(0, "binStep");
    scaleMin = table.getInt(0, "scaleMin");
    scaleMax = table.getInt(0, "scaleMax");
    println("Config table " + fileName + " loaded."); 
    println("startFreq = " + startFreq + " stopFreq = " + stopFreq + " binStep = " + binStep + " scaleMin = " + scaleMin + " scaleMax = ", scaleMax);
  } 
  
void saveConfig() {
//================ Function added by DJN 24 Aug 2017

    table.setInt(0, "startFreq", startFreq);
    table.setInt(0, "stopFreq",stopFreq);
    table.setInt(0, "binStep", binStep);
    table.setInt(0, "scaleMin", scaleMin);
    table.setInt(0, "scaleMax", scaleMax);
    saveTable(table, fileName, "csv");
    println("startFreq = " + startFreq + " stopFreq = " + stopFreq + " binStep = " + binStep + " scaleMin = " + scaleMin + " scaleMax = ", scaleMax);
    println("Config table " + fileName + " saved."); 
  }
 
void makeConfig() {
//================ function added by DJN 24 Aug 2017

  FileWriter fw= null;
  File file =null;

  try {
            file=new File(fileName);
            if(file.exists()) {
              //println("File exists.");
            }
            else
            {
                // Recreate missing config file
                file.createNewFile();
                fw = new FileWriter(file);
                // Write column headers to new config file
                fw.write("startFreq,stopFreq,binStep,scaleMin,scaleMax\n");
                // Write initial default values to new config file
                fw.write(startFreq + "," + stopFreq + "," + binStep + "," + scaleMin + "," + scaleMax);
                fw.flush();
                fw.close();
                println(fileName +  " created succesfully");
              }
            
            } 
      catch (IOException e) {
            e.printStackTrace();
        }
   
  println("Reached end of makeconfig");
}
  