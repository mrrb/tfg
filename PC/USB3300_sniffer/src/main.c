
// Standar libs
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// FTDI libs
#include <ftdi.h>

#define LOG(...) fprintf(stderr, __VA_ARGS__);
typedef struct ftdi_context ftdi_context_t;
typedef struct ftdi_device_list ftdi_device_list_t;

int main()
{
    ftdi_context_t *ftdi;
    if ((ftdi = ftdi_new()) == 0)
    {
        fprintf(stderr, "ftdi_new failed\n");
        return EXIT_FAILURE;
    }

    ftdi_device_list_t *ftdi_list;
    int ftdi_count;
    if((ftdi_count = ftdi_usb_find_all(ftdi, &ftdi_list, 0, 0)) >= 0)
    {
        LOG("Found %d FTDI devices.\n", ftdi_count);
    }
    else
    {
        LOG("Error trying to find FTDI devices.\n")
        return EXIT_FAILURE;
    }

    ftdi_list_free(&ftdi_list);

    ftdi_free(ftdi);
    return EXIT_SUCCESS;
}