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
 *     Initial: 2018/03/08      Mario Rubio
 */

#ifndef MAIN_CONFIG_H
#define MAIN_CONFIG_H

#include "driver/gpio.h"
#include "driver/adc.h"
#include "driver/uart.h"
#include "esp_wifi.h"
#include "esp_wifi_types.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "user_config.h"

/*
 * GPIO related stuff
 * 
 * YYYxxxxx Mode
 * xxxYYYxx Interrupt
 * xxxxxx00 None | xxxxxx10 PullUp | xxxxxx01 PullDown
 * 
 */
#define C_GPIO_PULLUP   0x02  // Enable PullUp resistor
#define C_GPIO_PULLDOWN 0x01  // Enable PullDown resistor
#define C_GPIO_NO_PULL  0x00  // Neither PullUp or PullDown resistor is enabled

#define C_GPIO_NONE GPIO_MODE_DISABLE<<5  // GPIO disabled
#define C_GPIO_IN   GPIO_MODE_INPUT<<5    // GPIO as input
#define C_GPIO_OUT  GPIO_MODE_OUTPUT<<5   // GPIO as output
#define C_GPIO_OD   GPIO_MODE_DEF_OD<<5   // GPIO OpenDrain

#define C_GPIO_INTR_DISABLE GPIO_INTR_DISABLE<<2     // All the interrupts for the current GPIO are disabled
#define C_GPIO_INTR_POSEDGE GPIO_INTR_POSEDGE<<2     // An interrupt is enabled in the positive edge of the input
#define C_GPIO_INTR_NEGEDGE GPIO_INTR_NEGEDGE<<2     // An interrupt is enabled in the negative edge of the input
#define C_GPIO_INTR_ANYEDGE GPIO_INTR_ANYEDGE<<2     // An interrupt is enabled in any edge of the input
#define C_GPIO_INTR_HIGH_LV GPIO_INTR_HIGH_LEVEL<<2  // Input high level trigger 
#define C_GPIO_INTR_LOW_LV  GPIO_INTR_LOW_LEVEL<<2   // Input low level trigger 

#define C_GPIO_INPUT  C_GPIO_IN|C_GPIO_INTR_DISABLE|C_GPIO_NO_PULL  // Predefined GPIO configuration for INPUTS
#define C_GPIO_OUTPUT C_GPIO_OUT|C_GPIO_INTR_DISABLE|C_GPIO_NO_PULL // Predefined GPIO configuration for OUTPUTS
#define C_GPIO_INOUT  C_GPIO_IN|C_GPIO_OUT|C_GPIO_INTR_DISABLE|C_GPIO_NO_PULL|C_GPIO_OD  // Predefined GPIO configuration for INOUTS

/*
 * WiFi related stuff
 */
#define C_MAX_SSID_LEN 32 /* SSID max. length */
enum C_WIFI_MODES_E
{
    C_WIFI_AP = 0,
    C_WIFI_STA,
    C_WIFI_APSTA
} C_WIFI_MODES;


/* 
 * 
 */

/*
 * GPIO PINs configuration
 */
esp_err_t main_pin_configure(uint8_t schema, uint64_t pin_bit_mask);

/*
 * Initialization of GPIO pins
 */
esp_err_t main_gpio_init(void);


/*
 * Initialization of UART0
 */
esp_err_t main_uart_init(void);


/*
 * Initialization of WiFi connection
 */
esp_err_t main_wifi_init(uint8_t mode);

/*
 * End of WiFi conecction
 */
esp_err_t main_wifi_stop(void);



#endif /* MAIN_CONFIG_H */