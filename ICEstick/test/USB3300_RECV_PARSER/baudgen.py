#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys

def gen_baud_divider(freq, baud):
    return int(freq/baud)

if __name__ == "__main__":
    freq = int(sys.argv[1])
    baud = int(sys.argv[2])
    print("For a {}Hz input and a desired baudrate of {}baud, the optimal divider is {}".format(freq, baud, gen_baud_divider(freq, baud)))
