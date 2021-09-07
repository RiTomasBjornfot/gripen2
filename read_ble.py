#!/usr/bin/python3
import pexpect, time, json, sys
import numpy as np
import os

class BleSensor:
    def __init__(self, addr, pname, sleep, psize, pcount):
        self.addr = addr
        self.pname = pname
        self.sleep = sleep
        self.psize = psize
        self.pcount = pcount

    def write_to_pipe(self):
      """
      Get data from a Bluetooth device
      """
      # init
      gatt = pexpect.spawn("gatttool -b " + self.addr + " -I")
      # init log
      #logger = open("."+self.pname+".log", "wa")
      #logger.write(time.ctime()+'\n')
      # connect
      gatt.sendline("connect")
      gatt.expect("Connection successful")
      print(gatt.after.decode())
      #logger.write(gatt.after.decode()+'\n')
      # set mtu
      gatt.sendline("mtu 240")
      gatt.expect("MTU was exchanged successfully: 236")
      print(gatt.after.decode())
      #logger.write(gatt.after.decode()+' \n')

      # turn on notifications
      # remove?
      gatt.sendline("char-write-req 0x28 0100")
      gatt.expect("Characteristic value was written successfully")
      print(gatt.after.decode())
     
      
      # writing ble data to pipe
      gatt.sendline("char-write-cmd 1E 53")
      print("reading from unit")
      t0 = time.time()
      #i = 0
      #while i < 2*self.count+2:
      #for i in range(int(1e9)):
      i = 0
      while i < self.psize*self.pcount:
        try:
            #logger.write(str(i)+'\n')
            time.sleep(self.sleep)
            gatt.expect("\r\n")
            z = gatt.before.decode()[82:-1]
            #logger.write(str(i)+z+'\n')
            #t = np.round(time.time() - t0, 2)
            #t = time.time()
            if len(z.split(' ')) == settings["DataLen"]:
              with open(self.pname, "w") as fp:
                fp.write(z)
              i += 1
        except Exception as e:
          print("pygatt.py: ", e)


      print("pygatt.py: Closing the connection")
      # stopping the notification
      gatt.sendline("char-write-cmd 1E 5A")
      # disconnecting and closing
      gatt.sendline("disconnect")
      gatt.close()
      #logger.close()

if __name__ == '__main__':
  with open(sys.argv[1], "r") as fp:
    settings = json.load(fp)
  
  ble = BleSensor(
      settings["BleAddr"],
      "fifo/a1", 
      settings["WriteSleep"], 
      settings["BlePackageSize"],
      settings["Packages"]
    )
  ble.write_to_pipe()
  
