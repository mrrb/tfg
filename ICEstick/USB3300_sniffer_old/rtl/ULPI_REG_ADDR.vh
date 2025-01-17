/*
 *
 * In this file are defined all the possible register address that can be read/write/clear in the USB3300 IC using the ULPI protocol.
 * For more info, refer to 'Table 6-3' in the USB3300 Datasheet.
 *
 */

`define ADDR_ULPI_READ_VENDOR_ID_LOW       5'h00
`define ADDR_ULPI_READ_VENDOR_ID_HIGH      5'h01
`define ADDR_ULPI_READ_PRODUCT_ID_LOW      5'h02
`define ADDR_ULPI_READ_PRODUCT_ID_HIGH     5'h03
`define ADDR_ULPI_READ_FUNCTION_CONTROL    5'h04
`define ADDR_ULPI_READ_INTERFACE_CONTROL   5'h07
`define ADDR_ULPI_READ_OTG_CONTROL         5'h0A
`define ADDR_ULPI_READ_USB_INT_EN_RISING   5'h0D
`define ADDR_ULPI_READ_USB_INT_EN_FALLING  5'h10
`define ADDR_ULPI_READ_USB_INT_STATUS      5'h13
`define ADDR_ULPI_READ_USB_INT_LATCH       5'h14
`define ADDR_ULPI_READ_DEBUG               5'h15
`define ADDR_ULPI_READ_SCRATCH             5'h16

`define ADDR_ULPI_WRITE_FUNCTION_CONTROL   5'h04
`define ADDR_ULPI_WRITE_INTERFACE_CONTROL  5'h07
`define ADDR_ULPI_WRITE_OTG_CONTROL        5'h0A
`define ADDR_ULPI_WRITE_USB_INT_EN_RISING  5'h0D
`define ADDR_ULPI_WRITE_USB_INT_EN_FALLING 5'h10
`define ADDR_ULPI_WRITE_SCRATCH            5'h16

`define ADDR_ULPI_SET_FUNCTION_CONTROL     5'h05
`define ADDR_ULPI_SET_INTERFACE_CONTROL    5'h08
`define ADDR_ULPI_SET_OTG_CONTROL          5'h0B
`define ADDR_ULPI_SET_USB_INT_EN_RISING    5'h0E
`define ADDR_ULPI_SET_USB_INT_EN_FALLING   5'h11
`define ADDR_ULPI_SET_SCRATCH              5'h17

`define ADDR_ULPI_CLEAR_FUNCTION_CONTROL   5'h06
`define ADDR_ULPI_CLEAR_INTERFACE_CONTROL  5'h09
`define ADDR_ULPI_CLEAR_OTG_CONTROL        5'h0C
`define ADDR_ULPI_CLEAR_USB_INT_EN_RISING  5'h0F
`define ADDR_ULPI_CLEAR_USB_INT_EN_FALLING 5'h12
`define ADDR_ULPI_CLEAR_SCRATCH            5'h18