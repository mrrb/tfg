#!/usr/bin/python3
# -*- coding: utf-8 -*-

from get_divider import get_min_divider
from get_divider import get_optimal_val

if __name__ == "__main__":
    counter_value = True;
    clk   = 12000000
    bauds = [
             110, 300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 28800, 38400, 56000, 57600, 115200, # Standard baud rates
             128000, 153600, 230400, 256000, 460800, 921600                                           # Less supported baud rates
            ]

    bauds.sort()
    bauds.reverse()
    baud_str_len = len(str(bauds[0]))+1
    for baud in bauds:
        if(counter_value):
            print("`define B{}{}{}".format(baud, ' '*(baud_str_len-len(str(baud))) ,get_optimal_val(clk, 1/baud)))
            # print("`define B{} {}".format(baud ,get_optimal_val(clk, 1/baud)))
        else:
            print("`define B{}{}{}".format(baud, ' '*(baud_str_len-len(str(baud))) ,get_min_divider(clk, 1/baud)))
            # print("`define B{} {}".format(baud ,get_min_divider(clk, 1/baud)))
