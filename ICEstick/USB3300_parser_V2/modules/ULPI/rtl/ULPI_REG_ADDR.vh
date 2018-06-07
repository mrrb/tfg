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

`define ADDR_READ_VENDOR_ID_LOW       8'h00
`define ADDR_READ_VENDOR_ID_HIGH      8'h01
`define ADDR_READ_PRODUCT_ID_LOW      8'h02
`define ADDR_READ_PRODUCT_ID_HIGH     8'h03
`define ADDR_READ_FUNCTION_CONTROL    8'h04
`define ADDR_READ_INTERFACE_CONTROL   8'h07
`define ADDR_READ_OTG_CONTROL         8'h0A
`define ADDR_READ_USB_INT_EN_RISING   8'h0D
`define ADDR_READ_USB_INT_EN_FALLING  8'h10
`define ADDR_READ_USB_INT_STATUS      8'h13
`define ADDR_READ_USB_INT_LATCH       8'h14
`define ADDR_READ_DEBUG               8'h15
`define ADDR_READ_SCRATCH             8'h16

`define ADDR_WRITE_FUNCTION_CONTROL   8'h04
`define ADDR_WRITE_INTERFACE_CONTROL  8'h07
`define ADDR_WRITE_OTG_CONTROL        8'h0A
`define ADDR_WRITE_USB_INT_EN_RISING  8'h0D
`define ADDR_WRITE_USB_INT_EN_FALLING 8'h10
`define ADDR_WRITE_SCRATCH            8'h16

`define ADDR_SET_FUNCTION_CONTROL     8'h05
`define ADDR_SET_INTERFACE_CONTROL    8'h08
`define ADDR_SET_OTG_CONTROL          8'h0B
`define ADDR_SET_USB_INT_EN_RISING    8'h0E
`define ADDR_SET_USB_INT_EN_FALLING   8'h11
`define ADDR_SET_SCRATCH              8'h17

`define ADDR_CLEAR_FUNCTION_CONTROL   8'h06
`define ADDR_CLEAR_INTERFACE_CONTROL  8'h09
`define ADDR_CLEAR_OTG_CONTROL        8'h0C
`define ADDR_CLEAR_USB_INT_EN_RISING  8'h0F
`define ADDR_CLEAR_USB_INT_EN_FALLING 8'h12
`define ADDR_CLEAR_SCRATCH            8'h18