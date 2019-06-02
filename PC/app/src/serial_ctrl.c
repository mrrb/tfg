#include "serial_ctrl.h"
#include "common.h"

#include <unistd.h>
#include <malloc.h>
#include <math.h>

// #define DEFAULT_BAUDRATE 921600
#define DEFAULT_BAUDRATE 3750000
#define DEFAULT_PORT "/dev/ttyUSB1"


/* ## Serial config ## */

// Serial baudrate
sctrl_err_t serial_set_baudrate(serial_t *serial, unsigned int baudrate)
{
    serial->baudrate = baudrate;
    serial->baudrate_ok = 1; 
    return SCTRL_OK;
}

// Serial portname
sctrl_err_t serial_set_portname(serial_t *serial, char *portname)
{
    sp_return_t err; /* Error */
    sp_port_t *port;

    err = sp_get_port_by_name(portname, &port);


    if(err == SP_OK)
    {
        serial->portname = portname;
        serial->sp_port = port;
        serial->portname_ok = 1;
        return SCTRL_OK;
    }

    serial->portname_ok = 0;
    return SCTRL_PORTNAME_ERR;
}

// Serial blocking
sctrl_err_t serial_set_blocking(serial_t *serial, uint8_t blocking_en)
{
    if(blocking_en == 2 || blocking_en == 1 || blocking_en == 0)
    {
        serial->blocking_en = blocking_en;
        return SCTRL_OK;
    }
    else
        return SCTRL_ERR;
}

// Serial timeout
sctrl_err_t serial_set_timeout(serial_t *serial, uint8_t timeout_ms)
{
    serial->timeout_ms = timeout_ms;
    return SCTRL_OK;
}

// Data bits
sctrl_err_t serial_set_bits(serial_t *serial, uint8_t n_bits)
{
    if(n_bits>=5 && n_bits<=9)
    {
        serial->n_bits = n_bits;
        serial->n_bits_ok = 1;
        return SCTRL_OK;
    }

    serial->n_bits_ok = 0;
    return SCTRL_BITS_ERR;
}

// Parity
sctrl_err_t serial_set_parity(serial_t *serial, enum sp_parity parity)
{
    serial->parity = parity;
    serial->parity_ok = 1;
    return SCTRL_OK;
}

// Stop bits
sctrl_err_t serial_set_stopbits(serial_t *serial, uint8_t stp_bits)
{
    if(stp_bits>=1 && stp_bits<=5)
    {
        serial->stp_bits = stp_bits;
        serial->stp_bits_ok = 1;
        return SCTRL_OK;
    }

    serial->stp_bits_ok = 0;
    return SCTRL_STP_BITS_ERR;
}

// Serial init
sctrl_err_t serial_init(serial_t *serial)
{
    sctrl_err_t err;

    serial->is_open = 0;
    if(serial->init_done == 1)
        return SCTRL_ERR;

    if((err = serial_set_baudrate(serial, DEFAULT_BAUDRATE)) != SCTRL_OK)
        return err;
    serial->portname = DEFAULT_PORT;
    serial->portname_ok = 1;
    if((err = serial_set_timeout(serial, 1)) != SCTRL_OK)
        return err;
    if((err = serial_set_bits(serial, 8)) != SCTRL_OK)
        return err;
    if((err = serial_set_parity(serial, SP_PARITY_NONE)) != SCTRL_OK)
        return err;
    if((err = serial_set_stopbits(serial, 1)) != SCTRL_OK)
        return err;

    serial_set_blocking(serial, 1);

    serial->init_done = 1;
    return SCTRL_OK;
}

// Serial config
sctrl_err_t serial_config(serial_t *serial)
{
    if(serial->init_done != 1)
        return SCTRL_ERR;
    if(serial->baudrate_ok!=1 ||
       serial->portname_ok!=1 ||
       serial->stp_bits_ok!=1 ||
       serial->parity_ok!=1   ||
       serial->n_bits_ok!=1)
        return SCTRL_ERR;

    if(sp_get_port_by_name(serial->portname, &(serial->sp_port)) != SP_OK)
    {
        LOG_E("Serial device not found.\n");
        return SCTRL_ERR;
    }

    if(sp_open(serial->sp_port, SP_MODE_READ_WRITE) != SP_OK)
    {
        LOG_E("Couldn't open serial device.\n");
        return SCTRL_ERR;
    }

    if(sp_set_baudrate(serial->sp_port, serial->baudrate) != SP_OK)
    {
        LOG_E("Invalid baudrate.\n");
        return SCTRL_ERR;
    }

    if(sp_set_bits(serial->sp_port, serial->n_bits) != SP_OK)
        return SCTRL_ERR;

    if(sp_set_parity(serial->sp_port, serial->parity) != SP_OK)
        return SCTRL_ERR;

    if(sp_set_stopbits(serial->sp_port, serial->stp_bits) != SP_OK)
        return SCTRL_ERR;   
    
    return SCTRL_OK;
}


