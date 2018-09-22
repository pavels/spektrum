spektrum
==========
**UI improvements by SV1SGK and SV8ARJ. W.I.P.**

Goals : 
-------
To make an excellent utility easy to use.
Soon with you.
73's from Nick and George.

Progress so far 
---------------
- Added: 2 Cursors for Frequency axis.
- Added: 2 Cursors for Amplitude axis.
- Added: Absolute and differential measurements with cursors.
- Added: Zoom functionality of the cursors's defined area (gain + frequency).
- Added: _Mouse Wheel_ Frequency limits adjustment on graph (Top area for upper, low area for lower).
- Added: _Mouse Wheel_ Gain limits adjustment on graph (left area for lower frequency, right for upper).
- Added: _Mouse Wheel_ in the centrer of the graph performs symetric zoom in/out.
- Added: View/settings store/recall (elementary "back" operation, nice for quick zoomed in graph inspection).
- Added: _Left click_ positions primary cursors.
- Added: _Left Double Click_ positions primary cursors and moves secondary out of the way.
- Added: _Right Double Click_ zooms area defined by cursors (Amplitude + frequency).
- Added: _Right mouse Click and Drag_ on a cursor moves the cursor.
- Added: _Middle (mouse wheel) Double Click_ resets full scale for Amplitude and Frequency.
- Added: _Middle (mouse wheel) Click and Drag_, moves the graph recalculating limits accordingly.
- Added: Reset buttons to Min/Max range next to Start and Stop frequency text boxes.
- Modified: Cursors on/off now operate on all 4 cursors.
- Added: ZOOM and BACK buttons.
- Added: Display of frequency, Amplitude and differences for all cursors.
- Modified: Button layout.
- Fixed: Save/Reload settings on exit/start. IMPORTANT : delete the "data" folder from the installation location if you have it.

User interface: | Mouse wheel close to graph edges adjusts limits 
:-------------------------: | :-------------------------:
![ Dual Cursor set ](https://github.com/SV8ARJ/spektrum/blob/master/screenshots/DefiningAreaWithCursors01.png) |![Double right click or ZOOM button ](https://github.com/SV8ARJ/spektrum/blob/master/screenshots/ChangingLowLimit.png)

The zoom area and measurements with cursors: | Zoomed in area 
:-------------------------: | :-------------------------:
![ Dual Cursor set ](https://github.com/SV8ARJ/spektrum/blob/master/screenshots/ZoomArea01.png) |![Double right click or ZOOM button ](https://github.com/SV8ARJ/spektrum/blob/master/screenshots/ZoomArea02.png)

Drag graph with middle mouse button: | Area of interest centered 
:-------------------------: | :-------------------------:
![ Graph is not centered ](https://github.com/SV8ARJ/spektrum/blob/master/screenshots/moving01.png) |![After drag ](https://github.com/SV8ARJ/spektrum/blob/master/screenshots/moving02.png)




Original readme starts here:
----------------------------



Spektrum is spectrum analyzer software for use with [rtl-sdr](http://sdr.osmocom.org/trac/wiki/rtl-sdr).

Biggest advantage is that it can do sweeps across large frequency span.

User interface part is written in [Processing](https://processing.org/)

FM frequency band             |  433 MHz antenna measurement
:-------------------------:|:-------------------------:
![ FM frequency band ](https://raw.githubusercontent.com/pavels/spektrum/master/screenshots/screen1.png)  |  ![ 433MHz antenna measurement ](https://raw.githubusercontent.com/pavels/spektrum/master/screenshots/screen2.png)

Vertical Cursor

![ Display Sample Dots ](https://raw.githubusercontent.com/dnegrych/spektrum/master/screenshots/screenVerticalCursor.png)

Display Sample Dots

![ Display Sample Dots ](https://raw.githubusercontent.com/dnegrych/spektrum/master/screenshots/screenShowSampleDots.png)

Quick Start
-----------

Grab the latest [release](https://github.com/pavels/spektrum/releases) for your OS and unpack it somewhere.

Connect and configure your rtl-sdr stick ( follow [this guide](http://rtlsdr.org/softwarewindows) for windows).

Launch the software.

**If you are running windows version and only thing you see is grey screen, you need to install Visual C++ Redistributable for Visual Studio 2012 - Get them from [http://www.microsoft.com/en-us/download/details.aspx?id=30679](http://www.microsoft.com/en-us/download/details.aspx?id=30679)**

Usage
-----

Usage is fairly simple

* Tweak parameters like frequency range, scale, tuner gain or offset tuning to suite your needs.
* Base display is average for each point, turn "min/max" to also see minimums and maximums for every displayed point.

Relative mode
-----

Relative mode allows you to "zero" the measurement and is useful for measurements with noise constant sources

You can find example here [http://www.rtl-sdr.com/rtl-sdr-tutorial-measuring-filter-characteristics-and-antenna-vswr-with-an-rtl-sdr-and-noise-source/](http://www.rtl-sdr.com/rtl-sdr-tutorial-measuring-filter-characteristics-and-antenna-vswr-with-an-rtl-sdr-and-noise-source/)

* Connect your noise source
* Set desired frequency range
* Click "Relative mode"
* Wait couple of sweeps - it will do running average of all collected data
* Click "Set relative" to set captured spectrum as reference. You should now see fairly straight line around 0dB
* Connect antenna or filter and tweak gain so you see what is desired

Background
----

Two libraries is needed to run the code

* rtl-sdr rtlpower - special branch, where rtlpower is separated into library, so we don't need to run the binary rtlpower. 
* java bridge - processing library to interface with rtlpower

The rtl-sdr branch is located here: [https://github.com/pavels/rtl-sdr](https://github.com/pavels/rtl-sdr)

The processing library is here [https://github.com/pavels/processing-rtlspektum-lib](https://github.com/pavels/processing-rtlspektum-lib)

Development
----

You need 

* Processing development environment [https://processing.org/](https://processing.org/)
* rtlspektrum processing library [https://github.com/pavels/processing-rtlspektum-lib/releases](https://github.com/pavels/processing-rtlspektum-lib/releases) (unpack latest rtlspektrum.zip into your processing libraries folder)

What is missing?
----

* Bugfixes - yep, there is most certainly bugs
* Cursors - proper cursors for measurement would be nice
* Better UX - the UI is pile of controls, no design, nothing
* Better README - this one is a bit crude


Contributing
-----
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.

Contributors
-----
 * [dnegrych](https://github.com/dnegrych)

Copyright
-----

Copyright (c) 2015 Pavel Šorejs. See LICENSE for further details.
