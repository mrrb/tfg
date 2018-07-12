#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import math as m

def get_min_divider(clk, time):
    # T = clk /(2^n)
    return m.ceil(m.log(clk*time)/m.log(2))

def time_from_divider(clk, divider):
    return (2**divider)/clk

def print_help(name):
    print("Usage: "+name+" [option] arg1 arg2")
    print("Options: ",
          " -d: Print the minimal divider value for a given clock (arg1) and time (arg2). [Default]",
          " -t: Print the time for a given clock (arg1) and divider (arg2).", sep='\n')
    sys.exit()

if __name__ == "__main__":
    arg   = sys.argv
    name  = arg.pop(0)
    l     = len(arg)
    modes = {'d':False, 't':False} # d -> Print the minimal divider value [clk, time]; t -> print time for a given divider and clk [clk, div]

    modes_count = 0
    for i in modes:
        try:
            arg.pop(arg.index('-'+i))
            modes_count += 1
            modes[i] = True
        except:
            pass
    err = 0
    if(modes_count == 0): modes['d'] = True
    elif(modes_count > 1): err = 1

    if(len(arg) != 2 or err == 1):
        print_help(name)
    elif(not(arg[0].replace('.','',1).isdigit() and arg[1].replace('.','',1).isdigit())):
        print_help(name)
    else:
        arg = [float(i) for i in arg]
        if(modes['d']):
            # print('Desired time: {}s'.format(arg[1]))
            div = get_min_divider(arg[0], arg[1])
            div = [div, div-1]
            times = [time_from_divider(arg[0], div[0]), time_from_divider(arg[0], div[1])]
            error = [int((abs(arg[1]-i)/arg[1])*100) for i in times]

            min_pos = error.index(min(error))
            print('Recomended divider (with {}% error): {} [{}s]'.format(min(error), div[min_pos], times[min_pos]))
            print('{} [{}s] - [{}s] - {} [{}s]'.format(div[1], times[1], arg[1], div[0], times[0]))

        if(modes['t']):
            time = time_from_divider(arg[0], arg[1])
            print('Time: {}s'.format(time))
