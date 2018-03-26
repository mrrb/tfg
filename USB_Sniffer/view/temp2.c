#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "esp_event.h"
#include "driver/uart.h"
#include "driver/timer.h"
#include "esp_wifi.h"
#include "soc/soc.h"

#include <stdio.h>
#include <inttypes.h>
#include <stdlib.h>

#define BUF_SIZE 100
#define LED      15
#define GPIO_OUTPUT (1ULL<<LED)

#define CLK_input 18
#define GPIO_INPUT  (1ULL<<CLK_input)

void app_main()
{
    gpio_config_t io_conf; // GPIO config
    io_conf.intr_type = GPIO_PIN_INTR_DISABLE; //disable interrupt
    io_conf.mode = GPIO_MODE_OUTPUT; //set as output mode
    io_conf.pin_bit_mask = GPIO_OUTPUT; //bit mask of the pins that you want to set,e.g.GPIO18/19
    io_conf.pull_down_en = GPIO_PULLDOWN_DISABLE; //disable pull-down mode
    io_conf.pull_up_en = GPIO_PULLUP_DISABLE ; //disable pull-up mode
    gpio_config(&io_conf); //configure GPIO with the given settings

    io_conf.intr_type = GPIO_INTR_NEGEDGE;
    io_conf.mode = GPIO_MODE_INPUT; //set as output mode
    io_conf.pin_bit_mask = GPIO_INPUT; //bit mask of the pins that you want to set,e.g.GPIO18/19
    io_conf.pull_down_en = GPIO_PULLDOWN_ENABLE; //disable pull-down mode
    io_conf.pull_up_en = GPIO_PULLUP_DISABLE; //disable pull-up mode
    gpio_config(&io_conf); //configure GPIO with the given settings

    uart_config_t uart_config =
    {
        .baud_rate = 9600,
        .data_bits = UART_DATA_8_BITS,
        .parity    = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE
    };
    uart_param_config(UART_NUM_0, &uart_config);
    uart_driver_install(UART_NUM_0, BUF_SIZE*2, 0, 0, NULL, 0);

    timer_config_t timer_config =
    {
        .alarm_en   = false,
        .counter_en = true,
    };
    timer_init(0, 0, &timer_config);
    timer_start(0, 0);

    int cnt = 0;
    double counter = 0;
    char *buffer   = (char*) calloc(BUF_SIZE, sizeof(char));
    int txt_size   = 0;
    for(;;)
    {
        vTaskDelay(1000 / portTICK_PERIOD_MS);
        gpio_set_level(LED, cnt++ % 2);
        timer_get_counter_time_sec(0, 0, &counter);
        txt_size = snprintf(buffer, BUF_SIZE*sizeof(char), "\nIteration: %d\nCounter: %lf\nStatus: %s\n",
                            cnt, counter, cnt % 2 != 0 ? "Off" : "On");

        uart_write_bytes(UART_NUM_0, buffer, txt_size);
    }

    free(buffer);
}