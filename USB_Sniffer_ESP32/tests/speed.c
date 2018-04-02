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
 *     Initial: 2018/04/01      Mario Rubio
 */

#include "driver/gpio.h"
#include "driver/timer.h"
#include "esp_log.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "soc/soc.h"

#include "xtensa/core-macros.h"

#include <stdint.h>
#include <inttypes.h>

#define GPIO_INPUT_PIN_TEST 22
#define GPIO_INPUT_MASK (1ULL<<GPIO_INPUT_PIN_TEST)
#define GPIO_OUTPUT_PIN_TEST 2
#define GPIO_OUTPUT_MASK (1ULL<<GPIO_OUTPUT_PIN_TEST)

void app_main()
{
    timer_config_t config;
    config.divider = 16;
    config.counter_dir = TIMER_COUNT_UP;
    config.counter_en = TIMER_PAUSE;
    config.alarm_en = TIMER_ALARM_EN;
    config.intr_type = 0;
    config.auto_reload = 0;
    timer_init(TIMER_GROUP_0, TIMER_0, &config);
    timer_set_counter_value(TIMER_GROUP_0, TIMER_0, 0x00000000ULL);
    timer_start(TIMER_GROUP_0, TIMER_0);

    gpio_config_t io_conf;
    io_conf.mode         = GPIO_MODE_INPUT;
    io_conf.intr_type    = GPIO_INTR_DISABLE;
    io_conf.pull_down_en = GPIO_PULLDOWN_DISABLE;
    io_conf.pull_up_en   = GPIO_PULLUP_DISABLE;
    io_conf.pin_bit_mask = GPIO_INPUT_MASK;
    gpio_config(&io_conf);

    io_conf.mode         = GPIO_MODE_OUTPUT;
    io_conf.intr_type    = GPIO_INTR_DISABLE;
    io_conf.pull_down_en = GPIO_PULLDOWN_DISABLE;
    io_conf.pull_up_en   = GPIO_PULLUP_DISABLE;
    io_conf.pin_bit_mask = GPIO_OUTPUT_MASK;
    gpio_config(&io_conf);

    unsigned int pre_c = 0, pos_c = 0;
    double   pre_t = 0, pos_t = 0;
    uint_fast8_t val;

    unsigned int results_c[5];
    double results_t[5];
    timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pre_t);

    ESP_LOGI("ESP_timer_init", "Initial timer val: %f", pre_t);

    for(;;)
    {
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pre_t);
        pre_c = XTHAL_GET_CCOUNT();
        pos_c = XTHAL_GET_CCOUNT();
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pos_t);
        results_t[0] = pos_t-pre_t;
        results_c[0] = pos_c-pre_c;

        // INPUT speed test w/ builtin function
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pre_t);
        pre_c = XTHAL_GET_CCOUNT();
        val = gpio_get_level(GPIO_INPUT_PIN_TEST);
        pos_c = XTHAL_GET_CCOUNT();
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pos_t);
        results_t[1] = pos_t-pre_t;
        results_c[1] = pos_c-pre_c;

        // OUTPUT speed test w/ builtin function
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pre_t);
        pre_c = XTHAL_GET_CCOUNT();
        gpio_set_level(GPIO_OUTPUT_PIN_TEST, 1);
        pos_c = XTHAL_GET_CCOUNT();
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pos_t);
        gpio_set_level(GPIO_OUTPUT_PIN_TEST, 0);
        results_t[2] = pos_t-pre_t;
        results_c[2] = pos_c-pre_c;

        /*
         * Page 59 of esp32_technical_reference_manual
         * GPIO registers start at address 0x3FF44000
         * GPIO_OUT_W1TS_REG -> 0x3FF44008 -> Set
         * GPIO_OUT_W1TC_REG -> 0x3FF4400C -> Clear
         * 
         * 0x3ff44000 -> 0x3FF4403C -> Input val
         */

        // INPUT speed test w/ direct register modification
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pre_t);
        pre_c = XTHAL_GET_CCOUNT();
        val = (*((volatile uint32_t *) (0x3ff44000 + 0x3c ))) & 1 << GPIO_INPUT_PIN_TEST;
        pos_c = XTHAL_GET_CCOUNT();
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pos_t);
        results_t[3] = pos_t-pre_t;
        results_c[3] = pos_c-pre_c;

        // OUTPUT speed test w/ direct register modification
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pre_t);
        pre_c = XTHAL_GET_CCOUNT();
        (*((volatile uint32_t *) (0x3ff44000 + 0x8 ))) ^= 1 << GPIO_OUTPUT_PIN_TEST; // High
        pos_c = XTHAL_GET_CCOUNT();
        timer_get_counter_time_sec(TIMER_GROUP_0, TIMER_0, &pos_t);
        (*((volatile uint32_t *) (0x3ff44000 + 0xC ))) ^= 1 << GPIO_OUTPUT_PIN_TEST; // Low
        results_t[4] = pos_t-pre_t;
        results_c[4] = pos_c-pre_c;
        
        ESP_LOGI("D_CCOUNT_IDLE", "Counter: %ui [%f]", results_c[0], results_t[0]);
        ESP_LOGI("D_CCOUNT_INPUT", "Function: %ui [%f]. Register: %ui [%f]",
                                    results_c[1], results_t[1], results_c[3], results_t[3]);
        ESP_LOGI("D_CCOUNT_OUTPUT", "Function: %ui [%f]. Register: %ui [%f]",
                                     results_c[2], results_t[2], results_c[4], results_t[4]);
        printf("\n");
        
        vTaskDelay(3000 / portTICK_PERIOD_MS);
    }

    printf("End of app_main(). Last value = %"PRIu16, val);

}