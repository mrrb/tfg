/* 
 *
 *  MIT License
 *  
 *  Copyright (c) 2019 Mario Rubio
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 * 
 */

#include "common.h"
#include "menu.h"
#include "serial_ctrl.h"
#include "thread_functions.h"

#include <pthread.h>

int main(int argc, char const *argv[])
{
    /* ## SERIAL CONFIG ## */
    serial_t serial_s, *serial;
    serial = &serial_s;

    sctrl_err_t err = serial_init(serial);
    if(err != SCTRL_OK)
    {
        LOG_E("Could not init serial port! Error code %d.\n", err);
        return 1;
    }
    serial_set_blocking(serial, 1); // Non blocking serial read/write


    /* ## MENU CONFIG ## */
    menu_t menu_s, *menu;
    menu = &menu_s;

    menu_init(menu, serial);


    /* ## THREAD CONFIG ## */
    pthread_t menu_thread_id, serial_ctrl_thread_id;

    pthread_create(&menu_thread_id, NULL, menu_thread_loop, (void *)menu); /* Menu Thread */
    pthread_create(&serial_ctrl_thread_id, NULL, serial_thread_loop, (void *)menu); /* Serial Control Thread */

    pthread_join(menu_thread_id, NULL); 
    pthread_join(serial_ctrl_thread_id, NULL);

    /* ## END ## */
    LOG("\nBye!\n");
    return 0;
}