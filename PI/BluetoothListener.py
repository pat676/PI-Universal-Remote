"""
A module listening for bluetooth signals and transmitting matching IR-Signals

This module will listen for bluetooth signals and match them with either a sequence or one IR Signal.
The files spesified in the parameters of the main loop will be used to match the signals.

Attributes:
    logger (Logging object):
        The logger used for the module
    port (Serial object):
        The port used for bluetooth comunication
    IRSignals (Dict):
        The dict matching IR Signal name with actual signal. Format:
        {deviceName:signalName:[signal])}
        {String:String:[int]}
    sequences (Dict):
        The dict matching sequence names to IR-signals. Format:
        {sequenceName:[deviceName1, signalName1, waittime1, deviceName2, signalName2, waittime2....]
        {String:[String, String, String...]
    bluetoothSignals (Dict):
        The dict containing bluetooth signals and matching IR Signals/ sequences. Format:
        {bluetoothSignal:[sig/seq, deviceName/sequenceName, signalName(if arg[0] = sig]}
        {String:[String, String, String(if arg[0] = sig)]}
        arg[0] of the array has to be sig or seq indicating signal or sequence. If arg[0] = seq the
        array will be of length 2, if sig length 3.
"""

import serial
import FileHandler as fh
import logging
import time

import IRInterface as iri
from Logger import *
from config import *

