Raspberry Pi:

This folder contains the software part for the pi. 

setup:

If you are using a raspberry pi with bluetooth, the UART serial interface that we want to use for 
comunication with the HM-10 bluetooth device is used by the raspberry pis built in bluetooth device. 
There are a lot of solutions to this problem, but since i am not using the built in bluetooth i chose
to disable the built in device. This can be done by opening the terminal and entering:

cd /boot/
sudo nano config.txt

use the arrows to navigate to the bottomn of the file and add the two lines:

dtoverlay=pi3-disable-bt
enable_uart=1

press: 
ctrl+x
Y
enter
to save the changes. 

This might be different in other PI or OS versions. 

Usage:
Download all files and run Remote.py to start adding/removing devices and signals. The interface is
crude at best, but it should be easy to use and do the trick. Signals will be saved in json format 
at the directory and filename specified by the SIGNALS_FILENAME and SIGNALS_DIRECTORY constants at the
top of RemoteUI.py. Change theese as you wich. A backup of the signals file will be created every time
you run the Remote.py

----------------------------------------------------------------------------
1.IRCommands.py 

This module uses pigpio to read and playback IR Signals. It is working for the intended use, 
but hasn't been tested thouroghly. Make sure you run sudo pigpiod before use.

TODO:
- Remove all prints to terminal and implement these as exceptions or move them to RemoteUI instead. 
  User interaction should only happen in RemoteUI.py
- Run sudo pigpiod directly from script
- Implement as a class
----------------------------------------------------------------------------
2. IRCommandsInterface.py

An easier interface to the IRCommands and implemented saving/reading signals from/to json file. The format
used for is a dict: {deviceName:signalName:[signal]}. The module is working for the intended use, but 
hasn't been tested thouroghly.

TODO:
- Remove all prints to terminal and implement these as exceptions instead. User interaction should only
  happen in RemoteUI.py
- Combine with the IRCommands.py in a class
----------------------------------------------------------------------------
3. RemoteUI.py

This is the terminal UI for creating/removing signals and devices from the signals file. Most functionallity
is implemented but not tested. It should also start the bluetoothDeamon for bluetooth to IR communication.

TODO:
- All prints/reads to terminal should happen in this file, move this functionallity from IRCommands.py and 
  IRCommandsInterface.py
- Implementent bluetooth deamon
- Add functionality for sending a sequence of commands with a pause between each signal. Suggested file 
  format:

sequencename:devicename:Signalname:waittime:devicename:signalname:waittime:.......\n
sequencename:devicename:Signalname:waittime:devicename:signalname:waittime:.......\n
......

newline will signify the end of a sequence. This format is choosen instead of json so it will be easy to 
manually the sequences in a text file. If sequence creation is implemented in terminal UI or GUI instead 
json format will be prefered. 
----------------------------------------------------------------------------