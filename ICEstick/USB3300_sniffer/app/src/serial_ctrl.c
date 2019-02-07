#include "serial_ctrl.h"
#include "common.h"

#include <unistd.h>
#include <malloc.h>
#include <math.h>

// /* ## Port list ## */

// void update_list_ports(serial_t *serial)
// {
//     if(serial->list_ports_ready == 1)
//     {
//         sp_return_t err; /* Error */

//         err = sp_list_ports(&(serial->list_ports));

//         serial->available_ports = 0;
//         if(err == SP_OK)
//             for(int i=0; serial->list_ports[i]; i++)
//                 serial->available_ports++;
//     }
// }

// void create_list_ports(serial_t *serial)
// {
//     sp_port_t **list_ports;

//     serial->list_ports = list_ports;
//     serial->list_ports_ready = 1;

//     update_list_ports(serial);
// }

/* ## Serial config ## */

sctrl_err_t serial_set_bloking(serial_t *serial, uint8_t bloking_en)
{
    serial->bloking_en = bloking_en;
    return SCTRL_OK;
}

sctrl_err_t serial_set_timeout(serial_t *serial, uint8_t timeout_ms)
{
    serial->timeout_ms = timeout_ms;
    return SCTRL_OK;
}

sctrl_err_t serial_set_default_timeout(serial_t *serial)
{
    return serial_set_timeout(serial, ceil(15*(921600/serial->baudrate)));
}

sctrl_err_t serial_config(serial_t *serial)
{
    if(serial->baudrate_ok!=1 || serial->portname_ok!=1)
        return SCTRL_ERR;

    sp_return_t err; /* Error */

    err = sp_get_port_by_name(serial->portname, &(serial->sp_port));

    if(err == SP_OK)
    {
        err = sp_open(serial->sp_port, SP_MODE_READ_WRITE);
        if(err == SP_OK)
        {
            err = sp_set_baudrate(serial->sp_port, serial->baudrate);
            if(err == SP_OK)
            {
                sp_set_bits(serial->sp_port, 8);
                sp_set_parity(serial->sp_port, SP_PARITY_NONE);
                sp_set_stopbits(serial->sp_port, 0);
                serial_set_default_timeout(serial);
                serial_set_bloking(serial, -1);

                return SCTRL_OK;
            }
            else
                LOG_E("Invalid baudrate.\n");
        }
        else
            LOG_E("Couldn't open serial device.\n");
    }
    else
        LOG_E("Serial device not found.\n");
    
    return SCTRL_ERR;
}

sctrl_err_t serial_set_baudrate(serial_t *serial, unsigned int baudrate)
{
    serial->baudrate = baudrate;
    serial->baudrate_ok = 1; 
    return SCTRL_OK;
}

sctrl_err_t serial_set_portname(serial_t *serial, char *portname)
{
    sp_return_t err; /* Error */
    sp_port_t *port;

    err = sp_get_port_by_name(portname, &port);

    if(err == SP_OK)
    {
        serial->portname = portname;
        serial->portname_ok = 1;
        return SCTRL_OK;
    }

    serial->portname_ok = 0;
    return SCTRL_ERR;
    
}

/* ## Serial control ## */

sctrl_err_t serial_open(serial_t *serial)
{
    return serial_config(serial);
}

sctrl_err_t serial_close(serial_t *serial)
{
    if(serial->is_open)
    {
        if(sp_close(serial->sp_port) == SP_OK)
            return SCTRL_OK;
    }
    return SCTRL_ERR;
}

int serial_input_waiting(serial_t *serial)
{
    if(serial->is_open)
    {
        return sp_input_waiting(serial->sp_port);
    }
    
    return -1;
}

int serial_output_waiting(serial_t *serial)
{
    if(serial->is_open)
    {
        return sp_output_waiting(serial->sp_port);
    }
    
    return -1;
}

int serial_read(serial_t *serial, size_t n_bytes, char *buffer)
{
    if(serial->is_open)
    {
        if(serial->bloking_en == -1)
        {
            while(serial_input_waiting(serial) < (int)n_bytes) {}
            return sp_nonblocking_read(serial->sp_port , buffer, n_bytes);
        }
        else if(serial->bloking_en)
            return sp_blocking_read(serial->sp_port , buffer, n_bytes, serial->timeout_ms);
        else	
            return sp_nonblocking_read(serial->sp_port , buffer, n_bytes);
    }

    return -1;
}

