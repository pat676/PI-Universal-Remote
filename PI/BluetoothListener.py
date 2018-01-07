import serial
import FileHandler as fh
import logging
from CustomExceptions import *
from Logger import *

port = serial.Serial("/dev/ttyAMA0", baudrate=9600)
EOS = ";" #End of signal symbol

signals = {}
sequences = {}

logger = fh.getLogger(LOGS_LEVEL, __name__, LOGS_DIRECTORY, BLUETOOTHLISTENER_LOGS_FILENAME)

def main(signalsFilePath, sequencesFilePath):
    logger.debug("Running the IR ")
    signals = fh.readJson(signalsFilePath)
    if(len(signals) == 0):
        logger.warning("No signals found in {}".format(signalsFilePath))
        
    #Reading stored sequences
    try:
        sequences = fh.loadSequences(sequencesFilePath)
        if(not sequences):
            #This might be intended if no sequence file is created
            logger.warning("Could not open sequence file: sequnceFilePath")
    except SequenceFormatException as e:
        logger.error(e.message,exc_info = True)
        exit(0)
    
    #mainLoop()
    
def mainLoop():
    while True:
        signal = ""
        while True:
            rcv = port.read()
            if rcv == EOS:
                break
            else:
                signal += rcv
        print(signal)
        
    
        
