#include "thread_functions.h"

#include "menu.h"
#include "common.h"
#include "serial_ctrl.h"

#include <stdio.h>
#include <stdint.h>
#include <malloc.h>
#include <unistd.h>
#include <time.h>
#include <jansson.h>

/*
 *  ToDo: Whenever read_en goes low, all the remaining data packets in the buffer must be saved.
 */

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
    // File save
    json_t *root = json_object(); //
    json_t *usb_data_array = json_array(); //

    json_object_set_new(root, "date", json_integer( (unsigned long)time(NULL) ));
    json_object_set_new(root, "USB_data", usb_data_array);

    // System renames
    menu_t *menu = (menu_t *) vargp;
    serial_t *serial = menu->serial;

    // Value of the read register
    uint8_t reg_val = 0;

    // Error code
    sctrl_err_t err;

    // Packet read
    raw_usb_data_t usb_data;

    // Buffer where the data_len and TxCMD are stored
    uint8_t buf_info[2];

    // Pointer to an array of uint8_t where all the received bytes are stored
    uint8_t *buf_data;

    // Number of bytes read in the serial port
    int bytes_read;

    long int total_packages = 0;

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
                    LOG_E("Port already open (Error code %d).\n", SCTRL_ALREADY_OPEN);
                
                if(reg_write(serial, 0x04, 0x69) != SCTRL_OK)
                {}
            }
            else if(opt == OPT_CLOSE_PORT)
            {
                if(serial->is_open == 1)
                {
                    if((err = serial_close(serial)) != SCTRL_OK)
                        LOG_E("Error code %d.", err);
                }
                else
                    LOG_E("Port already closed (Error code %d).\n", SCTRL_ALREADY_CLOSE);
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

                        LOG("The register with address 0x%x has been written with 0x%x (%d - b"BYTE_TO_BINARY_PATTERN")\n", menu->usr_addr, menu->usr_data, menu->usr_data, BYTE_TO_BINARY(menu->usr_data));
                    }
                }
                else
                    LOG_E("Trying to perform an operation while the port is closed (Error code %d)\n", SCTRL_OPERATION_WHILE_CLOSE);
            }
            else if(opt == OPT_RECV_TOGGLE)
            {
                LOG_I("Got here!");
                if(serial->is_open == 1)
                {
                    if((err = recv_data_toggle(menu->serial)) == SCTRL_OK)
                        if(menu->read_en == 1)
                        {
                            serial_delay(serial, 2);
                            sp_flush(serial->sp_port, SP_BUF_INPUT);
                            menu->read_en = 0;
                        }
                        else
                        {
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
                {
                    if(menu->read_en == 1)
                        recv_data_toggle(menu->serial);

                    serial_close(serial);
                }
                LOG("Saving dump in the file dump.json\n");
                FILE *fp = fopen("dump.json", "w+");

                char *buf = json_dumps(root, 0);
                fprintf(fp, "%s", buf);

                free(buf);
                fclose(fp);

                json_decref(root);
                json_decref(usb_data_array);

                menu->menu_kill = 1;
                menu->block_menu = 0;
                break;
            }

            menu->opt = OPT_IDLE;
            menu->block_menu = 0;
        }

        if(menu->read_en == 1 && serial_input_waiting(serial) >= 2)
        {
            // LOG_I("Got 1!");
            bytes_read = 0;
            json_t *packet_data_array = json_array();

            if((bytes_read = serial_read(serial, 2, (char *)buf_info)) != 2)
            {
                LOG_E("Fatal error. Out of sync. Reset FPGA and try again.\n");
                menu->menu_kill = 1;
                break;
            }
            usb_data.TxCMD = 0x3F & (((uint8_t)buf_info[0]&0xFC)>>2);
            usb_data.data_len = 0x3FF & (((uint16_t)buf_info[0]&0x03)<<8 | (uint16_t)buf_info[1]);

            serial_delay(serial, usb_data.data_len-1);

            buf_data = (uint8_t *)calloc(usb_data.data_len, sizeof(uint8_t));
            usb_data.data = buf_data;
            if(usb_data.data_len > 1024)
                LOG("%d bytes - Out Of Sync.\n", usb_data.data_len);
            if((bytes_read = serial_read(serial, usb_data.data_len, (char *)buf_data)) != usb_data.data_len)
            {
                LOG_E("Fatal error. Out of sync. Reset FPGA and try again.\n");
                menu->menu_kill = 1;
                break;
            }

            for(int i=0; i<usb_data.data_len; ++i)
            {
                json_array_append(packet_data_array, json_integer(usb_data.data[i]));
            }
            json_array_append(usb_data_array, json_pack("{sisiso}", "TxCMD",   usb_data.TxCMD,
                                                                    "DataLen", usb_data.data_len,
                                                                    "data",    packet_data_array));
            total_packages++;
        }
        else
            usleep(1000);
    }

    return NULL;
}