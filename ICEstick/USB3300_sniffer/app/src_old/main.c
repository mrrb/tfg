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

#include "menu.h"
#include "common.h"
#include "serial_cmds.h"

char *nav_items[] = {"Open port",
                     "Register Read",
                     "Register Write",
                     "Receive Reg. value",
                     "Receive Data",
                     "Close port",
                     "Exit"};

const char default_port[] = "/dev/ttyUSB1";
const int default_baudrate = 921600;


const enum
{
    ITEM_OPEN_PORT,
    ITEM_REG_READ,
    ITEM_REG_WRITE,
    ITEM_RECV_REG,
    ITEM_RECV_DATA,
    ITEM_CLOSE_PORT,
    ITEM_EXIT,
} item_num_e;


int size_change = 0;
int run = 1;
void term_resize_ctrl(int sig)
{
    signal(SIGWINCH, SIG_IGN);
    size_change = 1;
    signal(SIGWINCH, term_resize_ctrl);
}

void exit_ctrl(int sig)
{
    run = 0;
}

void chk_resize(window_t *win)
{
    if(size_change == 1)
    {
        resize_windows(win);  
        size_change = 0;
        print_nav_items(win);
    }
}

void main_menu_loop(window_t *win, app_data_t *app_data, void (*plot_func)(window_t *win, app_data_t *app_data))
{
    int usr_in;
    do
    {
        chk_resize(win);
        plot_func(win, app_data);
        usr_in = read_main_menu(win);
        update_windows(win);
    }while(usr_in != 27 && run == 1);
}

int main(int argc, char const *argv[])
{
    /* ## CONFIG ## */
    window_t *win = window_init();
    set_nav_items(win, nav_items, 7);

    win_size_t max_nav = {-1, 20};
    set_windows_limits(win, win->max_main, max_nav);

    signal(SIGWINCH, term_resize_ctrl);
    signal(SIGINT, exit_ctrl);

    app_data_t app_data;

    

    /* ## MAIN LOOP ## */

    int wsi;
    int usr_in;
    do
    {
        do
        {
            chk_resize(win);
            plot_default_menu(win, &app_data);
            print_nav_items(win);
            usr_in = read_nav_menu(win);
            update_windows(win);
        }while(usr_in != 'q' && usr_in != '\n' && run == 1);
        
        wsi = win->selected_item;
        

        if(wsi == ITEM_OPEN_PORT)
        {
            win->active_item = wsi;
            main_menu_loop(win, &app_data, plot_open_port_menu);
        }
        else if(wsi == ITEM_REG_READ)
        {
            win->active_item = wsi;
            main_menu_loop(win, &app_data, plot_reg_read_menu);
        }
        else if(wsi == ITEM_REG_WRITE)
        {
            win->active_item = wsi;
            main_menu_loop(win, &app_data, plot_reg_write_menu);
        }
        else if(wsi == ITEM_RECV_REG)
        {
            win->active_item = wsi;
            main_menu_loop(win, &app_data, plot_recv_reg_menu);
        }
        else if(wsi == ITEM_RECV_DATA)
        {
            win->active_item = wsi;
            main_menu_loop(win, &app_data, plot_recv_data_menu);
        }
        else if(wsi == ITEM_CLOSE_PORT)
        {
            win->active_item = wsi;
            main_menu_loop(win, &app_data, plot_close_port_menu);
        }
    } while(wsi != ITEM_EXIT && wsi != -1 && run == 1);


    /* ## END ## */

    window_delete(win);
    LOG("Bye!\n");
    return 0;
}