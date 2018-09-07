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
 *     Initial: 2018/06/01      Mario Rubio
 */

/*
 *
 * In this file are defined all the possible register address that can be read/write/set/clear in the USB3300 IC using the ULPI protocol.
 * For more info, refer to 'Table 6-3' in the USB3300 Datasheet.
 *
 */

`define ADDR_READ_VENDOR_ID_LOW       5'h00
`define ADDR_READ_VENDOR_ID_HIGH      5'h01
`define ADDR_READ_PRODUCT_ID_LOW      5'h02
`define ADDR_READ_PRODUCT_ID_HIGH     5'h03
`define ADDR_READ_FUNCTION_CONTROL    5'h04
`define ADDR_READ_INTERFACE_CONTROL   5'h07
`define ADDR_READ_OTG_CONTROL         5'h0A
`define ADDR_READ_USB_INT_EN_RISING   5'h0D
`define ADDR_READ_USB_INT_EN_FALLING  5'h10
`define ADDR_READ_USB_INT_STATUS      5'h13
`define ADDR_READ_USB_INT_LATCH       5'h14
`define ADDR_READ_DEBUG               5'h15
`define ADDR_READ_SCRATCH             5'h16

`define ADDR_WRITE_FUNCTION_CONTROL   5'h04
`define ADDR_WRITE_INTERFACE_CONTROL  5'h07
`define ADDR_WRITE_OTG_CONTROL        5'h0A
`define ADDR_WRITE_USB_INT_EN_RISING  5'h0D
`define ADDR_WRITE_USB_INT_EN_FALLING 5'h10
`define ADDR_WRITE_SCRATCH            5'h16

`define ADDR_SET_FUNCTION_CONTROL     5'h05
`define ADDR_SET_INTERFACE_CONTROL    5'h08
`define ADDR_SET_OTG_CONTROL          5'h0B
`define ADDR_SET_USB_INT_EN_RISING    5'h0E
`define ADDR_SET_USB_INT_EN_FALLING   5'h11
`define ADDR_SET_SCRATCH              5'h17

`define ADDR_CLEAR_FUNCTION_CONTROL   5'h06
`define ADDR_CLEAR_INTERFACE_CONTROL  5'h09
`define ADDR_CLEAR_OTG_CONTROL        5'h0C
`define ADDR_CLEAR_USB_INT_EN_RISING  5'h0F
`define ADDR_CLEAR_USB_INT_EN_FALLING 5'h12
`define ADDR_CLEAR_SCRATCH            5'h18