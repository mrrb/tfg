EESchema Schematic File Version 4
LIBS:diagramas_funcionamiento-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 9 9
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 1350 3800 0    98   Input ~ 0
Rx
Text GLabel 7800 4850 2    98   Output ~ 0
Rx_FULL
Text GLabel 1350 5800 0    98   Input ~ 0
NxT
Text GLabel 7800 3150 2    98   Output ~ 0
NrD
Text GLabel 7800 5350 2    98   Output ~ 0
Rx_EMPTY
Text GLabel 7800 5100 2    98   Output ~ 0
O_DATA[7:0]
$Comp
L modulos:FIFO_BRAM_SYNC U?
U 1 1 5CB7A24F
P 6600 5400
AR Path="/5C6B3D33/5C6B3D36/5CB7A24F" Ref="U?"  Part="1" 
AR Path="/5C6B3D33/5C6B3D39/5CB7A24F" Ref="U?"  Part="1" 
F 0 "U?" H 6850 6700 59  0001 C CNN
F 1 "FIFO_BRAM_SYNC" H 6600 7100 79  0001 C CNN
F 2 "" H 6600 5400 59  0001 C CNN
F 3 "" H 6600 5400 59  0001 C CNN
F 4 "8bits" H 6600 6800 59  0001 C CNN "DATA_WIDTH"
F 5 "1BRAM" H 6600 6700 59  0001 C CNN "FIFO_SIZE_ML"
F 6 "Almost_full >= 90%" H 6600 6900 39  0001 C CNN "ALMOST_FULL"
F 7 "Almost_empty <= 10%" H 6600 7000 39  0001 C CNN "ALMOST_EMPTY"
F 8 "Rx_buffer" H 6600 6600 50  0000 C CNN "name"
	1    6600 5400
	1    0    0    -1  
$EndComp
Text GLabel 6250 6200 0    98   UnSpc ~ 0
8
Text GLabel 6450 6200 0    98   UnSpc ~ 0
1
Wire Wire Line
	6300 6200 6300 6100
Wire Wire Line
	6500 6200 6500 6100
NoConn ~ 6700 6100
NoConn ~ 6900 6100
$Comp
L modulos:shift_register U?
U 1 1 5CB7A25B
P 4450 5200
AR Path="/5C6B3D33/5C6B3D36/5CB7A25B" Ref="U?"  Part="1" 
AR Path="/5C6B3D33/5C6B3D39/5CB7A25B" Ref="U?"  Part="1" 
F 0 "U?" H 4400 6700 98  0001 C CNN
F 1 "shift_register" H 4450 6500 98  0001 C CNN
F 2 "" H 7550 5500 98  0001 C CNN
F 3 "" H 7550 5500 98  0001 C CNN
F 4 "shift_Rx" H 4450 6350 50  0000 C CNN "name"
	1    4450 5200
	1    0    0    -1  
$EndComp
Text GLabel 4350 5400 0    98   UnSpc ~ 0
10
Wire Wire Line
	4450 5400 4450 5300
Text Label 3900 4750 0    59   ~ 0
[10]
Text Label 5950 4750 0    59   ~ 0
[8]
Text Label 3950 4900 0    59   ~ 0
[2]
Text Label 5150 3450 2    59   ~ 0
[2]
Text GLabel 1350 1000 0    98   Input ~ 0
rst
Text GLabel 1350 1200 0    98   Input ~ 0
clk
Text Notes 2150 700  2    98   ~ 0
UART_Rx
Text Label 2250 1200 2    79   ~ 0
60MHz
Text Label 2250 950  2    98   ~ 0
rst
$Comp
L modulos:clk_baud_pulse U?
U 1 1 5CB87DEE
P 2350 2450
AR Path="/5C6B3D33/5C6B3D36/5CB87DEE" Ref="U?"  Part="1" 
AR Path="/5C6B3D33/5C6B3D39/5CB87DEE" Ref="U?"  Part="1" 
F 0 "U?" H 2300 3700 98  0001 C CNN
F 1 "clk_baud_pulse" H 2350 3600 98  0001 C CNN
F 2 "" H 2350 2450 98  0001 C CNN
F 3 "" H 2350 2450 98  0001 C CNN
F 4 "clk_baud_Rx" H 2350 3550 50  0000 C CNN "name"
	1    2350 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	2450 2650 2450 2550
Wire Wire Line
	1350 1200 1800 1200
Wire Wire Line
	1800 1200 1800 1650
Wire Wire Line
	1800 1650 1900 1650
Connection ~ 1800 1200
Wire Wire Line
	2800 1650 2900 1650
Wire Wire Line
	2900 1650 2900 1400
Wire Wire Line
	1900 1800 1800 1800
Wire Wire Line
	1800 1800 1800 2600
Text GLabel 2250 6550 3    98   UnSpc ~ 0
BAUDS
Wire Wire Line
	1350 1000 3900 1000
Text GLabel 7800 1400 2    98   Output ~ 0
clk_Tx
$Comp
L modulos:num_div U?
U 1 1 5CC04727
P 2450 3250
F 0 "U?" H 3100 3100 59  0001 C CNN
F 1 "num_div" H 3100 3000 59  0001 C CNN
F 2 "" H 2800 3150 59  0001 C CNN
F 3 "" H 2800 3150 59  0001 C CNN
F 4 "2" H 2450 3450 59  0000 L CNN "div_val"
	1    2450 3250
	1    0    0    -1  
