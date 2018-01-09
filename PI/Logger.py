import logging
import os

#Logging

LOGS_LEVEL = logging.WARNING #Change to logging.DEBUG for more informtion
logging.basicConfig(level=LOGS_LEVEL) #Uncomment for logging to terminal
LOGS_DIRECTORY = "./LOGS/"
BLUETOOTHLISTENER_LOGS_FILENAME  = "BluetoothListener.log"
FILEHANDLER_LOGS_FILENAME  = "FileHandler.log"
REMOTEUI_LOGS_FILENAME = "RemotesUI"

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