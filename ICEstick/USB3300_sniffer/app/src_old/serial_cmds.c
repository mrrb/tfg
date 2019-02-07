#include "serial_cmds.h"
#include "common.h"


void serial_open()
{

}

void serial_close()
{
    
}

void reg_read(serial_t *serial, uint8_t addr)
{
    uint8_t full_cmd[2] = {0, 0};
    full_cmd[0] |= 0b11<<6;
    full_cmd[0] |= addr;

    char buff[2];
    sprintf(buff, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);
    write(serial->fd, buff, 2);

    usleep((int)(1000000/serial->baudrate)*2);
}

void reg_write(serial_t *serial, uint8_t addr, uint8_t data)
{
    uint8_t full_cmd[2] = {0, data};
    full_cmd[0] |= 0b10<<6;
    full_cmd[0] |= addr;

    char buff[2];
    sprintf(buff, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);
    write(serial->fd, buff, 2);
    usleep((int)(1000000/serial->baudrate)*2);
}

uint8_t recv_reg(serial_t *serial)
{
    uint8_t full_cmd[2] = {0, 0};
    full_cmd[0] |= 0b01<<6;

    char buff[2];
    sprintf(buff, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);
    write(serial->fd, buff, 2);

    usleep((int)(1000000/serial->baudrate)*4);

    char reg_val[2];
    int n = read(serial->fd, reg_val, 1);

    return (uint8_t) reg_val[0];
}

void recv_data(serial_t *serial, raw_USB_data_t *raw_data)
{
    uint8_t full_cmd[2] = {0, 0};

    char buff[2];
    sprintf(buff, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);
    write(serial->fd, buff, 2);

    usleep(10*(2+2));
    char data_info[3];
    int n = read(serial->fd, data_info, 2);

    raw_data->last_txcmd = ((uint8_t)data_info[0]&0xFC)>>2;
    raw_data->DATA_size  = ((uint8_t)data_info[0]&0x03)<<8 | (uint8_t)data_info[1];

    // raw_data->last_txcmd = (uint) atoi()
}
