/*
 * MIT License
 *
 * Copyright (c) 2018 Mario Rubio
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the 'Software'), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Revision History:
 *     Initial: 2018/03/26      Mario Rubio
 */


#ifndef USB3300_CONTROLLER_H
#define USB3300_CONTROLLER_H

#include "esp_err.h"
#include "user_config.h"
#include "config.h"
#include "esp_log.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/queue.h"

#include <stdint.h>

/*
 * 
 */
typedef enum
{
    MSG_TYPE_test = 0
} msg_type_t;

typedef struct
{
    double  time;           /*  */
    msg_type_t msg_type;    /*  */
    uint8_t IO_CTRL;        /* 76543210 -> (0) NXT, (1) DIR, (2) STP  */
    uint8_t DATA;           /* 76543210 -> (0) DATA0, ..., (7) DATA7 */
} USB3300_msg_t;

/*
 * 
 */
esp_err_t USB3300_controller_init(TaskHandle_t *USB3300_handle);

#endif /* USB3300_CONTROLLER_H */