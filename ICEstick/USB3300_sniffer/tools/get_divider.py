#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import math as m

def get_optimal_val(clk, time):
    return m.ceil(clk*time)

def get_min_divider(clk, time):
    # T = clk /(2^n)
    return m.ceil(m.log(get_optimal_val(clk, time))/m.log(2))

def time_from_divider(clk, divider):
    return (2**divider)/clk

def get_clock(time, divider):
    return  int((2**divider)/time)

def print_help(name):
    print("Usage: "+name+" [option] arg1 arg2")
    print("Options: ",
          " -o: Print the optimal counter value for a given clock (arg1) and Serial baudrate (arg2). [Default]",
          " -b: Print the minimal divider value for a given clock (arg1) and Serial baudrate (arg2).",
          " -d: Print the minimal divider value for a given clock (arg1) and time (arg2).",
          " -t: Print the time (and serial baudrate) for a given clock (arg1) and divider (arg2).",
          " -c: Print the clock for a given time (arg1) and divider (arg2).",
          sep='\n')
    sys.exit()

if __name__ == "__main__":
    arg   = sys.argv
    name  = arg.pop(0)
    l     = len(arg)
    modes = {'o':False, 'b':False, 'd':False, 't':False, 'c':False} # o -> Print the optimal counter value [clk, baudrate];
                                                                    # b -> Print the minimal divider value [clk, baudrate];
                                                                    # d -> Print the minimal divider value [clk, time];
                                                                    # t -> print time for a given divider and clk [clk, div]
                                                                    # c -> print clock for a given time and divider [time, div]

    modes_count = 0
    for i in modes:
        try:
            arg.pop(arg.index('-'+i))
            modes_count += 1
            modes[i] = True
        except:
            pass
    err = 0
    if(modes_count == 0): modes['o'] = True
    elif(modes_count > 1): err = 1

    if(len(arg) != 2 or err == 1):
        print_help(name)
    elif(not(arg[0].replace('.','',1).isdigit() and arg[1].replace('.','',1).isdigit())):
        print_help(name)
    else:
        arg = [float(i) for i in arg]
        if(modes['o']):
            print("Optimal counter value: {}".format(get_optimal_val(arg[0], 1/arg[1])))
        elif(modes['d'] or modes['b']):
            # print('Desired time: {}s'.format(arg[1]))
            if(modes['b']):
                arg_time = 1/arg[1]
            else:
                arg_time = arg[1]
            div = get_min_divider(arg[0], arg_time)
            div = [div, div-1]
            times = [time_from_divider(arg[0], div[0]), time_from_divider(arg[0], div[1])]
            error = [int((abs(arg_time-i)/arg_time)*100) for i in times]

            min_pos = error.index(min(error))
            print('Recomended divider (with {}% error): {} [{}s]'.format(min(error), div[min_pos], times[min_pos]))
            print('{} [{}s] - [{}s] - {} [{}s]'.format(div[1], times[1], arg_time, div[0], times[0]))

        elif(modes['t']):
            time = time_from_divider(arg[0], arg[1])
            baud = 1/time;
            print('Time: {}s'.format(time))
            print('Baudrate: {}bauds'.format(baud))

        elif(modes['c']):
            clk = get_clock(arg[0], arg[1])
            print('Clock: {}Hz'.format(clk))
