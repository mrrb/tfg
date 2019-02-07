/* 
 *
 *  MIT License
 *  
 *  Copyright (c) 2018 Mario Rubio
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 * 
 */

#include "serial.h"
#include "common.h"
#include "ANSI_codes.h"

#include <stdint.h>
#include <unitypes.h>

void print_main_menu(void)
{
    LOG(ANSI_ERASE_LINE);
    LOG(ANSI_TEXT_COLOR_GREEN "## Main menu ##" ANSI_GRAPHICS_RESET "\n");
                          LOG("0. Config Port.\n");
                          LOG("1. Send \"Register Read\" command.\n" 
                              "2. Send \"Register Write\" command.\n"
                              "3. Send \"Register Send\" command.\n"
                              "4. Send \"RECV\" command.\n");
                          LOG("5. View port info.\n");
                          LOG("6. Exit.\n");
}

int main(int argc, char const *argv[])
{
    LOG("%d, %s \n", argc, argv[0]);

    int in_select;
    do
    {
        print_main_menu();
        LOG("> ");
        scanf("%d", &in_select);
        // LOG("%d\n", in_select);
        LOG(ANSI_CURSOR_N_UP(8));
    } while(in_select != 6);
    







    // char* portname = "/dev/ttyUSB1";
    // int fd = serial_open(portname);
    // set_interface_attribs (fd, B921600, 0);


    // char snd[2];
    // char recv[1];
    // // snd[0] = 0b11000000;
    // // snd[0] = 0b11010000;
    // // snd[1] = 0;

    // // write(fd, snd, 2);

    // // usleep (3 * 100);

    // // snd[0] = 0b01000000;

    // // write(fd, snd, 2);

    // // usleep (6 * 100);

    // // read (fd, recv, 1);

    // // LOG(BYTE_TO_BINARY_PATTERN " (%x)\n", BYTE_TO_BINARY(recv[0]), recv[0]);

    // for(int i=0; i<=24; ++i)
    // {
    //     snd[0] = 0b11000000;
    //     snd[1] = 0;
    //     snd[0] |= i;

    //     write(fd, snd, 2);

    //     usleep (3 * 100);

    //     snd[0] = 0b01000000;

    //     write(fd, snd, 2);

    //     usleep (6 * 100);

    //     read (fd, recv, 1);

    //     LOG(BYTE_TO_BINARY_PATTERN" > ", BYTE_TO_BINARY(i));
    //     LOG(BYTE_TO_BINARY_PATTERN " (%x)\n", BYTE_TO_BINARY(recv[0]), recv[0]);
    // }


    // snd[0] = 0b10010110;
    // snd[1] = 0b00000000;
    // write(fd, snd, 2);
    // usleep (3 * 100);
    // snd[0] = 0b11010110;
    // write(fd, snd, 2);
    // usleep (3 * 100);

    // putchar('\n');
    // for(int i=0; i<=24; ++i)
    // {
    //     snd[0] = 0b11000000;
    //     snd[1] = 0;
    //     snd[0] |= i;

    //     write(fd, snd, 2);

    //     usleep (3 * 100);

    //     snd[0] = 0b01000000;

    //     write(fd, snd, 2);

    //     usleep (6 * 100);

    //     read (fd, recv, 1);

    //     LOG(BYTE_TO_BINARY_PATTERN" > ", BYTE_TO_BINARY(i));
    //     LOG(BYTE_TO_BINARY_PATTERN " (%x)\n", BYTE_TO_BINARY(recv[0]), recv[0]);
    // }
    // snd[0] = 0b01010000;

    // write(fd, snd, 2);

    // usleep (6 * 100);

    // for(int i=0; i<5; ++i)
    // {
    //     usleep (2 * 100);

    //     read (fd, recv, 1);

    //     LOG(BYTE_TO_BINARY_PATTERN " (%x)\n", BYTE_TO_BINARY(recv[0]), recv[0]);
    // }


    return 0;
}