class BTListener:
    logger = fh.getLogger(LOGS_LEVEL, __name__, LOGS_DIRECTORY, BLUETOOTHLISTENER_LOGS_FILENAME)
    port = serial.Serial("/dev/ttyAMA0", baudrate=9600)
    IRSignals = {}
    sequences = {}
    bluetoothSignals = {}

    def __init__(self, IRSignalsFilePath = IRSIGNALS_FILE, sequencesFilePath = SEQUENCES_FILE, bluetoothSignalsFilePath = BLUETOOTH_SIGNALS_FILE):
        self.IRSignalsFilePath = IRSignalsFilePath
        self.sequencesFilePath = sequencesFilePath
        self.bluetoothSignalsFilePath = bluetoothSignalsFilePath
        if not self.readSignalFiles():
            self.logger.error("Could not read IR and bluetooth signals from paths: {} {}"
                .format(self.IRSignalsFilePath, self.BLUETOOTH_SIGNALS_FILE))
            raise IOError("Could not open file and read files")
            

    def mainLoop(self):
        """
        Runs the main loop listening for bluetooth signals

        Args:
            IRSignalsFilePath       (String): The full path of the file containing the IRSignals
            sequencesFilePath       (String): The full path of the file containing the sequences
            bluetoothSignalsFilePath(String): The full path of the file containing the bluetoothSignals
        Returns:
            None
        """
        self.logger.debug("Running main loop with IR-Signals file: {}, sequencs file: {}, bluetooth signals file: {}".format(self.IRSignalsFilePath, 
            self.sequencesFilePath, self.bluetoothSignalsFilePath))
        self.logger.debug("Starting main loop  with EOS symbol: '{}'".format(EOS))

        while True:
            bluetoothSignal = ""
            while True:
                rcv = self.port.read().decode("utf-8") #Listening for bluetooth signals
                self.logger.debug("Recieved bluetooth char: {}".format(rcv))
                
                if rcv == EOS: #End of signal
                    self.decodeAndRunBluetoothSignal(bluetoothSignal)
                    break
                else:
                    bluetoothSignal += rcv
            

    def decodeAndRunBluetoothSignal(self, bluetoothSignal):
        """
        Decodes and runs a bluetooth signal

        Args:
            bluetoothSignal (String): The bluetooth signal
        Returns:
            True on success, False else
        """
        self.logger.debug("Decoding and running bluetooth signal: {}".format(bluetoothSignal))
        
        if bluetoothSignal in self.bluetoothSignals:
            self.logger.debug("Found signal in bluetoothSignals")
            bSig = self.bluetoothSignals[bluetoothSignal]
            
            if (bSig[0] == "sig" and len(bSig) == 3):
                return self.runIRSignal(bSig[1], bSig[2], IRSIGNAL_PLAYBACK_TIMES, IRSIGNAL_PLAYBACK_SLEEP)

            elif(bSig[0] == "seq" and len(bSig) == 2):
                return self.runSequence(bSig[1], SEQUENCE_PLAYBACK_TIMES, SEQUNECE_PLAYBACK_SLEEP)
                
            else:
                self.logger.error("Invalid bluetooth signal format: {}".format(bSig))
                return False
        else:
            self.logger.warning("Could not find bluetooth signal: {}".format(bluetoothSignal))
            return False
            

    def runSequence(self, sequenceName, repeatsForEachSignal = 1, repeatSleepTime = 0):
        """
        Transmits a sequence of signals from the global sequences dict
        
        waittime is the time in seconds between transmission of each signal in the sequence and is found in
        the sequences dict. The repeatSleepTime parameter is the time slept between repeats of each individual
        signal in the sequence.

        Args:
            sequenceName            (String): The name of the sequence
            repeatsForEachSignal    (int)   : The number of times each signal is repeated
            repeatSleepTime         (float) : The sleep time in seconds between each repeat
        Returns:
            True on success, False else

        """
        self.logger.debug("Running sequence: {}, with repeats for each signal: {}, sleep time between repeats: {}".format(sequenceName, repeatsForEachSignal, repeatSleepTime))
        
        if(sequenceName in self.sequences):
            sequence = self.sequences[sequenceName]
            
            if(not len(self.sequence)%3 == 0):
                #Each signal should have 3 entries in the sequence array (deviceName, signalName, waittime)
                self.logger.error("Sequence: {}, had unexpected length: {}. Lenght should be a mulitplum of 3".format(sequenceName, len(sequence)))
                return False
                
            numberOfSignals = int(len(self.sequence)/3)
            for i in range(0,numberOfSignals):
                
                deviceName = self.sequence[3*i]
                signalName = self.sequence[3*i+1]
                waitTime = self.sequence[3*i+2]
                    
                self.runIRSignal(deviceName, signalName, repeatsForEachSignal, repeatSleepTime)
                time.sleep(waitTime)
        
        else:
            self.logger.error("Could not find sequence: {}".format(sequenceName))
            return False
        
        return True


    def runIRSignal(self, deviceName, signalName, repeats = 1, repeatSleepTime = 0):
        """
        Transmit one IRSignal from the global IRSignals dict

        IRSignals dict is excepected to have the format {deviceNames:signalNames}. No tests for wrong format
        are performed
        
        Args:
            deviceName      (String): The name of the device
            signalName      (String): The name io the signal
            repeats         (int)   : Number of times the IR-Signal is transmitted
            repeatSleepTime (float) : The sleep time between each repeat
        Returns:
            True on success, False else.
        """
        self.logger.debug("Running IR Signal: {}, {},  with repeats for each signal: {}, sleep time between repeats: {}".format(deviceName, signalName, repeats, repeatSleepTime))
        
        if (deviceName in self.IRSignals) and (signalName in self.IRSignals[deviceName]):
            for i in range(0, repeats):
                iri.playback(self.IRSignals[deviceName][signalName])
                time.sleep(repeatSleepTime)
        else:
            self.logger.error("Could not find IRSignal: {}, {}".format(deviceName, signalName))
            return False
            
        return True


    def readSignalFiles(self):
        """
        Reads all signal files and assignes these to global parameters

        Will return True even if the sequences file could not be loaded, since the program will run
        without a sequences file.

        Args:
            IRSignalsFilePath           (String): The file path of the IRSignalsFile
            sequencesFilePath           (String): The file path of the sequencesFile
            bluetoothSignalsFilePath    (String): The file path of the bluetoothSignalsFile
        Returns:
            True on success, False else
        """
        self.logger.debug("Reading IR-Signal files: {}, sequences file: {} and bluetooth signals file: {}".format(
            self.IRSignalsFilePath, self.sequencesFilePath, self.bluetoothSignalsFilePath))
        
        #Reading stored IR-signals
        self.IRSignals = fh.readJson(self.IRSignalsFilePath)
        if(len(self.IRSignals) == 0):
            self.logger.error("No IR-signals found in {}".format(self.IRSignalsFilePath))
            return False
            
        #Reading stored sequences
        self.sequences = fh.loadSequences(self.sequencesFilePath)
        if(not self.sequences):
            #This might be intended if no sequence file is created
            self.logger.warning("Could not open sequence file: {}".format(self.sequncesFilePath))
        
        #Reading stored bluetooth signals
        self.bluetoothSignals = fh.loadBluetoothSignals(self.bluetoothSignalsFilePath)
        if(not self.bluetoothSignals):
            self.logger.error("No bluetooth signals found in {}".format(self.bluetoothSignalsFilePath))
            return False
        
        return True


    def testIfBluetoothSignalsHaveMatchingIRSignalsAndSequences(self):
        """
        Reads all files and tests if all bluetooth signals have a matching IR-Signal or sequence

        Returns:
            Number of mismatches

        """
        self.logger.info("Testing if all defined bluetooth signals have a matchin IR-Signal or sequence...")
        
        errors = 0;
        numberOfSignalsMatched = 0
        
        for key in self.bluetoothSignals:
            bSig = self.bluetoothSignals[key]
            
            if(bSig[0] == "sig"):
                deviceName = bSig[1]
                signalName = bSig[2]
                
                if((not deviceName in self.IRSignals) or (not signalName in self.IRSignals[deviceName])):
                    self.logger.warning("Bluetooth signals contained device name: {} signal name: {}, but IR signals did not".format(deviceName, signalName))
                    errors += 1
                
            elif(bSig[0] == "seq"):
                sequenceName = bSig[1]
                
                if(not sequenceName in self.sequences):
                    self.logger.warning("Bluetooth signals contained sequence: {}, but the sequence does not exist".format(sequenceName))
                    errors += 1
                
            else:
                self.logger.error("Bluetooth signals contained a value with parameter: {} instead of seq or sig".format(bSig[0]))
                errors += 1
                
        if(errors == 0):
            self.logger.info("All bluetooth signals were matched with IR-Signals and Sequences")
        else:
            self.logger.warning("A total of {} errors found while testing bluetooth signals vs sequences and IR-Signals".format(errors))
            
        return errors


    def testSequenceAgainstIRSignals(self):
        """
        Reads all sequences and checks if each element in sequence have a matching IR signal

        Returns:
            Number of mismatches
        """
        self.logger.info("Testing if each signal in sequence are well defined, i.e exist in IRSignals")
    
        warnings = 0

        for sequenceName in self.sequences:
            seq = self.sequences[sequenceName]

            for i in range(int(len(seq)/3)):
                deviceName = seq[i*3]
                signalName = seq[i*3 + 1]

                if(not deviceName in self.IRSignals):
                    self.logger.warning("Sequence contained device name: {} but IRSignals did not".format(deviceName))
                    warnings += 1
                    continue

                if(not signalName in self.IRSignals[deviceName]):
                    self.logger.warning("Sequence contained signal name: {} but IRSignals did not. Device name: {}".format(signalName, deviceName))
                    warnings += 1

        if(warnings == 0):
            self.logger.info("All sequences have matching matching IRSignals")

        else:
            self.logger.warning("A total of {} mismatches were found while testing sequence-IRSignal matching".format(warnings))

        return warnings
        