# ICEstick + FTDI FT2232H notes

Changes have been made to the default FT2232H USB bridge configuration so the FPGA and its SPI Flash memory work properly.
___

The FT2232H USB bridge features 2 independent channels with several protocols to use. One on those channels (Channel A) is used to program the onboard SPI Flash memory chip that the FPGA uses to store the synthesized circuit, the other channel, B, is preconfigured as a UART interface.

![ICEstick_FTDI_config](../img/ICEstick_FT2232H.png "ICEstick_FTDI_config")

Because the USB sniffer is using the SPI communication to transmit the USB3300 ULPI data, the default use of the channel B is changed from UART to MPSSE, so we can connect to it properly.

![FT2232H_pins](../img/FT2232H_pins.png "FT2232H_pins")

Changes:

* RXd is now TCK/SK (SPI clock). [IO 9]
* TXd is now TDI/DO (SPI MOSI).  [IO 8]
* RTS is now TDO/DI (SPI MISO).  [IO 7]
* CTS is now TMS/CS (SPI SS).    [IO 4]

___

Another thing to have in mind, the FTDI chip only support SPI modes 0 and 2 (as seeing in the table below), so the FPGA has to be configured accordingly.

| Mode | CPOL | CPHA |
|:----:|:----:|:----:|
|   0  |   0  |   0  |
|   1  |   0  |   1  |
|   2  |   1  |   0  |
|   3  |   1  |   1  |

In this case, both are configured to be in mode 0.

___

To still can use the UART interface (with external bridge) the pins are now:

* Rx => 61
* Tx => 62