#ifndef _SERIAL_CTRL_H_
#define _SERIAL_CTRL_H_

#include <libserialport.h>
#include <stdint.h>

typedef struct sp_port sp_port_t;
typedef struct sp_port_config sp_port_config_t;
typedef enum   sp_return sp_return_t;

struct _serial_s
{
    unsigned int baudrate;
    char *portname;
    uint8_t baudrate_ok;
    uint8_t portname_ok;

    int8_t bloking_en;
    uint8_t timeout_ms;

    sp_port_t *sp_port;

    // sp_port_t **list_ports;
    // int list_ports_ready;
    // int available_ports;

    uint8_t is_open;
};
typedef struct _serial_s serial_t;

struct _raw_usb_data_s
{
    uint8_t TxCMD;
    uint16_t data_len;

    uint8_t *data;
};
typedef struct _raw_usb_data_s raw_usb_data_t;

enum serial_ctrl_err
{
    SCTRL_OK,
    SCTRL_ERR,
};
typedef enum serial_ctrl_err sctrl_err_t;


/* ## Serial config ## */
sctrl_err_t serial_set_bloking(serial_t *serial, uint8_t bloking_en);
sctrl_err_t serial_set_timeout(serial_t *serial, uint8_t timeout_ms);
sctrl_err_t serial_set_baudrate(serial_t *serial, unsigned int baudrate);
sctrl_err_t serial_set_portname(serial_t *serial, char *portname);

/* ## Serial control ## */
sctrl_err_t serial_open(serial_t *serial);
sctrl_err_t serial_close(serial_t *serial);
int serial_input_waiting(serial_t *serial);
int serial_output_waiting(serial_t *serial);
int serial_read(serial_t *serial, size_t n_bytes, char *buffer);
int serial_write(serial_t *serial, size_t n_bytes, char *buffer);

/* ## App serial cmds ## */
sctrl_err_t reg_read(serial_t *serial, uint8_t addr);
sctrl_err_t reg_write(serial_t *serial, uint8_t addr, uint8_t data);
sctrl_err_t recv_reg(serial_t *serial, uint8_t *reg_val);
sctrl_err_t recv_data_toggle(serial_t *serial);
// sctrl_err_t recv_data_cmd(serial_t *serial, raw_usb_data_t *raw_data);


#endif /* _SERIAL_CTRL_H_ */