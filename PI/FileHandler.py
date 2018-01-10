"""
Functions for reading/ writing to and from files
"""

import os
import json
import logging
from Logger import *

logger = getLogger(LOGS_LEVEL, __name__, LOGS_DIRECTORY, FILEHANDLER_LOGS_FILENAME)


def backup(filepath, maxBackups = 3):
    """
    Does a backup of the given file.
    
    filename -> filename.bak -> filename.bak1 -> filename.bak2
    
    Args:
        filepath    (String): The path of the file
        maxBackups  (Int)  : Maximum number of backups kept at once
        
    Returns:
        Returns True if at least one backup is made, False else
    """
    logger.debug("Performing backup of {}, maxBackups: {}".format(filepath, maxBackups))

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
    

def readJson(filepath):
    """
    Reads a json file.
    
    Args:
        filepath    (String): The path of the file
    Returns:
        A dict containing the content of file if succsesfull, else an empty dict
    """
    logger.debug("Reading Json: {}".format(filepath))
    
    try:
        f = open(filepath, "r")
        content = json.load(f)
        f.close()
    except IOError:
        logger.info("File {} could not be read, return empty dict".format(filepath), exc_info = True)
        content = {}
        
    return content
    
    

def saveJson(directory, filename, data):
    """
    Saves the data dictionary in json format to given directory/filename.
    
    Since it normally will be pointless to continue without saving
    the function will raise an error if it failes
    
    Args:
        directory   (String): The directory of the file storing the signals
        filename    (String): The name of the file storing the signals
        data        (dict)  : The dictionary that will be saved
                    
    Returns:
        None
    """
    filepath = directory+filename
    logger.debug("Saving JSON to: {}".format(filepath))
    
    if not os.path.isdir(directory):
        try:
            os.mkdir(directory)
        except OSError as e:
            logger.error("Can't create directory: {} for saving".format(directory))
            raise
    try:
        f = open(filepath, "w")
    except IOError as e:
        logger.error("Attempt to open file: {} for writing failed".format(filepath))
        raise
    
    #Format the json text into a readable format
    saveStr = json.dumps(data, sort_keys=True)
    saveStr = saveStr.replace("],", "],\n" )
    saveStr = saveStr.replace("},", "},\n")
    saveStr = saveStr.replace(" {", " {\n ")
    
    f.write(saveStr + "\n")
    f.close()



def loadSequences(filepath):
    """
    Loads a sequence file containing a sequence of commands to be sent over IR.
    The sequence file should have the format:
    
    sequenceName1:device1:signal1:waittime1:device2:signal2:waittime2.....
    sequenceName2:device1:signal1:waittime1:device2:signal2:waittime2.....
    .....
        
    waittime is the time in seconds before next transmission
        
    Lines with invalid format will be skipped, but noted by logger.error
    
    Args:
        filepath    (String): The path of the sequence file
    Returns:
        Returns the sequences dict if sucsessfull, False else
        Output dict format: {sequenceName:[device1,signal1,waittime1,device2,signal2,waittime2,....]}
    """
    logger.debug("Reading sequences file: {}".format(filepath))
    
    sequences = {}
    try:
        file = open(filepath, "r")
    except IOError:
        logger.warning("Cant open sequencefile: {}".format(filepath))
        return False

    currentLine = 0
    
    for line in file:
        line = line.rstrip() #Removes trailing whitespace and newline
        currentLine += 1
        
        if(line[0] == "#" or line == ""):
            continue
        
        cmds = line.split(":")
        
        sequenceName = cmds[0]
        if(sequenceName in sequences):
            logger.warning("sequences file contained sequence: {} more than once, only the last can be used".format(cmds[0]))
        sequences[cmds[0]] = list()
        
        noError = True
        i = 1

        while(i<len(cmds) and noError):
            
            try:
                sequences[sequenceName].append(cmds[i])
                sequences[sequenceName].append(cmds[i+1])
                sequences[sequenceName].append(float(cmds[i+2]))
            
            except IndexError:
                msg = "Error in sequence file: {} at line {}, wrong number of arguments, skipping sequence".format(filepath, currentLine)
                logger.error(msg, exc_info=True)
                sequences.pop(cmds[0])
                noError = False
            
            except ValueError:
                msg = "Error in sequence file: {} at line {}, word: {}, waittime not a valid number".format(filepath, currentLine, i+2+1)
                logger.error(msg , exc_info=True)
                sequences.pop(cmds[0])
                noError = False
                
            i += 3
    return sequences


def loadBluetoothSignals(filepath):
    """
    Loads a file with bluetooth signals
    
    Format of file should be:
    
    For running one IR Signal:
    bluetoothSignal:sig:deviceName:signalName
        
    For running a sequence:
    bluetoothSignal:seq:sequenceName
        
    The second paramater has to be sig(Signal) or seq(Sequence), the rest is user defined.
    
    Args:
        filepath    (String): The path of the bluetooth signal file
    Returns:
        Bluetooth signal dict if successfull, False else
        Bluetooth signal dict format:{bluetoothSignals:[sig/seq,deviceName/sequenceName,signalName(if sig)]}
    """
    logger.debug("Reading Bluetooth signals file: {}".format(filepath))
    bluetoothSignals = {}

    try:
        file = open(filepath, "r")
    except IOError:
        logger.warning("Cant open Bluetooth signals file: {}".format(filepath))
        return False
    

    currentLine = 0
    for line in file:
        line = line.rstrip() #Remove trailing whitespace and newline
        currentLine += 1
        
        if(line[0] == "#" or line == "" or line == "\n"):
            continue
        
        args = line.split(":")
        
        if(not bluetoothSignalFormatIsCorrect(args)):
            logger.error("Incorrect format at line: {}, skipping signal: {}".format(currentLine, args[0]))
            continue
        
        signalName = args[0]
        if(signalName in bluetoothSignals):
            logger.warning("Bluetooth signals file contained signal: {} more than once, last at line: {} only the last can be used".format(args[0], currentLine))
        
        bluetoothSignals[signalName] = list()
        bluetoothSignals[signalName].append(args[1])
        bluetoothSignals[signalName].append(args[2])
        if(args[1] == "sig"):
            bluetoothSignals[signalName].append(args[3])
            
    return bluetoothSignals

def bluetoothSignalFormatIsCorrect(args):
    """
    Checks if the format of a bluetooth signal is correct

    Util function used by loadBluetoothSignals(). Checks if the args array is the correct format for a
    bluetooth signal

    args[0] is the name of the signal and can be any valid string.
    args[1] should be sig or seq
    if args[1] is sig the length should be 4, else the length should be 3
    
    Args:
        args    (String array): The parameters for the bluetooth signal
    Returns:
        True if correct, False else
    """
    
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