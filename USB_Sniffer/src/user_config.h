#ifndef USER_CONFIG_H
#define USER_CONFIG_H

#include "driver/uart.h"
#include "driver/adc.h"
#include "esp_wifi.h"

/*
 * USB3300 Pins
 */
#define GPIO_USB3300_DATA0 23   /* USB3300 Parallel Data 0 [INOUT] */
#define GPIO_USB3300_DATA1 22   /* USB3300 Parallel Data 1 [INOUT] */
#define GPIO_USB3300_DATA2 21   /* USB3300 Parallel Data 2 [INOUT] */
#define GPIO_USB3300_DATA3 19   /* USB3300 Parallel Data 3 [INOUT] */
#define GPIO_USB3300_DATA4 18   /* USB3300 Parallel Data 4 [INOUT] */
#define GPIO_USB3300_DATA5 5    /* USB3300 Parallel Data 5 [INOUT] */
#define GPIO_USB3300_DATA6 17   /* USB3300 Parallel Data 6 [INOUT] */
#define GPIO_USB3300_DATA7 16   /* USB3300 Parallel Data 7 [INOUT] */
#define GPIO_USB3300_STP   25   /* USB3300 stop signal [OUTPUT] */
#define GPIO_USB3300_NXT   35   /* USB3300 data flow control when LINK->PHY [INPUT] */
#define GPIO_USB3300_DIR   34   /* USB3300 direction signal [INPUT] */
#define GPIO_USB3300_CLK   27   /* USB3300 clock signal [INPUT] */
#define GPIO_USB3300_RST   NULL /* USB3300 reset pin [OUTPUT or NC] */

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
#define GPIO_SD_CMD   15 /* SD command [INOUT] */
#define GPIO_SD_CLK   14 /* SD clock [OUTPUT] */
#define GPIO_SD_DATA0 2  /* SD Serial Data 0 [INOUT] */
#define GPIO_SD_DATA1 4  /* SD Serial Data 1 [INOUT] */
#define GPIO_SD_DATA2 12 /* SD Serial Data 2 [INOUT] */
#define GPIO_SD_DATA3 13 /* SD Serial Data 3 [INOUT] */

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
 * DEBUG mode 
 */
enum debug_e
{
    DEBUG_DISABLE,
    DEBUG_ENABLE
} debug_status;

debug_status = DEBUG_ENABLE;

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