# Spektrum

Spektrum is a spectrum analyzer software for use with [rtl-sdr](http://sdr.osmocom.org/trac/wiki/rtl-sdr).

The biggest advantage is that it can do sweeps across a large frequency span.

User interface part is written in [Processing](https://processing.org/)

FM frequency band             |  433 MHz antenna measurement
:-------------------------:|:-------------------------:
![ FM frequency band ](https://raw.githubusercontent.com/pavels/spektrum/master/screenshots/screen1.png)  |  ![ 433MHz antenna measurement ](https://raw.githubusercontent.com/pavels/spektrum/master/screenshots/screen2.png)

User interface with Tabs: | Area/Line option 
:-------------------------: | :-------------------------:
![ Latest UI ](https://github.com/pavels/spektrum/raw/master/screenshots/newUI01.png) |![Area graph option ](https://github.com/pavels/spektrum/raw/master/screenshots/FilledGraph.png)

Mouse wheel zoom from middle of graph: | Mouse wheel close to graph edges adjusts limits 
:-------------------------: | :-------------------------:
![ Mouse wheel zoom ](https://github.com/pavels/spektrum/raw/master/screenshots/zoomBox.png) |![Double right-click or ZOOM button ](https://github.com/pavels/spektrum/raw/master/screenshots/ChangingLowLimit.png)

The zoom area and measurements with cursors: | Zoomed in area 
:-------------------------: | :-------------------------:
![ Dual Cursor set ](https://github.com/pavels/spektrum/raw/master/screenshots/ZoomArea01.png) |![Double right-click or ZOOM button ](https://github.com/pavels/spektrum/raw/master/screenshots/ZoomArea02.png)

Drag graph with middle mouse button: | Area of interest centered 
:-------------------------: | :-------------------------:
![ Graph is not centered ](https://github.com/pavels/spektrum/raw/master/screenshots/moving01.png) |![After drag ](https://github.com/pavels/spektrum/raw/master/screenshots/moving02.png)

Reference save/display: |  Averaging (video)
:-------------------------: | :-------------------------:
![ Reference save/display ](https://github.com/pavels/spektrum/raw/master/screenshots/referenceGraph.png) | ![ Averaging ](https://github.com/pavels/spektrum/raw/master/screenshots/Averaging01.png) 

Min Max hold & Median: |  VHF band scan with Max hold
:-------------------------: | :-------------------------:
![ Min Max hold & Median: ](https://github.com/pavels/spektrum/raw/master/screenshots/MinMaxMedian.png) | ![ VHF band scan with Max hold ](https://github.com/pavels/spektrum/raw/master/screenshots/MaxHoldScanVHF.png) 

Basic support for IF. |  Average stored as a reference and shifted up.
:-------------------------: | :-------------------------:
![ Basic support for IF ](https://github.com/pavels/spektrum/raw/master/screenshots/upDownConverter.png) | ![ Average stored as a reference and shifted up. ](https://github.com/pavels/spektrum/raw/master/screenshots/referenceOffset.png) 

RTL Power croping : OFF. |  RTL Power croping : ON.
:-------------------------: | :-------------------------:
![ Croping off ](https://github.com/pavels/spektrum/raw/master/screenshots/crop-off.png) | ![ Croping on ](https://github.com/pavels/spektrum/raw/master/screenshots/crop-on.png) 

Quick Start
-----------

Grab the latest [release](https://github.com/pavels/spektrum/releases) for your OS and unpack it somewhere.

Connect and configure your rtl-sdr stick.

### Windows

get Zadiag tool - [https://zadig.akeo.ie/](https://zadig.akeo.ie/) and install WinUSB driver for your SDR dongle

### Linux

Get libusb-1.0 from your distribution repository

To prevent loading wrong driver, create `/etc/modprobe.d/rtl-sdr.conf` file with following content
```
blacklist dvb_usb_rtl28xxu
```

Create udev rule `/etc/udev/rules.d/20.rtlsdr.rules` to access as non-root user: 
```
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="adm", MODE="0666"
```

Launch the software.

Usage
-----

Usage is fairly simple

* Tweak parameters like frequency range, scale, tuner gain or offset tuning to suit your needs.
* Base display is average for each point, turn "min/max" to also see minimums and maximums for every displayed point.

Relative mode
-----

Relative mode allows you to "zero" the measurement and is useful for measurements with noise constant sources

You can find an example here [http://www.rtl-sdr.com/rtl-sdr-tutorial-measuring-filter-characteristics-and-antenna-vswr-with-an-rtl-sdr-and-noise-source/](http://www.rtl-sdr.com/rtl-sdr-tutorial-measuring-filter-characteristics-and-antenna-vswr-with-an-rtl-sdr-and-noise-source/)

* Connect your noise source
* Set desired frequency range
* Click "Relative mode"
* Wait a couple of sweeps - it will do a running average of all collected data
* Click "Set relative" to set the captured spectrum as reference. You should now see a fairly straight line around 0dB
* Connect antenna or filter and tweak gain so you see what is desired

SV Mod (version v0.19a)
---

This project incorporates so-called SV MOD developed by SV8ARJ (George), SV1SGK (Nick) and others, which brought the following changes:

- Added: 2 Cursors for Frequency axis.
- Added: 2 Cursors for Amplitude axis.
- Added: Absolute and differential measurements with cursors.
- Added: Zoom functionality of the cursor's defined area (gain + frequency).
- Added: _Mouse Wheel_ Gain limits adjustment on a graph (Top area for upper, Bottom area for lower limit).
- Added: _Mouse Wheel_ Frequency limits adjustment on a graph (left area for lower frequency, right for upper).
- Added: _Mouse Wheel_ in the center of the graph performs symmetric zoom in/out.
- Added: View/settings store/recall (elementary "back" operation, nice for quick zoomed-in graph inspection).
- Added: _Right click_ positions primary cursors.
- Added: _Right Double Click_ positions primary cursors and moves secondary out of the way.
- Added: _Right Click and Drag_ defines area using primary and secondary cursors, also interactive Delta measurements.
- Added: _Left Double Click_ zooms area defined by cursors (Amplitude + frequency).
- Added: _Left Mouse Click and Drag_ on a cursor moves the cursor.
- Added: _Middle (mouse wheel) Double Click_ resets full scale for Amplitude and Frequency.
- Added: _Middle (mouse wheel) Click and Drag_, moves the graph recalculating limits accordingly.
- Added: Reset buttons to Min/Max range next to Start and Stop frequency text boxes.
- Modified: Cursors on/off now operate on all 4 cursors.
- Added: ZOOM and BACK buttons.
- Added: Display of frequency, Amplitude, and differences for all cursors.
- Modified: Button layout.
- Fixed: Save/Reload settings on exit/start.
- Added: Filled graph option (line or area).
- Added: VSWR calculation display for the antenna tunning guys (delta dB from cursors to VSWR).
- Added: Reference graph save / display.
- Added: Video averaging, useful on fast refresh (zoomed in).
- Added: Minimum, Maximum hold (persistent display).
- Added: Median value display (middle value between Max and Min).
- Added: IF frequency basic support (only Upper band displays left to right in ascending order).
- Added: Average graph can be saved as reference (if active when "save reference" is clicked).
- Added: Vertical offset for reference graph (controlled from knob).
- Added: Quick help reference screen (mouse operation).
- Modified: RF gain is now a rotary knob plus 3 buttons for 1/3, 1/2 and 2/3 presets.
- Modified: Created a tabbed interface to make room for further development.
- Added: 9+1 Presets plus controls to modify and recall.
- Added: Graph smoothing using RTL crop. (rtlspektrum library wrapper recompiled to export the "crop" setting).
- Modified: Behaviour of mouse and delete key in text fields from [here](https://github.com/Viproz/controlp5/releases/tag/v2.2.7) (controIP5 library fix by @Viproz, Thanks !).

Big thanks to all participating on this massive extension to Spektrum.

Background
----

Two libraries are needed to run the code

* rtl-sdr rtlpower - special branch, where rtlpower is separated into library, so we don't need to run the binary rtlpower. 
* java bridge - processing library to interface with rtlpower

The rtl-sdr branch is located here: [https://github.com/pavels/rtl-sdr](https://github.com/pavels/rtl-sdr)

The processing library is here [https://github.com/pavels/processing-rtlspektum-lib](https://github.com/pavels/processing-rtlspektum-lib)

Development
----

You need 

* Processing development environment [https://processing.org/](https://processing.org/)
* rtlspektrum processing library [https://github.com/pavels/processing-rtlspektum-lib/releases](https://github.com/pavels/processing-rtlspektum-lib/releases) (unpack latest rtlspektrum.zip into your processing libraries folder)
* controlP5 processing library [https://github.com/sojamo/controlp5](https://github.com/sojamo/controlp5)

Contributing
-----
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.

Contributors
-----
 * [Contributors](https://github.com/pavels/spektrum/graphs/contributors)

Copyright
-----

Copyright (c) 2015 Pavel Šorejs & Contributors. See LICENSE for further details.
