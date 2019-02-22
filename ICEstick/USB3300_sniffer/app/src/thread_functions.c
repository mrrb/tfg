#include "thread_functions.h"

#include "menu.h"
#include "common.h"
#include "serial_ctrl.h"

#include <stdio.h>
#include <stdint.h>
#include <malloc.h>
#include <unistd.h>

/* Menu Thread loop */

void *menu_thread_loop(void *vargp)
{
    menu_t *menu = (menu_t *) vargp;
    do
    {
        print_main_menu(menu);
    } while (menu->menu_kill != 1);
    
    return NULL;
}


/* App serial thread loop */

void *serial_thread_loop(void *vargp)
{
    menu_t *menu = (menu_t *) vargp;
    serial_t *serial = menu->serial;

    uint8_t reg_val = 0;

    sctrl_err_t err;


    char buf_info[2];
    char *buf_data;
    uint8_t TxCMD;
    uint16_t data_len;

    FILE * fp;
    fp = fopen("out.log", "w+");

    for(;;)
    {
        if(menu->block_menu == 1)
        {
            uint8_t opt = menu->opt;
            if(opt == OPT_CONFIG_PORT)
            {
                if(serial->is_open == 0)
                {
                    if((err = serial_set_baudrate(serial, menu->usr_baudrate)) != SCTRL_OK)
                        LOG_E("Unsuccessful baudrate config (Error code %d).\n", err);
                    if((err = serial_set_portname(serial, menu->usr_portname)) != SCTRL_OK)
                        LOG_E("Unsuccessful port name config (Error code %d).\n", err);
                }
                else
                    LOG_E("Trying to config port while open (Error code %d).\n", SCTRL_CONFIG_WHILE_OPEN);
            }
            else if(opt == OPT_OPEN_PORT)
            {
                if(serial->is_open == 0)
                {
                    if((err = serial_open(serial)) != SCTRL_OK)
                        LOG_E("Error code %d.", err);
                }
                else
                    LOG_E("Port already open (Error code %d).\n", SCTRL_OPEN_WHILE_OPEN);
            }
            else if(opt == OPT_CLOSE_PORT)
            {
                if(serial->is_open == 1)
                {
                    if((err = serial_close(serial)) != SCTRL_OK)
                        LOG_E("Error code %d.", err);
                }
                else
                    LOG_E("Port already closed (Error code %d).\n", SCTRL_CLOSE_WHILE_CLOSE);
            }
            else if(opt == OPT_REG_READ)
            {
                if(serial->is_open == 1)
                {
                    if(menu->read_en == 1)
                        LOG_I("Please, turn off first the receiver.\n");
                    else
                    {
                        err = reg_read(menu->serial, menu->usr_addr);
                        err = recv_reg(serial, &reg_val);

                        LOG("The value of the register with address 0x%x is 0x%x (%d - b"BYTE_TO_BINARY_PATTERN")\n", menu->usr_addr, reg_val, reg_val, BYTE_TO_BINARY(reg_val));
                    }
                }
                else
                    LOG_E("Trying to perform an operation while the port is closed (Error code %d)\n", SCTRL_OPERATION_WHILE_CLOSE);
            }
            else if(opt == OPT_REG_WRITE)
            {
                if(serial->is_open == 1)
                {
                    if(menu->read_en == 1)
                        LOG_I("Please, turn off first the receiver.\n");
                    else
                    {
                        err = reg_write(menu->serial, menu->usr_addr, menu->usr_data);

                        LOG("The register with address 0x%x has be write with 0x%x (%d - b"BYTE_TO_BINARY_PATTERN")\n", menu->usr_addr, menu->usr_data, menu->usr_data, BYTE_TO_BINARY(menu->usr_data));
                    }
                }
                else
                    LOG_E("Trying to perform an operation while the port is closed (Error code %d)\n", SCTRL_OPERATION_WHILE_CLOSE);
            }
            else if(opt == OPT_RECV_TOGGLE)
            {
                if(serial->is_open == 1)
                {
                    if((err = recv_data_toggle(menu->serial)) == SCTRL_OK)
                        if(menu->read_en == 1)
                        {
                            // Wait to clean all messages
                            menu->read_en = 0;
                        }
                        else
                        {
                            recv_data_toggle(menu->serial);
                            menu->read_en = 1;
                        }
                    else
                        LOG_E("Error code %d.", err);                    
                }
                else
                    LOG_E("Trying to perform an operation while the port is closed (Error code %d)\n", SCTRL_OPERATION_WHILE_CLOSE);
            }
            else if(opt == OPT_EXIT)
            {
                if(serial->is_open == 1)
                    serial_close(serial);
                menu->menu_kill = 1;
                menu->block_menu = 0;
                fclose(fp);
                break;
            }

            menu->opt = OPT_IDLE;
            menu->block_menu = 0;
        }

        if(menu->read_en == 1)
        {
            serial_delay(serial, 2);

            if(serial_read(serial, 2, buf_info) == 2)
            {
                TxCMD = ((uint8_t)buf_info[0]&0xFC)>>2;
                data_len = ((uint16_t)buf_info[0]&0x03)<<8 | (uint16_t)buf_info[1];
                

                buf_data = (char *)calloc(data_len, sizeof(char));
                serial_delay(serial, data_len);

                if(serial_read(serial, data_len, buf_data) == data_len)
                {
                    fprintf(fp, "Data_len: %d, RxCMD: "BYTE_TO_BINARY_PATTERN, data_len, BYTE_TO_BINARY(TxCMD));

                    if(data_len > 0)
                    {
                        fprintf(fp, " PID: "BYTE_TO_BINARY_PATTERN"\n", BYTE_TO_BINARY(buf_data[0]));

                        for(int j=1; j<data_len; j++)
                            fprintf(fp, "\t\t%d - 0x%x\n", j, buf_data[j] & 0xff);
                    }
                    else
                        fprintf(fp, "\n");
                }
            }
            fprintf(fp, "\n");
            free(buf_data);
        }
        else
            usleep(1000);
    }

    return NULL;
}