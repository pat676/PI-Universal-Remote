"""
A simple terminal UI for storing/deleting devices and assosiated signals and starting the
bluetooth deamon.

"""

import IRCommandsInterface as irci
import FileHandler as fh
import BluetoothListener as bl
from Logger import *

SIGNALS_FILENAME = "IRSignalsTest"
SIGNALS_DIRECTORY = "./SignalFiles/"
SEQUENCES_FILENAME = "Sequences"
SEQUENCES_DIRECTORY = "./SignalFiles/"
SEQUENCES_FILE = SEQUENCES_DIRECTORY+SEQUENCES_FILENAME
SIGNALS_FILE = SIGNALS_DIRECTORY+SIGNALS_FILENAME

SEPERATOR_LINE = "----------------------------------------"

logger = getLogger(LOGS_LEVEL, __name__, LOGS_DIRECTORY, REMOTEUI_LOGS_FILENAME)

#Reads and does a backup of the signals file
logger.debug("Attempting to read and backup signals file")
signals = fh.readJson(SIGNALS_FILE)
fh.backup(SIGNALS_FILE)
fh.saveJson(SIGNALS_DIRECTORY, SIGNALS_FILENAME, signals)


def mainMenu():
    while True:
        logger.debug("Running main menu")
        #Print info
        menuText = SEPERATOR_LINE + "\nMain Menu:\n" + SEPERATOR_LINE +"\n"+\
                    "1. Add devices\n"+\
                    "2. Remove devices\n"+\
                    "3. Add Signal to device\n"+\
                    "4. Remove Signal from device\n"+\
                    "5. Start bluetooth deamon\n"+\
                    "6. Quit\n"
        
        #Reading user input
        try:
            choice = input(menuText)
            logger.debug("User input: {} accepted".format(choice))
        except NameError:
            logger.debug("User input: {} not accepted".format(choice))
            print("Command invalid, please enter a number between 1 and 6")
            continue
        if(choice == 6):
            logger.debug("User exited")
            return
        
        #Running function corresponding to user input
        switcher = {
                    1: addDevice,\
                    2: removeDevice,\
                    3: addSignalToDevice,\
                    4: removeSignalFromDevice,\
                    5: startBluetoothDeamon,\
        }
        func = switcher.get(choice, False)
        if func == False:
            logger.debug("User entered invalid number in main menu: {}".format(choice))
            print("Command: {} invalid, please enter a number between 1 and 6\n".format(choice))
            continue
        else:
            func()
    
def addDevice():
    while(True):
        logger.debug("Running addDevice Menu")
        cont = True
        
        #Print menu information
        print(SEPERATOR_LINE + "\nAdd Device Menu:\n" + SEPERATOR_LINE)
        deviceName = raw_input("Please enter name of device:, type 'q' to cancel\n")
        
        #User exited to main menu
        if deviceName == "q":
            logger.debug("User exited to main menu")
            print("Device not added!")
            return
        
         #Check if device name allready exists
        if deviceName in signals:
            logger.debug("New devicename: {} allready exists".format(deviceName))
            cmd = raw_input("Device allready exists, do you want to erase all signals connected to this device? Y/N\n")
            cont = cmd == "Y" or cmd == "y"
        if not cont:
            logger.debug("User did not add device")
            print("Device not added!")
            continue
            
        #Else add new device
        logger.debug("Adding new device: {}".format(deviceName))
        signals[deviceName] = {}
        fh.saveJson(SIGNALS_DIRECTORY, SIGNALS_FILENAME, signals)
        print("Device added!")
    
def removeDevice():
    while(True):
        logger.debug("Running removeDevice menu")
        deviceNames = signals.keys()
    
        #Print menu information
        print(SEPERATOR_LINE + "\nRemove Device Menu:\n" + SEPERATOR_LINE)
        infoStr = "Please enter the number of the device to remove\n"
        deviceNum = presentNumberedListAndGetUserInput(deviceNames, infoStr)
        
        if(deviceNum == -1):
            logging.debug("User entered invalid command")
            print("Invalid command, please enter a number between 1 and {}".format(len(deviceNames)))
            continue
        
        #User exited to main menu
        if deviceNum == len(deviceNames):
            logging.debug("User exited removeDevice menu")
            return
        
        #Else valid device number
        deviceName = deviceNames[deviceNum]
        if(userConfirm("Delete device: {}".format(deviceName))):
            logging.debug("User confirmed deletion of: {}".format(deviceName))
            del signals[deviceName]
            fh.saveJson(SIGNALS_DIRECTORY,SIGNALS_FILENAME, signals)
            print ("Device: {} deleted".format(deviceName))
        else:
            logging.debug("User canceled deletion of: {}".format(deviceName))
            print("Device not deleted!")
        
            
