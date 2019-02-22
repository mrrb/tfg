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

int main(int argc, char const *argv[])
{
    /* ## CONFIG ## */
    serial_t serial_s, *serial;
    serial = &serial_s;

    serial_set_portname(serial, "/dev/ttyUSB1");
    serial_set_baudrate(serial, 3750000);
    // serial_set_baudrate(serial, 921600);
    
    serial_open(serial);
    
    uint8_t reg;
    uint8_t addr, data;

    FILE * fp;
    fp = fopen("out.log", "w+");

    // printf("## Register read Test ##\n");
    // addr = 0x00;
    // reg_read(serial, addr);
    // recv_reg(serial, &reg);
    // printf("Read addr 0x%x\n", addr);
    // printf("0x%x\n\n", reg);


    // printf("## Register write Test ##\n");
    // addr = 0x16;
    // data = 0x07;
    // reg_write(serial, addr, data);
    // reg_read(serial, addr);
    // recv_reg(serial, &reg);
    // printf("Write '%c' (0b"BYTE_TO_BINARY_PATTERN" - 0x%x) to the addr 0x%x\n", data, BYTE_TO_BINARY(data), data, addr);
    // printf("0x%x\n", reg);

    // raw_usb_data_t usb_data;
    // int code, j;
    // for(unsigned int i=0; i<100; i++)
    // {
    //     code = recv_data(serial, &usb_data);

    //     if(usb_data.data_len > 0)
    //     {
    //         fprintf(fp, "Data_len: %d, TxCMD: "BYTE_TO_BINARY_PATTERN, usb_data.data_len, BYTE_TO_BINARY(usb_data.TxCMD<<2));
    //         fprintf(fp, " PID: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(usb_data.data[0]));

    //         for(j=0; j<usb_data.data_len-1; j++)
    //             fprintf(fp, "\t%d - 0x%x\n", j, usb_data.data[j]);
    //     }
    //     else
    //         i--;
    // }
    recv_data_toggle(serial);

    char buf_info[2];
    char *buf_data;
    uint8_t TxCMD;
    uint16_t data_len;
    int i, j;
    for(i=0; i<100000; i++)
    {
        if(i%100 == 0)
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