/* ## Serial control ## */

sctrl_err_t serial_open(serial_t *serial)
{
    sctrl_err_t err;
    if(serial->is_open == 0)
    {
        if((err = serial_config(serial)) == SCTRL_OK)
            serial->is_open = 1;
        return err;
    }

    return SCTRL_ALREADY_OPEN;
}

sctrl_err_t serial_close(serial_t *serial)
{
    if(serial->is_open == 1)
    {
        if(sp_close(serial->sp_port) == SP_OK)
            serial->is_open = 0;
        return SCTRL_OK;
    }
    else
        return SCTRL_ALREADY_CLOSE;
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
        if(serial->blocking_en == 1)
            return sp_blocking_read(serial->sp_port , buffer, n_bytes, serial->timeout_ms);
        else if(serial->blocking_en == 2)
        {
            for(size_t i=0; i<n_bytes; i++)
            {
                while(sp_nonblocking_read(serial->sp_port , buffer+i, 1) <= 0)
                    serial_delay(serial, 1);                
            }
        }
        else	
            return sp_nonblocking_read(serial->sp_port , buffer, n_bytes);
    }

    return -1;
}

int serial_write(serial_t *serial, size_t n_bytes, char *buffer)
{
    if(serial->is_open)
    {
        if(serial->blocking_en == 1)
            return sp_blocking_write(serial->sp_port , buffer, n_bytes, serial->timeout_ms);
        else if(serial->blocking_en == 2)
            return sp_blocking_write(serial->sp_port , buffer, n_bytes, serial->timeout_ms);
        else	
            return sp_nonblocking_write(serial->sp_port , buffer, n_bytes);
    }

    return -1;
}

void serial_delay(serial_t *serial, int n_bytes)
{
    usleep(ceil((11*n_bytes*1000000)/serial->baudrate));
}

/* ## App serial cmds ## */

sctrl_err_t reg_read(serial_t *serial, uint8_t addr)
{
    uint8_t full_cmd[2] = {0, 0};

    full_cmd[0] |= 0b11<<6;
    full_cmd[0] |= addr;

    char buf[3];
    sprintf(buf, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);

    if(serial_write(serial, 2, buf) < 2)
        return SCTRL_ERR;
    
    sp_drain(serial->sp_port);

    return SCTRL_OK;
}

sctrl_err_t reg_write(serial_t *serial, uint8_t addr, uint8_t data)
{
    uint8_t full_cmd[2] = {0, 0};

    full_cmd[0] |= 0b10<<6;
    full_cmd[0] |= addr;
    full_cmd[1] |= data;

    char buf[3];
    sprintf(buf, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);

    if(serial_write(serial, 2, buf) < 2)
        return SCTRL_ERR;

    sp_drain(serial->sp_port);
    
    return SCTRL_OK;
}

sctrl_err_t recv_data_toggle(serial_t *serial)
{
    uint8_t full_cmd[2] = {0, 0};

    full_cmd[0] |= 0b00<<6;
    full_cmd[1]  = 0b10010110;

    char buf[3];
    sprintf(buf, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);

    // if(reg_write(serial, 0x04, 0x49) != SCTRL_OK)
    //     return SCTRL_ERR;

    if(serial_write(serial, 2, buf) < 2)
        return SCTRL_ERR;
    
    sp_drain(serial->sp_port);
    
    return SCTRL_OK;
}

sctrl_err_t recv_reg(serial_t *serial, uint8_t *reg_val)
{
    uint8_t full_cmd[2] = {0, 0};

    full_cmd[0] |= 0b01<<6;

    char buf[3];
    sprintf(buf, "%c%c", (char)full_cmd[0], (char)full_cmd[1]);

    if(serial_write(serial, 2, buf) < 2)
        return SCTRL_ERR;

    sp_drain(serial->sp_port);

    if(serial_read(serial, 1, (char *)reg_val) < 1)
        return SCTRL_ERR;

    return SCTRL_OK;
}