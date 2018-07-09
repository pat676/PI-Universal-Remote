Raspberry Pi:

This folder contains the software part for the pi. It is written for Python 3

- Setup:

If you are using a raspberry pi with bluetooth, the UART serial interface that we want to use for communication with the HM-10 bluetooth device is used by the raspberry pis built in bluetooth device. There are a lot of solutions to this problem, but since i am not using the built in bluetooth i chose to disable the built in device. This can be done by opening the terminal and entering:

sudo nano /boot/config.txt

use the arrows to navigate to the bottom of the file and add the two lines:

dtoverlay=pi3-disable-bt

enable_uart=1

To save the changes press:
ctrl+x
Y
enter

This might be different in other PI or OS versions.

- This module needs the pigpiod, to autorun this daemon every startup open a terminal and enter:

sudo systemctl enable pigpiod.service

- To autorun the bluetooth listener at startup, first install crontab:

sudo apt-get install gnome-schedule

- Then run: crontab -e and add this line to the file:

@reboot cd "your full path of PI folder" && python3 RemoteUI.py -b

These commands are run as root on startup, so you have to specify path from the root folder (cd /)

Example:

@reboot cd /home/pi/Desktop/UniversalRemote/PI && python3 RemoteUI.py -b

Usage:

Bluetooth signals have to be defined manually. An example file commenting how to do this can be found in the SignalFiles directory

Sequences of several IR-Signals can be defined manually in the sequence file found in the SignalFiles directory, but the program will run without the sequence file.

Run with:
$:python3 RemoteUI.py

1) Add devices IR-Signals with the menu
2) Run a test (currently option 6 in the main menu) to check that all bluetooth signals you defined in the
   bluetooth signals file have a mathing IR-Signal or sequence.
3) Run the bluetooth listener(Currently option 5 in the main menu) 
   If you implemented autorun of bluetooth listener at startup do a reboot instead (Or kill process).

----------------------------------------------------------------------------
1.IRInterface.py

This module uses pigpio to read and playback IR Signals. It is working for the intended use, but hasn't been tested thouroghly. Make sure you run sudo pigpiod before use.

TODO:
- Remove all prints to terminal and implement these as exceptions, logs or move them to RemoteUI instead. User interaction should only happen in RemoteUI.py
- Run sudo pigpiod directly from script
- Edit it to conform to the commenting and logging style of the project

----------------------------------------------------------------------------
2. RemoteUI.py

This is the terminal UI for creating/removing signals and devices from the signals file. Most functionality is implemented but not tested. It should also start the bluetooth daemon for bluetooth to IR communication.

TODO:
- All prints/reads to terminal should happen in this file, move this functionality from IRCommands.py and IRCommandsInterface.py
- Add the possibility to rename signals/devices
- Add user test to check if every IRSignal in every sequence matches an IRSignal in the IR Signals file
- Add user test to check hardware connections

----------------------------------------------------------------------------
3. FileHandler.py

Functions for reading/writing to/from files

TODO:
- Add test functions
----------------------------------------------------------------------------
4. Logger.py

Implemented for easy adjustment of logging level and logfilepaths. All constants regarding logging should be contained in this file

TODO:
- Up to date.
----------------------------------------------------------------------------
5. BluetoothListener.py

This is the module that will normally be running to listen for bluetooth signals and transmiting IR Signals

TODO:
- Add test functions
 