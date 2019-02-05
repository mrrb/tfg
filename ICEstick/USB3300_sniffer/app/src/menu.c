#include "menu.h"
#include "common.h"

#include <math.h>
#include <malloc.h>
#include <stdlib.h>
#include <string.h>

#define NAV_PORTION 0.18
#define KEY_DELAY 1


void init_colors_pairs(void)
{
    init_pair(TXT_NAV_NORMAL_PAIR, COLOR_WHITE, COLOR_BLACK);
    init_pair(TXT_NAV_HIGHLIGHT_PAIR, COLOR_BLACK, COLOR_WHITE);

    init_pair(TXT_HEADER, COLOR_CYAN, COLOR_BLACK);
}


void init_main_menu()
{
    
}


window_t *window_init(void)
{
    window_t *win = (window_t *)malloc(sizeof(window_t)*1);
    win->_init_done = 0;

    initscr();   /* Ncurses init */
    curs_set(0); /* Hide the cursor */  
    noecho();    /*  */ 
    // raw();       /* cbreak better? */ 
    cbreak();       /* cbreak better? */ 
    // keypad(stdscr, TRUE); /* Enables function keys, arrow keys, etc.. */
    

    if(has_colors() == FALSE)
    {
        endwin();
        LOG_E("Your terminal does not support color!\n");
        exit(1);
    }
    start_color();
    init_colors_pairs();

    int initial_y, initial_x;
    getmaxyx(stdscr, initial_y, initial_x);

    win->initial_y = win->latest_y = initial_y;
    win->initial_x = win->latest_x = initial_x;

    int main_width = (int)floor((1.-NAV_PORTION)*initial_x);
    win_size_t head_size = {3, main_width}; /* {y, x} */
    win_size_t main_size = {initial_y-3, main_width}; /* {y, x} */
    win_size_t nav_size  = {2, initial_x-main_width}; /* {y, x} */
    win->head_size = head_size;
    win->main_size = main_size;
    win->nav_size  = nav_size;

    keypad(win->win_head, FALSE); /* Disables function keys, arrow keys, etc.. */
    keypad(win->win_main, FALSE); /* Disables function keys, arrow keys, etc.. */
    keypad(win->win_nav, FALSE);  /* Disables function keys, arrow keys, etc.. */

    win->win_head = newwin(head_size.y, head_size.x, 0, nav_size.x-1);
    win->win_main = newwin(main_size.y, main_size.x, 3, nav_size.x-1);
    win->win_nav  = newwin(nav_size.y, nav_size.x, 3, 0);

    // wborder(win->win_head, '.', '.', '.', '.', '.', '.', '.', '.');
    box(win->win_main, 0, 0);
    box(win->win_nav, 0, 0);

    win_size_t win_size_init = {-1, -1};
    win->max_main = win_size_init;
    win->max_nav  = win_size_init;

    win->size_nav_items = 0;
    win->selected_item  = 0;
    win->active_item    = -1;

    win->_init_done = 1;

    return win;
}


void resize_windows(window_t *win)
{
    endwin();
    refresh();

    int latest_y, latest_x;
    getmaxyx(stdscr, latest_y, latest_x);
    win->latest_y = latest_y;
    win->latest_x = latest_x;

    win_size_t main_max, nav_max;
    main_max = win->max_main;
    nav_max  = win->max_nav;

    int main_width = (int)floor((1.-NAV_PORTION)*latest_x);
    win_size_t head_size = {3, main_width}; /* {y, x} */
    win_size_t main_size = {latest_y-3, main_width}; /* {y, x} */
    win_size_t nav_size  = {win->size_nav_items+2, latest_x-main_width}; /* {y, x} */

    if((nav_size.y > nav_max.y) && (nav_max.y != -1))
        nav_size.y = nav_max.y;

    if((nav_size.x > nav_max.x) && (nav_max.x != -1))
    {
        head_size.x += nav_size.x - nav_max.x;
        main_size.x += nav_size.x - nav_max.x;
        nav_size.x = nav_max.x;
    }

    if((main_size.y > main_max.y) && (main_max.y != -1))
        main_size.y = main_max.y;
    if((main_size.x > main_max.x) && (main_max.x != -1))
    {
        head_size.x = main_max.x;
        main_size.x = main_max.x;
    }

    win->head_size = head_size;
    win->main_size = main_size;
    win->nav_size  = nav_size;

    clear();
    wclear(win->win_head);
    wclear(win->win_main);
    wclear(win->win_nav);
    
    mvwin(win->win_head, 0, nav_size.x);
    mvwin(win->win_main, 3, nav_size.x);
    wresize(win->win_head, win->head_size.y, win->head_size.x);
    wresize(win->win_main, win->main_size.y, win->main_size.x);
    wresize(win->win_nav, win->nav_size.y, win->nav_size.x);
    
    box(win->win_head, 0, 0);
    box(win->win_main, 0, 0);
    box(win->win_nav, 0, 0);
}


