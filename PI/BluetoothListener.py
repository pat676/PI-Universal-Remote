import serial
import FileHandler as fh
import logging
import time

import IRInterface as iri
from Logger import *

logger = fh.getLogger(LOGS_LEVEL, __name__, LOGS_DIRECTORY, BLUETOOTHLISTENER_LOGS_FILENAME)
port = serial.Serial("/dev/ttyAMA0", baudrate=9600) #Used to recieve bluetooth signals
EOS = ";" #End of signal symbol for bluetooth signals

"""
Every IRsignal in a sequnce will be transmitted this SEQUENCE_PLAYBACK_TIMES with a pause of
SEQUNECE_PLAYBACK_SLEEP minutes between each transmission
"""
SEQUENCE_PLAYBACK_TIMES = 3
SEQUNECE_PLAYBACK_SLEEP = 0.1

"""
Every single IRsignal will be transmitted this IRSIGNAL_PLAYBACK_TIMES with a pause of
IRSIGNALS_PLAYBACK_SLEEP minutes between each transmission. IRSIGNAL_PLAYBACK_TIMES should usually be set
to 1, else it might create a problem for "press and hold"functionallity, like holding channel up button to
continously change channels.
"""
IRSIGNAL_PLAYBACK_TIMES = 1
IRSIGNAL_PLAYBACK_SLEEP = 0

IRSignals = {}
sequences = {}
bluetoothSignals = {}

"""
Runs the main loop listening for bluetooth signals

Input:
    IRSignalsFilePath       (String): The full path of the file containing the IRSignals
    sequencesFilePath       (String): The full path of the file containing the sequences
    bluetoothSignalsFilePath(String): The full path of the file containing the bluetoothSignals
Output:
    None
"""
def mainLoop(IRSignalsFilePath, sequencesFilePath, bluetoothSignalsFilePath):
    logger.debug("Running main loop with IR-Signals file: {}, sequencs file: {}, bluetooth signals file: {}".format(IRSignalsFilePath, sequencesFilePath, bluetoothSignalsFilePath))
    
    #Reading signal files and testing for succes
    if not readSignalFiles(IRSignalsFilePath, sequencesFilePath, bluetoothSignalsFilePath):
        logger.error("Aborting main loop, error while reading files")
        return
    
    logger.debug("Starting main loop  with EOS symbol: '{}'".format(EOS))
    while True:
        bluetoothSignal = ""
        while True:
            rcv = port.read().decode("utf-8") #Listening for bluetooth signals
            logger.debug("Recieved bluetooth char: {}".format(rcv))
            
            if rcv == EOS: #End of signal
                decodeAndRunBluetoothSignal(bluetoothSignal)
                break
            else:
                bluetoothSignal += rcv
        
"""
Decodes and runs a bluetooth signal

Innput:
    bluetoothSignal (String): The bluetooth signal
Output:
    True on success, False else
"""
def decodeAndRunBluetoothSignal(bluetoothSignal):
    logger.debug("Decoding and running bluetooth signal: {}".format(bluetoothSignal))
    
    if bluetoothSignal in bluetoothSignals:
        logger.debug("Found signal in bluetoothSignals")
        bSig = bluetoothSignals[bluetoothSignal]
        
        if (bSig[0] == "sig" and len(bSig) == 3):
            return runIRSignal(bSig[1], bSig[2], IRSIGNAL_PLAYBACK_TIMES, IRSIGNAL_PLAYBACK_SLEEP)

        elif(bSig[0] == "seq" and len(bSig) == 2):
            return runSequence(bSig[1], SEQUENCE_PLAYBACK_TIMES, SEQUNECE_PLAYBACK_SLEEP)
            
        else:
            logger.error("Invalid bluetooth signal format: {}".format(bSig))
            return False
    else:
        logger.warning("Could not find bluetooth signal: {}".format(bluetoothSignal))
        return False
        
