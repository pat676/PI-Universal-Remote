Pi Universal Remote

This is a project for creating a bluetooth controlled Universal Remte Hub with the raspberry pi 3 model B 
and IOS devices. The Raspberry pi and IOS Device will comunicate through an HM-10 bluetooth device connected 
to the Raspberry through the UART- SERIAL Interface. The Raspberry sends and recieves IR-Signals through one 
CHQ1838 IR-Reciever and two IR-Diodes.

You can use any parts of the project in your own projects, but expect bugs. If you decide to use parts of
this project please add a comment stating so in your own code.

Current status:

- Should be considered pre-alpha, most importantly the bluetooth deamon used to listen for bluetooth commands
  is not implemented, so the project wont work at this stage.

Setup:

WARNING: 
THIS IS A PROJECTED CREATED ON MY FREE TIME,I DO NOT TAKE RESPONSIBILITY FOR ANY BUGS OR DAMAGE 
RESULTING FROM USING ANY PART OF THIS PROJECT.

- Setup the Pi software as described in the README from the PI folder.
- Setup the hardware as described in the Hardware folder, NOTE THE WARNING IN THE README FILE


Implemented, but not tested:

- Reading/Sending IR commands on the PI and a simply UI To achieve this 
- Storing and loading IR commands to a file in json format.
- Text description of the hardware connections used. 
- IOS bluetooth interface for sending, but not reading bluetooth commands

More details of status of each part of the project can be found in the readmes of the individual folders.

If you want to contribute, report bugs, or have questionsCa feel free to contact me at pat676@hotmail.com







