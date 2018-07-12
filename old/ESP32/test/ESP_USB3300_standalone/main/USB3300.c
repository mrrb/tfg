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
 *     Initial: 2018/04/13      Mario Rubio
 */

#include "USB3300.h"

static const char *TAG = "USB3300";
static xQueueHandle pin_evt_queue = NULL;

static void IRAM_ATTR USB3300_clk_handler(void *arg)
{
    
}

static void IRAM_ATTR USB3300_nxt_handler(void *arg)
{
    uint32_t msg[SAMPLES];
    for(uint_fast8_t i=0; i<SAMPLES; ++i)
    {
        *(msg+i) = *((volatile uint32_t *)(0x3ff44000 + 0x3c));
    }
    xQueueSendFromISR(pin_evt_queue, msg, (void *)NULL);
}

static void IRAM_ATTR USB3300_dir_handler(void *arg)
{
    uint32_t msg[SAMPLES];
    for(uint_fast8_t i=0; i<SAMPLES; ++i)
    {
        *(msg+i) = *((volatile uint32_t *)(0x3ff44000 + 0x3c));
    }
    xQueueSendFromISR(pin_evt_queue, msg, (void *)NULL);
}

static void USB3300_task(void* arg)
{
    uint32_t *msg;
    for(;;)
    {
        if (xQueueReceive(pin_evt_queue, &msg, portMAX_DELAY))
        {
            for(uint_fast8_t i=0; i<SAMPLES; ++i)
            {
                ESP_LOGI(TAG, "%d - %x\n", i, *(msg+i));
            }
        }
    }
}

/*
 *
 */
esp_err_t USB3300_config(TaskHandle_t *USB3300_handle)
{
    ESP_LOGI(TAG, "GPIO config...");
    gpio_config_t config;
    config.pin_bit_mask = GPIO_USB3300_INPUT_MASK;
    config.intr_type    = GPIO_INTR_DISABLE;
    config.mode         = GPIO_MODE_INPUT;
    config.pull_down_en = GPIO_PULLDOWN_DISABLE;
    config.pull_up_en   = GPIO_PULLUP_DISABLE;
    gpio_config(&config);

    ESP_LOGI(TAG, "Interrupts config...");
    gpio_set_intr_type(GPIO_USB3300_CLK, GPIO_INTR_POSEDGE);
    gpio_set_intr_type(GPIO_USB3300_NXT, GPIO_INTR_POSEDGE);
    gpio_set_intr_type(GPIO_USB3300_DIR, GPIO_INTR_POSEDGE);

    ESP_LOGI(TAG, "Task init...");
    pin_evt_queue = xQueueCreate(SAMPLES+5, sizeof(uint32_t));
    xTaskCreatePinnedToCore(USB3300_task, "USB3300_task", 2048, (void *)NULL, 10, USB3300_handle, 1);

    ESP_LOGI(TAG, "Interrupts init...");
    gpio_install_isr_service(0);
    // gpio_isr_handler_add(GPIO_USB3300_CLK, USB3300_clk_handler, (void *)NULL);
    // gpio_isr_handler_add(GPIO_USB3300_NXT, USB3300_nxt_handler, (void *)NULL);
    gpio_isr_handler_add(GPIO_USB3300_DIR, USB3300_dir_handler, (void *)NULL);
    // gpio_isr_handler_remove

    return ESP_OK;
}