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
 *     Added new 
 */

#include "config.h"
#include "USB3300.h"
#include "web_server.h"

#include "freertos/FreeRTOS.h"

#include <stdio.h>
#include <stdlib.h>

void app_main(void)
{
    /*
     * Configuration > config.h
     */
    main_uart_init();

    printf("GPIO init...\n");
    main_gpio_init();
    printf("GPIO init done!\n");

    printf("WiFi init...\n");
    // Move prints inside intialization funcitons with control to print it or not!!
    main_wifi_init(C_WIFI_AP);
    printf("Created WiFi AP wi\n");
    printf("WiFi init done!\n");

    /*
     * Web server initialization > web_server.h
     */
    // main_web_server_init();
    // main_web_communication_init();

    USB3300_main();

    fflush(stdout);
}