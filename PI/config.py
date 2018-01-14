"""
Contains setup variables
"""

#Filenames and directory of the signal files
IRSIGNALS_FILENAME = "IRSignals"
IRSIGNALS_DIRECTORY = "./SignalFiles/"
SEQUENCES_FILENAME = "Sequences"
SEQUENCES_DIRECTORY = "./SignalFiles/"
BLUETOOTH_SIGNALS_FILENAME =  "BluetoothSignals"
BLUETOOTH_SIGNALS_DIRECTORY = "./SignalFiles/"

IRSIGNALS_FILE = IRSIGNALS_DIRECTORY+IRSIGNALS_FILENAME
SEQUENCES_FILE = SEQUENCES_DIRECTORY+SEQUENCES_FILENAME
BLUETOOTH_SIGNALS_FILE = BLUETOOTH_SIGNALS_DIRECTORY+BLUETOOTH_SIGNALS_FILENAME

#The number of times bluetooth listener transmits EACH signal in a sequence and sleep time between
SEQUENCE_PLAYBACK_TIMES = 3
SEQUNECE_PLAYBACK_SLEEP = 0.05

#The number of times bluetooth listener transmits one IR-Signal. Will not affect signals in sequences. Changing
#these to other values than 1 and 0 might interfere with "press and hold" functionallity like pressing volume
IRSIGNAL_PLAYBACK_TIMES = 1
IRSIGNAL_PLAYBACK_SLEEP = 0

#The end of bluetooth signal symbol
EOS = ";"

#Logging
import logging

LOGS_LEVEL = logging.INFO #Change to logging.DEBUG for more informtion, logging.INFO for less
logging.basicConfig(level=LOGS_LEVEL) #Uncomment for logging to terminal
LOGS_DIRECTORY = "./LOGS/"
BLUETOOTHLISTENER_LOGS_FILENAME  = "BluetoothListener.log"
FILEHANDLER_LOGS_FILENAME  = "FileHandler.log"
REMOTEUI_LOGS_FILENAME = "RemotesUI"
