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

#include "config.h"

/*
 *
 */
esp_err_t main_pin_configure(uint8_t schema, uint64_t pin_bit_mask)
{
    if(pin_bit_mask == 0) return ESP_ERR_INVALID_ARG;
    gpio_config_t io_conf; // GPIO config struct
    io_conf.mode      = (schema&0xE0)>>5; // GPIO mode
    io_conf.intr_type = (schema&0x1C)>>2; // GPIO intterupt type

    // Configuration of GPIO internal PULLDOWN resistor
    io_conf.pull_down_en = (schema&0x01) == 0x01 ? GPIO_PULLDOWN_ENABLE : GPIO_PULLDOWN_DISABLE;
    // Configuration of GPIO internal PULLUP resistor
    io_conf.pull_up_en   = (schema&0x02) == 0x02 ? GPIO_PULLUP_ENABLE   : GPIO_PULLUP_DISABLE;

    io_conf.pin_bit_mask = pin_bit_mask; // Bit mask for the pins that should be configurated

    gpio_config(&io_conf); // Configure GPIO with the given settings

    return ESP_OK;
}

/*
 * 
 */
esp_err_t main_gpio_init()
{
    /* Inputs */
    main_pin_configure(C_GPIO_INPUT, GPIO_USB3300_INPUT_MASK);
    main_pin_configure(C_GPIO_INPUT, GPIO_SD_INPUT_MASK);

    /* Outputs */
    main_pin_configure(C_GPIO_OUTPUT, GPIO_USB3300_OUTPUT_MASK);
    main_pin_configure(C_GPIO_OUTPUT, GPIO_SD_OUTPUT_MASK);

    /* Inouts */
    main_pin_configure(C_GPIO_INOUT, GPIO_USB3300_INOUT_MASK);
    main_pin_configure(C_GPIO_INOUT, GPIO_SD_INOUT_MASK);

    /* ADC */
    adc1_config_width(GPIO_ADC_WIDTH);
    adc1_config_channel_atten(GPIO_ADC_Vbus_CHANNEL, ADC_ATTEN_0db);
    adc1_config_channel_atten(GPIO_ADC_Vin_CHANNEL, ADC_ATTEN_0db);

    return ESP_OK;
}

/*
 * ESP32 UART init
 */
esp_err_t main_uart_init()
{
    if(debug_status == 1) printf("UART init...\n");
    uart_config_t uart_config;
    uart_config.baud_rate = UART0_INIT_BAUDRATE;      /* UART baud rate */
    uart_config.parity    = UART0_INIT_PARITY;        /* UART parity bits */
    uart_config.stop_bits = UART0_INIT_STOP;          /* UART stop bits */
    uart_config.data_bits = UART0_INIT_BITS;          /* UART data bits */
    uart_config.flow_ctrl = UART_HW_FLOWCTRL_DISABLE; /* UART flow control */

    uart_param_config(UART_NUM_0, &uart_config);
    uart_driver_install(UART_NUM_0, UART0_BUFFER_SIZE*2, 0, 0, NULL, 0);

    if(debug_status == 1) printf("UART init done! Status: %d\n", ESP_OK);
    return ESP_OK;
}


/*
 *
 */
static bool chk_stored_wifi_config(uint8_t mode)
{
    return false;
}

/*
 * 
 */
esp_err_t main_wifi_init(uint8_t mode)
{
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT(); /* Load default WiFi Config */
    esp_wifi_init(&cfg);

    esp_wifi_set_storage(WIFI_STORAGE_RAM);

    wifi_config_t wifi_config;
    strcpy((char *)wifi_config.ap.ssid, chk_stored_wifi_config(mode) ? "" : WIFI_AP_DEFAULT_SSID); /* AP SSID */
    strcpy((char *)wifi_config.ap.password, chk_stored_wifi_config(mode) ? "" : WIFI_AP_DEFAULT_PASSWORD); /* AP password */
    wifi_config.ap.channel  = chk_stored_wifi_config(mode) ? 1 : WIFI_AP_DEFAULT_CHANNEL;
    wifi_config.ap.channel  = chk_stored_wifi_config(mode) ? WIFI_AUTH_WPA_WPA2_PSK : WIFI_AP_DEFAULT_AUTH;
    wifi_config.ap.ssid_len = chk_stored_wifi_config(mode) ? 0 : 0;
    
    strcpy((char *)wifi_config.sta.ssid, chk_stored_wifi_config(mode) ? "" : WIFI_STA_DEFAULT_SSID); /* STA SSID */
    strcpy((char *)wifi_config.sta.password, chk_stored_wifi_config(mode) ? "" : WIFI_STA_DEFAULT_PASSWORD); /* STA password */

    
    if(mode == C_WIFI_AP)
    {
        esp_wifi_set_config(WIFI_IF_AP, &wifi_config);
    }
    else if(mode == C_WIFI_STA)
    {
        
    }
    else if(mode == C_WIFI_APSTA)
    {

    }
    else return ESP_ERR_INVALID_ARG;

    esp_wifi_start();

    return ESP_OK;
}