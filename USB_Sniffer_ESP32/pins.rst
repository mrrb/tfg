Needed_GPIO:
 * USB3300_DATA0. USB3300 Parallel Data 0 [INOUT].
 * USB3300_DATA1. USB3300 Parallel Data 1 [INOUT].
 * USB3300_DATA2. USB3300 Parallel Data 2 [INOUT].
 * USB3300_DATA3. USB3300 Parallel Data 3 [INOUT].
 * USB3300_DATA4. USB3300 Parallel Data 4 [INOUT].
 * USB3300_DATA5. USB3300 Parallel Data 5 [INOUT].
 * USB3300_DATA6. USB3300 Parallel Data 6 [INOUT].
 * USB3300_DATA7. USB3300 Parallel Data 7 [INOUT].
 * USB3300_STP.   USB3300 stop signal [OUTPUT].
 * USB3300_NXT.   USB3300 data flow control when LINK->PHY [INPUT].
 * USB3300_DIR.   USB3300 direction signal [INPUT].
 * USB3300_CLK.   USB3300 clock signal [INPUT].
 * USB3300_RST.   USB3300 reset pin [OUTPUT or NC].

Needed_POWER:
 * USB3300_3_3V.
 * USB3300_GND.

Needed_ADC:
 * ADC_Vbus. Voltage in the USB bus [INPUT].
 * ADC_Vin.  Voltage BEFORE the 3.3V regulator [INPUT].

Needed_SD_4_lines_mode
 * SD_CMD.   SD command [INOUT].
 * SD_CLK.   SD clock [OUTPUT].
 * SD_DATA0. SD Serial Data 0 [INOUT].
 * SD_DATA1. SD Serial Data 1 [INOUT].
 * SD_DATA2. SD Serial Data 2 [INOUT].
 * SD_DATA3. SD Serial Data 3 [INOUT].

============== ============= ==============
Name           ESP32_PIN     ESP32_function
-------------- ------------- --------------
USB3300_DATA0  GPIO23 [R15]
USB3300_DATA1  GPIO22 [R14]
USB3300_DATA2  GPIO21 [R11]
USB3300_DATA3  GPIO19 [R10]
USB3300_DATA4  GPIO18 [R09]
USB3300_DATA5  GPIO5  [R08]
USB3300_DATA6  GPIO17 [R07]
USB3300_DATA7  GPIO16 [R06]
USB3300_STP    GPIO25 [L08]
USB3300_NXT    GPIO35 [L11]
USB3300_DIR    GPIO34 [L12]
USB3300_CLK    GPIO27 [L06]
USB3300_RST    GPIO []
ADC_Vbus       GPIO32 [L10]
ADC_Vin        GPIO33 [L09]
SD_DATA0       GPIO2  [R04]
SD_DATA1       GPIO4  [R05]
SD_DATA2       GPIO12 [L04]
SD_DATA3       GPIO13 [L03]
SD_CMD         GPIO15 [R03]
SD_CLK         GPIO14 [L05]
USB3300_GND    GND           --
USB3300_3_3V   3.3V          --
============== ============= ==============


