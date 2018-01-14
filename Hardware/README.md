Hardware:
----------------------------------------------------------------------------

TODO:
- Create a simple drawing of the schematics.

WARNING:
I have little formal electronics education and my schematics might be wrong. If you dont know what you are 
doing never leave the device unattended and know that wrong connections might damage your PI and/or all 
connected devices. I do not take responsibility for any errors in the schematics. 
I have little formal electronics education and my schematics might be wrong. If you dont know what you are
doing never leave the device unattended and know that wrong connections might damage your PI and/or all
connected devices. I do not take responsibility for any errors in the schematics.

Pins are listed as physical numbering (From 1-40) with 1 being bottom left, 2 top left and so on.
Read https://www.raspberrypi.org/documentation/usage/gpio-plus-and-raspi2/ appendix 1.A for more
information

Hardware list:
1. Raspberry Pi 3 model B (Other models should work, but might require some changes)
2. Bluetooth HM-10 device
3. 2x 2N2222 NPN Transistor (A lot of other transistors will work with minor changes)
4. 1x 2k Ohm resistor
5. 1x 20 Ohm resistor
5. CHQ1838 IR Receiver (Other IR receivers should work)
6. 1x IR Led (Most will work, but the range and angle might differ)
7. Wiring

HM-10 Connections:
1. Connect the VCC to a 5 or 3.3 volt pin on the raspberry (Other models might require 3.3V).
   Suggested pin: 2
2. Connect ground to ground. Suggested Pin: 6
3. Connect TXD on the HM-10 to pin 10 on the raspberry
4. Connect RXD on the HM-10 to pin 8 on the raspberry

IR-led connections:
1. Connect the long legs of the IR-Led to 5V Suggested PIN: 17
2. Connect the short leg of the IR-Led to the transistors collector pin through a 100 oHm resistor
   Smaller resistor values will increase range but might affect the lifetime of the IR-Led. Very small values
   might affect the PI. (If you few devices (USB, ethernet, hdmi...) connected to the pi this shouldn't be a problem)
   Check the data-sheet for your transistor to find the pin-out.
3. Connect the emitter pin of the transistors to ground
4. Connect the transistor base to a 1kOhm resistor and connect the other end of the resistor
   to pin 40. (Other pins can be used, but you have to change the GPIO_OUT constant at the
   top of the IRRemoteInterface.py file. These constants use the GPIONumbering, not
   the physical numbering.)

IR-Reciever connection:
1. Connect VCC to VCC, suggested pin: 1
2. Connect Ground to ground, suggested pin: 6
3. Connect Out to pin 37(Other pins can be used, but you have to change the GPIO_IN constant at
   the top of the IRRemoteControllInterface.py file. These constants use the GPIONumbering, not
   the physical numbering.)


