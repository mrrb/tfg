#!/bin/python

# Serial control

import serial
import time
import sys

baudrate = 921600
device   = '/dev/ttyUSB1'

if __name__ == "__main__":
    # Serial device Init & Open
    stick = serial.Serial(port=device, baudrate=baudrate)


    for i in range(20):
        stick.write(b'Hola')

        time.sleep(0.5)

        data = b''
        while(stick.in_waiting > 0):
            data += stick.read(1)

        if(data != ''):
            print(data.hex())

    stick.close()    