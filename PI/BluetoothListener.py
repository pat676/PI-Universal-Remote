import serial
import FileHandler as fh
import logging
import IRCommandsInterface as irci
from Logger import *
import time

port = serial.Serial("/dev/ttyAMA0", baudrate=9600)
EOS = ";" #End of signal symbol

IRSignals = {}
sequences = {}
bluetoothSignals = {}

PLAYBACK_TIMES = 3 #Transmits each IRSignal this many times
PLAYBACK_SLEEP = 0.05 #Sleeps this amount of time between each transmission

logger = fh.getLogger(LOGS_LEVEL, __name__, LOGS_DIRECTORY, BLUETOOTHLISTENER_LOGS_FILENAME)
    
def mainLoop(signalsFilePath, sequencesFilePath, bluetoothSignalsFilePath):
    
    if not readSignalFiles(signalsFilePath, sequencesFilePath, bluetoothSignalsFilePath):
        logger.error("Aborting main loop") #Bluetooth or IR-Signals are missing
        return
    
    while True:
        bluetoothSignal = ""
        while True:
            rcv = port.read()
            logger.debug("Recieved bluetooth char: {}".format(rcv))
            if rcv == EOS:
                runSignal(bluetoothSignal)
                break
            else:
                bluetoothSignal += rcv
        
        
def runSignal(bluetoothSignal):
    logger.debug("Recieved Run command for bluetoothSignal: {}".format(bluetoothSignal))
    if bluetoothSignal in bluetoothSignals:
        bSig = bluetoothSignals[bluetoothSignal]
        
        if bSig[0] == "sig":
            if (bSig[1] in IRSignals) and (bSig[2] in IRSignals[bSig[1]]):
                for i in range(0,3):
                    irci.playback(IRSignals[bSig[1]][bSig[2]])
                    time.sleep(0.05)
                logger.debug("Sent IRSignal: {}, {}".format(bSig[1], bSig[2]))
            else:
                logger.error("Could not find device: {}, signal: {} in IRSignals".format(bSig[1], bSig[2]))
                
        elif(bSig[0] == "seq"):
            print("Sequence not implemented")
            
        else:
            logger.error("Bluetooth signals contained a value with parameter: {} instead of seq or sig".format(bSig[0]))
            return
    else:
        logger.info("Could not find bluetooth signal: {}".format(bluetoothSignal))
        
def readSignalFiles(IRSignalsFilePath, sequencesFilePath, bluetoothSignalsFilePath):
    global IRSignals, sequences, bluetoothSignals, logger
    
    #Reading stored IR-signals
    logger.debug("Reading IR-signals file")
    IRSignals = fh.readJson(IRSignalsFilePath)
    if(len(IRSignals) == 0):
        logger.warning("No IR-signals found in {}".format(signalsFilePath))
        return False
        
    #Reading stored sequences
    logger.debug("Reading sequences file")
    sequences = fh.loadSequences(sequencesFilePath)
    if(not sequences):
        #This might be intended if no sequence file is created
        logger.warning("Could not open sequence file: sequnceFilePath")
    
    #Reading stored bluetooth signals
    bluetoothSignals = fh.loadBluetoothSignals(bluetoothSignalsFilePath)
    if(not bluetoothSignals):
        logger.warning("No bluetooth signals found in {}".format(bluetoothSignalsFilePath))
        return False
    
    return True
        
def testIfSignalsMatch():
    logger.level = logging.INFO
    logger.info("Testing if all defined bluetooth signals have a matchin IR-Signal or sequence...")
    
    errors = 0;
    numberOfSignalsMatched = 0
    
    for key in bluetoothSignals:
        bSig = bluetoothSignals[key]
        
        if(bSig[0] == "sig"):
            if((not bSig[1] in signals) or (not bSig[2] in signals[bSig[1]])):
                logger.warning("Bluetooth signals contained device name: {} signal name: {}, but IR signals did not".format(bSig[1], bSig[2]))
                errors += 1
            numberOfSignalsMatched += 1
            
        elif(bSig[0] == "seq"):
            if(not bSig[1] in sequences):
                logger.warning("Bluetooth signals contained sequence: {}, but the sequence does not exist".format(bSig[1]))
                errors += 1
            numberOfSignalsMatched += 1
            
        else:
            logger.error("Bluetooth signals contained a value with parameter: {} instead of seq or sig".format(bSig[0]))
            errors += 1
            
    if(errors == 0):
        logger.info("All bluetooth signals were matched with IR-Signals and Sequences")
    else:
        logger.error("A total of {} errors found while testing bluetooth signals vs sequences and IR-Signals".format(errors))
        
    logger.level = LOGS_LEVEL
    return errors