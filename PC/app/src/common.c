#include "common.h"
#include "ANSI_codes.h" /* Graphics & Cursor capabilities */

#include <stdlib.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>


FILE *log_fp = NULL;
uint8_t log_file_en = 0;

void enable_log_file(void)
{
    log_file_en = 1;
    log_fp = fopen(LOG_FILE_NAME, "w+");
}

void disable_log_file(void)
{
    log_file_en = 0;
    fclose(log_fp);
    log_fp = NULL;
}

void LOG(const char *format, ...)
{
    va_list argptr;
    va_start(argptr, format);

    if(log_file_en == 1)
    {
        if(log_fp == NULL)
            enable_log_file();
        else
            fprintf(log_fp, format, argptr);
    }

    fprintf(stdout, format, argptr);

    va_end(argptr);
}