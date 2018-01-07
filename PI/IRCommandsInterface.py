"""
A simple interface to the IRCommands.py script.

This script allows reading/ playback of IR Signals as well as saving and loading these
signals to/from files.

"""
import IRCommands as ir
import os
import json

#Pins to recieve (GPIO_IN) and send (GPIO_OUT) IR Signals
GPIO_IN = 26
GPIO_OUT = 21

"""
Does a backup of the given file.

Input:
    filepath    (String): The path of the file
    maxBackups  (Int)  : Maximum number of backups kept at once
    
Output:
    Returns True if at least one backup is made, false else
"""
def backup(filepath, maxBackups = 3):
    """
    filename -> filename.bak -> filename.bak1 -> filename.bak2
    """
    for i in range(maxBackups,0,-1):
        try:
            oldPath = os.path.realpath(filepath)+".bak{}".format(i-1)
            newPath = os.path.realpath(filepath)+".bak{}".format(i)
            os.rename(oldPath,newPath)
        except OSError:
            pass

    try:
        os.rename(os.path.realpath(filepath), os.path.realpath(filepath)+".bak1")
    except:
        return False
        pass
    return True
    
"""
Reads the file containing the signals dict in json format. Returns an empty dict
if the filepath cant be read.

Input:
    filepath    (String): The path of the file
    errorMSg    (Bool)  : If true a msg will be printed if the file cant be loaded
Output:
    Loaded signals dict if succsesfull, empty signal dict else
    
"""
def readSignalsFile(filepath, errorMsg = False):
    try:
        f = open(filepath, "r")
        signals = json.load(f)
        f.close()
    except:
        if(errorMsg):
            print("Can't open: {} for loading signals, returning empty signals dict".format(file))
        signals = {}
        
    return signals

"""
Saves the signals in json format to given directory/filename. If the file or directory
do not exist the function try to make them. If this fails it will return False

Input:
    directory   (String): The directory of the file storing the signals
    filename    (String): The name of the file storing the signals
    signals     (Nested dict {devicenames:signalnames:[signal])
                The dictonary containing all signals
                
Output:
    True on succsess False else
"""
def saveSignalsFile(directory, filename, signals):
    filepath = directory+filename
    
    if not os.path.isdir(directory):
        try:
            os.mkdir(directory)
        except:
            print("Can't create directory: {} for saving".format(directory))
            return False
    try:
        f = open(filepath, "w")
    except:
        print("Can't open file: {} for saving".format(filepath))
        return False
    
    saveStr = json.dumps(signals, sort_keys=True)
    saveStr = saveStr.replace("],", "],\n" )
    saveStr = saveStr.replace("},", "},\n")
    saveStr = saveStr.replace(" {", " {\n ")
    f.write(saveStr + "\n")
    f.close()
    return True

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
def addSignalFromUser(directory, filename, devicename, signals):
    filepath = directory+filename
    while True:
        name = raw_input("Please enter the signal name for device: {}, type 'q' when finished\n".format(devicename))
    
        if(name == "q"):
            return
        
        else:
            newSignal = ir.read(GPIO_IN, name)
            if newSignal:
                signals[devicename].update(newSignal)
                saveSignalsFile(directory, filename, signals)
            
def playback(signal):
    ir.playback(GPIO_OUT, signal)