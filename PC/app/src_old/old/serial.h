/*
 *  Serial library created by the user wallyk @ stackoverflow 
 *  https://stackoverflow.com/questions/6947413/how-to-open-read-and-write-from-serial-port-in-c#answer-6947758
 */

#ifndef _SERIAL_H_
#define _SERIAL_H_

#include <errno.h>
#include <termios.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

struct _serial_s
{
    unsigned int baudrate;
    char *port_name;

    int fd;

    int is_open;
};
typedef struct _serial_s serial_t;

// int set_interface_attribs (int fd, int speed, int parity);
// void set_blocking (int fd, int should_block);
void serial_open(serial_t *serial);

#endif /* _SERIAL_H_ */