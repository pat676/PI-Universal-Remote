"""
Functions for reading/ writing to and from files
"""

import os
import json
import logging

LOGS_DIRECTORY = "./LOGS/"
LOGS_FILENAME  = "main.log"
LOGS_LEVEL     = logging.DEBUG

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
    except:
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
    except:
        logger.debug("File {} could not be read, return empty dict".format(filepath))
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
        except:
            logger.warning("Can't create directory: {} for saving".format(directory))
            return False
    try:
        f = open(filepath, "w")
    except:
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
Returns a logger saving log to file

Innput:
    level       (Logger level): Severity of the logger
    name:       (String):       Name of the logger
    directory   (String):       The directory of the log file
    filename    (String):       The name of the logfile
Output:
    The logger
"""
def getLogger(level, name, directory, filename):
    if not os.path.isdir(directory):
        os.mkdir(directory)
        
    logger = logging.getLogger(name)
    logger.setLevel(level)
    handler = logging.FileHandler(directory+filename)
    handler.setLevel(level)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger

logger = getLogger(LOGS_LEVEL, __name__, LOGS_DIRECTORY, LOGS_FILENAME)