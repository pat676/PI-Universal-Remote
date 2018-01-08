"""
Functions for reading/ writing to and from files
"""

import os
import json
import logging
from Logger import *

logger = getLogger(LOGS_LEVEL, __name__, LOGS_DIRECTORY, FILEHANDLER_LOGS_FILENAME)

"""
Does a backup of the given file.

Input:
    filepath    (String): The path of the file
    maxBackups  (Int)  : Maximum number of backups kept at once
    
Output:
    Returns True if at least one backup is made, false else
"""

def backup(filepath, maxBackups = 3):
    logger.debug("Performing backup of {}".format(filepath))
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
    except OSError:
        logger.info("No backup of {} was possible".format(filepath))
        return False
        pass
    return True
    
"""
Reads a json file.

Input:
    filepath    (String): The path of the file
Output:
    A dict containing the content of file if succsesfull, else an empty dict
    
"""
def readJson(filepath):
    logger.debug("Attempting to read: {}".format(filepath))
    try:
        logger.debug("File {} read".format(filepath))
        f = open(filepath, "r")
        content = json.load(f)
        f.close()
    except IOError:
        logger.info("File {} could not be read, return empty dict".format(filepath), exc_info = True)
        content = {}
        
    return content
    
    
"""
Saves the data dictionary in json format to given directory/filename.

Input:
    directory   (String): The directory of the file storing the signals
    filename    (String): The name of the file storing the signals
    data        (dict)  : The dictionary that will be saved
                
Output:
    True on succsess False else
    
Notes:
    If the file or directory doesnt exist they will be created.
"""
def saveJson(directory, filename, data):
    filepath = directory+filename
    logger.debug("Attempting to save JSON to: {}".format(filepath))
    
    if not os.path.isdir(directory):
        try:
            os.mkdir(directory)
        except OSError:
            logger.warning("Can't create directory: {} for saving".format(directory))
            return False
    try:
        f = open(filepath, "w")
    except IOError:
        logger.warning("Can't open file: {} for saving".format(filepath))
        return False
    
    saveStr = json.dumps(data, sort_keys=True)
    saveStr = saveStr.replace("],", "],\n" )
    saveStr = saveStr.replace("},", "},\n")
    saveStr = saveStr.replace(" {", " {\n ")
    f.write(saveStr + "\n")
    f.close()
    logger.debug("Saved JSON to: {}".format(filepath))
    return True

"""
Loads a sequence file containing a sequence of commands to be sent over IR.

Input:
    filepath    (String): The path of the sequence file
Output:
    Returns the sequences dict if sucsessfull.
Notes:
The sequence file should have the format:

sequenceName1:device1:signal1:waittime:device2:signal2:waittime.....
sequenceName2:device1:signal1:waittime:device2:signal2:waittime.....
.....

waittime is the time in seconds before next transmission

"""

def loadSequences(filepath):
    logger.debug("Attempting to read sequence file: {}".format(filepath))
    sequences = {}
    
    #Opens file
    try:
        file = open(filepath, "r")
    except IOError:
        logger.warning("Cant open sequencefile: {}".format(filepath))
        return False
    logger.debug("Successfully read sequence file: {}".format(filepath))
    
    currentLine = 0
    
    #Read all lines, each line is one sequence
    for line in file:
        line = line.rstrip() #Remove trailing whitespace
        currentLine += 1
        
        #Skips comments and empty lines
        if(line[0] == "#" or line == ""):
            continue
        
        cmds = line.split(":")
        
        #Check if sequence name allready exists in dict
        if(cmds[0] in sequences):
            logger.warning("sequences file contained sequence: {} more than once, only the last can be used".format(cmds[0]))
        sequences[cmds[0]] = list()
        
        noError = True
        i = 1
        #Create an array of all commands in that sequence
        while(i<len(cmds) and noError):
            
            try:
                sequences[cmds[0]].append(cmds[i])
                sequences[cmds[0]].append(cmds[i+1])
                sequences[cmds[0]].append(float(cmds[i+2]))
            
            #Sequence format error, skipping sequence
            except IndexError:
                msg = "Error in sequence file: {} at line {}, wrong number of arguments, skipping sequence".format(filepath, currentLine)
                logger.error(msg, exc_info=True)
                sequences.pop(cmds[0])
                noError = False
            
            #Sequence format error, skipping sequence
            except ValueError:
                msg = "Error in sequence file: {} at line {}, word: {}, waittime not a valid number".format(filepath, currentLine, i+2+1)
                logger.error(msg , exc_info=True)
                sequences.pop(cmds[0])
                noError = False
                
            i += 3
            
    logger.debug("Successfully parsed sequences from file: {} into dictionary".format(filepath))
    return sequences
    
def loadBluetoothSignals(filepath):
    logger.debug("Attempting to read Bluetooth signals file: {}".format(filepath))
    bluetoothSignals = {}
    
    #Opens file
    try:
        file = open(filepath, "r")
    except IOError:
        logger.warning("Cant open Bluetooth signals file: {}".format(filepath))
        return False
    logger.debug("Successfully read Bluetooth signals file: {}".format(filepath))
    
    #Reads all lines
    logger.debug("Starting to add bluetooth signals")
    currentLine = 0
    for line in file:
        line = line.rstrip() #Remove trailing whitespace
        currentLine += 1
        
        #Skip comments and empty lines
        if(line[0] == "#" or line == "" or line == "\n"):
            continue
        
        args = line.split(":")
        
        #Checking if format is correct
        if(not bluetoothSignalFormatIsCorrect(args)):
            logger.error("Incorrect format at line: {}, skipping signal: {}".format(currentLine, args[0]))
            continue
        
        #Check if Bluetooth signal allready exists in dict
        if(args[0] in bluetoothSignals):
            logger.warning("Bluetooth signals file contained signal: {} more than once, last at line: {} only the last can be used".format(args[0], currentLine))
        
        #Adding Bluetooth signal
        logger.debug("Adding bluetooth signal: {}".format(args))
        bluetoothSignals[args[0]] = list()
        bluetoothSignals[args[0]].append(args[1])
        bluetoothSignals[args[0]].append(args[2])
        if(args[1] == "sig"):
            bluetoothSignals[args[0]].append(args[3])
    return bluetoothSignals

def bluetoothSignalFormatIsCorrect(args):
    #Check length
    if((not len(args) == 4) and (not len(args) == 3)):
        logger.error("Bluetooth signal: {} incorrect, number of arguments should be 3 or 4, but is: {}".format(args[0], len(args)))
        return False
        
    #Check first if first argument equals seq or sig
    if((not args[1] == "sig") and (not args[1] == "seq")):
        logger.error("Bluetooth signal: {} incorrect, first argument should be sig or seq, but is: {}".format(args[0], len(args)))
        return False
    
    #Check if sig and length != 4
    if((args[1] == "sig") and (not len(args) == 4)):
        logger.error("Bluetooth signal: {} incorrect, arguments[1] is sig, meaning that number of arguments should be 4, but number of arguments are: {}".format(args[0], len(args)))
        return False
    
    #Check if seq and length != 3
    if((args[1] == "seq") and (not len(args) == 3)):
        logger.error("Bluetooth signal: {} incorrect, arguments[1] is seq, meaning that number of arguments should be 3, but number of arguments are: {}".format(args[0], len(args)))
        return False
        
    return True