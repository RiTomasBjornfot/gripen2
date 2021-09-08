# Gripen
This is the demonstator software for the Gripen project. The demonstator shall show measurements of acceleration data from two acceleration sensors and one tempurature sensor connected to a PC and Raspberry Pi 4.  

# Functional SW requirements
 * It can read data from a BLE unit (type?) via its notification functionallity. 
 * It can calculate data to physical values.
 * It can do a live plot of the data.
 * It can save data to file.
 * It can upload data to a server.
 * It has a client that can plot as data as x = time  y = values for each BLE unit.
  
# Non-functional SW requirements
 * The SW package has a basic description.
 * The SW can be run "out of box" with basic computer knowlage. 
 * All essential SW features can be set by editing a text file (see __Features__).
 * The SW has sufficient performance to grab all data from BLE unit when installed on a RPi 4 (approx 90 values each 0.03 s).
 * The SW has sufficient performance to perform live plotting of the mean values per package without delaying the grabbing.  

# Limitations
The system is not a real time system. Therefore there may be some time difference between the actual event and displaying of the event. Also, the plotting feature may skip some values to prioritize synchronisation over accuracy.

To give similar system performace regardless of number of blutooth devices or feature settings. The system uses paralell processing.  

# Prerequisits
 - PC with Debian or Raspberry Pi with latest Raspbian OS
 - BlueZ
 - Python 3.x
 - Julia 1.6.x

# Getting started
Each BLE unit has a configuration file in the units folder. When the programs to gather the data is run, it look for a configuration file for the BLE unit.
 1. Download this repository to your __gripen__ folder.
 2. Turn on the BLE and type ```sudo hcitool lescan``` in the terminal.
 3. In the output, locate your device and copy the MAC address. 
 5. Open the corresponding JSON file from the units folder and update the  __BleAddr__ value.

 # Features
  This is a description of the features in the json file.
 
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
 2. Start the uploader: ```cd cloud; ./upload.jl```
 3. Start the BLE reader: ```./read_ble.sh <unit>```.
 4. Start the calculator: ```./calc_ble.sh <unit>```.
 8. Set __WriteSize__ and __BlePackageSize__ to __5__.
 9. Open a terminal and type: ```./pygatt.py newdevice.json```
 10. Open a new terminal and type: ```./reader.py newdevice.json```
 11. Check the *.<__BlePipe__>.log* contains expected result
 12. Check that file and *<__BlePipe__>_<unixtime>.txt* contains data
 13. Open http://109.225.89.142:8001/ and view the result

 # Tips & Tricks
 * Avoid killing (<ctrl>-<c>)
 * Check for message __reading from unit__ output from __read_ble.sh__. If no message, no notifications from BLE.
 * If changing any feature, kill and restart __upload.jl__ so the new JSON version will be loaded to the server.
 * more...
