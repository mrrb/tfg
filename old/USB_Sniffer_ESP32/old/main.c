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
 *     Initial: 2018/03/08           Mario Rubio
 *     Restructured: 2018/03/28      Mario Rubio
 */

#include "config.h"
#include "USB3300.h"
#include "web_server.h"
#include "esp_log.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static const char* TAG = "main";

void app_main(void)
{
    // /*
    //  * Configuration > config.h
    //  */
    // main_app_config();
    // main_uart_init();
    // main_gpio_init();
    // main_wifi_init(C_WIFI_AP);

    // /*
    //  * Web server initialization > web_server.h
    //  */
    // // main_web_server_init();
    // // main_web_communication_init();


    // /*
    //  * USB3300 related stuff > USB3300.h
    //  */
    // TaskHandle_t USB3300_task_handle;
    // USB3300_controller_init(&USB3300_task_handle);

    /*
     * App MAIN loop
     */
    uint16_t delay_time = 1000;
    uint32_t beat_counter = 0;
    for(;;)
    {
        vTaskDelay(delay_time / portTICK_RATE_MS);
        ESP_LOGV(TAG, "Beat! See you in %dms! [%d, ]\n", delay_time, beat_counter++);
    }

    fflush(stdout);
}