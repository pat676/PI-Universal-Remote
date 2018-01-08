"""
A simple interface to the IRCommands.py script.

This script allows reading/ playback of IR Signals as well as saving and loading these
signals to/from files.

"""
import IRCommands as ir
import FileHandler as fh

#Pins to recieve (GPIO_IN) and send (GPIO_OUT) IR Signals
GPIO_IN = 26
GPIO_OUT = 21

"""
Starts a loop reading new signals from user, the signals will be added to
signals[devicename] and the signals dict will be saved after each succsesfully
read signal.

Input:
    directory   (String): The directory of the file storing the signals
    filename    (String): The name of the file storing the signals
    devicename  (String): The device where the signal should be added
    signals     (Nested dict {devicenames:signalnames:[signal])
                The dictonary containing all signals
                
Output:
    None
    
Notes:
    parameter devicename is assumed to exist in the signals dictonary, else and exception
    will be thrown.
"""
def addSignalFromUser(devicename, signals):
    while True:
        name = raw_input("Please enter the signal name for device: {}, type 'q' when finished\n".format(devicename))
    
        if(name == "q"):
            return
        
        else:
            newSignal = ir.read(GPIO_IN, name)
            if newSignal:
                signals[devicename].update(newSignal)
            
def playback(signal):
    ir.playback(GPIO_OUT, signal)