#ifndef _SERIAL_CTRL_H_
#define _SERIAL_CTRL_H_

#include <libserialport.h>
#include <stdint.h>

typedef struct sp_port sp_port_t;
typedef struct sp_port_config sp_port_config_t;
typedef enum   sp_return sp_return_t;

struct _serial_s
{
    // Config
    unsigned int baudrate;
    char *portname;
    enum sp_parity parity;
    uint8_t stp_bits;
    uint8_t n_bits;
    int8_t blocking_en;
    uint8_t timeout_ms;

    // Config status
    uint8_t baudrate_ok;
    uint8_t portname_ok;
    uint8_t parity_ok;
    uint8_t stp_bits_ok;
    uint8_t n_bits_ok;

    sp_port_t *sp_port;

    uint8_t is_open;
    uint8_t init_done;
};
typedef struct _serial_s serial_t;

struct _raw_usb_data_s
{
    uint8_t TxCMD;
    uint16_t data_len;

    uint8_t *data;

    uint8_t packet_ok;
};
typedef struct _raw_usb_data_s raw_usb_data_t;

enum serial_ctrl_err
{
    SCTRL_OK,
    SCTRL_ERR,
    SCTRL_PORTNAME_ERR,
    SCTRL_BITS_ERR,
    SCTRL_STP_BITS_ERR,

    SCTRL_CONFIG_WHILE_OPEN,
    SCTRL_OPERATION_WHILE_CLOSE,
    SCTRL_ALREADY_CLOSE,
    SCTRL_ALREADY_OPEN,
};
typedef enum serial_ctrl_err sctrl_err_t;


/* ## Serial config ## */
sctrl_err_t serial_init(serial_t *serial);
sctrl_err_t serial_set_blocking(serial_t *serial, uint8_t blocking_en);
sctrl_err_t serial_set_timeout(serial_t *serial, uint8_t timeout_ms);
sctrl_err_t serial_set_baudrate(serial_t *serial, unsigned int baudrate);
sctrl_err_t serial_set_portname(serial_t *serial, char *portname);
sctrl_err_t serial_set_bits(serial_t *serial, uint8_t n_bits);
sctrl_err_t serial_set_parity(serial_t *serial, enum sp_parity parity);
sctrl_err_t serial_set_stopbits(serial_t *serial, uint8_t stp_bits);

/* ## Serial control ## */
sctrl_err_t serial_open(serial_t *serial);
sctrl_err_t serial_close(serial_t *serial);
int serial_input_waiting(serial_t *serial);
int serial_output_waiting(serial_t *serial);
int serial_read(serial_t *serial, size_t n_bytes, char *buffer);
int serial_write(serial_t *serial, size_t n_bytes, char *buffer);
void serial_delay(serial_t *serial, int n_bytes);

/* ## App serial cmds ## */
sctrl_err_t reg_read(serial_t *serial, uint8_t addr);
sctrl_err_t reg_write(serial_t *serial, uint8_t addr, uint8_t data);
sctrl_err_t recv_reg(serial_t *serial, uint8_t *reg_val);
sctrl_err_t recv_data_toggle(serial_t *serial);


#endif /* _SERIAL_CTRL_H_ */