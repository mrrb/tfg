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
 *     Initial: 2018/04/13      Mario Rubio
 */

#ifndef USB3300_MAIN_H
#define USB3300_MAIN_H

#include "esp_err.h"
#include "esp_log.h"
#include "driver/gpio.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/queue.h"

#include <stdint.h>

#define SAMPLES 2
#define MODE    1

/*
 * Pin configuration
 */
#define GPIO_USB3300_DATA0 GPIO_NUM_23 /* USB3300 Parallel Data 0 [INOUT  */
#define GPIO_USB3300_DATA1 GPIO_NUM_22 /* USB3300 Parallel Data 1 [INOUT] */
#define GPIO_USB3300_DATA2 GPIO_NUM_21 /* USB3300 Parallel Data 2 [INOUT] */
#define GPIO_USB3300_DATA3 GPIO_NUM_19 /* USB3300 Parallel Data 3 [INOUT] */
#define GPIO_USB3300_DATA4 GPIO_NUM_18 /* USB3300 Parallel Data 4 [INOUT] */
#define GPIO_USB3300_DATA5 GPIO_NUM_5  /* USB3300 Parallel Data 5 [INOUT] */
#define GPIO_USB3300_DATA6 GPIO_NUM_17 /* USB3300 Parallel Data 6 [INOUT] */
#define GPIO_USB3300_DATA7 GPIO_NUM_16 /* USB3300 Parallel Data 7 [INOUT] */
#define GPIO_USB3300_NXT   GPIO_NUM_35 /* USB3300 data flow control when LINK->PHY [INPUT] */
#define GPIO_USB3300_DIR   GPIO_NUM_34 /* USB3300 direction signal [INPUT] */
#define GPIO_USB3300_CLK   GPIO_NUM_27 /* USB3300 clock signal [INPUT] */

#define GPIO_USB3300_INPUT_MASK  (1ULL<<GPIO_USB3300_NXT)| \
                                 (1ULL<<GPIO_USB3300_DIR)| \
                                 (1ULL<<GPIO_USB3300_CLK)| \
                                 (1ULL<<GPIO_USB3300_DATA0)| \
                                 (1ULL<<GPIO_USB3300_DATA1)| \
                                 (1ULL<<GPIO_USB3300_DATA2)| \
                                 (1ULL<<GPIO_USB3300_DATA3)| \
                                 (1ULL<<GPIO_USB3300_DATA4)| \
                                 (1ULL<<GPIO_USB3300_DATA5)| \
                                 (1ULL<<GPIO_USB3300_DATA6)| \
                                 (1ULL<<GPIO_USB3300_DATA7)

/*
 *
 */
esp_err_t USB3300_config(TaskHandle_t *USB3300_handle);

#endif /* USB3300_MAIN_H */