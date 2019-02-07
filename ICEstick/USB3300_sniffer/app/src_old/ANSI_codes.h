// http://ascii-table.com/ansi-escape-sequences.php

#ifndef _ANSI_H_ 
#define _ANSI_H_

// Cursor Position (Esc[Line;ColumnH)
#define ANSI_CURSOR_HOME "\x1b[H"
#define ANSI_CURSOR_SET(line, column) "\x1b["#line";"#column"H"

// Cursor
#define ANSI_CURSOR_UP      "\x1b[A"
#define ANSI_CURSOR_N_UP(N) "\x1b["#N"A"

#define ANSI_CURSOR_DOWN      "\x1b[B"
#define ANSI_CURSOR_N_DOWN(N) "\x1b["#N"B"

#define ANSI_CURSOR_FORWARD      "\x1b[C"
#define ANSI_CURSOR_N_FORWARD(N) "\x1b["#N"C"

#define ANSI_CURSOR_BACKWARD      "\x1b[D"
#define ANSI_CURSOR_N_BACKWARD(N) "\x1b["#N"D"

#define ANSI_CURSOR_POS_SAVE    "\x1b[s"
#define ANSI_CURSOR_POS_RESTORE "\x1b[u"

// Erase
#define ANSI_ERASE_DISPLAY "\x1b[2]"
#define ANSI_ERASE_LINE    "\x1b[K"

// Set Graphics Mode (Esc[Value;...;Valuem)
#define ANSI_GRAPHICS_RESET "\x1b[0m"

#define ANSI_BOLD       "\x1b[1m"
#define ANSI_UNDERSCORE "\x1b[4m"
#define ANSI_BLINK      "\x1b[5m"
#define ANSI_REVERSE    "\x1b[7m"
#define ANSI_CONCEALED  "\x1b[8m"

#define ANSI_TEXT_COLOR_BLACK   "\x1b[30m"
#define ANSI_TEXT_COLOR_RED     "\x1b[31m"
#define ANSI_TEXT_COLOR_GREEN   "\x1b[32m"
#define ANSI_TEXT_COLOR_YELLOW  "\x1b[33m"
#define ANSI_TEXT_COLOR_BLUE    "\x1b[34m"
#define ANSI_TEXT_COLOR_MAGENTA "\x1b[35m"
#define ANSI_TEXT_COLOR_CYAN    "\x1b[36m"
#define ANSI_TEXT_COLOR_WHITE   "\x1b[37m"

#define ANSI_BACKGROUND_COLOR_BLACK   "\x1b[40m"
#define ANSI_BACKGROUND_COLOR_RED     "\x1b[41m"
#define ANSI_BACKGROUND_COLOR_GREEN   "\x1b[42m"
#define ANSI_BACKGROUND_COLOR_YELLOW  "\x1b[43m"
#define ANSI_BACKGROUND_COLOR_BLUE    "\x1b[44m"
#define ANSI_BACKGROUND_COLOR_MAGENTA "\x1b[45m"
#define ANSI_BACKGROUND_COLOR_CYAN    "\x1b[46m"
#define ANSI_BACKGROUND_COLOR_WHITE   "\x1b[47m"

#endif /* _ANSI_H_ */