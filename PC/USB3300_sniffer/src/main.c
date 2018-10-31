
// Standar libs
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <unistd.h>

// FTDI libs
#include <ftdi.h>
#include "ftdi_custom.h"

#define DEBUG

#define LOG_E(...) fprintf(stderr, __VA_ARGS__) // Error log macro
#define LOG_I(...) fprintf(stdout, __VA_ARGS__) // Info log macro

static const char *ftdi_string[] = { "Test - 1", "Test - 2", "Test - 3"};

int main(int argc, char *argv[])
{
    #ifdef DEBUG
    LOG_I("Argument count: %d.\n", argc);
    for(int i=0; i<argc; ++i) LOG_I("%d - %s", i, argv[i]);
    LOG_I("\n");
    #endif

    // Libftdi init
    ftdi_context_t *ftdi;
    if ((ftdi = ftdi_new()) == 0)
    {
        fprintf(stderr, "ftdi_new failed\n");
        return EXIT_FAILURE;
    }

    // Get device list 
    ftdi_device_list_t *ftdi_list;
    int ftdi_count;
    if((ftdi_count = ftdi_usb_find_all(ftdi, &ftdi_list, 0, 0)) > 0)
    {
        LOG_I("Found %d FTDI devices:\n", ftdi_count);
    }
    else
    {
        if(ftdi_count == 0) LOG_E("FTDI device not connected??\n");
        else LOG_E("Error trying to find FTDI devices. ftdi_usb_find_all() error code: %d\n", ftdi_count);
        return EXIT_FAILURE;
    }

    // Show list of FTDI
    int ftdi_dev_string_code;
    ftdi_device_list_t *current_dev = ftdi_list;
    // Manufacterer 126 + 1 bytes
    // Product description 255 + 1 bytes
    // SerialNumber 126 + 1 bytes
    static int manufacturer_max = 126+1, description_max = 255+1, serial_max = 126+1;
    char *manufacturer_str = (char *)calloc(manufacturer_max, sizeof(char));
    char *description_str  = (char *)calloc(description_max, sizeof(char));
    char *serial_str       = (char *)calloc(serial_max, sizeof(char));
    for(int i=0; i<ftdi_count; ++i)
    {
        LOG_I(" Device %d:\n", i);
        ftdi_dev_string_code = ftdi_usb_get_strings(ftdi, current_dev->dev,
                                                    manufacturer_str, manufacturer_max,
                                                    description_str, description_max,
                                                    serial_str, serial_max);
        if(ftdi_dev_string_code == -7)      sprintf(manufacturer_str, "--");
        else if(ftdi_dev_string_code == -8) sprintf(description_str, "--");
        else if(ftdi_dev_string_code == -9) sprintf(serial_str, "--");
        else
        {
            LOG_E("   Error trying to get info from FTDI devices. ftdi_usb_get_strings() error code: %d\n", ftdi_dev_string_code);
            continue;
        }
        LOG_I("   Manufacterer: %s\n", manufacturer_str);
        LOG_I("   Description: %s\n", description_str);
        LOG_I("   Serial number: %s\n", serial_str);
        if(!(i==(ftdi_count-1))) current_dev = current_dev->next;
    }
    free(manufacturer_str); free(description_str); free(serial_str);

    // Let the user select which ftdi device use
    unsigned int opt;
    LOG_I("\nSelect the device number you want to use\n> "); scanf("%u", &opt);
    if(opt>=(unsigned int)ftdi_count)
    {
        LOG_E("Device not listed.\n");
        return EXIT_FAILURE;
    };

    // Open device
    int ftdi_open_code;
    current_dev = ftdi_list;
    for(unsigned int i=0; i<opt; ++i) current_dev = current_dev->next;
    if((ftdi_open_code = ftdi_usb_open_dev(ftdi, current_dev->dev)) == 0)
    {
        LOG_I("\nOpened ftdi device %d.\n", opt);
    }
    else
    {
        LOG_E("Error trying to open FTDI device. ftdi_usb_find_all() error code: %d\n", ftdi_open_code);
    }

    // Device configured to work as a SPI bus (mpsse) in the interface B
    ftdi_usb_reset(ftdi); // Default state in case there was something going on
    ftdi_set_interface(ftdi, INTERFACE_B); // INTERFACE_ANY or INTERFACE_A or INTERFACE_B
    ftdi_set_bitmode(ftdi, 0, 0); // All bits -> reset
    ftdi_set_bitmode(ftdi, 0, BITMODE_RESET); // All bits -> MPSSE





    // ftdi_eeprom_initdefaults(ftdi, ftdi_string[0], NULL, NULL);
    // LOG_I("ftdi_set_eeprom_value() - %d\n", ftdi_set_eeprom_value(ftdi, MAX_POWER, 500));
    // LOG_I("ftdi_eeprom_build() - %d\n", ftdi_eeprom_build(ftdi));
    // LOG_I("ftdi_write_eeprom() - %d\n", ftdi_write_eeprom(ftdi));
    // ftdi_write_eeprom(ftdi);
    // 
    // int *coso;

    // ftdi_eeprom_decode(ftdi, 1);

    // ftdi_get_eeprom_value(ftdi, VENDOR_ID, coso);
    // printf("%d\n", *coso);

    // LOG_I("[");
    // for(int i=0; i<50;++i)
    // {
    //     LOG_I("=");
    //     fflush(stdout);
    //     usleep(100000);
    // }
    // LOG_I("] Done!\n");

    
    ftdi_free(ftdi);
    return EXIT_SUCCESS;
}