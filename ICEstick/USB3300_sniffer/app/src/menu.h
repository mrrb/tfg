#ifndef _MENU_H_
#define _MENU_H_

#include "serial_ctrl.h"

// #include <semaphore.h>
#include <stdint.h>

#define USR_IN_SIZE_MAX 100 /* Input buffer max size */

struct _menu_s
{
    uint8_t opt; /* Menu option */

    uint8_t usr_addr; /* User input address */
    uint8_t usr_data; /* User input data */
    int usr_baudrate; /* User input baudrate */
    char usr_portname[USR_IN_SIZE_MAX]; /* User input port name */

    uint8_t block_menu; /* Simple menu blocking semaphore */

    uint8_t menu_kill;  /* Terminate menu */

    uint8_t read_en;    /* RECV ON[1] or OFF[0] */

    // sem_t block_menu;

    serial_t *serial;   /* Serial struct */
};
typedef struct _menu_s menu_t;

enum opt_values
{
    OPT_IDLE,
    OPT_CONFIG_PORT,
    OPT_OPEN_PORT,
    OPT_CLOSE_PORT,
    OPT_REG_READ,
    OPT_REG_WRITE,
    OPT_RECV_TOGGLE,
    OPT_EXIT
};
typedef enum opt_values opt_values_t;

// Functions
void menu_init(menu_t *menu_controls, serial_t *serial);
void print_main_menu(menu_t *menu);

#endif /* _MENU_H_ */