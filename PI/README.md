Raspberry Pi:

This folder contains the software part for the pi. 

setup:

If you are using a raspberry pi with bluetooth, the UART serial interface that we want to use for communication with the HM-10 bluetooth device is used by the raspberry pis built in bluetooth device. There are a lot of solutions to this problem, but since i am not using the built in bluetooth i chose to disable the built in device. This can be done by opening the terminal and entering:

cd /boot/
sudo nano config.txt

use the arrows to navigate to the bottom of the file and add the two lines:

dtoverlay=pi3-disable-bt
enable_uart=1

press: 
ctrl+x
Y
enter
to save the changes. 

This might be different in other PI or OS versions. 

Usage:
Download all files and run Remote.py to start adding/removing devices and signals. The interface is crude at best, but it should be easy to use and do the trick. Signals will be saved in json format at the directory and filename specified by the SIGNALS_FILENAME and SIGNALS_DIRECTORY constants at the top of RemoteUI.py. Change theese as you wish. A backup of the signals file will be created every time you run the Remote.py

----------------------------------------------------------------------------
1.IRCommands.py 

This module uses pigpio to read and playback IR Signals. It is working for the intended use, but hasn't been tested thouroghly. Make sure you run sudo pigpiod before use.

TODO:
- Remove all prints to terminal and implement these as exceptions, logs or move them to RemoteUI instead. User interaction should only happen in RemoteUI.py
- Run sudo pigpiod directly from script
- Implement as a class?
- Edit it to conform to the commenting and logging style of the project

----------------------------------------------------------------------------
2. IRCommandsInterface.py

An easier interface to the IRCommands and implemented saving/reading signals from/to json file. The format used for is a dict: {deviceName:signalName:[signal]}. The module is working for the intended use, but hasn't been tested thoroughly.

TODO:
- Remove all prints to terminal and implement these as exceptions or logging instead. User interaction should only happen in RemoteUI.py
- Combine with the IRCommands.py (in a class?)
----------------------------------------------------------------------------
3. RemoteUI.py

This is the terminal UI for creating/removing signals and devices from the signals file. Most functionality is implemented but not tested. It should also start the bluetooth daemon for bluetooth to IR communication.

TODO:
- All prints/reads to terminal should happen in this file, move this functionality from IRCommands.py and IRCommandsInterface.py
- Implementent bluetoothListener
- Add the possibility to rename signals/devices
----------------------------------------------------------------------------
4. FileHandler.py

Functions for reading/writing to/from files

TODO:
- Needs testing
- saveJson() will return false on IOError, should raise a customException and let other parts of the program handle this (Should ultimatly abort program)
----------------------------------------------------------------------------
5. CustomExceptions 

TODO:
- Up to date, implement more exceptions as needed
----------------------------------------------------------------------------
6. Logger.py

Implemented for easy adjustment of logging level and filepaths. All constants regarding logging should be contained in this file

TODO:
- Up to date.
----------------------------------------------------------------------------
7. BluetoothListener.py

This is the module that will normally be running to listen for bluetooth commands and transmit these over IR

TODO:
- Almost everything
 