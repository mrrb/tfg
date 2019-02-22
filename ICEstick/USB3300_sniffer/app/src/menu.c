#include "menu.h"
#include "serial_ctrl.h"
#include "common.h"
#include "ANSI_codes.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

/* input functions */

// Function that asks for a number in any base from STDIN, checks if It is in a valid range
// (from min_val to max_val) and return it.
// The placeholder value is shown at the beginning of the line.
int usr_num_input(char *placeholder, int min_val, int max_val, int base)
{
    char *end, buf[USR_IN_SIZE_MAX];
    int num;

    LOG("%s> ", placeholder);
    // https://stackoverflow.com/questions/26583717/how-to-scanf-only-integer
    while (fgets(buf, sizeof(buf), stdin))
    {
        num = strtol(buf, &end, base);
        if (end == buf || *end != '\n') {}
        else if(num < min_val || num > max_val) {}
        else
            break;

        LOG(ANSI_TEXT_COLOR_RED"Please, enter a valid option ");
        if(base == 16)
            LOG("(min: %x, max: %x).\n", min_val, max_val);
        else if(base == 2)
            LOG("(min: "BYTE_TO_BINARY_PATTERN", max: "BYTE_TO_BINARY_PATTERN").\n", BYTE_TO_BINARY(min_val), BYTE_TO_BINARY(max_val));
        else
            LOG("(min: %d, max: %d).\n", min_val, max_val);

        LOG(ANSI_GRAPHICS_RESET"\n%s> ", placeholder);
    }

    return num;
}

// Function that asks for a string and stores it in the parameter usr_input.
// The placeholder value is shown at the beginning of the line.
void usr_input(char *placeholder, char *usr_input)
{
    LOG("%s> ", placeholder);
    fgets(usr_input, USR_IN_SIZE_MAX, stdin);

    usr_input[strlen(usr_input) - 1] = 0;
}


/* Menus */

void print_valid_ports(menu_t *menu)
{
    sp_port_t **list_ptr;
    sp_list_ports(&list_ptr);

    int i, port_num;
    for(i=0; list_ptr[i] != NULL; i++)
    {
        LOG(" Port %d. %s\n", i, sp_get_port_name(list_ptr[i]));
    }

    if(i <= 0)
        LOG("There isn't any available ports.\n");
    else
    {
        port_num = usr_num_input("PortNum ", 0, i-1, 10);
        sprintf(menu->usr_portname, "%s", sp_get_port_name(list_ptr[port_num]));
        LOG("New portname: %s\n", menu->usr_portname);
    }
}

void print_port_config_menu(menu_t *menu)
{
    if(menu->serial->is_open == 1)
    {
        LOG("Please, close the Serial Port first before using this option.\n");
        return;
    }

    LOG(ANSI_TEXT_COLOR_BLUE);
    LOG("\n## PORT CONFIG MENU ## \n");
    LOG(ANSI_GRAPHICS_RESET);

    LOG("Baudrate: %d bauds\n", menu->serial->baudrate);
    LOG("Port Name: %s\n", menu->serial->portname);

    LOG("0. Set baudrate.\n");
    LOG("1. Set Port Name.\n");
    LOG("2. Select available port.\n");
    LOG("3. Go back.\n");

    int opt;
    while((opt = usr_num_input("",0, 3, 10)) != 3)
    {
        if(opt == 0)
        {
            menu->usr_baudrate = usr_num_input("Bauds", 300, 3750000, 10);
            LOG("New baudrate: %d\n", menu->usr_baudrate);
        }
        else if(opt == 1)
        {
            usr_input("Port", menu->usr_portname);
            LOG("New portname: %s\n", menu->usr_portname);
        }
        else if(opt == 2)
            print_valid_ports(menu);
    }

    menu->opt = OPT_CONFIG_PORT;
    LOG("Saving changes...\n");

    menu->block_menu = 1;
    while(menu->block_menu == 1)
        usleep(500000);
}

void print_toggle_port_menu(menu_t *menu)
{
    if(menu->serial->is_open == 0)
    {

        menu->opt = OPT_OPEN_PORT;
        LOG("Opening port...\n");
    }
    else if(menu->serial->is_open == 1)
    {

        menu->opt = OPT_CLOSE_PORT;
        LOG("Closing port...\n");
    }

    menu->block_menu = 1;
    while(menu->block_menu == 1)
        usleep(500000);
}

void print_reg_read_menu(menu_t *menu)
{
    if(menu->serial->is_open == 0)
    {
        LOG("Please, open the Serial Port first before using this option.\n");
        return;
    }

    LOG(ANSI_TEXT_COLOR_BLUE);
    LOG("\n## REGISTER READ MENU ## \n");
    LOG(ANSI_GRAPHICS_RESET);

    LOG("Last known address: 0x%x (%d - b"BYTE_TO_BINARY_PATTERN")\n", menu->usr_addr, menu->usr_addr, BYTE_TO_BINARY(menu->usr_addr));

    LOG("0. Read Address [DEC].\n");
    LOG("1. Read Address [HEX].\n");
    LOG("2. Read Address [BIN].\n");
    LOG("3. Perform Register Read.\n");

    int opt;
    while((opt = usr_num_input("",0, 3, 10)) != 3)
    {
        if(opt == 0)
            menu->usr_addr = usr_num_input("Addr", 0, 63, 10);
        else if(opt == 1)
            menu->usr_addr = usr_num_input("Addr", 0, 63, 16);
        else if(opt == 2)
            menu->usr_addr = usr_num_input("Addr", 0, 63, 2);
        LOG("New Address: 0x%x\n", menu->usr_addr);
    }

    menu->opt = OPT_REG_READ;
    LOG("Reading register...\n");

    menu->block_menu = 1;
    while(menu->block_menu == 1)
        usleep(500000);
}