$EndComp
Wire Wire Line
	2450 3400 2450 3500
Wire Wire Line
	2450 3500 2250 3500
Wire Wire Line
	2250 3500 2250 2550
Wire Wire Line
	1800 1200 3800 1200
$Comp
L modulos:states_machine_uart_rx U?
U 1 1 5CC28B8B
P 4550 3550
F 0 "U?" H 4550 5100 59  0001 C CNN
F 1 "states_machine_uart_rx" H 4550 5000 59  0001 C CNN
F 2 "" H 4950 4750 59  0001 C CNN
F 3 "" H 4950 4750 59  0001 C CNN
	1    4550 3550
	1    0    0    -1  
$EndComp
$Comp
L modulos:and2 U?
U 1 1 5CC29025
P 3200 1900
F 0 "U?" H 3200 2300 59  0001 C CNN
F 1 "and2" H 3200 2250 59  0001 C CNN
F 2 "" H 3200 1900 59  0001 C CNN
F 3 "" H 3200 1900 59  0001 C CNN
	1    3200 1900
	0    1    1    0   
$EndComp
Wire Wire Line
	4000 2500 3900 2500
Wire Wire Line
	3900 2500 3900 1000
Connection ~ 3900 1000
Wire Wire Line
	3900 1000 5900 1000
Wire Wire Line
	4000 2600 3800 2600
Wire Wire Line
	3800 2600 3800 1200
Connection ~ 3800 1200
Wire Wire Line
	3800 1200 5800 1200
Wire Wire Line
	3350 2700 3700 2700
Wire Wire Line
	4000 4350 3900 4350
Wire Wire Line
	3900 4350 3900 2500
Connection ~ 3900 2500
Wire Wire Line
	4000 4450 3700 4450
Wire Wire Line
	3700 4450 3700 2700
Connection ~ 3700 2700
Wire Wire Line
	3700 2700 4000 2700
NoConn ~ 4900 4600
Text GLabel 3900 4750 0    59   Input ~ 0
0
Wire Wire Line
	3900 4750 4000 4750
Wire Wire Line
	4000 4600 3600 4600
NoConn ~ 7200 5300
NoConn ~ 7200 4950
Wire Wire Line
	1350 5800 5300 5800
NoConn ~ 5100 2850
NoConn ~ 5100 2950
Connection ~ 2250 3500
Wire Notes Line
	1550 6400 1550 750 
Wire Notes Line
	1550 750  7600 750 
Wire Notes Line
	7600 750  7600 6400
Wire Notes Line
	7600 6400 1550 6400
Wire Wire Line
	2900 1400 3450 1400
Wire Wire Line
	3450 1650 3450 1400
Connection ~ 3450 1400
Wire Wire Line
	3450 1400 7800 1400
Wire Wire Line
	3100 2600 3100 1550
Wire Wire Line
	3100 1550 3250 1550
Wire Wire Line
	3250 1550 3250 1650
Connection ~ 3100 2600
Wire Wire Line
	3100 2600 1800 2600
Wire Wire Line
	3600 3300 4000 3300
Wire Wire Line
	3500 4900 4000 4900
Wire Wire Line
	3500 4000 3500 4900
Wire Wire Line
	3500 4000 3600 4000
Text Label 7550 5100 2    59   ~ 0
[8]
Text Label 4950 4750 2    59   ~ 0
[8]
Wire Wire Line
	2250 3500 2250 6550
Wire Wire Line
	5900 1000 5900 4500
Wire Wire Line
	6000 4900 5400 4900
Wire Wire Line
	6000 5250 5300 5250
Wire Wire Line
	5300 5250 5300 5800
Wire Wire Line
	5900 4500 6000 4500
Wire Wire Line
	6000 4600 5800 4600
Wire Wire Line
	5800 1200 5800 4600
Wire Wire Line
	4900 4750 6000 4750
Wire Wire Line
	7800 5100 7200 5100
Wire Wire Line
	7800 4850 7200 4850
Wire Wire Line
	7200 5200 7300 5200
Wire Wire Line
	7300 5200 7300 5350
Wire Wire Line
	7300 5350 7800 5350
Wire Wire Line
	5100 3150 5400 3150
Wire Wire Line
	1350 3800 3600 3800
Wire Wire Line
	3600 3300 3600 3800
Connection ~ 3600 3800
Wire Wire Line
	3600 3800 3600 4600
Wire Wire Line
	3100 3650 3100 2600
Wire Wire Line
	5100 3050 5200 3050
Wire Wire Line
	5200 3650 3100 3650
Wire Wire Line
	5200 3050 5200 3650
Wire Wire Line
	5300 4000 5300 3450
Wire Wire Line
	3600 4000 5300 4000
Wire Wire Line
	5100 3450 5300 3450
Wire Wire Line
	3350 2250 3350 2700
Wire Wire Line
	4350 5400 4450 5400
Wire Wire Line
	6450 6200 6500 6200
Wire Wire Line
	6300 6200 6250 6200
Wire Wire Line
	5400 4900 5400 3150
Connection ~ 5400 3150
Wire Wire Line
	5400 3150 7800 3150
$EndSCHEMATC
