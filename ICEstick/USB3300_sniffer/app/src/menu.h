#ifndef _MENU_H_
#define _MENU_H_

#include <ncurses.h>
#include <signal.h>

struct _win_size_s
{
    int y;
    int x;
};
typedef struct _win_size_s win_size_t;

struct _window_s
{
    char **nav_items;
    int size_nav_items;
    int selected_item;
    int active_item;

    int initial_y, latest_y; /* Initial & latest y term size */
    int initial_x, latest_x; /* Initial & latest x term size */

    /* Navigation lateral menu */
    WINDOW *win_nav;
    win_size_t nav_size, max_nav;

    /* Main window */
    WINDOW *win_main;
    win_size_t main_size, max_main;

    /* Header window */
    WINDOW *win_head;
    win_size_t head_size, max_head;

    /* Main menu plot items */

    

    int _init_done;
};
typedef struct _window_s window_t;

struct _plot_item_s
{
    int type;
    
    int pos_y;
    int pos_x;

    char *name;

    char *default_val;
    int size;
};
typedef struct _plot_item_s plot_item_t;

const enum
{
    TXT_NAV_NORMAL_PAIR = 1,
    TXT_NAV_HIGHLIGHT_PAIR,
    TXT_NAV_SELECTED_PAIR,

    TXT_HEADER,

    TXT_MAIN_NORMAL_PAIR,
} color_index_e;

window_t *window_init();
void set_nav_items(window_t *win, char **items, size_t items_size);
void set_windows_limits(window_t *win, win_size_t main_max, win_size_t nav_max);
void window_delete(window_t *win);

void resize_windows(window_t *win);
void update_windows(window_t *win);

int read_nav_menu(window_t *win);
int read_main_menu(window_t *win);

void print_nav_items(window_t *win);

void plot_default_menu(window_t *win);
void plot_open_port_menu(window_t *win);
void plot_reg_read_menu(window_t *win);
void plot_reg_write_menu(window_t *win);
void plot_recv_reg_menu(window_t *win);
void plot_recv_data_menu(window_t *win);
void plot_close_port_menu(window_t *win);


#endif /* _MENU_H_ */