void print_reg_write_menu(menu_t *menu)
{
    if(menu->serial->is_open == 0)
    {
        LOG("Please, open the Serial Port first before using this option.\n");
        return;
    }

    LOG(ANSI_TEXT_COLOR_BLUE);
    LOG("\n## REGISTER WRITE MENU ## \n");
    LOG(ANSI_GRAPHICS_RESET);

    LOG("Last known address: 0x%x (%d - b"BYTE_TO_BINARY_PATTERN")\n", menu->usr_addr, menu->usr_addr, BYTE_TO_BINARY(menu->usr_addr));
    LOG("Last known data: 0x%x (%d - b"BYTE_TO_BINARY_PATTERN")\n", menu->usr_data, menu->usr_data, BYTE_TO_BINARY(menu->usr_data));

    LOG("0. Write Address [DEC].\n");
    LOG("1. Write Address [HEX].\n");
    LOG("2. Write Address [BIN].\n");
    LOG("3. Write Data [DEC].\n");
    LOG("4. Write Data [HEX].\n");
    LOG("5. Write Data [BIN].\n");
    LOG("6. Perform Register Write.\n");

    int opt;
    while((opt = usr_num_input("", 0, 6, 10)) != 6)
    {
        if(opt == 0)
            menu->usr_addr = usr_num_input("Addr", 0, 254, 10);
        else if(opt == 1)
            menu->usr_addr = usr_num_input("Addr", 0, 254, 16);
        else if(opt == 2)
            menu->usr_addr = usr_num_input("Addr", 0, 254, 2);
        else if(opt == 3)
            menu->usr_data = usr_num_input("Data", 0, 254, 10);
        else if(opt == 4)
            menu->usr_data = usr_num_input("Data", 0, 254, 16);
        else if(opt == 5)
            menu->usr_data = usr_num_input("Data", 0, 254, 2);
        
        if(opt >= 0 && opt <= 2)
            LOG("New Address: 0x%x\n", menu->usr_addr);
        if(opt >= 3 && opt <= 5)
            LOG("New Data: 0x%x\n", menu->usr_data);
    }

    menu->opt = OPT_REG_WRITE;
    LOG("Writing register...\n");

    menu->block_menu = 1;
    while(menu->block_menu == 1)
        usleep(500000);
}

void print_recv_toggle_menu(menu_t *menu)
{
    if(menu->serial->is_open == 0)
    {
        LOG("Please, open the Serial Port first before using this option.\n");
        return;
    }


    menu->opt = OPT_RECV_TOGGLE;
    LOG("Switching the status of the Receiver...\n");

    menu->block_menu = 1;
    while(menu->block_menu == 1)
        usleep(500000);
}

void print_exit_menu(menu_t *menu)
{
    menu->opt = OPT_EXIT;

    menu->block_menu = 1;
    while(menu->block_menu == 1)
        usleep(500000);
}

void print_main_menu(menu_t *menu)
{
    LOG(ANSI_TEXT_COLOR_BLUE);
    LOG("\n## MAIN MENU ## \n");
    LOG(ANSI_GRAPHICS_RESET);

    if(menu->serial->is_open == 1)
        LOG(ANSI_TEXT_COLOR_RED);
    LOG("0. Config port.\n");
    LOG(ANSI_GRAPHICS_RESET);

    if(menu->serial->is_open == 1)
        LOG("1. Close port");
    else
        LOG("1. Open port");

    LOG(" [%s @ %d].\n", menu->serial->portname, menu->serial->baudrate);

    if(menu->serial->is_open == 0)
        LOG(ANSI_TEXT_COLOR_RED);
    LOG("2. Command: REG_READ.\n");
    LOG("3. Command: REG_WRITE.\n");
    LOG("4. Command: RECV_TOGGLE [Currently %s].\n", (menu->read_en == 0) ? "OFF" : "ON");
    LOG(ANSI_GRAPHICS_RESET);

    LOG("5. Exit.\n");

    int opt = usr_num_input("", 0, 5, 10);
    
    if(opt == 0)
        print_port_config_menu(menu);
    else if(opt == 1)
        print_toggle_port_menu(menu);
    else if(opt == 2)
        print_reg_read_menu(menu);
    else if(opt == 3)
        print_reg_write_menu(menu);
    else if(opt == 4)
        print_recv_toggle_menu(menu);
    else if(opt == 5)
        print_exit_menu(menu);
}


/* Menu control */

void menu_init(menu_t *menu, serial_t *serial)
{
    menu->menu_kill = 0;
    menu->read_en = 0;
    menu->block_menu = 0;

    menu->opt    = OPT_IDLE;
    menu->serial = serial;

    menu->usr_addr = 0;
    menu->usr_data = 0;
    menu->usr_baudrate = serial->baudrate;

    sprintf(menu->usr_portname, "%s", serial->portname);
}