#include "serial.h"
#include "serial_cmds.h"
#include "common.h"

#include <stdio.h>

int main()
{
    serial_t serial;
    serial.baudrate = 921600;
    serial.port_name = "/dev/ttyUSB1";

    serial_open(&serial);

    uint8_t reg;
    uint8_t addr, data;

    printf("## Register read Test ##\n");
    addr = 0x0A;
    reg_read(&serial, addr);
    reg = recv_reg(&serial);
    printf("Read addr 0x%x\n", addr);
    printf("0x%x\n\n", reg);

    // printf("## Register write Test ##\n");
    // addr = 0x0A;
    // data = 0x07;
    // reg_write(&serial, addr, data);
    // reg_read(&serial, addr);
    // reg = recv_reg(&serial);
    // printf("Write '%c' (0b"BYTE_TO_BINARY_PATTERN" - 0x%x) to the addr 0x%x\n", data, BYTE_TO_BINARY(data), data, addr);
    // printf("0x%x\n", reg);


    return 0;
}