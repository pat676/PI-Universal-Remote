"""
A simple terminal UI for storing/deleting devices and assosiated signals and starting the
bluetooth deamon.

"""

import IRCommandsInterface as irci
import FileHandler as fh

SIGNALS_FILENAME = "IRSignalsTest"
SIGNALS_DIRECTORY = "./SignalFiles/"
SIGNALS_FILE = SIGNALS_DIRECTORY+SIGNALS_FILENAME

SEPERATOR_LINE = "----------------------------------------"

#Reads and does a backup of the signals file
signals = fh.readJson(SIGNALS_FILE)
fh.backup(SIGNALS_FILE)
fh.saveJson(SIGNALS_DIRECTORY, SIGNALS_FILENAME, signals)

def mainMenu():
    while True:
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
        except:
            print("Command invalid, please enter a number between 1 and 6")
            continue
        if(choice == 6):
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
            print("Command: {} invalid, please enter a number between 1 and 6\n".format(choice))
            continue
        else:
            func()
    
def addDevice():
    while(True):
        cont = True
        
        #Print menu information
        print(SEPERATOR_LINE + "\nAdd Device Menu:\n" + SEPERATOR_LINE)
        deviceName = raw_input("Please enter name of device:, type 'q' to cancel\n")
        
        #User exited to main menu
        if deviceName == "q":
            print("Device not added!")
            return
        
         #Check if device name allready exists
        if deviceName in signals:
            cont = raw_input("Device allready exists, do you want to erase all signals connected to this device? Y/N\n") == "Y"
        if not cont:
            print("Device not added!")
            continue
            
        #Else add new device
        signals[deviceName] = {}
        fh.saveJson(SIGNALS_DIRECTORY, SIGNALS_FILENAME, signals)
        print("Device added!")
    
def removeDevice():
    while(True):
        
        deviceNames = signals.keys()
    
        #Print menu information
        print(SEPERATOR_LINE + "\nRemove Device Menu:\n" + SEPERATOR_LINE)
        infoStr = "Please enter the number of the device to remove\n"
        deviceNum = presentNumberedListAndGetUserInput(deviceNames, infoStr)
        
        if(deviceNum == -1):
            print("Invalid command, please enter a number between 1 and {}".format(len(deviceNames)))
            continue
        
        #User exited to main menu
        if deviceNum == len(deviceNames):
            return
        
        #Else valid device number
        deviceName = deviceNames[deviceNum]
        if(userConfirm("Delete device: {}".format(deviceName))):
            del signals[deviceName]
            fh.saveJson(SIGNALS_DIRECTORY,SIGNALS_FILENAME, signals)
            print ("Device: {} deleted".format(deviceName))
        else:
            print("Device not deleted!")
        
            
def addSignalToDevice():
    while(True):
        deviceNames = signals.keys()
        
        #Print menu information
        print(SEPERATOR_LINE + "\nAdd Signal To Device Menu:\n" + SEPERATOR_LINE)
        infoStr = "Please enter the number of the device\n"
        deviceNum = presentNumberedListAndGetUserInput(deviceNames, infoStr)
        
        #Invalid user input
        if(deviceNum == -1):
            print("Invalid command, please enter a number between 1 and {}".format(len(deviceNames)))
            continue
        
        #User exited to main menu
        if deviceNum == len(deviceNames):
            return
        
        #Else valid device Number, add signal. This function also saves the signals file
        irci.addSignalFromUser(SIGNALS_DIRECTORY, SIGNALS_FILENAME, deviceNames[deviceNum], signals)
        
def removeSignalFromDevice():
    while(True):
        deviceNames = signals.keys()
        
        #Print menu information
        print(SEPERATOR_LINE + "\nRemove Signal From Device:\n" + SEPERATOR_LINE)
        infoStr = "Please enter the number of the device\n"
        deviceNum = presentNumberedListAndGetUserInput(deviceNames, infoStr)
        
        #Invalid user input
        if(deviceNum == -1):
            print("Invalid command, please enter a number between 1 and {}".format(len(deviceNames)))
            continue
        
        #User exited to main menu
        if deviceNum == len(deviceNames):
            return
        
        #Else valid device Number
        deviceName = deviceNames[deviceNum]
        
        while(True):
            
            signalNames = signals[deviceName].keys()
        
            #Print menu information
            print(SEPERATOR_LINE + "\nRemove Signal From Device: {}\n" + SEPERATOR_LINE).format(deviceName)
            infoStr = "Please enter the number of the signal\n"
            signalNum = presentNumberedListAndGetUserInput(signalNames, infoStr)
        
            #Invalid user input
            if(signalNum == -1):
                print("Invalid command, please enter a number between 1 and {}".format(len(signalNames)))
                continue
            
            if signalNum == len(signalNames):
                break
            
            #Else valid singal Number
            signalName = signalNames[signalNum]
            if(userConfirm("Delete signal {} from device: {}".format(signalName, deviceName))):
                del signals[deviceName][signalName]
                fh.saveJson(SIGNALS_DIRECTORY,SIGNALS_FILENAME, signals)
                print ("Signal: {} from device: {} deleted".format(signalName, deviceName))
            else:
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
        counter = 1
        for str in inList:
            print("{}. {}".format(counter, str))
            counter += 1
        print("{}. Quit".format(counter))
        
        #Get user input
        try:
            num = input(infoStr)
            num -= 1
        except:
            return -1
        if(num <0 or num > len(inList)):
            print("ok")
            return -1
        else:
            return num

def userConfirm(outStr):
    cmd = raw_input(outStr + " Y/N\n")
    if( cmd == "Y" or cmd =="y"):
        return True
    else:
        return False
#irci.playback(signals["Testdevice1"]["1"])
mainMenu()