int serial_write(serial_t *serial, size_t n_bytes, char *buffer)
{
    if(serial->is_open)
    {
        if(serial->bloking_en == -1)
        {
            while(serial_output_waiting(serial) > 0) {}
            return sp_nonblocking_write(serial->sp_port , buffer, n_bytes);
        }
        else if(serial->bloking_en)
            return sp_blocking_write(serial->sp_port , buffer, n_bytes, serial->timeout_ms);
        else	
            return sp_nonblocking_write(serial->sp_port , buffer, n_bytes);
    }

    return -1;
}

/* ## App serial cmds ## */

sctrl_err_t reg_read(serial_t *serial, uint8_t addr)
{
    uint8_t full_cmd[2] = {0, 0};

    full_cmd[0] |= 0b11<<6;
    full_cmd[0] |= addr;

    char buf[2];
    sprintf(buf, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);

    if(serial_write(serial, 2, buf) < 2)
        return SCTRL_ERR;
    
    // usleep(2*(ceil(1000000/serial->baudrate)));
    
    return SCTRL_OK;
}

sctrl_err_t reg_write(serial_t *serial, uint8_t addr, uint8_t data)
{
    uint8_t full_cmd[2] = {0, 0};

    full_cmd[0] |= 0b10<<6;
    full_cmd[0] |= addr;
    full_cmd[1] |= data;

    char buf[2];
    sprintf(buf, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);

    if(serial_write(serial, 2, buf) < 2)
        return SCTRL_ERR;

    // usleep(2*(ceil(1000000/serial->baudrate)));
    
    return SCTRL_OK;
}

sctrl_err_t recv_data_toggle(serial_t *serial)
{
    uint8_t full_cmd[2] = {0, 0};

    full_cmd[0] |= 0b00<<6;
    full_cmd[1]  = 0b10010110;

    char buf[2];
    sprintf(buf, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);

    if(serial_write(serial, 2, buf) < 2)
        return SCTRL_ERR;
    
    // usleep(2*(ceil(1000000/serial->baudrate)));
    
    return SCTRL_OK;
}

sctrl_err_t recv_reg(serial_t *serial, uint8_t *reg_val)
{
    uint8_t full_cmd[2] = {0, 0};

    full_cmd[0] |= 0b01<<6;

    char buf[2];
    sprintf(buf, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);

    if(serial_write(serial, 2, buf) < 2)
        return SCTRL_ERR;

    // usleep(3*(ceil(1000000/serial->baudrate)));

    if(serial_read(serial, 1, (char *)reg_val) < 1)
        return SCTRL_ERR;

    return SCTRL_OK;
}


// sctrl_err_t recv_data_cmd(serial_t *serial, raw_usb_data_t *raw_data)
// {
//     uint8_t full_cmd[2] = {0, 0};

//     full_cmd[0] |= 0b00<<6;

//     char buf_send[2];
//     sprintf(buf_send, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);

//     if(serial_write(serial, 2, buf_send) < 2)
//         return SCTRL_ERR;
    
//     // usleep(4*(ceil(1000000/serial->baudrate)));

//     char buf[2];
//     if(serial_read(serial, 2, buf) < 2)
//         return SCTRL_ERR;

//     raw_data->TxCMD = ((uint8_t)buf[0]&0xFC)>>2;
//     raw_data->data_len = ((uint16_t)buf[0]&0x03)<<8 | (uint16_t)buf[1];
    
//     // usleep(raw_data->data_len*(ceil(1000000/serial->baudrate)));

//     char *buf_data = (char *)calloc(raw_data->data_len, sizeof(char));
//     if(serial_read(serial, raw_data->data_len, buf_data) < raw_data->data_len)
//         return SCTRL_ERR;

//     raw_data->data = (uint8_t *)buf_data;

//     return SCTRL_OK;
// }

sctrl_err_t recv_data_loop(serial_t *serial, raw_usb_data_t *raw_data)
{
    

    return SCTRL_OK;
}