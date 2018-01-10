Pi Universal Remote

This is a project for creating a bluetooth controlled Universal Remote Hub with the raspberry pi 3 model B
and IOS devices. The Raspberry pi and IOS Device will communicate through an HM-10 bluetooth device connected to the Raspberry through the UART- SERIAL Interface. The Raspberry sends and receives IR-Signals through one
CHQ1838 IR-Reciever and two IR-Diodes.

You can use any parts of the project in your own projects, but expect bugs. If you decide to use parts of
this project please add a comment stating so in your own code.

Current status:

- The project works but expect a lot of bugs. A lot of features are still under development

Setup:

WARNING:
THIS IS A PROJECTED CREATED ON MY FREE TIME,I DO NOT TAKE RESPONSIBILITY FOR ANY BUGS OR DAMAGE
RESULTING FROM USING ANY PART OF THIS PROJECT.

- Setup the Pi software as described in the README from the PI folder.
- Setup the hardware as described in the Hardware folder, NOTE THE WARNING IN THE README FILE
- Find an iPhone app able to send bluetooth commands to the HM-10 module (A custom app is under development)

Implemented, but not tested:

- Reading and storing IR Signals on the PI and a simply UI To achieve this
- A module listening for bluetooth signals and converting theese to IR-Signals
- Text description of the hardware connections used.

More details of status of each part of the project can be found in the readme of the individual folders.

If you want to contribute, report bugs, or have questions, feel free to contact me at pat676@hotmail.com







