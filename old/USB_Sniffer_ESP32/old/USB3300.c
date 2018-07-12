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

#include "USB3300.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>


static const char* TAG = "USB3300";
static xQueueHandle clk_evt_queue = NULL;

esp_err_t USB3300_main()
{
    // uint64_t ctrl = 0;
    // uint8_t  last = 0;
    // uint8_t  new  = 0;
    // uint8_t  data = 0x00;
    // for(;;)
    // {
    //     new = gpio_get_level(GPIO_USB3300_CLK);
    //     if( new == 1 && last == 0)
    //     {
    //         if(ctrl++%10000 == 0)
    //         {
    //             printf("Iteration: %" PRId64 " ", ctrl-1);
    //             data = 0x0;
    //             data = gpio_get_level(GPIO_USB3300_DATA0)|
    //                    gpio_get_level(GPIO_USB3300_DATA1)<<1|
    //                    gpio_get_level(GPIO_USB3300_DATA2)<<2|
    //                    gpio_get_level(GPIO_USB3300_DATA3)<<3|
    //                    gpio_get_level(GPIO_USB3300_DATA4)<<4|
    //                    gpio_get_level(GPIO_USB3300_DATA5)<<5|
    //                    gpio_get_level(GPIO_USB3300_DATA6)<<6|
    //                    gpio_get_level(GPIO_USB3300_DATA7)<<7;
    //             printf("Data: %#x ", data);

    //             printf("DIR: %s NXT: %s\n", gpio_get_level(GPIO_USB3300_DIR)==1 ? "On" : "Off",
    //                                            gpio_get_level(GPIO_USB3300_NXT)==1 ? "On" : "Off");
    //         }
    //     }
    //     last = new;
    // }

    for(;;)
    {

    }
    
    return ESP_OK;
}

static void IRAM_ATTR USB3300_isr_handler(void* arg)
{
    USB3300_msg_t new_msg;

    new_msg.DATA = gpio_get_level(GPIO_USB3300_DATA0)|
                   gpio_get_level(GPIO_USB3300_DATA1)<<1|
                   gpio_get_level(GPIO_USB3300_DATA2)<<2|
                   gpio_get_level(GPIO_USB3300_DATA3)<<3|
                   gpio_get_level(GPIO_USB3300_DATA4)<<4|
                   gpio_get_level(GPIO_USB3300_DATA5)<<5|
                   gpio_get_level(GPIO_USB3300_DATA6)<<6|
                   gpio_get_level(GPIO_USB3300_DATA7)<<7;
    new_msg.msg_type = MSG_TYPE_test;
    new_msg.IO_CTRL  = gpio_get_level(GPIO_USB3300_DIR)>>1|
                       gpio_get_level(GPIO_USB3300_NXT);
    xQueueSendFromISR(clk_evt_queue, &new_msg, (void*) NULL);
}

static void USB3300_task(void* arg)
{
    #ifdef USB3300_TASK_DISABLE
        vTaskSuspend(xTaskGetCurrentTaskHandle());
    #endif
    uint32_t cnt = 0;
    USB3300_msg_t msg;
    for(;;)
    {
        if(xQueueReceive(clk_evt_queue, &msg, portMAX_DELAY))
        {
            if(cnt++%10000 == 0)
            {
                INFO("Debug_test: %d\n", msg);
                // INFO("Data: %#x. IO_ctrl: %#x", msg.DATA, msg.IO_CTRL);
            }
        }
    }
}

esp_err_t USB3300_controller_init(TaskHandle_t *USB3300_handle)
{
    ESP_LOGI(TAG, "USB3300 module controller init!\n");

    clk_evt_queue = xQueueCreate(15, sizeof(USB3300_msg_t));
    xTaskCreate(USB3300_task, "USB3300_task", USB3300_TASK_STACK_DEPTH, (void*) NULL, USB3300_TASK_PRIORITY, USB3300_handle);

    gpio_install_isr_service(ESP_INTR_DEFAULT_FLAG);
    gpio_isr_handler_add(GPIO_USB3300_CLK, USB3300_isr_handler, (void*) NULL);

    ESP_LOGI(TAG, "USB3300 init done! Status: %d\n", ESP_OK);
    return ESP_OK;
}