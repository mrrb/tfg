#ifndef USER_CONFIG_H
#define USER_CONFIG_H

#include "driver/uart.h"
#include "driver/adc.h"
#include "driver/gpio.h"
#include "esp_wifi.h"

#include <stdint.h>

#define DEBUG /* Debug mode enable */

/*
 * Components
 */
#define WIFI_C              /* Include WiFi support  */
#define BLUETOOTH_C         /* Include Bluetooth support  */
#define SD_CARD_C           /* Include SD card support  */
#define UART_C              /* Include UART support  */
#define WEB_SERVER_C        /* Include a built-in WEB server */
#define DEFAULT_WEB_PAGE_C  /* Include a default web page */
#define VOLTAGE_VBUS_CTRL_C /* Include support for USB bus voltage control */
#define VOLTAGE_VIN_CTRL_C  /* Include support for input voltage control */
#define CJSON_SUPPORT       /* Include support for the cJSON lib */

/*
 * USB3300 Pins
 */
#define GPIO_USB3300_DATA0 GPIO_NUM_23   /* USB3300 Parallel Data 0 [INOUT] */
#define GPIO_USB3300_DATA1 GPIO_NUM_22   /* USB3300 Parallel Data 1 [INOUT] */
#define GPIO_USB3300_DATA2 GPIO_NUM_21   /* USB3300 Parallel Data 2 [INOUT] */
#define GPIO_USB3300_DATA3 GPIO_NUM_19   /* USB3300 Parallel Data 3 [INOUT] */
#define GPIO_USB3300_DATA4 GPIO_NUM_18   /* USB3300 Parallel Data 4 [INOUT] */
#define GPIO_USB3300_DATA5 GPIO_NUM_5    /* USB3300 Parallel Data 5 [INOUT] */
#define GPIO_USB3300_DATA6 GPIO_NUM_17   /* USB3300 Parallel Data 6 [INOUT] */
#define GPIO_USB3300_DATA7 GPIO_NUM_16   /* USB3300 Parallel Data 7 [INOUT] */
#define GPIO_USB3300_STP   GPIO_NUM_25   /* USB3300 stop signal [OUTPUT] */
#define GPIO_USB3300_NXT   GPIO_NUM_35   /* USB3300 data flow control when LINK->PHY [INPUT] */
#define GPIO_USB3300_DIR   GPIO_NUM_34   /* USB3300 direction signal [INPUT] */
#define GPIO_USB3300_CLK   GPIO_NUM_27   /* USB3300 clock signal [INPUT] */
#define GPIO_USB3300_RST   NULL          /* USB3300 reset pin [OUTPUT or NC] */

#define GPIO_USB3300_INPUT_MASK  (1ULL<<GPIO_USB3300_NXT)| \
                                 (1ULL<<GPIO_USB3300_DIR)| \
                                 (1ULL<<GPIO_USB3300_CLK)
#define GPIO_USB3300_OUTPUT_MASK (1ULL<<GPIO_USB3300_STP)
#define GPIO_USB3300_INOUT_MASK  (1ULL<<GPIO_USB3300_DATA0)| \
                                 (1ULL<<GPIO_USB3300_DATA1)| \
                                 (1ULL<<GPIO_USB3300_DATA2)| \
                                 (1ULL<<GPIO_USB3300_DATA3)| \
                                 (1ULL<<GPIO_USB3300_DATA4)| \
                                 (1ULL<<GPIO_USB3300_DATA5)| \
                                 (1ULL<<GPIO_USB3300_DATA6)| \
                                 (1ULL<<GPIO_USB3300_DATA7)

/*
 * SDcard Pins
 */
#define GPIO_SD_CMD   GPIO_NUM_15 /* SD command [INOUT] */
#define GPIO_SD_CLK   GPIO_NUM_14 /* SD clock [OUTPUT] */
#define GPIO_SD_DATA0 GPIO_NUM_2  /* SD Serial Data 0 [INOUT] */
#define GPIO_SD_DATA1 GPIO_NUM_4  /* SD Serial Data 1 [INOUT] */
#define GPIO_SD_DATA2 GPIO_NUM_12 /* SD Serial Data 2 [INOUT] */
#define GPIO_SD_DATA3 GPIO_NUM_13 /* SD Serial Data 3 [INOUT] */

