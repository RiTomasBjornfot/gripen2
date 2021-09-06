# Gripen
This is the demonstator software for the Gripen project. The goal is to measure acceleration data from two bluetooth connected devices. The software shall work "out of box" with basic computer knowlage. Features can be set only by editing a text file (see __Features__). 

# Limitations
The system is not a real time system. Therefore there may be some time difference between the actual event and displaying of the event. Also, the plotting feature may skip some values to prioritize synchronisation over accuracy.

To give similar system performace regardless of number of blutooth devices or featur2386
e settings. The system uses paralell processing.  

# Prerequisits
 - Raspberry Pi with latest Raspbian OS
 - Python 3.x

# How to get started
 1. Download this repository to your __gripen__ folder
 2. Turn on the BLE and type ```sudo hcitool lescan``` in the terminal
 3. In the output, locate your device and copy the address. 
 4. Copy the *defaultunit.json* file to *<myunit>.json* ```cp defaultunit.json <myunit>.json```.
 5. Open *<myunit>.json* and paste the ble address as __BleAddr__ value.
 6. Set a name for your named pipe as __BlePipe__ value.
 7. Create the named pipe ```mkfifo <name>```
 8. As above, set a name for your named pipe as __SavePipe__ value.
 9. Create the named pipe ```mkfifo <name>```

 # Features
 This is a description of the features in the json file
 Key | Value | Description
 --- | --- | ---
  __BleAddr__ | String |The bluetooth address of the unit
  __BlePipe__ | String | The name of the named pipe to the bluetooth
  __WriteSleep__ | Float | ?
  __WriteSize__ | Int | ?
  __BlePackageSize__ | Int | ?
  __Packages__ | Int | The number of packages to save.
  __DataLen__ | Int | The number of datapoints one grab.
  __SavePipe__ | String | The name of the save fifo.
  __Filename__ | String | The name of the saved data file.
  __Upload__ | Bool | ?
  __Plot__ | Bool | Set *true* to show the plot.
  __PlotPipe__ | String | The name of the plot fifo.
 
 
# A simple test
 1. Set __Upload__ to __false__ and __SaveToFile__ to __true__.
 2. Set __Packages__ to 1. 
 3. Set __WriteSize__ and __BlePackageSize__ to __5__.
 4. Open a terminal and type: ```./pygatt.py newdevice.json```
 5. Open a new terminal and type: ```./reader.py newdevice.json```
 6. Check the *.<__BlePipe__>.log* contains expected result
 7. Check that file and *<__BlePipe__>_<unixtime>.txt* contains data
 8. Check web page
