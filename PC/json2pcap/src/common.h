#ifndef _COMMON_H_
#define _COMMON_H_

    #include <stdio.h>      /*  */
    #include "ANSI_codes.h" /* Graphics & Cursor capabilities */

    // Binary print
    // https://stackoverflow.com/questions/111928/is-there-a-printf-converter-to-print-in-binary-format#3208376
    #define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
    #define BYTE_TO_BINARY(byte)  \
    (byte & 0x80 ? '1' : '0'), \
    (byte & 0x40 ? '1' : '0'), \
    (byte & 0x20 ? '1' : '0'), \
    (byte & 0x10 ? '1' : '0'), \
    (byte & 0x08 ? '1' : '0'), \
    (byte & 0x04 ? '1' : '0'), \
    (byte & 0x02 ? '1' : '0'), \
    (byte & 0x01 ? '1' : '0') 

    // LOG macros
    #define LOG(format, ...)   fprintf(stdout, format, ##__VA_ARGS__)                                                     /* Log Message */
    #define LOG_I(format, ...) fprintf(stdout, ANSI_TEXT_COLOR_CYAN "Info  > " ANSI_GRAPHICS_RESET format, ##__VA_ARGS__) /* Log Info */
    #define LOG_D(format, ...) fprintf(stdout, ANSI_TEXT_COLOR_CYAN "Debug > " ANSI_GRAPHICS_RESET format, ##__VA_ARGS__) /* Log Debug */
    #define LOG_E(format, ...) fprintf(stderr, ANSI_TEXT_COLOR_RED  "Error > " ANSI_GRAPHICS_RESET format, ##__VA_ARGS__) /* Log Error */

#endif /* _COMMON_H_ */