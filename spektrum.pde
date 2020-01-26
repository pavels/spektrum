import controlP5.*;
import rtlspektrum.Rtlspektrum;
import java.io.FileWriter;
import java.util.*;
import processing.serial.*;

Serial myPort;

Rtlspektrum spektrumReader;
ControlP5 cp5;
DataPoint[] scaledBuffer;

boolean startingupBypassSaveConfiguration = true;

int reloadConfigurationAfterStartUp = 0;// This will be set at the end of the startup
int CONFIG_RELOAD_DELAY = 30;  // 0 is disabled

interface  CURSORS {
  int
    CUR_NONE      = 0,
    CUR_X_LEFT    = 1,
    CUR_X_RIGHT   = 2,
    CUR_Y_TOP     = 3,
    CUR_Y_BOTTOM  = 4;
}

int movingCursor = CURSORS.CUR_NONE;

String tmpMessage;
String tmpMessage1;

final int NONE = 0;
// TABS
//
int tabActiveID = 1;
String tabActiveName = "default";
final int TAB_HEIGHT = 25;
final int TAB_HEIGHT_ACTIVE = 30;

final int TAB_GENERAL = 1;
final int TAB_MEASURE = 2;
final int TAB_SETTINGS = 3;
final int TAB_SARK100 = 4;

String tabLabels[] = {"global", "SETUP", "MEASURE", "SETTINGS", "NOT YET", "WHO ARE YOU"};

final int ITEM_GAIN = 1;
final int ITEM_FREQUENCY = 2;
final int ITEM_ZOOM = 3;
final int ITEM_RF_GAIN = 4;

// interface  IF_TYPES {
//  int
final int  IF_TYPE_NONE      = 0;
final int  IF_TYPE_ABOVE     = 1;
final int  IF_TYPE_BELOW     = 2;
// }

// Configuration
//
final int nrOfConfigurations = 10;			// First element is used for the Autosave functionality.
final int DO_NOT_SAVE_CONFIGURATION = 0;
final int SAVE_CONFIGURATION = 1;

final int PRESET_SAVE = 1;
final int PRESET_LOAD = 2;
int configurationOperation = 0 ;

int CONFIG_SAVE_DELAY = 80;  // 0 is disabled
configurationClass[] configSet = new  configurationClass[10];
int configurationActive=0;
String configurationName;
DropdownList configurationDropdown;
int configurationSaveDelay = 0;

// Maybe not needed -- TBD
//
public class configurationClass {
  public int startFreq;
  public int stopFreq;
  public int binStep;
  public int scaleMin;
  public int scaleMax;
  public int rfGain;
  public int fullRangeMin;
  public int fullRangeMax;
  public int ifOffset;
  public int ifType;
  public int activeConfig;
  public String configName;

  public configurationClass(int i)
  {
    configName = "Config" + i;
  }
}


int timeToSet = 1;  // GRGNICK add
int itemToSet = 0;  // GRGNICK add -- 1 is Gain, 2 is Frequency
int infoText1X = 0;
int infoText1Y = 0;
int infoColor = #00FF3F;
int infoLineX = 0;
int infoLineY = 0;
int infoRectangle[] = {0, 0, 0, 0};
String infoText = "";

int lastWidth =0;

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
int cropPercent = 0;	// RTL data chunks percentage to keep. Values 0 to 70 percent


int scaleMin = -110;
int scaleMax = 40;

int uiNextLineIndex = 0;
int[][] uiLines = new int[10][10];

final int GRAPH_DRAG_NONE = 0;
final int GRAPH_DRAG_STARTED = 1;
final int GRAPH_DRAG_ENDED = 0;
int mouseDragGraph = GRAPH_DRAG_NONE;

int dragGraphStartX;
int dragGraphStartY;

int cursorVerticalLeftX = -1;
int cursorVerticalRightX = -1;
int cursorHorizontalTopY = -1;
int cursorHorizontalBottomY = -1;

int cursorVerticalLeftX_Color = #3399ff;  // Cyan
int cursorHorizontalBottomY_Color = #3399ff;

int cursorVerticalRightX_Color = #ff80d5; // Magenta
int cursorHorizontalTopY_Color = #ff80d5;

int cursorDeltaColor = #00E010;
ListBox deviceDropdown;
DropdownList gainDropdown;
DropdownList serialDropdown;


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

int showInfoScreen = 0;
class DataPoint {
  public int x;
  public double yMin = 0;
  public double yMax = 0;
  public double yAvg = 0;
}

class infoScreen {
  public int topY = 0;
  public int leftX = 0;
  public int width = 0;
  public int height = 0;
  public String text = "";
  color colorBack;
}

infoScreen infoHelp;


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
color buttonColor = color(70, 70, 70);
color buttonColorText = color(255, 255, 230);
color setButtonColor = color(127, 0, 0);
color clickMeButtonColor = color(20, 200, 20);
color willSaveButtonColor = color(200, 20, 20);
boolean drawSampleToggle=false;
boolean vertCursorToggle=true;
boolean drawFill=false;

// Reference
//
boolean refShow = false;	// If the reference graph is shown on screen
boolean refStoreFlag = false; // Used to flag a save in draw()
DataPoint[] refArray ; // Storage of reference graph
boolean refArrayHasData = false;
int refYoffset=0;


// Average
//
DataPoint[] avgArray ; // Storage of reference graph
boolean avgShow = false;
boolean avgArrayHasData = false;
int avgDepth = 10;
int avgNewSampleWeight = 1;
boolean avgSamples = false;

// Persistent
//
DataPoint[] perArray ; // Storage of Minimum and Maximum persiastant data graph
boolean perShowMax = false;
boolean perShowMin = false;
boolean perShowMed = false;
boolean perArrayHasData = false;


int lastScanPosition = 0;
int scanPosition = 0;
int completeCycles = 0;	// How many times the scanner has finished the defined range

color tabColorBachground = color(0, 70, 80);


//=========================

void MsgBox( String Msg, String Title ) {
  // Messages
  javax.swing.JOptionPane.showMessageDialog ( null, Msg, Title, javax.swing.JOptionPane.ERROR_MESSAGE  );
}

void setupStartControls() {
  int x, y;
  int width = 170;

  x = 15;
  y = 40;

  // frameRate(30);

  deviceDropdown = cp5.addListBox("deviceDropdown")
    .setBarHeight(20)
    .setItemHeight(20)
    .setPosition(x, y)
    .setSize(width, 80);

  deviceDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Select device");

  for (int i=0; i<devices.length; i++) {
    deviceDropdown.addItem(devices[i], i);
  }

  scaledBuffer =  new DataPoint[0];
}

