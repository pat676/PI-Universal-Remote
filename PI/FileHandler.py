"""
Functions for reading/ writing to and from files
"""

import os
import json
import logging
from CustomExceptions import *
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
        logger.warning("No backup of {} was possible".format(filepath))
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
    logger.debug("Succsesfully read sequence file: {}".format(filepath))
    
    currentLine = 0
    #Read all lines, each line is one sequence
    for line in file:
        currentLine += 1
        cmds = line.split(":")
        sequences[cmds[0]] = list()
        i = 1
        #Create an array of all commands in that sequence
        while(i<len(cmds)):
            try:
                sequences[cmds[0]].append(cmds[i])
                sequences[cmds[0]].append(cmds[i+1])
                sequences[cmds[0]].append(float(cmds[i+2]))
            except IndexError:
                msg = "Error in sequence file: {} at line {}, wrong number of arguments".format(filepath, currentLine)
                logger.error(msg, exc_info=True)
                raise SequenceFormatException(msg)
            except ValueError:
                msg = "Error in sequence file: {} at line {}, word: {}, waittime not a valid number".format(filepath, currentLine, i+2+1)
                logger.error(msg , exc_info=True)
                raise SequenceFormatException(msg)
            i += 3
    logger.debug("Succsesfully parsed sequences from file: {} into dictionary".format(filepath))
    return sequences
    