"""
Runs a sequence of signals.

Input:
    sequenceName            (String): The name of the sequence
    repeatsForEachSignal    (int)   : The number of times each signal is repeated
    repeatSleepTime         (float) : The sleep time in seconds between each repeat
Output:
    True on success, False else
Notes:
    waittime is the time in seconds between transmission of each signal in the sequence and is found in
    the sequences dict.
    the repeatSleepTime parameter is the time slept between repeats of each individual signal in the
    sequence.
"""
def runSequence(sequenceName, repeatsForEachSignal = 1, repeatSleepTime = 0):
    logger.debug("Running sequence: {}, with repeats for each signal: {}, sleep time between repeats: {}".format(sequenceName, repeatsForEachSignal, repeatSleepTime))
    
    if(sequenceName in sequences):
        sequence = sequences[sequenceName]
        
        #Get all IR-Signals in the sequence
        for i in range(0,len(sequence)-1,3):
            
            #Get the next IR-Signal
            try:
                deviceName = sequence[i]
                signalName = sequence[i+1]
                waitTime = sequence[i+2]
            except IndexError:
                logger.error("Sequence: {}, had unexpected length: {}. Lenght should be a mulitplum of 3".format(sequnceName, sequences))
                return False
                
            #Run the IR-Signal
            runIRSignal(deviceName, signalName, repeatsForEachSignal, repeatSleepTime)
            time.sleep(waitTime)
    
    else:
        logger.error("Could not find sequence: {}".format(sequenceName))
        return False
    
    return True

"""
Uses bluetooth signal information to transmit one IRSignal.

Innput:
    deviceName      (String): The name of the device
    signalName      (String): The name io the signal
    repeats         (int)   : Number of times the IR-Signal is transmitted
    repeatSleepTime (float) : The sleep time between each repeat
Output:
    True on success, False else.
Notes:
    IRSignals dict is excepected to have the format {deviceNames:signalNames}. No tests for wrong format
    are performed
"""
def runIRSignal(deviceName, signalName, repeats = 1, repeatSleepTime = 0):
    logger.debug("Running IR Signal: {}, {},  with repeats for each signal: {}, sleep time between repeats: {}".format(deviceName, signalName, repeats, repeatSleepTime))
    
    if (deviceName in IRSignals) and (signalName in IRSignals[deviceName]):
        for i in range(0, repeats):
            iri.playback(IRSignals[deviceName][signalName])
            time.sleep(repeatSleepTime)
    else:
        logger.error("Could not find IRSignal: {}, {}".format(deviceName, signalName))
        return False
        
    return True

"""
Reads all signal files and assignes theese to global parameters

Input:
    IRSignalsFilePath           (String): The file path of the IRSignalsFile
    sequencesFilePath           (String): The file path of the sequencesFile
    bluetoothSignalsFilePath    (String): The file path of the bluetoothSignalsFile
Output:
    True on success, False else
Notes:
    Will return True even if the sequences file could not be loaded, since the program will run
    without a sequences file.
"""
def readSignalFiles(IRSignalsFilePath, sequencesFilePath, bluetoothSignalsFilePath):
    logger.debug("Reading IR-Signal files: {}, sequences file: {} and bluetooth signals file: {}".format(IRSignalsFilePath, sequencesFilePath, bluetoothSignalsFilePath))
    global IRSignals, sequences, bluetoothSignals, logger
    
    #Reading stored IR-signals
    IRSignals = fh.readJson(IRSignalsFilePath)
    if(len(IRSignals) == 0):
        logger.error("No IR-signals found in {}".format(signalsFilePath))
        return False
        
    #Reading stored sequences
    sequences = fh.loadSequences(sequencesFilePath)
    if(not sequences):
        #This might be intended if no sequence file is created
        logger.warning("Could not open sequence file: sequnceFilePath")
    
    #Reading stored bluetooth signals
    bluetoothSignals = fh.loadBluetoothSignals(bluetoothSignalsFilePath)
    if(not bluetoothSignals):
        logger.error("No bluetooth signals found in {}".format(bluetoothSignalsFilePath))
        return False
    
    return True

"""
Reads all files and tests if all bluetooth signals have a matching IR-Signal or sequence

Output:
    Number of mismatches
Notes:
    Logging will be set to INFO level during the run.
"""
def testIfBluetoothSignalsHaveMatchingIRSignalsAndSequences():
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