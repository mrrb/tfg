/* 
 *
 *  MIT License
 *  
 *  Copyright (c) 2019 Mario Rubio
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

#include "common.h"
#include "serial_ctrl.h"

#include <stdlib.h>

void print_main_menu(void)
{
    LOG(ANSI_ERASE_LINE);
    LOG(ANSI_TEXT_COLOR_GREEN "## Main menu ##" ANSI_GRAPHICS_RESET "\n");
                          LOG("0. Config Port.\n");
                          LOG("1. Open Port.\n");
                          LOG("2. Send \"Register Read\" command.\n" 
                              "3. Send \"Register Write\" command.\n"
                              "4. Send \"Register Send\" command.\n"
                              "5. Send \"RECV toggle\" command.\n");
                          LOG("6. Close Port.\n");
                          LOG("7. Exit.\n");
                          LOG("> ");
}

int main(int argc, char const *argv[])
{
    /* ## CONFIG ## */
    serial_t serial_s, *serial;
    serial = &serial_s;

    serial_set_portname(serial, "/dev/ttyUSB1");
    serial_set_baudrate(serial, 921600);
    
    serial_open(serial);
    
    uint8_t reg;
    uint8_t addr, data;

    FILE * fp;
    fp = fopen("out.log", "w+");

    
    /* ## MAIN LOOP ## */

    char usr_in = '\0';
    print_main_menu();
    while((usr_in = getchar()) != '7')
    {
        if(usr_in == '0')
        {

        }
        else if(usr_in == '1')
        {
            
        }
        else if(usr_in == '2')
        {

        }
        else if(usr_in == '3')
        {

        }
        else if(usr_in == '4')
        {

        }
        else if(usr_in == '5')
        {

        }
        else if(usr_in == '6')
        {

        }
        print_main_menu();
    }
    

    recv_data_toggle(serial);

    char buf_info[2];
    char *buf_data;
    uint8_t TxCMD;
    uint16_t data_len;
    int i, j;
    for(i=0; i<10000; i++)
    {
        if(i%10 == 0)
            LOG("DATA #%d\n", i);

        if(serial_read(serial, 2, buf_info) < 2)
            break;

        TxCMD = ((uint8_t)buf_info[0]&0xFC)>>2;
        data_len = ((uint16_t)buf_info[0]&0x03)<<8 | (uint16_t)buf_info[1];
        
        buf_data = (char *)calloc(data_len, sizeof(char));
        if(serial_read(serial, data_len, buf_data) < data_len)
            break;

        fprintf(fp, "Data_len: %d, RxCMD: "BYTE_TO_BINARY_PATTERN, data_len, BYTE_TO_BINARY(TxCMD));

        if(data_len > 0)
        {
            fprintf(fp, " PID: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(buf_data[0]));

            for(j=1; j<data_len; j++)
                fprintf(fp, "\t\t%d - 0x%x\n", j, buf_data[j] & 0xff);
        }
        else
            fprintf(fp, "\n");

        fprintf(fp, "\n");
        free(buf_data);
    }

    LOG_I("Loop count: %d\n", i);
    recv_data_toggle(serial);


    serial_close(serial);

    return 0;
}