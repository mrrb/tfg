#!/bin/python

# Serial control

import serial
import time
import sys

from bitstring import BitArray

stick = serial.Serial()

default_device   = '/dev/ttyUSB1'
default_baudrate = 921600
debug = False

def print_main_menu():
    global stick
    print("## MAIN MENU ##")
    print("["+str(stick.port)+", "+str(stick.baudrate)+", Open: "+str(stick.is_open)+"]")

    print("0. Config port.")

    if(stick.port == None or stick.is_open):
        print("\x1b[31m", end='')
    print("1. Open port.")
    print("\x1b[0m", end='')

    if(not(stick.is_open)):
        print("\x1b[31m", end='')
    print("2. Send \"Register Read\" command.")
    print("3. Send \"Register Write\" command.")
    print("4. Send \"Register Send\" command.")
    print("5. Send \"RECV\" command.")
    print("6. Close port.")

    print("\x1b[0m", end='')
    print("7. Exit.")

def print_config_menu():
    print("## CONFIG MENU ##")
    print("0. Baudrate.")
    print("1. Device.")
    print("2. Use defaults ["+default_device+", "+str(default_baudrate)+"].")
    print("3. Go back.")

def send_cmd(cmd, addr=0, data=0):
    global stick
    global debug
    # CMD  ADDR     DATA
    # xx   xxxxxx   xxxxxxxx
    # byte0 = (cmd<<6) | addr
    # byte1 = data
    bytes_send = bytes([(cmd<<6) | addr, data])
    print('Sending:', bytes_send)
    if(not(debug)):
        stick.write(bytes_send)


def read_data():
    global stick
    data = b''
    while(stick.in_waiting > 0):
        data += stick.read(1)

    if(data != ''):
        print((BitArray(data)).bin, '(' + str(BitArray(data)) + ')')

def main():
    global debug
    global device
    global baudrate
    global port_config_done
    while(True):
        print_main_menu()

        cmd = input('> ')

        if(cmd == '0'):
            print_config_menu()
            while(True):
                cmd0 = input('> ')
                if(cmd0 == '0'):
                    stick.baudrate = int(input('Baudrate > '))
                elif(cmd0 == '1'):
                    stick.port = input('Device > ')
                elif(cmd0 == '2'):
                    stick.port = default_device
                    stick.baudrate = default_baudrate
                elif(cmd0 == '3'):
                    break

        elif(cmd == '1' and stick.port != None and not(stick.is_open)):
            if(not(debug)):
                stick.open()
        elif(cmd == '2' and (stick.is_open or debug)):
            addr = input('Addr > ')
            addr = '0b' + addr
            send_cmd(int('0b11', 2), addr=int(addr, 2))
        elif(cmd == '3' and (stick.is_open or debug)):
            addr = input('Addr > ')
            addr = '0b' + addr
            data = input('Data > ')
            data = '0b' + data
            send_cmd(int('0b10', 2), addr=int(addr, 2), data=int(data, 2))
        elif(cmd == '4' and (stick.is_open or debug)):
            send_cmd(int('0b01', 2))
            time.sleep(0.1)
            read_data()
        elif(cmd == '5' and (stick.is_open or debug)):
            send_cmd(int('0b00', 2))
            time.sleep(0.1)
            read_data()
        elif(cmd == '6' and stick.is_open):
            if(stick.is_open):
                stick.close()
        elif(cmd == '7'):
            if(stick.is_open):
                stick.close()
            break
        else:
            print("\x1b[31m", end='')
            print("Input error!!")
            print("\x1b[0m", end='')

        print()




    # for i in range(100):
    #     stick.write(b'a')

    #     time.sleep(0.5)

    #     data = b''
    #     while(stick.in_waiting > 0):
    #         data += stick.read(1)

    #     if(data != ''):
    #         print((BitArray(data)).bin, '(' + str(BitArray(data)) + ')')

    # stick.close()

if __name__ == "__main__":
    main()