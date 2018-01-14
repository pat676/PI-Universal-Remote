"""
A simple terminal UI for storing/deleting devices and assosiated signals and starting the
bluetooth deamon.

Attributes:
    logger (Logging object):
        The logger used for the module
    SEPERATOR_LINE (String):
        The line used to seperate menus in the terminal UI
"""

import sys

import IRInterface as iri
import FileHandler as fh
import BluetoothListener as bl
from Logger import *
from config import *


SEPERATOR_LINE = "----------------------------------------"
logger = getLogger(LOGS_LEVEL, __name__, LOGS_DIRECTORY, REMOTEUI_LOGS_FILENAME)

#Reads and does a backup of the signals file
logger.debug("Attempting to read and backup signals file")
IRSignals = fh.readJson(IRSIGNALS_FILE)
fh.backup(IRSIGNALS_FILE)
fh.saveJson(IRSIGNALS_DIRECTORY, IRSIGNALS_FILENAME, IRSignals)


def mainMenu():
    """
    Runs the main menu
    """
    while True:
        logger.debug("Running main menu")
        
        menuText = SEPERATOR_LINE + "\nMain Menu:\n" + SEPERATOR_LINE +"\n"+\
                    "1. Add devices\n"+\
                    "2. Remove devices\n"+\
                    "3. Add Signal to device\n"+\
                    "4. Remove Signal from device\n"+\
                    "5. Start bluetooth listener\n"+\
                    "6. Test if all bluetooth signals have a matching IR-Signal or sequence\n"+\
                    "7. Quit\n"
        
        try:
            choice = int(input(menuText))
            logger.debug("User input: {} accepted".format(choice))
        except ValueError:
            logger.debug("User input not accepted")
            print("Command invalid, please enter a number between 1 and 6")
            continue
        
        if(choice == 7):
            logger.debug("User exited")
            return
        
        switcher = {
                    1: addDevice,\
                    2: removeDevice,\
                    3: addSignalToDevice,\
                    4: removeSignalFromDeviceSelectDevice,\
                    5: startBluetoothListener,\
                    6: testIfSignalsMatch\
        }
        func = switcher.get(choice, False)
        
        if func == False:
            logger.debug("User entered invalid number in main menu: {}".format(choice))
            print("Command: {} invalid, please enter a number between 1 and 6\n".format(choice))
            continue
        else:
            func()
    
def addDevice():
    """
    Runs the add device menu
    """
    while(True):
        logger.debug("Running addDevice Menu")
        cont = True
        
        print(SEPERATOR_LINE + "\nAdd Device Menu:\n" + SEPERATOR_LINE)
        deviceName = input("Please enter name of device:, type 'q' to cancel\n")
        
        if deviceName == "q":
            logger.debug("User exited to main menu")
            print("Device not added!")
            return
        
        if deviceName in IRSignals:
            logger.debug("New devicename: {} allready exists".format(deviceName))
            cont = userConfirm("Device allready exists, do you want to erase all signals connected to this                  device?")
            
        if not cont:
            logger.debug("User did not add device")
            print("Device not added!")
            continue
            
        #Else add new device
        logger.debug("Adding new device: {}".format(deviceName))
        IRSignals[deviceName] = {}
        fh.saveJson(IRSIGNALS_DIRECTORY, IRSIGNALS_FILENAME, IRSignals)
        print("Device added!")
    
def removeDevice():
    """
    Runs the remove device menu
    """
    while(True):
        logger.debug("Running removeDevice menu")
        deviceNames = list(IRSignals.keys())
    
        print(SEPERATOR_LINE + "\nRemove Device Menu:\n" + SEPERATOR_LINE)
        infoStr = "Please enter the number of the device to remove\n"
        deviceNum = presentNumberedListAndGetUserInput(deviceNames, infoStr)
        
        if(deviceNum == -1):
            logging.debug("User entered invalid command")
            print("Invalid command, please enter a number between 1 and {}".format(len(deviceNames)))
            continue
        
        if deviceNum == len(deviceNames):
            logging.debug("User exited removeDevice menu")
            return
        
        deviceName = deviceNames[deviceNum]
        if(userConfirm("Delete device: {}".format(deviceName))):
            logging.debug("User confirmed deletion of: {}".format(deviceName))
            del IRSignals[deviceName]
            fh.saveJson(IRSIGNALS_DIRECTORY,IRSIGNALS_FILENAME, IRSignals)
            print ("Device: {} deleted".format(deviceName))
        else:
            logging.debug("User canceled deletion of: {}".format(deviceName))
            print("Device not deleted!")
        
            
def addSignalToDevice():
    """
    Runs the add signal to device menu
    """
    while(True):
        logging.debug("Running addSignalToDevice menu")
        deviceNames = list(IRSignals.keys())
        
        print(SEPERATOR_LINE + "\nAdd Signal To Device Menu:\n" + SEPERATOR_LINE)
        infoStr = "Please enter the number of the device\n"
        deviceNum = presentNumberedListAndGetUserInput(deviceNames, infoStr)
        
        if(deviceNum == -1):
            logging.debug("User entered invalid command")
            print("Invalid command, please enter a number between 1 and {}".format(len(deviceNames)))
            continue
        
        if deviceNum == len(deviceNames):
            logging.debug("User exited addSignalToDevice menu")
            return
        
        deviceName = deviceNames[deviceNum]
        logging.debug("Adding a new device: {}".format(deviceName))
        iri.addSignalFromUser(deviceName, IRSignals)
        fh.saveJson(IRSIGNALS_DIRECTORY, IRSIGNALS_FILENAME, IRSignals)
        