#define GPIO_SD_INPUT_MASK  0
#define GPIO_SD_OUTPUT_MASK (1ULL<<GPIO_SD_CLK)
#define GPIO_SD_INOUT_MASK  (1ULL<<GPIO_SD_CMD)| \
                            (1ULL<<GPIO_SD_DATA0)| \
                            (1ULL<<GPIO_SD_DATA1)| \
                            (1ULL<<GPIO_SD_DATA2)| \
                            (1ULL<<GPIO_SD_DATA3)

/*
 * ADC1 Pins
 */
#define GPIO_ADC_Vbus 32              /* Voltage in the USB bus [INPUT] */
#define GPIO_ADC_Vbus_CHANNEL 4       /* Voltage in the USB bus [INPUT] */
#define GPIO_ADC_Vin  33              /* Voltage BEFORE the 3.3V regulator [INPUT] */
#define GPIO_ADC_Vin_CHANNEL  5       /* Voltage BEFORE the 3.3V regulator [INPUT] */

#define GPIO_ADC_WIDTH ADC_WIDTH_9Bit /* ADC1 measure width */

/*
 * UART0 config
 */
#define UART0_INIT_BAUDRATE 115200              /* UART baud rate */
#define UART0_INIT_PARITY   UART_PARITY_DISABLE /* UART parity bits */
#define UART0_INIT_BITS     UART_DATA_8_BITS    /* UART data bits */
#define UART0_INIT_STOP     UART_STOP_BITS_1    /* UART stop bits */

#define UART0_BUFFER_SIZE   200                 /* UART buffer size */


/*
 * WiFi config
 */
#define WIFI_AP_DEFAULT_SSID     "USB_Sniffer"          /* Wifi default SSID in AP mode */
#define WIFI_AP_DEFAULT_PASSWORD "Password1234"         /* Wifi default PASSWORD in AP mode */
#define WIFI_AP_DEFAULT_AUTH     WIFI_AUTH_WPA2_PSK     /* Wifi default AUTH MODE in AP mode */
#define WIFI_AP_DEFAULT_CHANNEL  1                      /* Wifi default CHANNEL in AP mode */

#define WIFI_STA_DEFAULT_SSID     "WiFi_test"           /* Wifi default SSID in STA mode */
#define WIFI_STA_DEFAULT_PASSWORD "Password1234"        /* Wifi default PASSWORD in STA mode */


// ============================
// DO NOT EDIT BELOW THIS LINE!
// ============================

/*
 *
 */
#define P_AUTHOR  "Mario Rubio"
#define P_VERSION "V0.0.1"
#define P_YEAR    2018
#define P_MONTH   03
#define P_DAY     29

/*
 * DEBUG mode 
 */
typedef enum
{
    DEBUG_DISABLE = 0,
    DEBUG_ENABLE
} debug_t;
extern uint8_t debug_status;

/*
 * USB3300 Pins
 */
#define GPIO_USB3300_INPUT_MASK  (1ULL<<GPIO_USB3300_NXT)| \
                                 (1ULL<<GPIO_USB3300_DIR)| \
                                 (1ULL<<GPIO_USB3300_CLK)
#define GPIO_USB3300_OUTPUT_MASK (1ULL<<GPIO_USB3300_STP)
#define GPIO_USB3300_INOUT_MASK  (1ULL<<GPIO_USB3300_DATA0)| \
                                 (1ULL<<GPIO_USB3300_DATA1)| \
                                 (1ULL<<GPIO_USB3300_DATA2)| \
                                 (1ULL<<GPIO_USB3300_DATA3)| \
                                 (1ULL<<GPIO_USB3300_DATA4)| \
                                 (1ULL<<GPIO_USB3300_DATA5)| \
                                 (1ULL<<GPIO_USB3300_DATA6)| \
                                 (1ULL<<GPIO_USB3300_DATA7)

/*
 * SDcard Pins
 */
#define GPIO_SD_INPUT_MASK  0
#define GPIO_SD_OUTPUT_MASK (1ULL<<GPIO_SD_CLK)
#define GPIO_SD_INOUT_MASK  (1ULL<<GPIO_SD_CMD)| \
                            (1ULL<<GPIO_SD_DATA0)| \
                            (1ULL<<GPIO_SD_DATA1)| \
                            (1ULL<<GPIO_SD_DATA2)| \
                            (1ULL<<GPIO_SD_DATA3)

/*
 * ADC1 Pins
 */

/*
 * UART0 config
 */

/*
 * WiFi config
 */


#endif /* USER_CONFIG_H */