import controlP5.*;
import rtlspektrum.Rtlspektrum;
import java.io.FileWriter;           // added by Dave N 24 Aug 2017
import java.util.*;

// The spektrum:: the SV mods -- SV1SGK and SV8ARJ UI improvements.
// 
// GRGNCK version 0.5-grg
// GRGNCK version 0.6-nck
// GRGNCK version 0.7-nck
// GRGNCK version 0.8-nck
// GRGNCK version 0.9-grg
// GRGNCK version 0.10-grg
// GRGNCK version 0.11-grg
// GRGNCK version 0.12-grg
// GRGNCK version 0.13-grg
// GRGNCK version 0.14-grg
//
// Changelog : 
/*
v0.9
    Added: 2 Cursors for Frequency axis.
    Added: 2 Cursors for Amplitude axis.
    Added: Absolute and differential measurements with cursors.
    Added: Zoom functionality of the cursors's defined area (gain + frequency).
    Added: Mouse Wheel Frequency limits adjustment on graph (Top area for upper, low area for lower).
    Added: Mouse Wheel Gain limits adjustment on graph (left area for lower frequency, right for upper).
    Added: View/settings store/recall (elementary "back" operation, nice for quick zoomed in graph inspection).
    Added: Left click positions primary cursors.
    Added: Left Double Click positions primary cursors and moves secondary out of the way.
    Added: Right Double Click zooms area defined by cursors (Amplitude + frequency).
    Added: Right mouse Click and Drag on a cursor moves the cursor.
    Added: Middle (mouse wheel) Double Click resets full scale for Amplitude and Frequency.
    Added: Middle (mouse wheel) Click and Drag, moves the graph recalculating limits accordingly.
    Added: Reset buttons to Min/Max range next to Start and Stop frequency text boxes.
    Modified: Cursors on/off now operate on all 4 cursors.
    Added: ZOOM and BACK buttons.
    Added: Display of frequency, Amplitude and differences for all cursors.
    Modified: Button layout.
    Fixed: Save/Reload settings on exit/start. IMPORTANT : delete the "data" folder from the installation location if you have it.
v0.10
    Added: Mouse wheel in the centrer of the graph performs symetric zoom in/out
v0.11
    Modified: Mouse behavior to (LMB=Left Mouse Button, RMB=Right, etc etc ):  
    - _LMB Click_ : Nothing
    - _LMB Drag_ on cursor: Move cursor
    - _LMB Double Click_ : Zoom to selected area
    - _RMB Click_ : position primary cursors to pointer
    - _RMB Double Click_ : position primary pointers to mouse and send to edges secondary cursors
    - _RMB Drag_ : define area with all cursors
    - _MWheel Click_ : Nothing
    - _MWheel Double Click_ : Full scales reset to max
    - _MWHeel Drag_ : Move graph refedining min/max frequency and amplitude
    - _MWHeel Up/Down_ : On Four edges of graph adjusts corresponding value (min/max freq or db)
    - _MWHeel Up/Down_ : On middle of graph area zooms in/out the graph by symetrically changing all four limits
    - Added: Mouse Wheel zoom is pre-shown by rectangle on graph.
    - Added: Fill or Line for graph.
v0.12
    - Added: VSWR calculation for the antenna tunning guys.
    - Added: Reference graph (Save a graph in memory and have on screen for comparisons).
v0.13
	- Fixed: double click in controls area was doing the zoom operation.
    - Added: Min Freq, Max Freq, rfGain, ifOffset ifType in config
	- Added: Averaging system based on video refresh rate.
v0.14
	- Fixed: Limited cursor movement
	- UI re-arranged
    - Added: Min/Max/Med persistant display
*/


Rtlspektrum spektrumReader;
ControlP5 cp5;
DataPoint[] scaledBuffer;

boolean startingupBypassSaveConfiguration = true;

int reloadConfigurationAfterStartUp = 0;// This will be set at the end of the startup
int CONFIG_RELOAD_DELAY = 0;  // 0 is disabled

interface  CURSORS {
  int
  CUR_NONE      = 0,
  CUR_X_LEFT    = 1,
  CUR_X_RIGHT   = 2,
  CUR_Y_TOP     = 3,
  CUR_Y_BOTTOM  = 4;
}

int movingCursor = CURSORS.CUR_NONE;


final int ITEM_GAIN = 1;
final int ITEM_FREQUENCY = 2;
final int ITEM_ZOOM = 3;

int timeToSet = 1;  // GRGNICK add
int itemToSet = 0;  // GRGNICK add -- 1 is Gain, 2 is Frequency
int infoText1X = 0;
int infoText1Y = 0;
int infoColor = #00FF3F;
int infoLineX = 0;
int infoLineY = 0;
int infoRectangle[] = {0,0,0,0};
String infoText = "";


int zoomBackFreqMin = 0;
int zoomBackFreqMax = 0;
int zoomBackScalMin = 0;
int zoomBackScalMax = 0;

int fullRangeMin = 24000000;
int fullRangeMax = 1800000000;
int fullScaleMin = -110;
int fullScaleMax = 40;
  
int startFreq = 88000000;
int stopFreq = 108000000;
int binStep = 1000;
int binStepProtection = 200;
int vertCursorFreq = 88000000;
int tmpFreq = 0;
int rfGain = 0;
int ifOffset = 0;
int ifType = 0;


int scaleMin = -110;
int scaleMax = 40;

int uiNextLineIndex = 0;
int[] uiLines = new int[10];

final int GRAPH_DRAG_NONE = 0;
final int GRAPH_DRAG_STARTED = 1;
final int GRAPH_DRAG_ENDED = 0;
int mouseDragGraph = GRAPH_DRAG_NONE;

int dragGraphStartX;
int dragGraphStartY;
  
int cursorVerticalLeftX = -1;//graphX();
int cursorVerticalRightX = -1;//(graphX() + graphWidth())*hzPerPixel();
int cursorHorizontalTopY = -1;//graphY();
int cursorHorizontalBottomY = -1;//graphY() + graphHeight();

int cursorVerticalLeftX_Color = #3399ff;  // Cyan
int cursorHorizontalBottomY_Color = #3399ff;

int cursorVerticalRightX_Color = #ff80d5; // Magenta
int cursorHorizontalTopY_Color = #ff80d5;

int cursorDeltaColor = #00E010;
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
float minMaxTextY = 660;

int deltaLabelsX;
int deltaLabelsY;
int deltaLabelsXWaiting;
int deltaLabelsYWaiting;

boolean overGraph = false;
boolean mouseDragLock = false;
int startDraggingThr = 5;
int lastMouseX;
color buttonColor = color(70,70,70);
color buttonColorText = color(255,255,230);
color setButtonColor = color(127,0,0);
color clickMeButtonColor = color(20,200,20); 
boolean drawSampleToggle=false;
boolean vertCursorToggle=true;
boolean drawFill=false;

// Reference
//
boolean refShow = false;	// If the reference graph is shown on screen
boolean refStoreFlag = false; // Used to flag a save in draw()
DataPoint[] refArray ; // Storage of reference graph
boolean refArrayHasData = false;

// Average
//
DataPoint[] avgArray ; // Storage of reference graph
boolean avgShow = false;
boolean avgArrayHasData = false;
int avgDepth = 10;
int avgNewSampleWeight = 1;
boolean avgSamples = false; 

// Persistant
//
DataPoint[] perArray ; // Storage of Minimum and Maximum persiastant data graph
boolean perShowMax = false;
boolean perShowMin = false;
boolean perShowMed = false;
boolean perArrayHasData = false;


int lastScanPosition = 0;
int scanPosition = 0;
int completeCycles = 0;	// How many times the scanner has finished the defined range


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
  
  scaledBuffer =  new DataPoint[0];
}

