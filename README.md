spektrum
==========

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

Copyright
-----

Copyright (c) 2015 Pavel Šorejs. See LICENSE for further details.