def removeSignalFromDeviceSelectDevice():
    """
    Runs the remove signal from device menu
    """
    while(True):
        logging.debug("Running the removeSignalFromDevice menu")
        deviceNames = list(IRSignals.keys())
        
        print(SEPERATOR_LINE + "\nRemove Signal From Device:\n" + SEPERATOR_LINE)
        infoStr = "Please enter the number of the device\n"
        deviceNum = presentNumberedListAndGetUserInput(deviceNames, infoStr)
        
        if(deviceNum == -1):
            logging.debug("User entered invalid command")
            print("Invalid command, please enter a number between 1 and {}".format(len(deviceNames)))
            continue
        
        if deviceNum == len(deviceNames):
            logging.debug("User exited the removeSignalFromDevice menu")
            return
        
        deviceName = deviceNames[deviceNum]
        
        removeSignalFromDeviceSelectSignal(deviceName)

def removeSignalFromDeviceSelectSignal(deviceName):
    """
    Runs the remove signal from device menu after user has selected device
    
    Args:
        deviceName  (String): The selected device
    """
    
    while(True):
        logging.debug("Running the remove signal from device: {} loop".format(deviceName))
        signalNames = list(IRSignals[deviceName].keys())
    
        print(SEPERATOR_LINE + "\nRemove Signal From Device: {}\n".format(deviceName) + SEPERATOR_LINE)
        infoStr = "Please enter the number of the signal\n"
        signalNum = presentNumberedListAndGetUserInput(signalNames, infoStr)
    
        if(signalNum == -1):
            logging.debug("User entered invalid command, restarting loop")
            print("Invalid command, please enter a number between 1 and {}".format(len(signalNames)))
            continue
        
        if signalNum == len(signalNames):
            logging.debug("User exited, returning to choose device menu")
            return
        
        signalName = signalNames[signalNum]
        
        if(userConfirm("Delete signal {} from device: {}".format(signalName, deviceName))):
            logging.debug("User confimed deletion of {} from {}".format(signalName, deviceName))
            del IRSignals[deviceName][signalName]
            fh.saveJson(IRSIGNALS_DIRECTORY,IRSIGNALS_FILENAME, IRSignals)
            print ("Signal: {} from device: {} deleted".format(signalName, deviceName))
        else:
            logging.debug("User aborted deletion of {} from {}".format(signalName, deviceName))
            print("Signal not deleted!")


def startBluetoothListener():
    """
    Starts the bluetooth listener
    """
    logging.debug("Starting the bluetooth listener")
    print("Starting the bluetooth listener...")
    bl.mainLoop(IRSIGNALS_FILE, SEQUENCES_FILE, BLUETOOTH_SIGNALS_FILE)


def testIfSignalsMatch():
    """
    Runs a test from bluetooth listener module. The tests checks if every bluetooth signal has a matching
    IR-Signal
    """
    bl.testIfBluetoothSignalsHaveMatchingIRSignalsAndSequences()
    

def presentNumberedListAndGetUserInput(inList, infoStr):
    """
    Prints a numbered list to terminal and returns an integer respons from user
    
    Example:
        infoStr example: "Please enter the number of the device to remove\n"
    Args:
        inList      (list)  : The list that will be presented to the user
        infoStr     (String): The information presented to the user regarding input
                              alternatives
    Returns:
        -1 if input is out of range or not a valid number, else the user input is returned
    """
    logging.debug("Presenting NumberedList and getting user input")
        
    counter = 1
    logging.debug("Printing list")
    for str in inList:
        print("{}. {}".format(counter, str))
        counter += 1
    print("{}. Quit".format(counter))
        
        
    logging.debug("Getting user input")
    try:
        num = int(input(infoStr))
        num -= 1
    except ValueError:
        logging.debug("User input not a valid number, returning", exc_info = True)
        return -1
    if(num <0 or num > len(inList)):
        logging.debug("User input: {} out of range, (len(inList) = {}".format(num+1, len(inList)))
        return -1
    else:
        logging.debug("User input: {} was valid".format(num+1))
        return num

def userConfirm(outStr):
    """
    Asks for user confirmation
    
    The outStr is printed to terminal with a choise of Y/N.
    
    Args:
        ouStr   (String): Information to the user about what choice he is making
    Returns:
        True if user input is Y/y, False else
    """
    logging.debug("Running user confirmation")
    
    cmd = input(outStr + " Y/N\n")
    if( cmd == "Y" or cmd =="y"):
        logging.debug("User confirmed: {}".format(cmd))
        return True
    else:
        logging.debug("User did not confirm: {}".format(cmd))
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "-b":
        startBluetoothListener()
    else:
        mainMenu()