void setupControls(){
  int x, y;
  int width = 170;

  x = 15;
  y = 35;

 
  cp5.addTextfield("startFreqText")
    .setPosition(x, y)
    .setSize(width-50, 20)
    .setText(str(startFreq))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Start frequency [Hz]")    
    ;
    
  
  cp5.addButton("resetMin")
    //.setValue(0)
    .setPosition(width-30, y)
    .setSize(40, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("|<< RST")
    ;
 

  // --------------------------------------------------------------------
  //  
  y += 40;

  cp5.addTextfield("stopFreqText")
    .setPosition(x, y)
    .setSize(width-50, 20)
    .setText(str(stopFreq))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("End frequency [Hz]")
    ;
     
 cp5.addButton("resetMax")
    //.setValue(0)
    .setPosition(width-30, y)
    .setSize(40, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("RST >>|")
    ;
    


  // --------------------------------------------------------------------
  //  
  y += 40;
  
  cp5.addTextfield("binStepText")
    .setPosition(x, y)
    .setSize(60, 20)
    .setText(str(binStep))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Bin size [Hz]")
    ;
    
  
  cp5.addButton("setRange")
    .setValue(0)
    .setPosition(100, y)
    .setSize(width/2, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set range")
    ;
    
  uiLines[uiNextLineIndex++] = y;
  	
  

  // --------------------------------------------------------------------
  //  
  y += 50;

  cp5.addTextfield("scaleMinText")
    .setPosition(x, y)
    .setSize(25, 20)
    .setText(str(scaleMin))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Lower")
    ;

  cp5.addTextfield("scaleMaxText")
    .setPosition(20 + 30, y)
    .setSize(25, 20)
    .setText(str(scaleMax))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Upper")
    ;



  cp5.addButton("setScale")
    //.setValue(0)
    .setPosition(100, y)
    .setSize(width/2, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set scale")
    ;
  
  // --------------------------------------------------------------------
  //  
  y += 40;
  
  cp5.addButton("autoScale")
    //.setValue(0)
    .setPosition(x, y)
    .setSize(80, 20)
	.setColorLabel(buttonColorText)
    .setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Auto scale")
    ;
    
  cp5.addButton("resetScale")
    //.setValue(0)
    .setPosition(x+90, y)
    .setSize(80, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Reset scale")
    ;
    
  uiLines[uiNextLineIndex++] = y;
 
  // --------------------------------------------------------------------
  //  
  y += 50;
  
  // toggle vertical sursor on or off
  cp5.addToggle("vertCursorToggle")
   .setPosition(x, y)
   .setSize(20,20)
   .getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Cursors")
   ;
   
    // toggle for how samples are shown - line / dots
  cp5.addToggle("drawSampleToggle")
     .setPosition(x + 70, y)
     .setSize(20,20)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Line/Dots")
     ;
	 
  // toggle for how samples are shown - line / dots
  cp5.addToggle("drawFill")
     .setPosition(x + 140, y)
     .setSize(20,20)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Filled Graph")
     ; 

  // --------------------------------------------------------------------
  //  
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

   uiLines[uiNextLineIndex++] = y;
	 
  // --------------------------------------------------------------------
  //  
  y += 35;
  
  cp5.addTextlabel("label")
	.setText("GAIN")
	.setPosition(x, y)
	.setSize(20,20);

  // --------------------------------------------------------------------
  //  
  y += 15;
  
  gainDropdown = cp5.addDropdownList("gainDropdown")
                    .setBarHeight(20)
                    .setItemHeight(20)
                    .setPosition(x, y)
                    .setSize(40, 60)
                    ;
  
  gainDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("");
  
  for (int i=0; i<gains.length; i++){
    gainDropdown.addItem(str(gains[i]), gains[i]);
  }
  
  //gainDropdown.setValue(0);
  gainDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText(str(gains[0]));
 
 
 
   cp5.addToggle("refShow")
     .setPosition(x + 60, y)
     .setSize(20,20)
     .setValue(false)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Show reference")
     ;
 
   cp5.addButton("refSave")
    .setPosition(x+width/2+5, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Save Reference")
    ;
	
	// ---------------------------
	
	cp5.addToggle("avgShow")
     .setPosition(x + 60, y+40)
     .setSize(20,20)
     .setValue(false)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Video Average")
     ;
	
 	cp5.addToggle("avgSamples")
     .setPosition(x + 90, y+40)
     .setSize(20,20)
     .setValue(false)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("+")
     ;
 
	cp5.addTextfield("avgDepthTxt")
    .setSize(30, 20)
	.setPosition(x + 130, y+40)
    .setText(str(avgDepth))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Depth")
    ;
	
	
	
	
	
	// --------------------------------------------------------------------
    //  
    y += 30;  
	
	cp5.addToggle("perShowMaxToggle")
     .setPosition(x + 30, y+50)
     .setSize(20,20)
     .setValue(false)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Persistance")
     ;
	
	cp5.addToggle("perShowMedToggle")
     .setPosition(x + 60, y+50)
     .setSize(20,20)
     .setValue(false)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("")
     ;
	

	
 	cp5.addToggle("perShowMinToggle")
     .setPosition(x + 90, y+50)
     .setSize(20,20)
     .setValue(false)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("+");
	
	cp5.addButton("perReset")
    .setPosition(x + 130, y+50)
    .setSize(40, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("RESET")
    ;
		
	uiLines[uiNextLineIndex++] = y + 50;
	
		
  // --------------------------------------------------------------------
  //  
  y += 100;  
  
  cp5.addButton("zoomBack")
    .setPosition(x+width/2+5, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Back")
    ;
  
  cp5.addButton("zoomIn")
    .setPosition(x, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Zoom")
    ;


  // --------------------------------------------------------------------
  //  
  y += 30;
  
  cp5.addButton("toggleRelMode")
    //.setValue(0)
    .setPosition(x, y)                //.setPosition(x+width/4, y)
    .setSize(width, 20)               //.setSize(width/2, 20)
    .setColorBackground(#700000)  //.setColorBackground(buttonColor)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Relative mode")
    ;
  
  // --------------------------------------------------------------------
  //  
  y += 30;  
 
  cp5.addButton("freezeDisplay")
    //.setValue(0)
    .setPosition(x, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Pause")
    ;
  
  cp5.addButton("exitProgram")
    //.setValue(0)
    .setPosition(x+width/2+5, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
	.setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Exit")
    ;
   

  uiLines[uiNextLineIndex++] = 0;   
    
  // Keep the down left position for the Delta label
  deltaLabelsYWaiting = y + 60;
  deltaLabelsXWaiting = x + 10;
  // Use it now
  deltaLabelsY = deltaLabelsYWaiting;
  deltaLabelsX = deltaLabelsXWaiting;
  
  // Min/Max labels position (Down left)
  minMaxTextY = height-50;
 
  println("Reached end of setupControls.");
  
  startingupBypassSaveConfiguration = false;//Ready laoding... now you are able to save..
  
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

public void perShowMaxToggle(int theValue){
  if(setupDone){
    if(theValue > 0){
      perShowMax = true;
    }else{
      perShowMax = false;
    }
  }
}

public void perShowMinToggle(int theValue){
  if(setupDone){
    if(theValue > 0){
      perShowMin = true;
    }else{
      perShowMin = false;
    }
  }
}

public void perShowMedToggle(int theValue){
  if(setupDone){
    if(theValue > 0){
      perShowMed = true;
    }else{
      perShowMed = false;
    }
  }
}

public void setRange(int theValue){
  
  // Button color indicating change
  cp5.get(Button.class,"setRange").setColorBackground( buttonColor );
  
  cursorVerticalLeftX = -1;
  cursorVerticalRightX = -1;
  
  try{
    startFreq = parseInt(cp5.get(Textfield.class,"startFreqText").getText());
    stopFreq = parseInt(cp5.get(Textfield.class,"stopFreqText").getText());
    binStep = parseInt(cp5.get(Textfield.class,"binStepText").getText());
    //RED-C-REM  vertCursorFreq = parseInt(cp5.get(Textfield.class,"vertCursorFreqText").getText());
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
  
  // Button color indicating change
  cp5.get(Button.class,"setScale").setColorBackground( buttonColor );
    
  cursorHorizontalTopY = -1;
  cursorHorizontalBottomY = -1;
  
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


public void resetScale(int theValue){

  // Button color indicating change
  //cp5.get(Button.class,"setScale").setColorBackground( clickMeButtonColor );
  
  scaleMin = fullScaleMin;
  scaleMax = fullScaleMax;
  cp5.get(Textfield.class,"scaleMinText").setText(str(scaleMin));
  cp5.get(Textfield.class,"scaleMaxText").setText(str(scaleMax));
  
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

void refSave(  ){
	println("Flaging for graph storage");
	refStoreFlag = true;
}

void perReset(  ){
	perArrayHasData = false;
}
	


// On set scale (V or H) fix the cursors involved so the primaries are always on the lower side (swap them is needed).
void swapCursors(){
  int tmpInt;
  
  if (cursorVerticalLeftX > cursorVerticalRightX){
    tmpInt = cursorVerticalLeftX;
    cursorVerticalLeftX = cursorVerticalRightX;
    cursorVerticalRightX = tmpInt;
  }
  
  if (cursorHorizontalTopY > cursorHorizontalBottomY){
    tmpInt = cursorHorizontalTopY;
    cursorHorizontalTopY = cursorHorizontalBottomY;
    cursorHorizontalBottomY = tmpInt;
  }
  
}

void zoomBack(){

  swapCursors();//Fix order
  
  cp5.get(Textfield.class,"startFreqText").setText( str(zoomBackFreqMin) );
  cp5.get(Textfield.class,"stopFreqText").setText( str(zoomBackFreqMax) );
  cp5.get(Textfield.class,"scaleMinText").setText( str(zoomBackScalMin) );
  cp5.get(Textfield.class,"scaleMaxText").setText( str(zoomBackScalMax) );
  
  zoomBackFreqMin = startFreq;
  zoomBackFreqMax = stopFreq;
  zoomBackScalMin = scaleMin;
  zoomBackScalMax = scaleMax;
  
  setScale(1);
  setRange(1);
}

void zoomIn(){
  
  swapCursors();//Fix order
  
  zoomBackFreqMin = startFreq;
  zoomBackFreqMax = stopFreq;
  zoomBackScalMin = scaleMin;
  zoomBackScalMax = scaleMax;
  
  cp5.get(Textfield.class,"startFreqText").setText( str(startFreq + hzPerPixel() * (cursorVerticalLeftX - graphX())) );
  cp5.get(Textfield.class,"stopFreqText").setText( str(startFreq + hzPerPixel() * (cursorVerticalRightX - graphX())) );
  cp5.get(Textfield.class,"scaleMinText").setText( str(scaleMax - ( ( (cursorHorizontalBottomY - graphY()) * gainPerPixel() ) / 1000 )) );
  cp5.get(Textfield.class,"scaleMaxText").setText( str(scaleMax - ( ( (cursorHorizontalTopY - graphY()) * gainPerPixel() ) / 1000 )) );
  
  setScale(1);
  setRange(1);
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
  
  reloadConfigurationAfterStartUp = CONFIG_RELOAD_DELAY;//Reload configuration after this time 
  
}

void stop(){
  spektrumReader.stopAutoScan();
} 

void draw(){
  background(color(#222324));
  // background(color(#220000));
  
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
  // println(buffer.length);
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
  

  
  scaledBuffer = scaleBufferX(buffer);
  
  // scaledBuffer = scaleBufferX(buffer);
  
  // Reference graph
  //
  if ( !refArrayHasData && refShow  ) { 
	refArray = new DataPoint[scaledBuffer.length]; 
	refShow = false; 
	cp5.get(Toggle.class,"refShow").setValue(0);
  }
  if ( refShow && refArray.length != scaledBuffer.length )  {
	  refStoreFlag = true;
	  refShow = false;
  }
  if ( refStoreFlag )  {	
		refArray = new DataPoint[scaledBuffer.length];
		println("STORE size: " + refArray.length );
		arrayCopy( scaledBuffer, refArray );
		refArrayHasData = true;
		refStoreFlag = false;
		refShow = true;
		cp5.get(Toggle.class,"refShow").setValue(1);
  }  
  
  // Average - 
  //
  if ( !avgArrayHasData && avgShow  ) { 
	avgArray = new DataPoint[scaledBuffer.length]; 
	//avgShow = false; 
	// cp5.get(Toggle.class,"avgShow").setValue(0);
  }
  if ( avgShow && avgArray.length != scaledBuffer.length )  {
	  avgArray = new DataPoint[scaledBuffer.length];
  }
  
  
  // Persistant data - 
  //
  if ( !perArrayHasData && (perShowMin || perShowMax || perShowMed)  ) { 
	perArray = new DataPoint[scaledBuffer.length]; 
	//avgShow = false; 
	// cp5.get(Toggle.class,"avgShow").setValue(0);
  }
  if ( (perShowMin || perShowMax || perShowMed) && perArray.length != scaledBuffer.length )  {
	  perArray = new DataPoint[scaledBuffer.length];
  }
  
  
  
  
  // Data processing per screen point
  //
  for(int i = 0;i<scaledBuffer.length;i++){
      if(scaledBuffer[i] == null) continue;
      
      if(minScaledValue > scaledBuffer[i].yAvg){
        minScaledValue = scaledBuffer[i].yAvg;
      }
      
      if(maxScaledValue < scaledBuffer[i].yAvg){
        maxScaledValue = scaledBuffer[i].yAvg;
      }
	  
//	 if ( !avgArrayHasData ) {	// Initialize array
//		println("STORING Average");
//		scaledBuffer[i].avgY = scaledBuffer[i].yAvg; // * avgDepth;
//		avgArrayHasData = true;					
//	}
//	else
//	{
//		
//	}
//	  
  }
  

  drawGraphMatt(scaleMin, scaleMax, startFreq, stopFreq);  

  double scaleFactor = (double)graphHeight() / (scaleMax - scaleMin);
  DataPoint lastPoint = null;
  DataPoint refLastPoint = null;
  DataPoint avgLastPoint = null;
  DataPoint perLastPoint = null;
  
	DataPoint point = null;
	DataPoint refPoint = null;
	DataPoint avgPoint = null;
	DataPoint perPoint = null;
  
	color tmpColorGraph = color( 200,200,40 );
	color tmpColorAvg = color( 10,200,40 );
	//color tmpColorPerMax = color( 255, 0, 102 );
	//color tmpColorPerMin = color( 200, 0, 99 );
	color tmpColorPerMax = color( 180, 180, 180 );
	color tmpColorPerMin = color( 160, 160, 160 );
	color tmpColorPerMed = color( 51, 204, 255 );
	
	
  int tmpAlpha = 255;
  if (avgShow || perShowMed)  tmpAlpha = 70; else tmpAlpha = 255;
  
  // Main point per point loop
  //
  for (int i = 0; i < scaledBuffer.length; i++){
    point = scaledBuffer[i];
	refPoint = null;
	avgPoint = scaledBuffer[i];
	perPoint = scaledBuffer[i];
	
	if (refShow && refArrayHasData ) { refPoint = refArray[i]; }
	if (avgShow && avgArrayHasData ) { avgPoint = avgArray[i]; }
	if ((perShowMin || perShowMax || perShowMed ) && perArrayHasData ) { perPoint = perArray[i]; }
	
    if (point == null ) continue;
	if (avgPoint == null) avgArrayHasData = false;
	if (perPoint == null) perArrayHasData = false;
	
    if (lastPoint != null){
	
	// MAIN graph
	//
	if ( drawFill ) {
		graphDrawFill(lastPoint.x, (int)((lastPoint.yAvg - scaleMin) * scaleFactor), point.x, (int)((point.yAvg - scaleMin) * scaleFactor), #fcf400, 50);  
	}		
	
	graphDrawLine(lastPoint.x, (int)((lastPoint.yAvg - scaleMin) * scaleFactor), point.x, (int)((point.yAvg - scaleMin) * scaleFactor),tmpColorGraph , tmpAlpha);
	
	if(minmaxDisplay){
		graphDrawLine(lastPoint.x, (int)((lastPoint.yMin - scaleMin) * scaleFactor), point.x, (int)((point.yMin - scaleMin) * scaleFactor), #C23B22, 255);
		graphDrawLine(lastPoint.x, (int)((lastPoint.yMax - scaleMin) * scaleFactor), point.x, (int)((point.yMax - scaleMin) * scaleFactor), #03C03C, 255);
	}
	

	// Reference graph
	//	
	if (refShow){
		graphDrawLine(refLastPoint.x, (int)((refLastPoint.yAvg - scaleMin) * scaleFactor), refPoint.x, (int)((refPoint.yAvg - scaleMin) * scaleFactor), #1080A0, 255);
	}

	// Average graph
	//
	if (avgShow){	  
		if ( !avgArrayHasData ) {	// Initialize array
			println("STORING Average");
			avgArray = new DataPoint[scaledBuffer.length];
			arrayCopy( scaledBuffer, avgArray);
			avgArrayHasData = true;				
		}
		else	// Update and show
		{	
			if ( !avgSamples  )
			{
				avgArray[i].yAvg = avgArray[i].yAvg - (avgArray[i].yAvg / avgDepth ) +  (scaledBuffer[i].yAvg / (float)avgDepth);
			}
			else if ( completeCycles > 0) {
				avgArray[i].yAvg = avgArray[i].yAvg - (avgArray[i].yAvg / avgDepth ) +  (scaledBuffer[i].yAvg / (float)avgDepth);
				completeCycles = 0;  
				// println("UPDATED");
			}
			
			if (avgLastPoint!= null) {
				graphDrawLine(avgLastPoint.x, (int)((avgLastPoint.yAvg - scaleMin) * scaleFactor), avgPoint.x,   (int)((avgPoint.yAvg - scaleMin) * scaleFactor), tmpColorAvg, 255);
			}
		}

	}
	
	// Persistant graph
	//
	if (perShowMin || perShowMax || perShowMed){	  
		if ( !perArrayHasData ) {	// Initialize array
			println("STORING Persistant");
			perArray = new DataPoint[scaledBuffer.length];
			arrayCopy( scaledBuffer, perArray);
			for ( int jj=0; jj< scaledBuffer.length-1; jj++) {
				perArray[jj].yMax = perArray[jj].yAvg ;
				perArray[jj].yMin = perArray[jj].yAvg ;
			}
				
	//		for ( int jj=0; jj< scaledBuffer.length-1; jj++) {
	//			perArray[jj].yMax = scaledBuffer[jj].yAvg;
	//			perArray[jj].yMin = scaledBuffer[jj].yAvg;
	//		}
			perArrayHasData = true;				
		}
		else	// Update and show
		{	
			if ( scaledBuffer[i].yAvg> perArray[i].yMax ) perArray[i].yMax = scaledBuffer[i].yAvg;
			if ( scaledBuffer[i].yAvg< perArray[i].yMin ) perArray[i].yMin = scaledBuffer[i].yAvg;
			perArray[i].yAvg = perArray[i].yMin + ( perArray[i].yMax - perArray[i].yMin ) /2;
			
			
			
			if (perLastPoint!= null) {
				if (perShowMax)
					graphDrawLine(perLastPoint.x, (int)((perLastPoint.yMax - scaleMin) * scaleFactor), perPoint.x,   (int)((perPoint.yMax - scaleMin) * scaleFactor), tmpColorPerMax, 200);
				if (perShowMin)
					graphDrawLine(perLastPoint.x, (int)((perLastPoint.yMin - scaleMin) * scaleFactor), perPoint.x,   (int)((perPoint.yMin - scaleMin) * scaleFactor), tmpColorPerMin, 200);
				if (perShowMed)
					graphDrawLine(perLastPoint.x, (int)((perLastPoint.yAvg - scaleMin) * scaleFactor), perPoint.x,   (int)((perPoint.yAvg - scaleMin) * scaleFactor), tmpColorPerMed, 255);
					
			}
		}

	}	
	
	

		
   }
    
    lastPoint = point;
	refLastPoint = refPoint;
	avgLastPoint = avgPoint;
	perLastPoint = perPoint;
  }
  
  fill(#222324);
  stroke(#D5921F);
  
  
  
  
  textAlign(LEFT); 
  fill(#C23B22);
  text("Min: " + String.format("%.2f", minFrequency / 1000) + "kHz " + String.format("%.2f", minValue) + "dB", minMaxTextX +5, minMaxTextY+20);
  fill(#03C03C);
  text("Max: " + String.format("%.2f", maxFrequency / 1000) + "kHz " + String.format("%.2f", maxValue) + "dB", minMaxTextX +5, minMaxTextY+40);
 
  if(vertCursorToggle){
    setVertCursor();
    drawVertCursor();
  }
  
 
  scanPosition = spektrumReader.getScanPos();
  
  if ( lastScanPosition != scanPosition ) {
	if (scanPosition - lastScanPosition <= 0) completeCycles++;
	lastScanPosition = scanPosition ;
	// println("RECYCLE !!!" + lastScanPosition);
  
  }
  
  if(sweepDisplay){
    int scanPos = (int)(((float)graphWidth() / (float)buffer.length) * (float)scanPosition);
    sweep(scanPos, #FFFFFF, 64);
  }
  
  /*
  if (cursorVerticalLeftX >= 0) sweep( cursorVerticalLeftX - graphX(),  cursorVerticalLeftX_Color, 255);
  else cursorVerticalLeftX = graphX();
  if (cursorVerticalRightX >= 0) sweep( cursorVerticalRightX - graphX(),  cursorVerticalRightX_Color, 255);
  else cursorVerticalRightX = graphX() + graphWidth();
  if (cursorHorizontalTopY >= 0) sweepVertical( cursorHorizontalTopY - graphY(),  cursorHorizontalTopY_Color, 255);
  else cursorHorizontalTopY = graphY();
  if (cursorHorizontalBottomY >= 0) sweepVertical( cursorHorizontalBottomY - graphY(),  cursorHorizontalBottomY_Color, 255);
  else cursorHorizontalBottomY = graphY() + graphHeight();
  */
  if (cursorVerticalLeftX < 0) cursorVerticalLeftX = graphX();
  if (cursorVerticalRightX < 0) cursorVerticalRightX = graphX() + graphWidth();
  if (cursorHorizontalTopY < 0) cursorHorizontalTopY = graphY();
  if (cursorHorizontalBottomY < 0) cursorHorizontalBottomY = graphY() + graphHeight();
  
  
  // ========================= GRGNICK 
  //
  if ( timeToSet > 1 ) {  // GRGNICK add
     timeToSet--;
     
     if ( infoText1X != 0) {  // Do we need any infomative text ?
        fill( infoColor );
        textSize(40);
        text( infoText,  infoText1X, infoText1Y );
        textSize(12);
        stroke(#FFFFFF);
        if (itemToSet == ITEM_FREQUENCY)  line(infoLineX, graphY(),     infoLineX, graphY() + graphHeight());
        if (itemToSet == ITEM_GAIN)       line(graphX(), infoLineY,     graphX() + graphWidth(),infoLineY);
        if (itemToSet == ITEM_ZOOM) {     noFill(); rect( infoRectangle[0], infoRectangle[1], infoRectangle[2], infoRectangle[3] ); }
     }
     
     /*if ( infoText1X != 0) {  // Do we need any infomative text ?
        fill( infoColor );
        textSize(40);
        text( infoText,  infoText1X, infoText1Y );
        textSize(12);
     }*/
  } 
  else if ( timeToSet == 1 ) {
      timeToSet = 0;
      if (itemToSet == ITEM_FREQUENCY) setRange(1);
      if (itemToSet == ITEM_GAIN) setScale(1);
      if (itemToSet == ITEM_ZOOM) { setScale(1);     setRange(1); }
      
      infoText1X = 0;
  }
  
  
  // ==== Reload configuration after start up NOT USED for now - temporary remedy for abnormal behavior - data folder should be removed
  //
  if (reloadConfigurationAfterStartUp > 1){
    reloadConfigurationAfterStartUp--;
  }
  else if (reloadConfigurationAfterStartUp == 1){
    reloadConfigurationAfterStartUp = 0;
    loadConfig();
    setScale(1);
    setRange(1);
    println("Reload Config!");
  }
   
}
// end of draw rtn =============================================


// Average waveform check box
//
void avgShow( int value)
{
	if (value == 1) {
		avgShow = true;
		avgArrayHasData = false;
		avgDepth = max( parseInt(cp5.get(Textfield.class,"avgDepthTxt").getText()),2);
	} else {
		avgShow = false;
		avgArrayHasData = false;
	}
}



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

// GRG-NICK
public void resetMin(){
  //Set the start freq at full range
  
  cp5.get(Textfield.class,"startFreqText").setText( str(fullRangeMin) );
  
  setRange(1);
  
}


void resetMax(){
  //Set the stop freq full range
  
  cp5.get(Textfield.class,"stopFreqText").setText( str(fullRangeMax) );
  
  setRange(1);
   
}





void loadConfig(){
		
  //================ Function added by DJN 24 Aug 2017 
  table = loadTable(fileName, "header"); 
  startFreq = table.getInt(0, "startFreq");
  stopFreq = table.getInt(0, "stopFreq");
  binStep = table.getInt(0, "binStep"); 
  scaleMin = table.getInt(0, "scaleMin"); 
  scaleMax = table.getInt(0, "scaleMax"); 
  // rfGain = table.getInt(0, "rfGain");
  fullRangeMin = table.getInt(0, "minFreq"); 
  fullRangeMax = table.getInt(0, "maxFreq");
  
  //Protection 
  if (binStep < binStepProtection) binStep = binStepProtection;
   
  // Init zoom back 
  zoomBackFreqMin = startFreq; 
  zoomBackFreqMax = stopFreq;  
  zoomBackScalMin = scaleMin;  
  zoomBackScalMax = scaleMax; 
   
   
  println("Config table " + fileName + " loaded.");  
  println("startFreq = " + startFreq + " stopFreq = " + stopFreq + " binStep = " + binStep + " scaleMin = " + 
      scaleMin + " scaleMax = ", scaleMax + " rfGain = " + rfGain + " fullRangeMin = " + fullRangeMin + "  fullRangeMax = " + fullRangeMax + 
      " ifOffset = " + ifOffset + " ifType = " + ifType);

 
}   
   
void saveConfig(){ 
  //================ Function added by DJN 24 Aug 2017   
  // Note: saveTable fails if file is being backed up at time saveTable is run!   
   
  if (startingupBypassSaveConfiguration == false) {   
    table.setInt(0, "startFreq", startFreq);  
    table.setInt(0, "stopFreq",stopFreq); 
    table.setInt(0, "binStep", binStep);
    table.setInt(0, "scaleMin", scaleMin); 
    table.setInt(0, "scaleMax", scaleMax);
    table.setInt(0, "rfGain",rfGain);
	  table.setInt(0, "minFreq",fullRangeMin); 
	  table.setInt(0, "maxFreq",fullRangeMax); 
	  table.setInt(0, "ifOffset",ifOffset);
	  table.setInt(0, "ifType",ifType); 
	
    saveTable(table, fileName, "csv");  
     
    println("startFreq = " + startFreq + " stopFreq = " + stopFreq + " binStep = " + binStep + " scaleMin = " +  
      scaleMin + " scaleMax = ", scaleMax + " rfGain = " + rfGain + " fullRangeMin = " + fullRangeMin + "  fullRangeMax = " + fullRangeMax + 
      " ifOffset = " + ifOffset + " ifType = " + ifType);  
    println("Config table " + fileName + " saved.");
  } 
   
} 
   
void makeConfig(){  
  //================ function added by DJN 24 Aug 2017 
  FileWriter fw= null;
  File file =null; 
  
  println("File " + fileName);//println("File " + dataPath(fileName)); 
  
  try { 
    file=new File(fileName);//file=new File(dataPath(fileName));
	println( file.getAbsolutePath());  
  if(file.exists()){  
      println("File " + fileName + " exists.");//println("File " + dataPath(fileName) + " exists.");
    }else{ 
      // Recreate missing config file 
      file.createNewFile(); 
      fw = new FileWriter(file);
      // Write column headers to new config file  
      // Write initial default values to new config file
      // fw.write(startFreq + "," + stopFreq + "," + binStep + "," + scaleMin + "," + scaleMax + "," + rfGain + ",24000000,1800000000");
	   
      fw.write("startFreq,stopFreq,binStep,scaleMin,scaleMax,rfGain,minFreq,maxFreq,ifOffset,ifType\n"); 
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0\n"); 
       
	  fw.flush(); 
      fw.close(); 
      println(fileName +  " created succesfully");//println(dataPath(fileName) +  " created succesfully"); 
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
  //RED-C-REM  cp5.get(Textfield.class,"vertCursorFreqText").setText(str(vertCursorFreq));
}

//==============================================
void drawVertCursor(){  
  float xBand;
  float xCur;
  float xPlot; 
  xBand = (stopFreq - startFreq); 
  
  /*   Remove RED cursor
  float xBand = (stopFreq - startFreq);   
  float xCur = (vertCursorFreq - startFreq);
  float xPlot = (xCur/xBand)* (graphWidth() + 230 - graphX());  // adjust cursor scale here!
  stroke(#FF0000);
  fill(#FF0000);
  line(graphX()+ xPlot, graphY(), graphX()+ xPlot, graphY()+graphHeight());
  //println("Bandwidth=" + xBand+ " cursor freq=" + vertCursorFreq +  " xCur=" + xCur + " Cursor =" + xPlot);
  textAlign(CENTER);
  text(numToStr(vertCursorFreq)  + " Hz", graphX() + xPlot, graphY()  - 10);
  */
  
  
  
  //GRGNICK Cursors
  //
  int freqLeft;
  int freqRight;
  freqLeft = startFreq + hzPerPixel() * (cursorVerticalLeftX - graphX());
  freqRight = startFreq + hzPerPixel() * (cursorVerticalRightX - graphX());
  float scaleBottom;
  float scaleTop;
  scaleBottom = scaleMax - ( ( (cursorHorizontalBottomY - graphY()) * gainPerPixel() ) / 1000.0 );
  scaleTop = scaleMax - ( ( (cursorHorizontalTopY - graphY()) * gainPerPixel() ) / 1000.0 );
  textSize(16);
  // LEFT
  stroke(cursorVerticalLeftX_Color);
  fill(cursorVerticalLeftX_Color);
  line(cursorVerticalLeftX, graphY(), cursorVerticalLeftX, graphY()+graphHeight());
  textAlign(CENTER);
  text(numToStr(freqLeft/1000)  + " kHz", cursorVerticalLeftX-10, graphY()  - 5);
  
  // RIGHT
  stroke(cursorVerticalRightX_Color);
  fill(cursorVerticalRightX_Color);
  line(cursorVerticalRightX, graphY(), cursorVerticalRightX, graphY()+graphHeight());
  textAlign(CENTER);
  text(numToStr(freqRight/1000)  + " kHz", cursorVerticalRightX-10, graphY()  - 5);
  
  // BOTTOM
  stroke(cursorHorizontalBottomY_Color);
  fill(cursorHorizontalBottomY_Color);
  line(graphX(), cursorHorizontalBottomY, graphX()+graphWidth(), cursorHorizontalBottomY);
  textAlign(CENTER);
  text(     String.format("%.1f",scaleBottom)  + " db", graphX()+graphWidth()+20, cursorHorizontalBottomY+4);
  
  // TOP
  stroke(cursorHorizontalTopY_Color);
  fill(cursorHorizontalTopY_Color);
  line(graphX(), cursorHorizontalTopY, graphX()+graphWidth(), cursorHorizontalTopY);
  textAlign(CENTER);
  text(String.format("%.1f",scaleTop)  + " db", graphX()+graphWidth()+20, cursorHorizontalTopY+4);
  
  // DELTA  - FREQ / SCALE
  //
  float tmpVSWR = 1;
  float tmpDdb = 0;
   
  tmpDdb = abs(scaleBottom - scaleTop);
  tmpVSWR = (pow(10 , (tmpDdb / 20 )) +1 ) / ( pow( 10, (tmpDdb / 20))  - 1  ) ;
  
  textAlign(LEFT);
  fill(cursorDeltaColor);
  text("Δx : " + numToStr((freqRight - freqLeft)/1000)  + " kHz" , deltaLabelsX, deltaLabelsY ) ;
  text("Δy : " + String.format("%.1f",scaleBottom - scaleTop) + " db" , deltaLabelsX, deltaLabelsY + 20 );
  textSize(12);    
  text("VSWR: 1 : " + String.format("%.3f",tmpVSWR), deltaLabelsX, deltaLabelsY + 38 );	   
  //text("Δf " + numToStr(freqRight - freqLeft)  + " Hz", cursorVerticalLeftX+((cursorVerticalRightX-cursorVerticalLeftX)/2), graphY()  + 12);
  //text("Δs " + numToStr(scaleBottom - scaleTop)  + " db", graphX()+graphWidth()-20,    cursorHorizontalTopY+((cursorHorizontalBottomY-cursorHorizontalTopY)/2)    );
  
  textSize(12); 
  noFill(); stroke(#808080);
  rect( deltaLabelsX - 10, deltaLabelsY - 20 , 170,65);
  
  for ( uiNextLineIndex = 0; uiLines[uiNextLineIndex] != 0 ; uiNextLineIndex++ ) 
	line( 5, uiLines[uiNextLineIndex] + 30 ,  195, uiLines[uiNextLineIndex]  + 30);
  
}

// ====================================================================
 
String numToStr(int inNum){ 
  // Convert number to string with commas  
  String outStr = nfc(inNum);
  return outStr;  
}  
 
int getGraphXfromFreq( int frequency ) { 
   return max(graphX() -10, min( graphX() + graphWidth() + 10, graphX() + graphWidth()  * (frequency/1000 - startFreq/1000) / (stopFreq/1000 - startFreq/1000)));  
} 

int getGraphYfromDb( int db ) {
   return min(graphY() + graphHeight() + 10,  max( graphY() - 10, graphHeight() +graphY() - graphHeight() * (db - scaleMin) / (scaleMax - scaleMin) ));   
} 
   
//============== Move the red vertical cursor===============================================   
 
void mousePressed(MouseEvent evnt){ 
  int thisMouseX = mouseX; 
  int thisMouseY = mouseY;
   
  boolean CLICK_ABOVE; 
  boolean CLICK_LEFT; 
  boolean DOUBLE_CLICK;
   
  CLICK_ABOVE = false;  
  CLICK_LEFT = false; 
  DOUBLE_CLICK = false;
   
  // Only alow clicks in the graph
  // 
  if ( mouseX < graphX() ) return;   
  
  if (evnt.getCount() == 2) { 
	DOUBLE_CLICK = true;  
    if (mouseButton == RIGHT) { cursorVerticalRightX = graphWidth() + graphX();  cursorHorizontalTopY = graphY(); } // TAG01 RIGHT->LEFT was LEFT  
    if (mouseButton == CENTER) {resetMin();   resetMax();   resetScale(1); };
    if (mouseButton == LEFT) zoomIn() ;        // TAG01 RIGHT->LEFT was RIGHT 
      
    
    println("DOUBLE CLICK DETECTED");
    return;    // ATTENTION !!! RETURN !!!! BAD BAD HABIT. TODO properly. -GRG 
  } 
    
   
  //Protecion 
  if (thisMouseX < graphX() || thisMouseX > graphWidth() + graphX() +1) return;
  if (thisMouseY < graphY() || thisMouseY > graphHeight() + graphY() +1) return;   
   
  //Calculate center 
  if ( (thisMouseX - graphX()) < (graphWidth()/2) ){  
    CLICK_LEFT = true; 
  } 
   
  if ( (thisMouseY - graphY() < graphHeight()/2) ){  
    CLICK_ABOVE = true;  
  }
   
  
  int clickFreq = startFreq + hzPerPixel() * (thisMouseX - graphX()); 
  int clickScale;  
  clickScale = ( (thisMouseY - graphY()) * gainPerPixel() ) / 1000 ;   //      startFreq + hzPerPixel() * (thisMouseY - graphY()); 
  clickScale = scaleMax - clickScale; 
   
  if (mouseButton == RIGHT ) // TAG01 RIGHT<->LEFT was LEFT  
  { 
    // Test if the mouse over graph 
    if (thisMouseX >= graphX() && thisMouseX <= graphWidth() + graphX() +1){  
      mouseDragLock = true;  
      
      vertCursorFreq = clickFreq;  
      lastMouseX = mouseX;
      println("clickFreq = " + clickFreq);     
    }
     
     
    cursorVerticalLeftX = mouseX;  
    cursorHorizontalBottomY = mouseY; 
      
    println("clickFreq: " + clickFreq + ",   clickScale: " + clickScale);
     
     
  } 
  else if (mouseButton == CENTER){ 
    
    mouseDragGraph = GRAPH_DRAG_STARTED;
     
    dragGraphStartX = mouseX; 
    dragGraphStartY = mouseY; 
    
      
  } 
  else if (mouseButton == LEFT){  // TAG01 RIGHT->LEFT was RIGHT 
    int SELECT_THR = 20; 
    // Drag cursors  
    //
    //  TOP 
    if ( abs(mouseY-cursorHorizontalTopY) <= SELECT_THR ){ 
      println("TOP LINE");
      println("clickScale: " + clickScale); 
      cp5.get(Textfield.class,"scaleMaxText").setText(str(clickScale));
      sweepVertical( mouseY - graphY(),  #fcd420, 255);
      cursorHorizontalTopY = mouseY;
      movingCursor = CURSORS.CUR_Y_TOP; 
       
      // Button color indicating change
      cp5.get(Button.class,"setScale").setColorBackground( clickMeButtonColor );
       
    }
    //  BOTTOM 
    else if ( abs(mouseY-cursorHorizontalBottomY) <= SELECT_THR ){
      println("BOTTOM LINE");
      println("clickScale: " + clickScale);
      cp5.get(Textfield.class,"scaleMinText").setText(str(clickScale));
      sweepVertical( mouseY - graphY(),  #fcd420, 255);
      cursorHorizontalBottomY = mouseY; 
      movingCursor = CURSORS.CUR_Y_BOTTOM; 
      
      // Button color indicating change
      cp5.get(Button.class,"setScale").setColorBackground( clickMeButtonColor ); 
    }
    // LEFT 
    else if ( abs(mouseX-cursorVerticalLeftX) <= SELECT_THR ){
      println("LEFT LINE");
      println("clickFreq: " + clickFreq);
      cp5.get(Textfield.class,"startFreqText").setText(str(clickScale));
      sweep( mouseX - graphX(),  #fcd420, 255);
      cursorVerticalLeftX = mouseX;
      movingCursor = CURSORS.CUR_X_LEFT;
      
      // Button color indicating change
      cp5.get(Button.class,"setRange").setColorBackground( clickMeButtonColor );
      
    }
    // RIGHT
    else if ( abs(mouseX-cursorVerticalRightX) <= SELECT_THR ){
      println("RIGHT LINE");
      println("clickFreq: " + clickFreq);
      cp5.get(Textfield.class,"stopFreqText").setText(str(clickScale));
      sweep( mouseX - graphX(),  #fcd420, 255);
      cursorVerticalRightX = mouseX;
      movingCursor = CURSORS.CUR_X_RIGHT;
      
      // Button color indicating change
      cp5.get(Button.class,"setRange").setColorBackground( clickMeButtonColor );
    }
    
    
  }
  
}

void mouseDragged(){
  int thisMouseX = mouseX;
  int thisMouseY = mouseY;
  
  //Protecion
  if (thisMouseX < graphX() || thisMouseX > graphWidth() + graphX() +1) return;
  if (thisMouseY < graphY() || thisMouseY > graphHeight() + graphY() +1) return;
  
  // Dragging Red cursor
  if(mouseDragLock){
    /*vertCursorFreq = vertCursorFreq + (thisMouseX - lastMouseX) * hzPerPixel();
    vertCursorFreq = round(vertCursorFreq/binStep) * binStep; // only allow frequency of multiples of binStep
    lastMouseX = thisMouseX;*/
    
    if ( ( abs(cursorVerticalLeftX - mouseX) > startDraggingThr ) || ( abs(cursorHorizontalBottomY - mouseY) > startDraggingThr ) ){
      cursorVerticalRightX = mouseX;
      cursorHorizontalTopY = mouseY;
      
      deltaLabelsX = mouseX-30;
      deltaLabelsY = mouseY-29;
      
    }
    
  }
  
  
  if (movingCursor == CURSORS.CUR_X_LEFT) {
    //if (thisMouseX<cursorVerticalRightX) {
      cursorVerticalLeftX = thisMouseX;
      int clickFreq = startFreq + hzPerPixel() * (thisMouseX - graphX());
      cp5.get(Textfield.class,"startFreqText").setText( str(clickFreq) );
    //}
  }
  else if (movingCursor == CURSORS.CUR_X_RIGHT) {
    //if (thisMouseX>cursorVerticalLeftX) { 
      cursorVerticalRightX = thisMouseX;
      int clickFreq = startFreq + hzPerPixel() * (thisMouseX - graphX());
      cp5.get(Textfield.class,"stopFreqText").setText( str(clickFreq) );
    //}
  }
  else if (movingCursor == CURSORS.CUR_Y_TOP) {
    //if (thisMouseY<cursorHorizontalBottomY) {
      cursorHorizontalTopY = thisMouseY;
      int clickScale = scaleMax - ( ( (thisMouseY - graphY()) * gainPerPixel() ) / 1000 ) ;
      cp5.get(Textfield.class,"scaleMaxText").setText(str(clickScale));
    //}
  }
  else if (movingCursor == CURSORS.CUR_Y_BOTTOM) {
    //if (thisMouseY>cursorHorizontalTopY) {
      cursorHorizontalBottomY = thisMouseY;
      int clickScale = scaleMax - ( ( (thisMouseY - graphY()) * gainPerPixel() ) / 1000 ) ;
      cp5.get(Textfield.class,"scaleMinText").setText(str(clickScale));
    //}
  }
  
  if (mouseButton == RIGHT){    // TAG01 RIGHT->LEFT was LEFT
    stroke(#606060);
    line( cursorVerticalLeftX, cursorHorizontalBottomY,   mouseX, mouseY) ;
  }
  else if (mouseButton == CENTER){
    stroke(#606060);
    line( dragGraphStartX, dragGraphStartY,   mouseX, mouseY) ;
  }
  
}

void mouseReleased(){
  mouseDragLock = false;
  lastMouseX = 0;
    
  movingCursor = CURSORS.CUR_NONE;
  
  
  deltaLabelsX = deltaLabelsXWaiting;
  deltaLabelsY = deltaLabelsYWaiting;
  
  // Move graph
  if (mouseDragGraph == GRAPH_DRAG_STARTED) {
    mouseDragGraph = GRAPH_DRAG_NONE;
    
    int deltaF;
    int deltaDB;
    int freqLeft;
    int freqRight;
    freqLeft = startFreq + hzPerPixel() * (dragGraphStartX - graphX());
    freqRight = startFreq + hzPerPixel() * (mouseX - graphX());
    int scaleBottom;
    int scaleTop;
    scaleBottom = scaleMax - ( ( (dragGraphStartY - graphY()) * gainPerPixel() ) / 1000 );
    scaleTop = scaleMax - ( ( (mouseY - graphY()) * gainPerPixel() ) / 1000 );

    
    deltaF = freqRight - freqLeft ;
    deltaDB = scaleBottom - scaleTop;
    
    // Move graph up/down
    if (deltaDB != 0){
      scaleMin += deltaDB;
      scaleMax += deltaDB;
      
      // Protections
      if (scaleMin < fullScaleMin) {scaleMin = fullScaleMin;}
      if (scaleMin > fullScaleMax) {scaleMin = fullScaleMin;}
      if (scaleMax < fullScaleMin) {scaleMax = fullScaleMin;}
      if (scaleMax > fullScaleMax) {scaleMax = fullScaleMax;}
      
      // Set new scales
      cp5.get(Textfield.class,"scaleMinText").setText( str(scaleMin) );
      cp5.get(Textfield.class,"scaleMaxText").setText( str(scaleMax) );
  
      setScale(1);
      println("deltaDB: " + numToStr(deltaDB) + ", -New Scale: \n" + "  LOWER:" + numToStr(scaleMin) + ",  UPPER:" + numToStr(scaleMax) );
    }
    
    // Move graph right/left
    if (abs(deltaF) > 10){
      startFreq -= deltaF;
      stopFreq -= deltaF;
      
      // Protections
      if (startFreq < fullRangeMin) {startFreq = fullRangeMin;}
      if (startFreq > fullRangeMax) {startFreq = fullRangeMax;}
      if (stopFreq < fullRangeMin) {stopFreq = fullRangeMin;}
      if (stopFreq > fullRangeMax) {stopFreq = fullRangeMax;}
      
      // Set new scales
      cp5.get(Textfield.class,"startFreqText").setText( str(startFreq) );
      cp5.get(Textfield.class,"stopFreqText").setText( str(stopFreq) );
      
      println("deltaF: " + numToStr(deltaF) + ", -New Freq: \n" + "  START:" + numToStr(startFreq) + ",  STOP:" + numToStr(stopFreq) );
      
      setRange(1);
    }
    
    
  }
  
}


void mouseWheel(MouseEvent event){
  final int NOTHING = 0;
  final int GAIN_HIGH = 1;
  final int GAIN_LOW = 2;
  final int FREQ_LEFT = 4;
  final int FREQ_RIGHT = 8;
  final int GRAPH_ZOOM = 16;
  final int TIME_UNTIL_SET = 25;
 
  int tmpFreq;
  int tmpFreq2;
  int tmpGain;
  int tmpGain2;
    
  int toModify;
  int gMouseX;
  int gMouseY;
  int freqStep = 0;
  
  int scaleFreqOverDb = 0;
 
  gMouseX = mouseX - graphX();
  gMouseY = mouseY - graphY();
 
  toModify = NOTHING;
 
  // Centre of graph horizontal is for incr/decr GAIN top/bottom
  //
  if ( abs( gMouseX - graphWidth()/2 ) < graphWidth()/4 ) {    
    // println ("Middle COLUMN");
    
    // Top or bottom ?
    //
    if ( gMouseY <  graphHeight()/4 ) {
        toModify = GAIN_HIGH;
    }
    else if (  graphHeight() - gMouseY <  graphHeight()/4 ) {
        toModify = GAIN_LOW;
    }   
  }
 
  // Middle of graph's vertical is for incr/decr frequency max/min
  //
  if ( abs( gMouseY - graphHeight()/2 ) < graphHeight()/4 ) {
    // println ("Middle ROW");
    
    // Left or Right ?
    //
    if ( gMouseX <  graphWidth()/4 && gMouseX > 0 ) {
        toModify = FREQ_LEFT;
    }
    else if (  graphWidth() - gMouseX <  graphWidth()/4 ) {
        toModify = FREQ_RIGHT;
    }   
            
  }
  
  // Middle of graph on X and Y is for zoom
  //
  if ( abs( gMouseX - graphWidth()/2 ) < graphWidth()/4  && abs( gMouseY - graphHeight()/2 ) < graphHeight()/4 )
        toModify = GRAPH_ZOOM ;
 
 
  tmpFreq = 0;
  if (toModify > 0   ) {
       infoText1X = min( max( graphX() +90, mouseX),  graphWidth() + 140 ) ;
       infoText1Y = max( graphY() +40, mouseY );
  }
  if ( stopFreq - startFreq > 50000000 ) freqStep = 10000000; else freqStep = 1000000;
  
  switch ( toModify ) {
   
    // GAIN ====================
    //
     case  GAIN_LOW:
       tmpGain = (( parseInt(cp5.get(Textfield.class,"scaleMinText").getText()) ) - event.getCount()) ;
       if (tmpGain < fullScaleMin ) tmpGain = fullScaleMin;
       if (tmpGain > fullScaleMax ) tmpGain = fullScaleMax-1;
       if (tmpGain >= scaleMax ) tmpGain = scaleMax - 1;
       cp5.get(Textfield.class,"scaleMinText").setText(str(tmpGain));
       infoText = str(tmpGain)  + " db" ;
       itemToSet = ITEM_GAIN;
       infoLineY = getGraphYfromDb( tmpGain  );
       
       timeToSet = TIME_UNTIL_SET;
     break;
     
     case  GAIN_HIGH:
       tmpGain = (( parseInt(cp5.get(Textfield.class,"scaleMaxText").getText()) ) - event.getCount()) ;
       if (tmpGain < fullScaleMin ) tmpGain = fullScaleMin + 1;
       if (tmpGain > fullScaleMax ) tmpGain = fullScaleMax;
       if (tmpGain <= scaleMin ) tmpGain = scaleMin + 1;
       cp5.get(Textfield.class,"scaleMaxText").setText(str(tmpGain));
       itemToSet = ITEM_GAIN;
       infoText = str(tmpGain)   + " db" ;
       infoLineY = getGraphYfromDb( tmpGain  );
       
       timeToSet = TIME_UNTIL_SET;
     break;
     
     // FREQUENCY ===================
     //
     case  FREQ_LEFT:
       // tmpObject =  cp5.get(Textfield.class,"startFreqText");
       tmpFreq = (( parseInt(cp5.get(Textfield.class,"startFreqText").getText()) /freqStep ) - event.getCount() )  * freqStep ;
       if (tmpFreq < fullRangeMin ) tmpFreq = fullRangeMin;
       if (tmpFreq > fullRangeMax ) tmpFreq = fullRangeMax;
       if (tmpFreq >= stopFreq ) tmpFreq = stopFreq - 1000000;
       cp5.get(Textfield.class,"startFreqText").setText(str(tmpFreq));
       itemToSet = ITEM_FREQUENCY;
       infoText = str( tmpFreq / 1000000 )  + " MHz" ;
  //     infoLineX =  max( graphX() - 10, graphX() + graphWidth()  * (tmpFreq/1000000 - startFreq/1000000) / (stopFreq/1000000 - startFreq/1000000));
       infoLineX = getGraphXfromFreq( tmpFreq );
       
       timeToSet = TIME_UNTIL_SET;
     break;
     
     case  FREQ_RIGHT:
       tmpFreq = (( parseInt(cp5.get(Textfield.class,"stopFreqText").getText()) / freqStep) - event.getCount())  * freqStep;
       if (tmpFreq < fullRangeMin ) tmpFreq = fullRangeMin;
       if (tmpFreq > fullRangeMax ) tmpFreq = fullRangeMax;
       if (tmpFreq <= startFreq ) tmpFreq = startFreq + 1000000;
       cp5.get(Textfield.class,"stopFreqText").setText(str(tmpFreq));
       itemToSet = ITEM_FREQUENCY;
       infoText = str( tmpFreq / 1000000 ) + " MHz";
  //     infoLineX =  min( graphX() + graphWidth() + 10, graphX() + graphWidth()  * (tmpFreq/1000000 - startFreq/1000000) / (stopFreq/1000000 - startFreq/1000000));
       infoLineX = getGraphXfromFreq( tmpFreq );
       timeToSet = TIME_UNTIL_SET;
     break;
       
     case GRAPH_ZOOM:
       scaleFreqOverDb =  (stopFreq - startFreq) / (scaleMax - scaleMin) ;  // How many Hz for each db
       tmpGain  = min( max( (( parseInt(cp5.get(Textfield.class,"scaleMinText").getText()) ) - event.getCount()), fullScaleMin), fullScaleMax) ;
       tmpGain2 = max( min( (( parseInt(cp5.get(Textfield.class,"scaleMaxText").getText()) ) + event.getCount()), fullScaleMax), fullScaleMin) ;
       if ( tmpGain2 <= tmpGain ) tmpGain2 = tmpGain + 2;
       if ( tmpGain == fullScaleMax ) {   tmpGain = fullScaleMax-1;      tmpGain2=fullScaleMax;   }
       cp5.get(Textfield.class,"scaleMinText").setText(str(tmpGain));
       cp5.get(Textfield.class,"scaleMaxText").setText(str(tmpGain2));
       
       tmpFreq  =  min( max( parseInt(cp5.get(Textfield.class,"startFreqText").getText()) - scaleFreqOverDb * event.getCount(),  fullRangeMin ), fullRangeMax )  ;
       tmpFreq2 =  max( min( parseInt(cp5.get(Textfield.class,"stopFreqText").getText())  + scaleFreqOverDb * event.getCount(),  fullRangeMax ), fullRangeMin )  ;
       
       if (tmpFreq >= tmpFreq2) tmpFreq2 = tmpFreq + 10000000;
       
       cp5.get(Textfield.class,"startFreqText").setText(str(tmpFreq));
       cp5.get(Textfield.class,"stopFreqText").setText(str(tmpFreq2));
       
       if ( event.getCount() >0 ) infoText = "ZOOM OUT"; else infoText="ZOOM IN";
       infoRectangle[0]= getGraphXfromFreq( tmpFreq ); 
       infoRectangle[1]= getGraphYfromDb( tmpGain); 
       infoRectangle[2]= getGraphXfromFreq( tmpFreq2 ) - infoRectangle[0];  
       infoRectangle[3]= ( getGraphYfromDb( tmpGain2) - infoRectangle[1]); 
       
       itemToSet = ITEM_ZOOM;
       timeToSet = TIME_UNTIL_SET;
     break;
    
  }

}