def addSignalToDevice():
    while(True):
        logging.debug("Running addSignalToDevice menu")
        deviceNames = signals.keys()
        
        #Print menu information
        print(SEPERATOR_LINE + "\nAdd Signal To Device Menu:\n" + SEPERATOR_LINE)
        infoStr = "Please enter the number of the device\n"
        deviceNum = presentNumberedListAndGetUserInput(deviceNames, infoStr)
        
        #Invalid user input
        if(deviceNum == -1):
            logging.debug("User entered invalid command")
            print("Invalid command, please enter a number between 1 and {}".format(len(deviceNames)))
            continue
        
        #User exited to main menu
        if deviceNum == len(deviceNames):
            logging.debug("User exited addSignalToDevice menu")
            return
        
        #Else valid device Number, add signal. This function also saves the signals file
        logging.debug("Calling the IRCommands module for adding a new device")
        irci.addSignalFromUser(SIGNALS_DIRECTORY, SIGNALS_FILENAME, deviceNames[deviceNum], signals)
        
def removeSignalFromDevice():
    while(True):
        logging.debug("Running the removeSignalFromDevice menu")
        deviceNames = signals.keys()
        
        #Print menu information
        print(SEPERATOR_LINE + "\nRemove Signal From Device:\n" + SEPERATOR_LINE)
        infoStr = "Please enter the number of the device\n"
        deviceNum = presentNumberedListAndGetUserInput(deviceNames, infoStr)
        
        #Invalid user input
        if(deviceNum == -1):
            logging.debug("User entered invalid command")
            print("Invalid command, please enter a number between 1 and {}".format(len(deviceNames)))
            continue
        
        #User exited to main menu
        if deviceNum == len(deviceNames):
            logging.debug("User exited the removeSignalFromDevice menu")
            return
        
        #Else valid device Number
        deviceName = deviceNames[deviceNum]
        
        while(True):
            logging.debug("Running the remove signal from device: {} loop".format(deviceName))
            signalNames = signals[deviceName].keys()
        
            #Print menu information
            print(SEPERATOR_LINE + "\nRemove Signal From Device: {}\n" + SEPERATOR_LINE).format(deviceName)
            infoStr = "Please enter the number of the signal\n"
            signalNum = presentNumberedListAndGetUserInput(signalNames, infoStr)
        
            #Invalid user input
            if(signalNum == -1):
                logging.debug("User entered invalid command, restarting loop")
                print("Invalid command, please enter a number between 1 and {}".format(len(signalNames)))
                continue
            
            if signalNum == len(signalNames):
                logging.debug("User exited, returning to choose device menu")
                break
            
            #Else valid singal Number
            signalName = signalNames[signalNum]
            if(userConfirm("Delete signal {} from device: {}".format(signalName, deviceName))):
                logging.debug("User confimed deletion of {} from {}".format(signalName, deviceName))
                del signals[deviceName][signalName]
                fh.saveJson(SIGNALS_DIRECTORY,SIGNALS_FILENAME, signals)
                print ("Signal: {} from device: {} deleted".format(signalName, deviceName))
            else:
                logging.debug("User aborted deletion of {} from {}".format(signalName, deviceName))
                print("Signal not deleted!")
        
    
def startBluetoothDeamon():
    print("Not implemented")

"""
Prints a numbered list to terminal and returns an integer respons from user

Input:
    inList      (list)  : The list that will be presented to the user
    infoStr     (String): The information presented to the user regarding input
                          alternatives
Output:
    -1 if input is out of range or not a valid number, else the user input is returned

Notes:
    infoStr example: "Please enter the number of the device to remove\n"
"""
def presentNumberedListAndGetUserInput(inList, infoStr):
        #Print list information numbered
        logging.debug("Presenting NumberedList and getting user input")
        counter = 1
        logging.debug("Printing list")
        for str in inList:
            print("{}. {}".format(counter, str))
            counter += 1
        print("{}. Quit".format(counter))
        
        #Get user input
        logging.debug("Getting user input")
        try:
            num = input(infoStr)
            num -= 1
        except NameError:
            logging.debug("User input not a valid number, returning", exc_info = True)
            return -1
        if(num <0 or num > len(inList)):
            logging.debug("User input: {} out of range, (len(inList) = {}".format(num, len(inList)))
            return -1
        else:
            logging.debug("User input: {} was valid".format)
            return num

def userConfirm(outStr):
    logging.debug("Running user confirmation")
    cmd = raw_input(outStr + " Y/N\n")
    if( cmd == "Y" or cmd =="y"):
        logging.debug("User confirmed: {}".format(cmd))
        return True
    else:
        logging.debug("User did not confirm: {}".format(cmd))
        return False

#bl.main(SIGNALS_FILE, SEQUENCES_FILE)
mainMenu()


