EESchema Schematic File Version 4
LIBS:diagramas_funcionamiento-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 9
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L modulos:FIFO_BRAM_SYNC U?
U 1 1 5C7415BD
P 5900 4550
F 0 "U?" H 6350 5850 59  0001 C CNN
F 1 "FIFO_BRAM_SYNC" H 5900 5700 79  0001 C CNN
F 2 "" H 5900 4550 59  0001 C CNN
F 3 "" H 5900 4550 59  0001 C CNN
F 4 "16bits" H 5650 5600 59  0001 C CNN "DATA_WIDTH"
F 5 "1BRAM" H 6100 5600 59  0001 C CNN "FIFO_SIZE_ML"
F 6 "Almost_full >= 90%" H 5900 5866 39  0001 C CNN "ALMOST_FULL"
F 7 "Almost_empty <= 10%" H 5900 5865 39  0001 C CNN "ALMOST_EMPTY"
F 8 "op_stack" H 5900 5750 50  0000 C CNN "name"
	1    5900 4550
	1    0    0    -1  
$EndComp
Text GLabel 4450 1550 0    98   Input ~ 0
rst
Text GLabel 4450 1800 0    98   Input ~ 0
clk
Text GLabel 4450 2250 0    98   Input ~ 0
UART_DATA[7:0]
Text GLabel 4450 2450 0    98   Input ~ 0
UART_Rx_EMPTY
Text GLabel 7350 2650 2    98   Output ~ 0
UART_NXT
Text GLabel 4400 4400 0    98   Input ~ 0
op_stack_pull
Text GLabel 7350 4100 2    98   Output ~ 0
op_stack_msg[15:0]
Text GLabel 7350 4350 2    98   Output ~ 0
op_stack_empty
Text Notes 4550 1300 0    118  ~ 0
ULPI_op_stack
$Comp
L modulos:states_machine_ulpi_op_stack U?
U 1 1 5C7420A5
P 5900 2850
F 0 "U?" H 5900 3950 118 0001 C CNN
F 1 "states_machine_ulpi_op_stack" H 5850 3800 118 0001 C CNN
F 2 "" H 6000 2850 118 0001 C CNN
F 3 "" H 6000 2850 118 0001 C CNN
	1    5900 2850
	1    0    0    -1  
$EndComp
Wire Wire Line
	5000 1550 5000 2050
Wire Wire Line
	5000 3650 5300 3650
Wire Wire Line
	4900 1800 4900 2150
Wire Wire Line
	4900 3750 5300 3750
Wire Wire Line
	5200 2050 5000 2050
Connection ~ 5000 2050
Wire Wire Line
	5000 2050 5000 3650
Wire Wire Line
	5200 2150 4900 2150
Connection ~ 4900 2150
Wire Wire Line
	4900 2150 4900 3750
NoConn ~ 6600 2550
Wire Wire Line
	5300 3900 5200 3900
Wire Wire Line
	5200 3900 5200 3100
Wire Wire Line
	5300 4050 5100 4050
Wire Wire Line
	5100 4050 5100 3000
Wire Wire Line
	6800 2350 6800 3100
Wire Wire Line
	5200 3100 6800 3100
Wire Wire Line
	6600 2350 6800 2350
Wire Wire Line
	6700 3000 6700 2750
Wire Wire Line
	6700 2750 6600 2750
Wire Wire Line
	5100 3000 6700 3000
NoConn ~ 6500 4100
NoConn ~ 6500 4450
Text GLabel 7350 3850 2    98   Output ~ 0
op_stack_full
Wire Wire Line
	4450 1550 5000 1550
Wire Wire Line
	4450 1800 4900 1800
Wire Wire Line
	4400 4400 5300 4400
Wire Wire Line
	6500 4350 7350 4350
Wire Wire Line
	7350 2650 6600 2650
Wire Notes Line
	4550 1350 7250 1350
Wire Notes Line
	7250 1350 7250 5600
Wire Notes Line
	7250 5600 4550 5600
Wire Notes Line
	4550 5600 4550 1350
Text GLabel 5550 5300 0    79   UnSpc ~ 0
16
NoConn ~ 5800 5250
NoConn ~ 6000 5250
NoConn ~ 6200 5250
Wire Wire Line
	5600 5300 5600 5250
Text Label 4550 2250 0    59   Italic 0
[8]
Wire Wire Line
	4700 2250 4700 2300
Wire Wire Line
	4700 2300 5200 2300
Wire Wire Line
	4450 2250 4700 2250
Wire Wire Line
	4700 2400 4700 2450
Wire Wire Line
	4700 2400 5200 2400
Wire Wire Line
	4450 2450 4700 2450
Text Label 7250 4100 2    59   Italic 0
[16]
Wire Wire Line
	7050 4250 7050 4100
Wire Wire Line
	7050 4250 6500 4250
Wire Wire Line
	7050 4000 7050 3850
Wire Wire Line
	7050 4000 6500 4000
Wire Wire Line
	7050 3850 7350 3850
Wire Wire Line
	7050 4100 7350 4100
Text Label 6700 2350 2    59   Italic 0
[16]
Text Label 5200 3900 0    59   Italic 0
[16]
Text Notes 4600 1550 0    59   ~ 0
rst
Text Notes 4600 1800 0    59   ~ 0
60MHz
Wire Wire Line
	5600 5300 5550 5300
$EndSCHEMATC