void setupControls() {
  int x, y;
  int width = 170;
  Textlabel tmpLabel;

  // Setup TABS
  //
  // if you want to receive a controlEvent when
  // a  tab is clicked, use activeEvent(true)
  //

  cp5.addTab("default")
    .setColorLabel(color(255))
    .activateEvent(true)
    .setId(TAB_GENERAL)
    .setLabel(tabLabels[TAB_GENERAL])
    .setHeight(TAB_HEIGHT_ACTIVE)
    ;
  background(color(#222324));

  // General tab (1) =================================================
  //
  x = 15;
  y = 10;
  uiNextLineIndex = 0;

  uiLines[uiNextLineIndex++][TAB_GENERAL] = y;

  y+=35;

  cp5.addTextlabel("receiverLabel")
    .setText("RECEIVER RANGE:")
    .setPosition(x-13, y)
    .setColorValue(0xffffff00)
    .setFont(createFont("ARIAL", 10))
    ;
  y+=35;

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
    .setAutoClear(true)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Bin size [Hz]")
    ;


  cp5.addButton("setRangeButton")
    .setValue(0)
    .setPosition(95, y)
    .setSize(width/2, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set range")
    ;

  y += 10;

  uiLines[uiNextLineIndex++][TAB_GENERAL] = y;

  // -------------------------------------------------------------------- IF offset
  //
  y+=35;

  cp5.addTextlabel("ifLabel")
    .setText("UP/DOWN CONVERTER:")
    .setPosition(x-13, y)
    .setColorValue(0xffffff00)
    .setFont(createFont("ARIAL", 10))
    ;

  y+=30;

  cp5.addTextfield("ifOffset")
    .setPosition(x, y)
    .setSize(90, 20)
    .setText(str(binStep))
    .setAutoClear(true)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("IF Frequency")
    ;

  cp5.get(Textfield.class, "ifOffset").setText(str(ifOffset));  // Spaggeti because mouse events and code modification events have the same result on event code...

  // toggle vertical sursor on or off
  cp5.addToggle("ifPlusToggle")
    .setPosition(x  + 100, y)
    .setSize(20, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Above")
    ;

  // toggle for how samples are shown - line / dots
  cp5.addToggle("ifMinusToggle")
    .setPosition(x + 140, y)
    .setSize(20, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Below")
    ;

  uiLines[uiNextLineIndex++][TAB_GENERAL] = y;

  // --------------------------------------------------------------------
  //
  y+=35;

  cp5.addTextlabel("optionsLabel")
    .setText("VARIOUS OPTIONS:")
    .setPosition(x-13, y)
    .setColorValue(0xffffff00)
    .setFont(createFont("ARIAL", 10))
    ;

  y+=35;

  // toggle vertical sursor on or off
  cp5.addToggle("vertCursorToggle")
    .setPosition(x, y)
    .setSize(20, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Cursors")
    ;

  // toggle for how samples are shown - line / dots
  cp5.addToggle("drawSampleToggle")
    .setPosition(x + 70, y)
    .setSize(20, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Line/Dots")
    ;

  // toggle for how samples are shown - line / dots
  cp5.addToggle("drawFill")
    .setPosition(x + 140, y)
    .setSize(20, 20)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Filled Graph")
    ;

  // --------------------------------------------------------------------
  //
  y += 40;

  cp5.addToggle("offsetToggle")
    .setPosition(x, y)
    .setSize(20, 20)
    .setValue(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Offset tunning")
    ;

  cp5.addToggle("minmaxToggle")
    .setPosition(x + 70, y)
    .setSize(20, 20)
    .setValue(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Min/Max")
    ;

  cp5.addToggle("sweepToggle")
    .setPosition(x + 140, y)
    .setSize(20, 20)
    .setValue(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Sweep")
    ;

  y += 40;

  cp5.addTextfield("cropPrcntTxt")
    .setPosition(x, y)
    .setSize(60, 20)
    .setText(str(cropPercent))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Crop percent (0-70%)")
    ;

  uiLines[uiNextLineIndex++][TAB_GENERAL] = y;

  // ---------------------------- Configurations
  //
  y+=35;

  cp5.addTextlabel("configLabel")
    .setText("CONFIGURATION PRESETS:")
    .setPosition(x-13, y)
    .setColorValue(0xffffff00)
    .setFont(createFont("ARIAL", 10))
    ;

  // Quick n dirty. Load from file and populate list.
  //
  Table tmpTable = loadTable(fileName, "header");

  y+=35;

  cp5.addTextfield("presetName")
    .setPosition(x, y)
    .setSize(100, 20)
    .setText(tmpTable.getString(0, "configName"))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Current preset")
    ;

  configurationDropdown = cp5.addDropdownList("configurationList")
    .setBarHeight(20)
    .setItemHeight(20)
    .setPosition(x, y)
    .setSize(100, 80)
    .hide();
  configurationDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText(configurationName);

  cp5.addButton("selectPreset")
    .setPosition(x+105, y)
    .setSize(20, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("...")
    ;

  cp5.addButton("savePreset")
    .setPosition(x+135, y)
    .setSize(40, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Save to")
    ;

  // Populate presets dropdwon list
  //
  for (int i=0; i<nrOfConfigurations; i++) {
    configurationDropdown.addItem( tmpTable.getString(i, "configName"), i);
  }

  y+=30;

  // Bottom of UI area
  //

  y = graphHeight() - 130;
  uiLines[uiNextLineIndex++][TAB_GENERAL] = y - 40;

  cp5.addButton("freezeDisplay")
    .setPosition(x, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Pause")
    ;

  cp5.addButton("exitProgram")
    .setPosition(x+width/2+5, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Exit")
    ;

  uiLines[uiNextLineIndex++][TAB_GENERAL] = 0;

  // TAB MEASURE =============================================================================
  //

  cp5.addTab(tabLabels[TAB_MEASURE])
    .setColorBackground( tabColorBachground )
    .activateEvent(true)
    .setId(TAB_MEASURE)
    .setHeight(TAB_HEIGHT)
    ;


  // GAIN SCALE --------------------------------------------------------------------
  //

  y = 10;
  uiNextLineIndex = 0;

  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  y+=35;
  tmpLabel = cp5.addTextlabel("verticalLabel")
    .setText("VERTICAL SCALE & RF GAIN:")
    .setPosition(x-13, y)
    .setColorValue(0xffffff00)
    .setFont(createFont("ARIAL", 10))
    ;
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y+=35;

  cp5.addTextfield("scaleMinText")
    .setPosition(60, y)
    .setSize(25, 20)
    .setText(str(scaleMin))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Lower")
    ;
  cp5.getController("scaleMinText").moveTo(tabLabels[TAB_MEASURE]);


  cp5.addTextfield("scaleMaxText")
    .setPosition(90, y)
    .setSize(25, 20)
    .setText(str(scaleMax))
    .setAutoClear(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Upper")
    ;
  cp5.getController("scaleMaxText").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("setScale")
    .setPosition(120, y)
    .setSize(60, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set scale")
    ;
  cp5.getController("setScale").moveTo(tabLabels[TAB_MEASURE]);

  // Gain
  //
  cp5.addTextlabel("label")
    .setText("GAIN")
    .setPosition(x, y-12)
    .setSize(20, 20);
  cp5.getController("label").moveTo(tabLabels[TAB_MEASURE]);

  // --------------------------------------------------------------------
  //
  cp5.addKnob("rfGain")
    .setRange(gains[0], gains[gains.length-1])
    .setValue(50)
    .setPosition(x, y  )
    .setRadius(15)
    .setDragDirection(Knob.VERTICAL)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("")
    ;
  cp5.getController("rfGain").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("rfGain01")
    .setPosition(x, y+40)
    .setSize(9, 20)
    .setColorLabel(buttonColorText)
    .setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("")
    ;
  cp5.addButton("rfGain02")
    .setPosition(x+10, y+40)
    .setSize(9, 20)
    .setColorLabel(buttonColorText)
    .setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("")
    ;

  cp5.addButton("rfGain03")
    .setPosition(x+20, y+40)
    .setSize(9, 20)
    .setColorLabel(buttonColorText)
    .setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("")
    ;
  cp5.getController("rfGain01").moveTo(tabLabels[TAB_MEASURE]);
  cp5.getController("rfGain02").moveTo(tabLabels[TAB_MEASURE]);
  cp5.getController("rfGain03").moveTo(tabLabels[TAB_MEASURE]);

  // --------------------------------------------------------------------
  //
  y += 40;

  cp5.addButton("autoScale")
    //.setValue(0)
    .setPosition(60, y)
    .setSize(55, 20)
    .setColorLabel(buttonColorText)
    .setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Auto scale")
    ;
  cp5.getController("autoScale").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("resetScale")
    //.setValue(0)
    .setPosition(120, y)
    .setSize(60, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Reset scale")
    ;
  cp5.getController("resetScale").moveTo(tabLabels[TAB_MEASURE]);

  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  // REF, AVG, PERSISTENT --------------------------------------------------------------------
  //

  y+=35;
  tmpLabel = cp5.addTextlabel("avgLabel")
    .setText("VIDEO AVERAGING :")
    .setPosition(x-13, y)
    .setColorValue(0xffffff00)
    .setFont(createFont("ARIAL", 10))
    ;
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y+=35;

  // ---------------------------
  cp5.addToggle("avgShow")
    .setPosition(x, y)
    .setSize(20, 20)
    .setValue(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("ON/OFF")
    ;
  cp5.getController("avgShow").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addToggle("avgSamples")
    .setPosition(x + 70, y)
    .setSize(20, 20)
    .setValue(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Freeze")
    ;
  cp5.getController("avgSamples").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addTextfield("avgDepthTxt")
    .setSize(30, 20)
    .setPosition(x + 130, y)
    .setText(str(avgDepth))
    .setAutoClear(true)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Depth")
    ;
  cp5.getController("avgDepthTxt").moveTo(tabLabels[TAB_MEASURE]);

  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  // ------- REFERENCE
  //
  y+=35;
  tmpLabel = cp5.addTextlabel("refLabel")
    .setText("REFERENCE GRAPH:")
    .setPosition(x-13, y)
    .setColorValue(0xffffff00)
    .setFont(createFont("ARIAL", 10))
    ;
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y+=35;

  cp5.addToggle("refShow")
    .setPosition(x, y)
    .setSize(20, 20)
    .setValue(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Show")
    ;
  cp5.getController("refShow").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("refSave")
    .setPosition(50, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Save Reference")
    ;
  cp5.getController("refSave").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addKnob("refYoffset")
    .setRange(-graphHeight(), graphHeight())
    .setValue(50)
    .setPosition(150, y-10 )
    .setRadius(15)
    .setDragDirection(Knob.VERTICAL)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("")
    ;
  cp5.getController("refYoffset").moveTo(tabLabels[TAB_MEASURE]);

  // --------------------------------------------------------------------
  //
  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  y+=35;
  tmpLabel = cp5.addTextlabel("persistenceLabel")
    .setText("MIN, MAX, MEDIAN HOLD :")
    .setPosition(x-13, y)
    .setColorValue(0xffffff00)
    .setFont(createFont("ARIAL", 10))
    ;
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y+=35;

  cp5.addToggle("perShowMaxToggle")
    .setPosition(x, y)
    .setSize(20, 20)
    .setValue(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("MAX")
    ;
  cp5.getController("perShowMaxToggle").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addToggle("perShowMedToggle")
    .setPosition(x + 35, y)
    .setSize(20, 20)
    .setValue(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("med")
    ;
  cp5.getController("perShowMedToggle").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addToggle("perShowMinToggle")
    .setPosition(x + 70, y)
    .setSize(20, 20)
    .setValue(false)
    .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("MIN");
  cp5.getController("perShowMinToggle").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("perReset")
    .setPosition(x + 130, y)
    .setSize(40, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("RESET")
    ;
  cp5.getController("perReset").moveTo(tabLabels[TAB_MEASURE]);

  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;


  // --------------------------------------------------------------------
  //
  y+=35;
  tmpLabel = cp5.addTextlabel("zoomLabel")
    .setText("PRESET / RETURN TO PREVIOUS:")
    .setPosition(x-13, y)
    .setColorValue(0xffffff00)
    .setFont(createFont("ARIAL", 10))
    ;
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y+=25;

  cp5.addButton("presetRestore")
    .setPosition(x, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Pre-set")
    ;
  cp5.getController("presetRestore").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("zoomBack")
    .setPosition(x+width/2+5, y)
    .setSize(width/2-5, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Back")
    ;
  cp5.getController("zoomBack").moveTo(tabLabels[TAB_MEASURE]);

  y+=10;
  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  // --------------------------------------------------------------------
  //
  y += 50;

  cp5.addButton("toggleRelMode")
    //.setValue(0)
    .setPosition(x, y)
    .setSize(width, 20)
    .setColorBackground(#700000)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Relative mode")
    ;
  cp5.getController("toggleRelMode").moveTo(tabLabels[TAB_MEASURE]);


  // --------------------------------------------------------------------
  //
  y = graphHeight() - 120;

  uiLines[uiNextLineIndex++][TAB_GENERAL ] = 0;

  cp5.addButton("helpShow")
    .setPosition(60, y+110)
    .setSize(80, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("HELP")
    ;
  cp5.getController("helpShow").moveTo("global");

  cp5.addTextarea("textArea01")
    .setPosition(0, 0)
    .setSize(1, 1)
    .setText("")
    ;

  // Keep the down left position for the Delta label
  deltaLabelsYWaiting = y + 60;
  deltaLabelsXWaiting = x + 10;
  // Use it now
  deltaLabelsY = deltaLabelsYWaiting;
  deltaLabelsX = deltaLabelsXWaiting;

  // Min/Max labels position (Down left)
  minMaxTextY = height-50;

  loadConfigPostCreation();

  // TAB MR100 ===========================================================
  //
  /* NOT FINISHED */

  /*
  cp5.addTab(tabLabels[TAB_SARK100])
    .setColorBackground( tabColorBachground )
    .setColorLabel(color(255))
    .activateEvent(true)
    .setId(TAB_SARK100)
    .setHeight(TAB_HEIGHT)
    ;



  x = 15;
  y = 10;
  uiNextLineIndex=0;
  uiLines[uiNextLineIndex++][TAB_SARK100] = y;

  y += 40;

  serialDropdown = cp5.addDropdownList("serialPort")
    .setBarHeight(20)
    .setItemHeight(20)
    .setPosition(x, y)
    .setSize(80, 80);

  serialDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Select port");
  cp5.getController("serialPort").moveTo(tabLabels[TAB_SARK100]);

  printArray(Serial.list());

  for (int i=0; i<Serial.list().length; i++) {
    serialDropdown.addItem(Serial.list()[i], i);
  }

  cp5.addButton("openSerial")
    .setPosition(width-30, y)
    .setSize(40, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Open")
    ;
  cp5.getController("openSerial").moveTo(tabLabels[TAB_SARK100]);

  uiLines[uiNextLineIndex++][TAB_SARK100] = 0;
  */

  println("Reached end of setupControls.");
  startingupBypassSaveConfiguration = false;    //Ready loading... now you are able to save..

  // arrange controller in separate tabs
  // Tab 'global' is a tab that lies on top of any
  // other tab and is always visible
}

// Generic event handler for controls
//
void controlEvent(ControlEvent theEvent) {
  // println("controlEvent: EVENT DETECTED");
  if (theEvent.isTab()) {
    // println("got an event from tab : "+theEvent.getTab().getName()+" with id "+theEvent.getTab().getId());
    cp5.getTab(tabActiveName).setHeight(TAB_HEIGHT);
    tabActiveID = theEvent.getTab().getId();
    theEvent.getTab().setHeight(TAB_HEIGHT_ACTIVE);
    tabActiveName = theEvent.getTab().getName();
  }

  if (theEvent.isController()) {
    println(theEvent.getController().getName());
    if (theEvent.getController().getName()=="rfGain") {
      println("RF GAIN CLICKED");
    }
  }
}

public void cropPrcntTxt(String tmpText) {
  cropPercent = parseInt(tmpText);
  cropPercent = max( min(70, cropPercent ), 0 );
  cp5.get(Textfield.class, "cropPrcntTxt").setText(str(cropPercent));
  setRangeButton(0);
}

// Change the active configuration from the drop down list
//
public void configurationList(int confValue) {
  if ( configurationOperation == PRESET_SAVE ) {
    table.setString( confValue, "configName", cp5.get(Textfield.class, "presetName").getText());
    saveConfigToIndx( confValue );
    configurationDropdown.clear();
    for (int i=0; i<nrOfConfigurations; i++) {
      configurationDropdown.addItem( table.getString(i, "configName"), i);
    }
  } else {	// Load
    configurationActive = confValue;
    println("configurationList: Setting active configuration to " + confValue );
    loadConfig();
    loadConfigPostCreation();
    zoomIn();
  }

  configurationOperation = NONE;
  cp5.get(Textfield.class, "presetName").setText( configurationName );
  configurationDropdown.hide();
  cp5.get(Button.class, "savePreset").setColorBackground( buttonColor );
}

public void selectPreset() {
  if ( configurationDropdown.isVisible() ) {
    configurationDropdown.hide();
    configurationOperation = NONE;
    cp5.get(Button.class, "savePreset").setColorBackground( buttonColor );
  } else {
    configurationDropdown.show();
  }

  configurationDropdown.bringToFront();
  configurationDropdown.open();
}

public void savePreset() {
  if ( configurationOperation != NONE ) { // If already opened for saving, cancel it.
    configurationOperation = NONE;
    configurationDropdown.hide();
    configurationDropdown.close();
    cp5.get(Button.class, "savePreset").setColorBackground( buttonColor );
  } else {
    configurationOperation = PRESET_SAVE;
    configurationDropdown.show();
    configurationDropdown.open();
    cp5.get(Button.class, "savePreset").setColorBackground( willSaveButtonColor );
  }
}

public void presetRestore() {
  loadConfig();
  loadConfigPostCreation();
  zoomIn();
}

public void openSerial() {
  println( cp5.getController("serialPort").getValue());
  println( cp5.get(DropdownList.class, "serialPort").getValue());
}

public void rfGain(int gainValue) {
  // println( gainValue);
  spektrumReader.setGain(gainValue);
}

public void rfGain01(int gainValue) {
  //println( (int) (( gains[0] + ( gains[gains.length-1] - gains[0]) / 3 )  ) );
  int tpmInt = (int) (( gains[0] + ( gains[gains.length-1] - gains[0]) * 1 / 3 )  ) ;
  rfGain( tpmInt );
  cp5.get(Knob.class, "rfGain").setValue(tpmInt);
}

public void rfGain02(int gainValue) {
  int tpmInt = (int) (( gains[0] + ( gains[gains.length-1] - gains[0]) / 2 )  ) ;
  rfGain( tpmInt );
  cp5.get(Knob.class, "rfGain").setValue(tpmInt);
}

public void rfGain03(int gainValue) {
  int tpmInt = (int) (( gains[0] + ( gains[gains.length-1] - gains[0]) *2 / 3 )  ) ;
  rfGain( tpmInt );
  cp5.get(Knob.class, "rfGain").setValue(tpmInt);
}

// IF settings UI
//
public void ifPlusToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      cp5.get(Toggle.class, "ifMinusToggle").setValue(0);
      ifType = IF_TYPE_ABOVE;
      ifOffset  = parseInt(cp5.get(Textfield.class, "ifOffset").getText());
    } else {
      ifType = IF_TYPE_NONE;
    }

    configurationSaveDelay = CONFIG_SAVE_DELAY;
  }
}
public void ifMinusToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      cp5.get(Toggle.class, "ifPlusToggle").setValue(0);
      ifType = IF_TYPE_BELOW;
      ifOffset  = parseInt(cp5.get(Textfield.class, "ifOffset").getText());
    } else {
      ifType = IF_TYPE_NONE;
    }
  }

  configurationSaveDelay = CONFIG_SAVE_DELAY;
}

// Min/Max UI
//
public void offsetToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      spektrumReader.setOffsetTunning(true);
    } else {
      spektrumReader.setOffsetTunning(false);
    }
  }
}

public void minmaxToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      minmaxDisplay = true;
    } else {
      minmaxDisplay = false;
    }
  }
}

public void sweepToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      sweepDisplay = true;
    } else {
      sweepDisplay = false;
    }
  }
}

public void perShowMaxToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      perShowMax = true;
    } else {
      perShowMax = false;
    }
  }
}

public void perShowMinToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      perShowMin = true;
    } else {
      perShowMin = false;
    }
  }
}

public void perShowMedToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      perShowMed = true;
    } else {
      perShowMed = false;
    }
  }
}

public int ifCorrectedFreq( int inFreq ) {
  int tmpFreq=inFreq;

  if (ifType == IF_TYPE_ABOVE) tmpFreq -= ifOffset;
  else if (ifType == IF_TYPE_BELOW) tmpFreq = ifOffset - tmpFreq;

  return tmpFreq;
}

public void setRangeButton(int saveConfig) {
  setRange(SAVE_CONFIGURATION);
}

public void setRange(int saveConfig) {
  // Button color indicating change
  cp5.get(Button.class, "setRangeButton").setColorBackground( buttonColor );

  cursorVerticalLeftX = -1;
  cursorVerticalRightX = -1;

  try {
    startFreq = parseInt(cp5.get(Textfield.class, "startFreqText").getText());
    stopFreq = parseInt(cp5.get(Textfield.class, "stopFreqText").getText());
    binStep = parseInt(cp5.get(Textfield.class, "binStepText").getText());
    cropPercent = parseInt(cp5.get(Textfield.class, "cropPrcntTxt").getText());
  }
  catch(Exception e) {
    println("setRange exception.");
  }

  if (startFreq == 0 || stopFreq <= startFreq || binStep < 1) return;

  if ( saveConfig == SAVE_CONFIGURATION ) configurationSaveDelay = CONFIG_SAVE_DELAY;

  double tmpCrop = (double) ( max( min(70, cropPercent ), 0 ) / 100.0);
  relMode = 0;
  spektrumReader.clearFrequencyRange();
  spektrumReader.setFrequencyRange(startFreq, stopFreq, binStep, tmpCrop);
  spektrumReader.startAutoScan();
  println("setRange: CROP set to " + tmpCrop);
}

public void setScale(int theValue) {
  // Button color indicating change
  cp5.get(Button.class, "setScale").setColorBackground( buttonColor );

  cursorHorizontalTopY = -1;
  cursorHorizontalBottomY = -1;

  try {
    scaleMin = parseInt(cp5.get(Textfield.class, "scaleMinText").getText());
    scaleMax = parseInt(cp5.get(Textfield.class, "scaleMaxText").getText());
  }
  catch(Exception e) {
    return;
  }

  configurationSaveDelay = CONFIG_SAVE_DELAY;
}


public void resetScale(int theValue) {
  scaleMin = fullScaleMin;
  scaleMax = fullScaleMax;
  cp5.get(Textfield.class, "scaleMinText").setText(str(scaleMin));
  cp5.get(Textfield.class, "scaleMaxText").setText(str(scaleMax));
}

public void autoScale(int theValue) {
  if (setupDone) {
    if (minmaxDisplay) {
      scaleMin = (int)(minValue - abs((float)minValue*0.1));
      scaleMax = (int)(maxValue + abs((float)maxValue*0.1));
    } else {
      scaleMin = (int)(minScaledValue - abs((float)minScaledValue*0.1));
      scaleMax = (int)(maxScaledValue + abs((float)maxScaledValue*0.1));
    }
    cp5.get(Textfield.class, "scaleMinText").setText(str(scaleMin));
    cp5.get(Textfield.class, "scaleMaxText").setText(str(scaleMax));
  }
}

void refSave(  ) {
  println("Flaging for graph storage");
  refStoreFlag = true;
}

void perReset(  ) {
  perArrayHasData = false;
}

// On set scale (V or H) fix the cursors involved so the primaries are always on the lower side (swap them is needed).
void swapCursors() {
  int tmpInt;

  if (cursorVerticalLeftX > cursorVerticalRightX) {
    tmpInt = cursorVerticalLeftX;
    cursorVerticalLeftX = cursorVerticalRightX;
    cursorVerticalRightX = tmpInt;
  }

  if (cursorHorizontalTopY > cursorHorizontalBottomY) {
    tmpInt = cursorHorizontalTopY;
    cursorHorizontalTopY = cursorHorizontalBottomY;
    cursorHorizontalBottomY = tmpInt;
  }
}

void zoomBack() {

  swapCursors();//Fix order

  cp5.get(Textfield.class, "startFreqText").setText( str(zoomBackFreqMin) );
  cp5.get(Textfield.class, "stopFreqText").setText( str(zoomBackFreqMax) );
  cp5.get(Textfield.class, "scaleMinText").setText( str(zoomBackScalMin) );
  cp5.get(Textfield.class, "scaleMaxText").setText( str(zoomBackScalMax) );

  zoomBackFreqMin = startFreq;
  zoomBackFreqMax = stopFreq;
  zoomBackScalMin = scaleMin;
  zoomBackScalMax = scaleMax;

  setScale(1);
  setRange(SAVE_CONFIGURATION);
}

void zoomIn() {

  swapCursors();//Fix order

  zoomBackFreqMin = startFreq;
  zoomBackFreqMax = stopFreq;
  zoomBackScalMin = scaleMin;
  zoomBackScalMax = scaleMax;

  cp5.get(Textfield.class, "startFreqText").setText( str(startFreq + hzPerPixel() * (cursorVerticalLeftX - graphX())) );
  cp5.get(Textfield.class, "stopFreqText").setText( str(startFreq + hzPerPixel() * (cursorVerticalRightX - graphX())) );
  cp5.get(Textfield.class, "scaleMinText").setText( str(scaleMax - ( ( (cursorHorizontalBottomY - graphY()) * gainPerPixel() ) / 1000 )) );
  cp5.get(Textfield.class, "scaleMaxText").setText( str(scaleMax - ( ( (cursorHorizontalTopY - graphY()) * gainPerPixel() ) / 1000 )) );

  setScale(SAVE_CONFIGURATION);
  setRange(1);
}

public void toggleRelMode(int theValue) {
  if (setupDone) {
    relMode++;
    if (relMode > 2) {
      relMode = 0;
    }
  }
}

public void deviceDropdown(int theValue) {
  deviceDropdown.hide();
  spektrumReader = new Rtlspektrum(theValue);
  int status = spektrumReader.openDevice();

  // Initialiaze configuration class array
  //
  for (int i=0; i<nrOfConfigurations; i++) {
    configSet[i] = new  configurationClass(i+1);
  }

  //============ Function calls added by Dave N
  makeConfig();  // create config file if it is not found.
  loadConfig();
  //============================

  if (status < 0) {
    MsgBox("Can't open rtl-sdr device.", "Spektrum");
    exit();
    return;
  }

  gains = spektrumReader.getGains();

  setupControls();
  relMode = 0;

  setupDone = true;
}

public void gainDropdown(int theValue) {
  spektrumReader.setGain(gains[theValue]);
}

void setup() {
  size(1200, 750);  // Size should be the first statement
  if (frame != null) {
    surface.setResizable(true);
  }

  devices = Rtlspektrum.getDevices();
  for (String dev : devices) {
    println(dev);
  }

  cp5 = new ControlP5(this);

  setupStartControls();
  println("Reached end of setup.");

  reloadConfigurationAfterStartUp = CONFIG_RELOAD_DELAY;//Reload configuration after this time
}

void stop() {
  spektrumReader.stopAutoScan();
}

void draw() {
  background(color(#222324));

  if (!setupDone) {
    return;
  }

  if ( width != lastWidth )
  {
    refShow = false;
    avgShow = false;
    println("RESIZE DETECTED");
    lastWidth = width;
    cp5.get(Toggle.class, "refShow").setValue(0);
    cp5.get(Toggle.class, "avgShow").setValue(0);
    return;
  }

  if (relMode == 1) {
    cp5.get(Button.class, "toggleRelMode").getCaptionLabel().setText("Set relative");
    spektrumReader.setRelativeMode(Rtlspektrum.RelativeModeType.RECORD);
  } else if (relMode == 2) {
    cp5.get(Button.class, "toggleRelMode").getCaptionLabel().setText("Cancel relative");
    spektrumReader.setRelativeMode(Rtlspektrum.RelativeModeType.RELATIVE);
  } else {
    cp5.get(Button.class, "toggleRelMode").getCaptionLabel().setText("Relative mode");
    spektrumReader.setRelativeMode(Rtlspektrum.RelativeModeType.NONE);
  }

  double[] buffer = spektrumReader.getDbmBuffer();

  minValue = Double.POSITIVE_INFINITY;
  minScaledValue = Double.POSITIVE_INFINITY;

  maxValue = Double.NEGATIVE_INFINITY;
  maxScaledValue = Double.NEGATIVE_INFINITY;
  for (int i = 0; i<buffer.length; i++) {
    if (minValue > buffer[i] && buffer[i] != Double.NEGATIVE_INFINITY) {
      minFrequency = startFreq + i * binStep;
      minValue = buffer[i];
    }

    if (maxValue < buffer[i] && buffer[i] != Double.POSITIVE_INFINITY) {
      maxFrequency = startFreq + i * binStep;
      maxValue = buffer[i];
    }
  }

  scaledBuffer = scaleBufferX(buffer);

  // Reference graph
  //
  if ( !refArrayHasData && refShow  ) {
    refArray = new DataPoint[scaledBuffer.length];
    refShow = false;
    cp5.get(Toggle.class, "refShow").setValue(0);
  }
  if ( refShow && refArray.length != scaledBuffer.length ) {
    refStoreFlag = true;
    refShow = false;
  }
  if ( refStoreFlag ) {

    // println("STORE size: " + refArray.length );

    if (avgShow && avgArrayHasData ) {
      refArray = new DataPoint[avgArray.length];
      arrayCopy( avgArray, refArray );
      cp5.get(Toggle.class, "avgShow").setValue(0);
    } else {
      refArray = new DataPoint[scaledBuffer.length];
      arrayCopy( scaledBuffer, refArray );
    }
    refArrayHasData = true;
    refStoreFlag = false;
    refShow = true;
    cp5.get(Toggle.class, "refShow").setValue(1);
    cp5.get(Knob.class, "refYoffset").setValue(0);
  }

  // Average graph
  //
  if ( !avgArrayHasData && avgShow  ) {
    avgArray = new DataPoint[scaledBuffer.length];
  }
  if ( avgShow && avgArray.length != scaledBuffer.length ) {
    avgArray = new DataPoint[scaledBuffer.length];
  }

  // Persistent data graph
  //
  if ( !perArrayHasData && (perShowMin || perShowMax || perShowMed)  ) {
    perArray = new DataPoint[scaledBuffer.length];
  }
  if ( (perShowMin || perShowMax || perShowMed) && perArray.length != scaledBuffer.length ) {
    perArray = new DataPoint[scaledBuffer.length];
  }

  // Data processing per screen point
  //
  for (int i = 0; i<scaledBuffer.length; i++) {
    if (scaledBuffer[i] == null) continue;

    if (minScaledValue > scaledBuffer[i].yAvg) {
      minScaledValue = scaledBuffer[i].yAvg;
    }

    if (maxScaledValue < scaledBuffer[i].yAvg) {
      maxScaledValue = scaledBuffer[i].yAvg;
    }
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

  color tmpColorGraph = color( 200, 200, 40 );
  color tmpColorAvg = color( 10, 200, 40 );
  color tmpColorRef = color( 51, 51, 255 );
  color tmpColorPerMax = color( 180, 180, 180 );
  color tmpColorPerMin = color( 160, 160, 160 );
  color tmpColorPerMed = color( 51, 204, 255 );
  color tmpColorFill = color ( 102, 102, 0 );


  int tmpAlpha = 255;
  if (avgShow || perShowMed)  tmpAlpha = 70;
  else tmpAlpha = 255;

  // Main point per point loop
  //
  for (int i = 0; i < scaledBuffer.length; i++) {
    point = scaledBuffer[i];
    refPoint = null;
    avgPoint = scaledBuffer[i];
    perPoint = scaledBuffer[i];

    if (refShow && refArrayHasData ) {
      refPoint = refArray[i];
    }
    if (avgShow && avgArrayHasData ) {
      avgPoint = avgArray[i];
    }
    if ((perShowMin || perShowMax || perShowMed ) && perArrayHasData ) {
      perPoint = perArray[i];
    }

    if (point == null ) continue;
    if (avgPoint == null) avgArrayHasData = false;
    if (perPoint == null) perArrayHasData = false;

    if (lastPoint != null) {

      // MAIN graph
      //
      if ( drawFill ) {
        graphDrawFill(lastPoint.x, (int)((lastPoint.yAvg - scaleMin) * scaleFactor), point.x, (int)((point.yAvg - scaleMin) * scaleFactor), tmpColorFill, 255);  // #fcf400
      }

      graphDrawLine(lastPoint.x, (int)((lastPoint.yAvg - scaleMin) * scaleFactor), point.x, (int)((point.yAvg - scaleMin) * scaleFactor), tmpColorGraph, tmpAlpha);

      if (minmaxDisplay) {
        graphDrawLine(lastPoint.x, (int)((lastPoint.yMin - scaleMin) * scaleFactor), point.x, (int)((point.yMin - scaleMin) * scaleFactor), #C23B22, 255);
        graphDrawLine(lastPoint.x, (int)((lastPoint.yMax - scaleMin) * scaleFactor), point.x, (int)((point.yMax - scaleMin) * scaleFactor), #03C03C, 255);
      }

      // Reference graph
      //
      if (refShow) {
        graphDrawLine(refLastPoint.x, ((int)((refLastPoint.yAvg - scaleMin) * scaleFactor) )  - refYoffset,
          refPoint.x, ( (int)((refPoint.yAvg - scaleMin) * scaleFactor)) - refYoffset, tmpColorRef, 255);
      }

      // Average graph
      //
      if (avgShow) {
        if ( !avgArrayHasData ) {	// Initialize array
          println("STORING Average");
          avgArray = new DataPoint[scaledBuffer.length];
          arrayCopy( scaledBuffer, avgArray);
          avgArrayHasData = true;
        } else	// Update and show
        {
          if ( !avgSamples  )
          {
            // if (scaledBuffer[i].yAvg > 1000) println(scaledBuffer[i].yAvg);
            if (scaledBuffer[i].yAvg < 1000)
              avgArray[i].yAvg = avgArray[i].yAvg - (avgArray[i].yAvg / avgDepth ) +  (scaledBuffer[i].yAvg / (float)avgDepth);
          } else if ( completeCycles > 0) {
            avgArray[i].yAvg = avgArray[i].yAvg - (avgArray[i].yAvg / avgDepth ) +  (scaledBuffer[i].yAvg / (float)avgDepth);
            completeCycles = 0;
            // println("UPDATED");
          }

          if (avgLastPoint!= null) {
            graphDrawLine(avgLastPoint.x, (int)((avgLastPoint.yAvg - scaleMin) * scaleFactor), avgPoint.x, (int)((avgPoint.yAvg - scaleMin) * scaleFactor), tmpColorAvg, 255);
          }
        }
      }

      // Persistent graph
      //
      if (perShowMin || perShowMax || perShowMed) {
        if ( !perArrayHasData ) {	// Initialize array
          println("STORING Persistant");
          perArray = new DataPoint[scaledBuffer.length];
          arrayCopy( scaledBuffer, perArray);
          for ( int jj=0; jj< scaledBuffer.length-1; jj++) {
            perArray[jj].yMax = perArray[jj].yAvg ;
            perArray[jj].yMin = perArray[jj].yAvg ;
          }

          perArrayHasData = true;
        } else	// Update and show
        {
          if ( scaledBuffer[i].yAvg> perArray[i].yMax ) perArray[i].yMax = scaledBuffer[i].yAvg;
          if ( scaledBuffer[i].yAvg< perArray[i].yMin ) perArray[i].yMin = scaledBuffer[i].yAvg;
          perArray[i].yAvg = perArray[i].yMin + ( perArray[i].yMax - perArray[i].yMin ) /2;

          if (perLastPoint!= null) {
            if (perShowMax)
              graphDrawLine(perLastPoint.x, (int)((perLastPoint.yMax - scaleMin) * scaleFactor), perPoint.x, (int)((perPoint.yMax - scaleMin) * scaleFactor), tmpColorPerMax, 200);
            if (perShowMin)
              graphDrawLine(perLastPoint.x, (int)((perLastPoint.yMin - scaleMin) * scaleFactor), perPoint.x, (int)((perPoint.yMin - scaleMin) * scaleFactor), tmpColorPerMin, 200);
            if (perShowMed)
              graphDrawLine(perLastPoint.x, (int)((perLastPoint.yAvg - scaleMin) * scaleFactor), perPoint.x, (int)((perPoint.yAvg - scaleMin) * scaleFactor), tmpColorPerMed, 255);
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

  // Original Min/Max
  //
  textAlign(LEFT);
  fill(#C23B22);
  text("Min: " + String.format("%.2f", minFrequency / 1000) + "kHz " + String.format("%.2f", minValue) + "dB", minMaxTextX +5, minMaxTextY+20);
  fill(#03C03C);
  text("Max: " + String.format("%.2f", maxFrequency / 1000) + "kHz " + String.format("%.2f", maxValue) + "dB", minMaxTextX +5, minMaxTextY+40);


  // Cursors and measurements
  //
  if (vertCursorToggle) {
    drawVertCursor();
  }


  // UI seperator lines
  //
  for ( uiNextLineIndex = 0; uiLines[uiNextLineIndex][tabActiveID] != 0; uiNextLineIndex++ )
    line( 5, uiLines[uiNextLineIndex][tabActiveID] + 30, 195, uiLines[uiNextLineIndex][tabActiveID]  + 30);


  // Frequency scan detection (complete cycles through spectrum range)
  //
  scanPosition = spektrumReader.getScanPos();

  if ( lastScanPosition != scanPosition ) {
    if (scanPosition - lastScanPosition <= 0) completeCycles++;
    lastScanPosition = scanPosition ;
    // println("RECYCLE !!!" + lastScanPosition);
  }

  // Sweep indicator position (vertical line)
  //
  if (sweepDisplay) {
    int scanPos = (int)(((float)graphWidth() / (float)buffer.length) * (float)scanPosition);
    sweep(scanPos, #FFFFFF, 64);
  }

  if (cursorVerticalLeftX < 0) cursorVerticalLeftX = graphX();
  if (cursorVerticalRightX < 0) cursorVerticalRightX = graphX() + graphWidth();
  if (cursorHorizontalTopY < 0) cursorHorizontalTopY = graphY();
  if (cursorHorizontalBottomY < 0) cursorHorizontalBottomY = graphY() + graphHeight();

  if ( timeToSet > 1 ) {
    timeToSet--;

    if ( infoText1X != 0) {  // Do we need any infomative text ?
      fill( infoColor );
      textSize(40);
      text( infoText, infoText1X, infoText1Y );
      textSize(12);
      stroke(#FFFFFF);
      if (itemToSet == ITEM_FREQUENCY)  line(infoLineX, graphY(), infoLineX, graphY() + graphHeight());
      if (itemToSet == ITEM_GAIN)       line(graphX(), infoLineY, graphX() + graphWidth(), infoLineY);
      if (itemToSet == ITEM_ZOOM) {
        noFill();
        rect( infoRectangle[0], infoRectangle[1], infoRectangle[2], infoRectangle[3] );
      }
    }
  } else if ( timeToSet == 1 ) {
    timeToSet = 0;
    if (itemToSet == ITEM_FREQUENCY) setRange(SAVE_CONFIGURATION);
    if (itemToSet == ITEM_GAIN) setScale(1);
    if (itemToSet == ITEM_ZOOM) {
      setScale(1);
      setRange(SAVE_CONFIGURATION);
    }

    infoText1X = 0;
  }

  // Delayed saving
  //
  if (configurationSaveDelay > 1) {
    configurationSaveDelay--;
  } else if (configurationSaveDelay == 1) {
    configurationSaveDelay = 0;
    saveConfig();
    println("TMR: Config saved (after delay).");
  }
}
//
// end of draw routine =============================================


// Help Button
//
void helpShow ( ) {
  Textarea tmpTA=cp5.get(Textarea.class, "textArea01");
  PFont pfont = createFont("Arial", 15, true); // use true/false for smooth/no-smooth
  ControlFont font = new ControlFont(pfont, 15, 50);

  tmpTA.moveTo("global");

  tmpMessage = "SPEKTRUM - Quick reference.\n";
  tmpMessage+= "\n";
  tmpMessage+= "Mouse operation :-                                                                          \n" ;
  tmpMessage+= "\n";
  tmpMessage+= "Left Mouse Button :                                                                         \n" ;
  tmpMessage+= "- Click and Drag on Cursor : Move cursor                                                    \n" ;
  tmpMessage+= "- Double Click : Zoom in defined area (by cursors)                                          \n" ;
  tmpMessage+= "\n";
  tmpMessage+= "Right Mouse Button :                                                                        \n" ;
  tmpMessage+= "- Click : Move primary cursors to mouse pointer                                             \n" ;
  tmpMessage+= "- Double click : Move primary cursors to pointer, store away secondary cursors.             \n" ;
  tmpMessage+= "- Click and Drag : Define an area with primary and secondary cursors. Diff. measurements.   \n" ;
  tmpMessage+= "\n";
  tmpMessage+= "Mouse wheel :                                                                               \n" ;
  tmpMessage+= "- Double click : Reset full ranges (Amplitude and Frequency)                                \n" ;
  tmpMessage+= "- Click and Drag : Move graph in X/Y preserving X/Y delta ranges (Pan graph)                \n" ;
  tmpMessage+= "- Rotate on top/bottom of graph to change corresponding Amplitude limit                     \n" ;
  tmpMessage+= "- Rotate on left/right of graph to change corresponding frequency limit                     \n" ;
  tmpMessage+= "- Rotate in middle of graph to change zoom level (X and Y)                                  \n" ;
  tmpMessage+= "\n\n";
  tmpMessage+= "\n";

  tmpMessage1 = "Tips\n\n";
  tmpMessage1+= "- On rotary knobs (eg RF gain) left click and drag up/down for fast adjustment. \n";
  tmpMessage1+= "- An average graph may also be saved as reference if it is active when the 'SAVE REFERENCE'\n";
  tmpMessage1+= "  Button is clicked        \n";
  tmpMessage1+= "- Crop (percent) will make the graph smoother but slower. Enter a value between 0 and 70 and\n";
  tmpMessage1+= "  press [ENTER]\n";
  tmpMessage1+= "\n\n\n\n\n\n\n\n\n\n\n\n\n";
  tmpMessage1+= "\n";

  if ( showInfoScreen == 0) {
    tmpTA.setPosition( graphX() + 10, graphY() + 10 );
    tmpTA.setSize(graphWidth() - 20, graphHeight() - 20);
    tmpTA.setColorBackground( #808080);
    tmpTA.setText(tmpMessage + tmpMessage1);
    tmpTA.setFont(font);

    // Close button
    //
    cp5.addButton("closeHelp")
      .setPosition(graphX() + graphWidth() - 60, graphY() + 15)
      .setSize(40, 20)
      .setColorBackground(buttonColor)
      .setColorLabel(buttonColorText)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("CLOSE")
      ;

    showInfoScreen = 1;
  } else {
    showInfoScreen = 0;
    tmpTA.clear();
    tmpTA.setPosition( 0, -20 );
    tmpTA.setSize(10, 10);
    cp5.get(Button.class, "closeHelp").remove();
  }
}

void closeHelp () {
  helpShow ( );
}

// Average waveform check box
//
void avgShow( int value)
{
  if (value == 1) {
    avgShow = true;
    avgArrayHasData = false;
    avgDepth = max( parseInt(cp5.get(Textfield.class, "avgDepthTxt").getText()), 2);
  } else {
    avgShow = false;
    avgArrayHasData = false;
  }
}

void freezeDisplay() {
  //================ added by DJN 26 Aug 2017
  if (frozen) {
    frozen = false;
    cp5.get(Button.class, "freezeDisplay").getCaptionLabel().setText("Pause");
    loop();
    println("Display unfrozen.");
  } else {
    frozen = true;
    cp5.get(Button.class, "freezeDisplay").getCaptionLabel().setText("Run");
    noLoop();
    println("Display frozen.");
  }
}

void exitProgram() {
  println("Exit program rtn.");
  if (setupDone)  exit();
}

public void resetMin() {
  //Set the start freq at full range

  cp5.get(Textfield.class, "startFreqText").setText( str(fullRangeMin) );
  setRange(SAVE_CONFIGURATION);
}


void resetMax() {
  //Set the stop freq full range

  cp5.get(Textfield.class, "stopFreqText").setText( str(fullRangeMax) );
  setRange(SAVE_CONFIGURATION);
}



void loadConfigPostCreation()
{
  if (ifType == IF_TYPE_ABOVE) {
    cp5.get(Toggle.class, "ifMinusToggle").setValue(0);
    cp5.get(Toggle.class, "ifPlusToggle").setValue(1);
  } else if (ifType == IF_TYPE_BELOW ) {
    cp5.get(Toggle.class, "ifMinusToggle").setValue(1);
    cp5.get(Toggle.class, "ifPlusToggle").setValue(0);
  } else {
    cp5.get(Toggle.class, "ifMinusToggle").setValue(0);
    cp5.get(Toggle.class, "ifPlusToggle").setValue(0);
  }

  cp5.get(Textfield.class, "ifOffset").setText(str(ifOffset));
  cp5.get(Textfield.class, "cropPrcntTxt").setText(str(cropPercent));
}

void loadConfig() {

  //================ Function added by DJN 24 Aug 2017
  table = loadTable(fileName, "header");

  startFreq = table.getInt(configurationActive, "startFreq");
  stopFreq = table.getInt(configurationActive, "stopFreq");
  if (startFreq >= stopFreq)  stopFreq = startFreq +100000;
  binStep = table.getInt(configurationActive, "binStep");
  scaleMin = table.getInt(configurationActive, "scaleMin");
  scaleMax = table.getInt(configurationActive, "scaleMax");
  fullRangeMin = table.getInt(configurationActive, "minFreq");
  fullRangeMax = table.getInt(configurationActive, "maxFreq");

  ifOffset = table.getInt(configurationActive, "ifOffset");
  ifType = table.getInt(configurationActive, "ifType");

  cropPercent = table.getInt(configurationActive, "cropPrcnt");

  configurationName = table.getString(configurationActive, "configName");

  //Protection
  if (binStep < binStepProtection) binStep = binStepProtection;
  cropPercent = max( min(70, cropPercent ), 0 );	// Just in case....

  // Init zoom back
  zoomBackFreqMin = startFreq;
  zoomBackFreqMax = stopFreq;
  zoomBackScalMin = scaleMin;
  zoomBackScalMax = scaleMax;

  println("loadConfig: Config table " + fileName + " loaded.");
  println("startFreq = " + startFreq + " stopFreq = " + stopFreq + " binStep = " + binStep + " scaleMin = " +
    scaleMin + " scaleMax = ", scaleMax + " rfGain = " + rfGain + " fullRangeMin = " + fullRangeMin + "  fullRangeMax = " + fullRangeMax +
    " ifOffset = " + ifOffset + " ifType = " + ifType);

  try {
    cp5.get(Textfield.class, "ifOffset").setText(str(ifOffset));  // Spaghetti because mouse events and code modification events have the same result on event code...
  }
  catch (Exception e) {
  }
}

void saveConfig() {
  saveConfigToIndx( 0 );
}

void saveConfigToIndx( int configIndx ) {
  //================ Function added by DJN 24 Aug 2017
  // Note: saveTable fails if file is being backed up at time saveTable is run!
  int i;
  if (startingupBypassSaveConfiguration == false) {

    println("saveConfig: Active Configuration " + configurationActive + " with name " + configurationName);

    table.setInt(0, "activeConfig", configurationActive);

    table.setInt(configIndx, "startFreq", startFreq);
    table.setInt(configIndx, "stopFreq", stopFreq);
    table.setInt(configIndx, "binStep", binStep);
    table.setInt(configIndx, "scaleMin", scaleMin);
    table.setInt(configIndx, "scaleMax", scaleMax);
    table.setInt(configIndx, "rfGain", rfGain);
    table.setInt(configIndx, "minFreq", fullRangeMin);
    table.setInt(configIndx, "maxFreq", fullRangeMax);
    table.setInt(configIndx, "ifOffset", ifOffset);
    table.setInt(configIndx, "ifType", ifType);
    table.setInt(configIndx, "cropPrcnt", cropPercent);

    saveTable(table, fileName, "csv");

    println("STORE TO " +  configurationActive + " : startFreq = " + startFreq + " stopFreq = " + stopFreq + " binStep = " + binStep + " scaleMin = " +
      scaleMin + " scaleMax = ", scaleMax + " rfGain = " + rfGain + " fullRangeMin = " + fullRangeMin + "  fullRangeMax = " + fullRangeMax +
      " ifOffset = " + ifOffset + " ifType = " + ifType);
    println("Config table " + fileName + " saved.");
  }
}

void makeConfig() {

  FileWriter fw= null;
  File file =null;
  println("File " + fileName);

  try {
    file=new File(fileName);
    println( file.getAbsolutePath());
    if (file.exists()) {
      println("File " + fileName + " exists.");
    } else {
      // Recreate missing config file
      file.createNewFile();
      fw = new FileWriter(file);

      fw.write("startFreq,stopFreq,binStep,scaleMin,scaleMax,rfGain,minFreq,maxFreq,ifOffset,ifType,cropPrcnt,activeConfig,configName\n");

      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,AutoSave\n");
      fw.write("88000000,108000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,FM Band\n");
      fw.write("118000000,178000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,VHF Band+\n");
      fw.write("380000000,450000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,UHF Band+\n");
      fw.write("120000000,170000000,2000,-110,40,0,24000000,1800000000,120000000,1,0,0,Spyverter\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config A\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config B\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config C\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config D\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config E\n");

      fw.flush();
      fw.close();
      println(fileName +  " created succesfully");
    }
  }
  catch(IOException e) {
    e.printStackTrace();
  }


  println("Reached end of makeconfig");
}

//==============================================
void drawVertCursor() {
  float xBand;
  float xCur;
  float xPlot;
  xBand = (stopFreq - startFreq);

  int tmpInt;
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
  text(numToStr(ifCorrectedFreq(freqLeft) /1000)  + " kHz", cursorVerticalLeftX-10, graphY()  - 5);

  // RIGHT
  stroke(cursorVerticalRightX_Color);
  fill(cursorVerticalRightX_Color);
  line(cursorVerticalRightX, graphY(), cursorVerticalRightX, graphY()+graphHeight());
  textAlign(CENTER);
  text(numToStr(ifCorrectedFreq(freqRight)/1000)  + " kHz", cursorVerticalRightX-10, graphY()  - 5);

  // BOTTOM
  stroke(cursorHorizontalBottomY_Color);
  fill(cursorHorizontalBottomY_Color);
  line(graphX(), cursorHorizontalBottomY, graphX()+graphWidth(), cursorHorizontalBottomY);
  textAlign(CENTER);
  text(     String.format("%.1f", scaleBottom)  + " db", graphX()+graphWidth()+20, cursorHorizontalBottomY+4);

  // TOP
  stroke(cursorHorizontalTopY_Color);
  fill(cursorHorizontalTopY_Color);
  line(graphX(), cursorHorizontalTopY, graphX()+graphWidth(), cursorHorizontalTopY);
  textAlign(CENTER);
  text(String.format("%.1f", scaleTop)  + " db", graphX()+graphWidth()+20, cursorHorizontalTopY+4);

  // DELTA  - FREQ / SCALE
  //
  float tmpVSWR = 1;
  float tmpDdb = 0;

  tmpDdb = abs(scaleBottom - scaleTop);
  tmpVSWR = (pow(10, (tmpDdb / 20 )) +1 ) / ( pow( 10, (tmpDdb / 20))  - 1  ) ;

  int labelXOffset = 0;
  int labelYOffset = 0;
  if ( deltaLabelsX > graphX() -40 ) {
    if ( deltaLabelsX > graphWidth() / 2 ) labelXOffset = -140;
    else labelXOffset = 50;
    if ( deltaLabelsY > graphHeight() / 2 ) labelYOffset = -30;
    else labelYOffset = 60;
  }
  textAlign(LEFT);
  fill(cursorDeltaColor);
  text("Δx : " + numToStr((freqRight - freqLeft)/1000)  + " kHz", deltaLabelsX + labelXOffset, deltaLabelsY + labelYOffset );
  text("Δy : " + String.format("%.1f", scaleBottom - scaleTop) + " db", deltaLabelsX + labelXOffset, deltaLabelsY + 20 + labelYOffset );
  textSize(12);
  text("VSWR: 1 : " + String.format("%.3f", tmpVSWR), deltaLabelsX + labelXOffset, deltaLabelsY + 38 + labelYOffset );

  textSize(12);
  noFill();
  stroke(#808080);
  rect( deltaLabelsX - 10 + labelXOffset, deltaLabelsY - 20 + labelYOffset, 170, 65);
}

// ====================================================================

String numToStr(int inNum) {
  // Convert number to string with commas
  String outStr = nfc(inNum);
  return outStr;
}

int getGraphXfromFreq( int frequency ) {
  return max(graphX() -10, min( graphX() + graphWidth() + 10, graphX() + graphWidth()  * (frequency/1000 - startFreq/1000) / (stopFreq/1000 - startFreq/1000)));
}

int getGraphYfromDb( int db ) {
  return min(graphY() + graphHeight() + 10, max( graphY() - 10, graphHeight() +graphY() - graphHeight() * (db - scaleMin) / (scaleMax - scaleMin) ));
}

//============== Move the red vertical cursor===============================================

void mousePressed(MouseEvent evnt) {
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

  // Help open ? Just close it
  //
  if (showInfoScreen >0) {
    closeHelp();
    return;
  }

  if (evnt.getCount() == 2) {
    DOUBLE_CLICK = true;
    if (mouseButton == RIGHT) {
      cursorVerticalRightX = graphWidth() + graphX();
      cursorHorizontalTopY = graphY();
    } // TAG01 RIGHT->LEFT was LEFT
    if (mouseButton == CENTER) {
      resetMin();
      resetMax();
      resetScale(1);
    };
    if (mouseButton == LEFT) zoomIn() ;        // TAG01 RIGHT->LEFT was RIGHT


    println("DOUBLE CLICK DETECTED");
    return;    // ATTENTION !!! RETURN !!!! BAD BAD HABIT. TODO properly. -GRG
  }


  //Protecion
  if (thisMouseX < graphX() || thisMouseX > graphWidth() + graphX() +1) return;
  if (thisMouseY < graphY() || thisMouseY > graphHeight() + graphY() +1) return;

  //Calculate center
  if ( (thisMouseX - graphX()) < (graphWidth()/2) ) {
    CLICK_LEFT = true;
  }

  if ( (thisMouseY - graphY() < graphHeight()/2) ) {
    CLICK_ABOVE = true;
  }


  int clickFreq = startFreq + hzPerPixel() * (thisMouseX - graphX());
  int clickScale;
  clickScale = ( (thisMouseY - graphY()) * gainPerPixel() ) / 1000;
  clickScale = scaleMax - clickScale;

  if (mouseButton == RIGHT ) // TAG01 RIGHT<->LEFT was LEFT
  {
    // Test if the mouse over graph
    if (thisMouseX >= graphX() && thisMouseX <= graphWidth() + graphX() +1) {
      mouseDragLock = true;

      vertCursorFreq = clickFreq;
      lastMouseX = mouseX;
      println("clickFreq = " + clickFreq);
    }


    cursorVerticalLeftX = mouseX;
    cursorHorizontalBottomY = mouseY;

    println("clickFreq: " + clickFreq + ",   clickScale: " + clickScale);
  } else if (mouseButton == CENTER) {

    mouseDragGraph = GRAPH_DRAG_STARTED;

    dragGraphStartX = mouseX;
    dragGraphStartY = mouseY;
  } else if (mouseButton == LEFT) {  // TAG01 RIGHT->LEFT was RIGHT
    int SELECT_THR = 20;
    // Drag cursors
    //
    //  TOP
    if ( abs(mouseY-cursorHorizontalTopY) <= SELECT_THR ) {
      println("TOP LINE");
      println("clickScale: " + clickScale);
      cp5.get(Textfield.class, "scaleMaxText").setText(str(clickScale));
      sweepVertical( mouseY - graphY(), #fcd420, 255);
      cursorHorizontalTopY = mouseY;
      movingCursor = CURSORS.CUR_Y_TOP;

      // Button color indicating change
      cp5.get(Button.class, "setScale").setColorBackground( clickMeButtonColor );
    }
    //  BOTTOM
    else if ( abs(mouseY-cursorHorizontalBottomY) <= SELECT_THR ) {
      println("BOTTOM LINE");
      println("clickScale: " + clickScale);
      cp5.get(Textfield.class, "scaleMinText").setText(str(clickScale));
      sweepVertical( mouseY - graphY(), #fcd420, 255);
      cursorHorizontalBottomY = mouseY;
      movingCursor = CURSORS.CUR_Y_BOTTOM;

      // Button color indicating change
      cp5.get(Button.class, "setScale").setColorBackground( clickMeButtonColor );
    }
    // LEFT
    else if ( abs(mouseX-cursorVerticalLeftX) <= SELECT_THR ) {
      println("LEFT LINE");
      println("clickFreq: " + clickFreq);
      cp5.get(Textfield.class, "startFreqText").setText(str(clickScale));
      sweep( mouseX - graphX(), #fcd420, 255);
      cursorVerticalLeftX = mouseX;
      movingCursor = CURSORS.CUR_X_LEFT;

      // Button color indicating change
      cp5.get(Button.class, "setRangeButton").setColorBackground( clickMeButtonColor );
    }
    // RIGHT
    else if ( abs(mouseX-cursorVerticalRightX) <= SELECT_THR ) {
      println("RIGHT LINE");
      println("clickFreq: " + clickFreq);
      cp5.get(Textfield.class, "stopFreqText").setText(str(clickScale));
      sweep( mouseX - graphX(), #fcd420, 255);
      cursorVerticalRightX = mouseX;
      movingCursor = CURSORS.CUR_X_RIGHT;

      // Button color indicating change
      cp5.get(Button.class, "setRangeButton").setColorBackground( clickMeButtonColor );
    }
  }
}

void mouseDragged() {
  int thisMouseX = mouseX;
  int thisMouseY = mouseY;

  //Protecion
  if (thisMouseX < graphX() || thisMouseX > graphWidth() + graphX() +1) return;
  if (thisMouseY < graphY() || thisMouseY > graphHeight() + graphY() +1) return;

  // Dragging Red cursor
  if (mouseDragLock) {
    if ( ( abs(cursorVerticalLeftX - mouseX) > startDraggingThr ) || ( abs(cursorHorizontalBottomY - mouseY) > startDraggingThr ) ) {
      cursorVerticalRightX = mouseX;
      cursorHorizontalTopY = mouseY;

      deltaLabelsX = mouseX-30;
      deltaLabelsY = mouseY-29;
    }
  }

  if (movingCursor == CURSORS.CUR_X_LEFT) {
    cursorVerticalLeftX = thisMouseX;
    int clickFreq = startFreq + hzPerPixel() * (thisMouseX - graphX());
    cp5.get(Textfield.class, "startFreqText").setText( str(clickFreq) );
  } else if (movingCursor == CURSORS.CUR_X_RIGHT) {
    cursorVerticalRightX = thisMouseX;
    int clickFreq = startFreq + hzPerPixel() * (thisMouseX - graphX());
    cp5.get(Textfield.class, "stopFreqText").setText( str(clickFreq) );
  } else if (movingCursor == CURSORS.CUR_Y_TOP) {
    cursorHorizontalTopY = thisMouseY;
    int clickScale = scaleMax - ( ( (thisMouseY - graphY()) * gainPerPixel() ) / 1000 ) ;
    cp5.get(Textfield.class, "scaleMaxText").setText(str(clickScale));
  } else if (movingCursor == CURSORS.CUR_Y_BOTTOM) {
    cursorHorizontalBottomY = thisMouseY;
    int clickScale = scaleMax - ( ( (thisMouseY - graphY()) * gainPerPixel() ) / 1000 ) ;
    cp5.get(Textfield.class, "scaleMinText").setText(str(clickScale));
  }

  if (mouseButton == RIGHT) {    // TAG01 RIGHT->LEFT was LEFT
    stroke(#606060);
    line( cursorVerticalLeftX, cursorHorizontalBottomY, mouseX, mouseY) ;
  } else if (mouseButton == CENTER) {
    stroke(#606060);
    line( dragGraphStartX, dragGraphStartY, mouseX, mouseY) ;
  }
}

void mouseReleased() {
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
    if (deltaDB != 0) {
      scaleMin += deltaDB;
      scaleMax += deltaDB;

      // Protections
      if (scaleMin < fullScaleMin) {
        scaleMin = fullScaleMin;
      }
      if (scaleMin > fullScaleMax) {
        scaleMin = fullScaleMin;
      }
      if (scaleMax < fullScaleMin) {
        scaleMax = fullScaleMin;
      }
      if (scaleMax > fullScaleMax) {
        scaleMax = fullScaleMax;
      }

      // Set new scales
      cp5.get(Textfield.class, "scaleMinText").setText( str(scaleMin) );
      cp5.get(Textfield.class, "scaleMaxText").setText( str(scaleMax) );

      setScale(1);
      println("deltaDB: " + numToStr(deltaDB) + ", -New Scale: \n" + "  LOWER:" + numToStr(scaleMin) + ",  UPPER:" + numToStr(scaleMax) );
    }

    // Move graph right/left
    if (abs(deltaF) > 10) {
      startFreq -= deltaF;
      stopFreq -= deltaF;

      // Protections
      if (startFreq < fullRangeMin) {
        startFreq = fullRangeMin;
      }
      if (startFreq > fullRangeMax) {
        startFreq = fullRangeMax;
      }
      if (stopFreq < fullRangeMin) {
        stopFreq = fullRangeMin;
      }
      if (stopFreq > fullRangeMax) {
        stopFreq = fullRangeMax;
      }

      // Set new scales
      cp5.get(Textfield.class, "startFreqText").setText( str(startFreq) );
      cp5.get(Textfield.class, "stopFreqText").setText( str(stopFreq) );

      println("deltaF: " + numToStr(deltaF) + ", -New Freq: \n" + "  START:" + numToStr(startFreq) + ",  STOP:" + numToStr(stopFreq) );

      setRange(1);
    }
  }
}


void mouseWheel(MouseEvent event) {
  final int NOTHING = 0;
  final int GAIN_HIGH = 1;
  final int GAIN_LOW = 2;
  final int FREQ_LEFT = 4;
  final int FREQ_RIGHT = 8;
  final int GRAPH_ZOOM = 16;
  final int TIME_UNTIL_SET = 25;
  final int TIME_UNTIL_SET_FAST = 10;

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
    } else if (  graphHeight() - gMouseY <  graphHeight()/4 ) {
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
    } else if (  graphWidth() - gMouseX <  graphWidth()/4 ) {
      toModify = FREQ_RIGHT;
    }
  }

  // Middle of graph on X and Y is for zoom
  //
  if ( abs( gMouseX - graphWidth()/2 ) < graphWidth()/4  && abs( gMouseY - graphHeight()/2 ) < graphHeight()/4 )
    toModify = GRAPH_ZOOM ;


  tmpFreq = 0;
  if (toModify > 0   ) {
    infoText1X = min( max( graphX() +90, mouseX), graphWidth() + 140 ) ;
    infoText1Y = max( graphY() +40, mouseY );
  }
  if ( stopFreq - startFreq > 50000000 ) freqStep = 10000000;
  else freqStep = 1000000;

  switch ( toModify ) {

  // GAIN ====================
  //
  case  GAIN_LOW:
    tmpGain = (( parseInt(cp5.get(Textfield.class, "scaleMinText").getText()) ) - event.getCount()) ;
    if (tmpGain < fullScaleMin ) tmpGain = fullScaleMin;
    if (tmpGain > fullScaleMax ) tmpGain = fullScaleMax-1;
    if (tmpGain >= scaleMax ) tmpGain = scaleMax - 1;
    cp5.get(Textfield.class, "scaleMinText").setText(str(tmpGain));
    infoText = str(tmpGain)  + " db" ;
    itemToSet = ITEM_GAIN;
    infoLineY = getGraphYfromDb( tmpGain  );

    timeToSet = TIME_UNTIL_SET;
    break;

  case  GAIN_HIGH:
    tmpGain = (( parseInt(cp5.get(Textfield.class, "scaleMaxText").getText()) ) - event.getCount()) ;
    if (tmpGain < fullScaleMin ) tmpGain = fullScaleMin + 1;
    if (tmpGain > fullScaleMax ) tmpGain = fullScaleMax;
    if (tmpGain <= scaleMin ) tmpGain = scaleMin + 1;
    cp5.get(Textfield.class, "scaleMaxText").setText(str(tmpGain));
    itemToSet = ITEM_GAIN;
    infoText = str(tmpGain)   + " db" ;
    infoLineY = getGraphYfromDb( tmpGain  );

    timeToSet = TIME_UNTIL_SET;
    break;

  // FREQUENCY ===================
  //
  case  FREQ_LEFT:
    tmpFreq = (( parseInt(cp5.get(Textfield.class, "startFreqText").getText()) /freqStep ) - event.getCount() )  * freqStep ;
    if (tmpFreq < fullRangeMin ) tmpFreq = fullRangeMin;
    if (tmpFreq > fullRangeMax ) tmpFreq = fullRangeMax;
    if (tmpFreq >= stopFreq ) tmpFreq = stopFreq - 1000000;
    cp5.get(Textfield.class, "startFreqText").setText(str(tmpFreq));
    itemToSet = ITEM_FREQUENCY;
    infoText = str( ifCorrectedFreq(tmpFreq) / 1000000 )  + " MHz" ;
    infoLineX = getGraphXfromFreq( tmpFreq );
    timeToSet = TIME_UNTIL_SET;
    break;

  case  FREQ_RIGHT:
    tmpFreq = (( parseInt(cp5.get(Textfield.class, "stopFreqText").getText()) / freqStep) - event.getCount())  * freqStep;
    if (tmpFreq < fullRangeMin ) tmpFreq = fullRangeMin;
    if (tmpFreq > fullRangeMax ) tmpFreq = fullRangeMax;
    if (tmpFreq <= startFreq ) tmpFreq = startFreq + 1000000;
    cp5.get(Textfield.class, "stopFreqText").setText(str(tmpFreq));
    itemToSet = ITEM_FREQUENCY;
    infoText = str( ifCorrectedFreq( tmpFreq )/ 1000000 ) + " MHz";
    infoLineX = getGraphXfromFreq( tmpFreq );
    timeToSet = TIME_UNTIL_SET;
    break;

  case GRAPH_ZOOM:
    scaleFreqOverDb =  (stopFreq - startFreq) / (scaleMax - scaleMin) ;  // How many Hz for each db
    tmpGain  = min( max( (( parseInt(cp5.get(Textfield.class, "scaleMinText").getText()) ) - event.getCount()), fullScaleMin), fullScaleMax) ;
    tmpGain2 = max( min( (( parseInt(cp5.get(Textfield.class, "scaleMaxText").getText()) ) + event.getCount()), fullScaleMax), fullScaleMin) ;
    if ( tmpGain2 <= tmpGain ) tmpGain2 = tmpGain + 2;
    if ( tmpGain == fullScaleMax ) {
      tmpGain = fullScaleMax-1;
      tmpGain2=fullScaleMax;
    }
    cp5.get(Textfield.class, "scaleMinText").setText(str(tmpGain));
    cp5.get(Textfield.class, "scaleMaxText").setText(str(tmpGain2));

    tmpFreq  =  min( max( parseInt(cp5.get(Textfield.class, "startFreqText").getText()) - scaleFreqOverDb * event.getCount(), fullRangeMin ), fullRangeMax )  ;
    tmpFreq2 =  max( min( parseInt(cp5.get(Textfield.class, "stopFreqText").getText())  + scaleFreqOverDb * event.getCount(), fullRangeMax ), fullRangeMin )  ;

    if (tmpFreq >= tmpFreq2) tmpFreq2 = tmpFreq + 10000000;

    cp5.get(Textfield.class, "startFreqText").setText(str(tmpFreq));
    cp5.get(Textfield.class, "stopFreqText").setText(str(tmpFreq2));

    if ( event.getCount() >0 ) infoText = "ZOOM OUT";
    else infoText="ZOOM IN";
    infoRectangle[0]= getGraphXfromFreq( tmpFreq );
    infoRectangle[1]= getGraphYfromDb( tmpGain);
    infoRectangle[2]= getGraphXfromFreq( tmpFreq2 ) - infoRectangle[0];
    infoRectangle[3]= ( getGraphYfromDb( tmpGain2) - infoRectangle[1]);

    itemToSet = ITEM_ZOOM;
    timeToSet = TIME_UNTIL_SET;
    break;
  }
}
