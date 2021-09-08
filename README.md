# Gripen
This is the demonstator software for the Gripen project. The demonstator shall show measurements of acceleration data from two sensors and tempurature from one sensor. The sensors are conected to a PC and Raspberry Pi 4 over BLE.  

# Functional requirements
 * It can read data from a BLE unit (type?) via its notification functionallity. 
 * It can calculate data to physical values.
 * It can do a live plot of the data.
 * It can save data to file.
 * It can upload data to a server.
 * It has a client that can plot as data as x = time  y = values for each BLE unit.
  
# Non-functional requirements
 * The SW package has a basic description.
 * The SW can be run "out of box" with basic computer knowlage. 
 * All essential SW features can be set by editing a text file (see __Features__).
 * The SW has sufficient performance to grab all data from BLE unit when installed on a RPi 4 (approx 90 values each 0.03 s).
 * The SW has sufficient performance to perform live plotting of the mean values per package without delaying the grabbing.  

# Limitations
  * The system is not a real time system. Therefore there may be some time difference between the actual event and displaying of the event. Also, the plotting feature may skip some values to prioritize synchronisation over accuracy.

# The software topology
Each BLE unit has a configuration file in the units folder. When the SW is run, it look for a configuration file for the BLE unit. The software is split into 4 different programs. that is to separate tasks in sub-processed for the OS in order to gain performance. 
  * __read_ble.sh__, reads the notification output from the BLE and sends to a Named Pipe (fifo).
  * __calc_ble.jl__, reads the data in the Named Pipe, calculates it into physical values and saves the result to files. It also handles the live plotting.
  * __upload.jl__, uploads the files to the server.
  * __web2.jl__, the server program.

# Prerequisits
 - PC with Debian or Raspberry Pi with latest Raspbian OS
 - BlueZ
 - Python 3.x
 - Julia 1.6.x

# Getting started
Each BLE unit has a configuration file in the units folder. When the SW is run, it look for a configuration file for the BLE unit.
 1. Download this repository to your __gripen__ folder.
 2. Turn on the BLE and type ```sudo hcitool lescan``` in the terminal.
 3. In the output, locate your device and copy the MAC address. 
 5. Open the corresponding JSON file from the units folder and update the  __BleAddr__ value.

 # Features
  This is a description of the features in the JSON file.
 
 Key | Value | Description
 --- | --- | ---
  __BleAddr__ | String |The bluetooth address of the unit
  __CalibrationPosition__ | List | To set the position of the x,y,z axis 
  __CalibrationMagnetude__ | List | To set the magnitude of the x,y,z axis
  __BlePackageSize__ | Int | The number of readings from BLE in a package
  __Packages__ | Int | The number of packages to save.
  __DataLen__ | Int | The allowed string length from BLE
  __Filename__ | String | The name of the saved data file.
  __Plot__ | Bool | Set *true* to show the plot.
 
# How to run
 1. Start the web-server: 
    ```
    > cd cloud/dev; ./ssh_connect.sh
    > cd servers/gripen2; ./web2.jl
    ```
    NOTE: When the output is: __[ Info: Listening on: 0.0.0.0:8001]__ the server is up and running.
 2. Start the uploader: 
    ```Check for message __reading from unit__ output from __read_ble.sh__. If no message, no notifications from BLE.
    cd cloud; ./upload.jl
    ```
    *NOTE: The uploader, looks for files in the __data__ folder. When a file is found it uploads it to the server and moves it to the __backup__ folder. It is active for about one hour and it is harmless to kill it whenever needed.*
 4. Start the BLE reader: 
    ```
    ./read_ble.sh <unit>
    ```
    *NOTE: The unit is the name of the JSON, without the .json extension locatyed in the units folder. e.g. units/x.json => x.*  
  
 7. Start the calculator: 
    ```
    ./calc_ble.sh <unit>
    ```
    *NOTE: make sure that the same <unit> is used. If not, __read_ble.sh__ will pause until data is read from the fifo.*
  
 9. Open http://109.225.89.142:8001/ and view the result
  
  *NOTE: To view more then one sensor, open a new web-browser.*

 # Tips & Tricks
  * Check for message __reading from unit__ output from __read_ble.sh__. If no message, no notifications from BLE.
  * Avoid killing ([ctrl]-[c]) __read_ble.sh__. In certain cases, this can *lock* the BLE and rebooting the BLE is required.
  * Check for message __reading from unit__ output from __read_ble.sh__. If no message, no notifications from BLE.
  * If changing any feature, restart __upload.jl__ to let the new JSON version will be loaded to the server.
  * There is no problem running more then one BLE unit at the same time. The esiest way is to this, is open new set of terminals and run the SW inte samme manner as the other BLE. Just make sure that a different Named Pipe is used. Do this by using another JSON file as command line argument.  
