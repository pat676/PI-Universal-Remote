import logging
import os
from config import *

def getLogger(level, name, directory, filename):
    """
    Returns a logger saving log to file
    
    Args:
        level       (Logger level): Severity of the logger
        name:       (String):       Name of the logger
        directory   (String):       The directory of the log file
        filename    (String):       The name of the logfile
    Returns:
        The logger
    """
    
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