void set_windows_limits(window_t *win, win_size_t main_max, win_size_t nav_max)
{
    win->max_main = main_max;
    win->max_nav  = nav_max;

    resize_windows(win);    
}


void set_nav_items(window_t *win, char **items, size_t items_size)
{
    win->nav_items = items;
    win->size_nav_items = items_size;
    win->selected_item = 0;

    resize_windows(win);
}


void print_header_title(window_t *win, char *text)
{
    wclear(win->win_head);
    wborder(win->win_head, '|', '|', '-', '-', '+', '+', '+', '+');

    int x_pos = (int)(win->head_size.x / 2) - (int)(strlen(text)/2);
    wattron(win->win_head, COLOR_PAIR(TXT_HEADER));
    wattron(win->win_head, A_BOLD);
    mvwprintw(win->win_head, 1, x_pos, "%s", text);
    wattroff(win->win_head, A_BOLD);
    wattroff(win->win_head, COLOR_PAIR(TXT_HEADER));
}


void plot_input_box(WINDOW w, int pos_y, int pos_x)
{
    
}


void plot_btn(WINDOW w, int pos_y, int pos_x)
{

}


void plot_default_menu(window_t *win)
{
    char header_text[] = "Default menu title!!";
    print_header_title(win, header_text);
}


void plot_open_port_menu(window_t *win)
{
    char header_text[] = "Open port title!!";
    print_header_title(win, header_text);
}


void plot_reg_read_menu(window_t *win)
{
    char header_text[] = "Register read title!!";
    print_header_title(win, header_text);
}


void plot_reg_write_menu(window_t *win)
{
    char header_text[] = "Register write title!!";
    print_header_title(win, header_text);
}


void plot_recv_reg_menu(window_t *win)
{
    char header_text[] = "Receive register value title!!";
    print_header_title(win, header_text);
}


void plot_recv_data_menu(window_t *win)
{
    char header_text[] = "Receive DATA title!!";
    print_header_title(win, header_text);
}


void plot_close_port_menu(window_t *win)
{
    char header_text[] = "Close port title!!";
    print_header_title(win, header_text);
}


void print_nav_items(window_t *win)
{
    int text_width = win->nav_size.x - 2;
    for(int i=0; i<win->size_nav_items; i++)
    {
        if(i == win->selected_item)
            // wattron(win->win_nav, A_STANDOUT);
            wattron(win->win_nav, COLOR_PAIR(TXT_NAV_HIGHLIGHT_PAIR));
        else
            // wattroff(win->win_nav, A_STANDOUT);
            wattron(win->win_nav, COLOR_PAIR(TXT_NAV_NORMAL_PAIR));
        mvwprintw(win->win_nav, i+1, 1, "%.*s", text_width, win->nav_items[i]);
        wattroff(win->win_nav, COLOR_PAIR(TXT_NAV_NORMAL_PAIR));
        wattroff(win->win_nav, COLOR_PAIR(TXT_NAV_HIGHLIGHT_PAIR));
    }
}


void update_windows(window_t* win)
{
    keypad(win->win_nav, FALSE);
    keypad(win->win_main, FALSE);

    wrefresh(win->win_head);
    wrefresh(win->win_main);
    wrefresh(win->win_nav);
}


int read_nav_menu(window_t *win)
{
    keypad(win->win_nav, TRUE);
    halfdelay(KEY_DELAY);
    int wsi;

    int usr_in = wgetch(win->win_nav);

    wsi = win->selected_item;
    if(usr_in == KEY_DOWN)
        win->selected_item = (wsi < (win->size_nav_items-1)) ? wsi+1 : 0;
    else if(usr_in == KEY_UP)
        win->selected_item = (wsi > 0) ? wsi-1 : win->size_nav_items-1;
    
    if(usr_in == 'q')
        win->selected_item = -1;

    return usr_in;
}


int read_main_menu(window_t *win)
{
    keypad(win->win_nav, TRUE);
    halfdelay(KEY_DELAY);

    int usr_in = wgetch(win->win_nav);

    // if(usr_in == KEY_DOWN)
    //     win->selected_item = (wsi < (win->size_nav_items-1)) ? wsi+1 : 0;
    // else if(usr_in == KEY_UP)
    //     win->selected_item = (wsi > 0) ? wsi-1 : win->size_nav_items-1;

    return usr_in;
}


void window_delete(window_t *win)
{
    delwin(win->win_head);
    delwin(win->win_main);
    delwin(win->win_nav);
    free(win);
    endwin();
}