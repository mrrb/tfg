EESchema Schematic File Version 4
LIBS:diagramas_funcionamiento-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 7 9
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Sheet
S 950  950  1450 500 
U 5C6B3D36
F0 "UART_Tx" 59
F1 "UART_Tx.sch" 59
$EndSheet
$Sheet
S 950  1750 1450 450 
U 5C6B3D39
F0 "UART_Rx" 59
F1 "UART_Rx.sch" 59
$EndSheet
$Comp
L modulos:UART_Rx U?
U 1 1 5C99376E
P 6000 5450
F 0 "U?" H 6000 6750 59  0001 C CNN
F 1 "UART_Rx" H 6000 6600 59  0001 C CNN
F 2 "" H 5050 5150 59  0001 C CNN
F 3 "" H 5050 5150 59  0001 C CNN
F 4 "UART_Rx" H 6000 6900 50  0000 C CNN "name"
	1    6000 5450
	1    0    0    -1  
$EndComp
Text GLabel 4700 1650 0    98   Input ~ 0
rst
Text GLabel 4700 1900 0    98   Input ~ 0
clk
Text GLabel 4700 4550 0    98   Input ~ 0
Rx
Text GLabel 7300 2650 2    98   Output ~ 0
Tx
Text GLabel 4700 2800 0    98   Input ~ 0
I_DATA[7:0]
Text GLabel 4700 3000 0    98   Input ~ 0
send_data
Text GLabel 4700 4950 0    98   Input ~ 0
NxT
Text GLabel 7300 4350 2    98   Output ~ 0
clk_Rx
Text GLabel 7300 2400 2    98   Output ~ 0
clk_Tx
Text GLabel 7300 4700 2    98   Output ~ 0
O_DATA[7:0]
Text GLabel 7300 2950 2    98   Output ~ 0
TiP
Text GLabel 7300 4950 2    98   Output ~ 0
NrD
Text GLabel 7300 3200 2    98   Output ~ 0
Tx_FULL
Text GLabel 7300 5200 2    98   Output ~ 0
Rx_FULL
Text GLabel 7300 5450 2    98   Output ~ 0
Rx_EMPTY
$Comp
L modulos:UART_Tx U?
U 1 1 5C995741
P 6000 3450
F 0 "U?" H 6000 5000 98  0001 C CNN
F 1 "UART_Tx" H 6000 4850 98  0001 C CNN
F 2 "" H 6000 3350 98  0001 C CNN
F 3 "" H 6000 3350 98  0001 C CNN
F 4 "UART_Tx" H 6000 4800 50  0000 C CNN "name"
	1    6000 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	4700 1650 5400 1650
Wire Wire Line
	5400 1650 5400 2400
Wire Wire Line
	5400 2400 5500 2400
Wire Wire Line
	5400 2400 5400 4300
Wire Wire Line
	5400 4300 5600 4300
Connection ~ 5400 2400
Wire Wire Line
	4700 1900 5300 1900
Wire Wire Line
	5300 1900 5300 2500
Wire Wire Line
	5300 2500 5500 2500
Wire Wire Line
	5600 4400 5300 4400
Wire Wire Line
	5300 4400 5300 2500
Connection ~ 5300 2500
Wire Wire Line
	4700 2800 5500 2800
Wire Wire Line
	4700 3000 5500 3000
Wire Wire Line
	4700 4550 5600 4550
Wire Wire Line
	4700 4950 5600 4950
Wire Wire Line
	6400 5050 6500 5050
Wire Wire Line
	6500 5050 6500 5450
Wire Wire Line
	6500 5450 7300 5450
Wire Wire Line
	6400 4950 6600 4950
Wire Wire Line
	6600 4950 6600 5200
Wire Wire Line
	6600 5200 7300 5200
Wire Wire Line
	6400 4850 6700 4850
Wire Wire Line
	6700 4850 6700 4950
Wire Wire Line
	6700 4950 7300 4950
Wire Wire Line
	6400 4700 7300 4700
Wire Wire Line
	6400 4350 7300 4350
Wire Wire Line
	6500 2950 7300 2950
Wire Wire Line
	6500 3050 6600 3050
Wire Wire Line
	6600 3050 6600 3200
Wire Wire Line
	6600 3200 7300 3200
Wire Wire Line
	6500 2450 6600 2450
Wire Wire Line
	6600 2450 6600 2400
Wire Wire Line
	6600 2400 7300 2400
Wire Wire Line
	6500 2650 7300 2650
Text GLabel 6000 5950 3    98   UnSpc ~ 0
bauds
Wire Wire Line
	6000 3550 6000 3900
Wire Wire Line
	6000 3900 6800 3900
Wire Wire Line
	6800 3900 6800 5600
Wire Wire Line
	6800 5600 6000 5600
Connection ~ 6000 5600
Wire Wire Line
	6000 5600 6000 5550
Wire Notes Line
	7100 5800 7100 1450
Wire Notes Line
	7100 1450 4900 1450
Wire Notes Line
	4900 1450 4900 5800
Wire Notes Line
	4900 5800 7100 5800
Wire Wire Line
	6000 5600 6000 5950
Text Notes 5250 1400 2    98   ~ 0
UART
Text Label 5050 2800 2    59   Italic 0
[8]
Text Label 7100 4700 2    59   Italic 0
[8]
Text Label 5300 1900 2    79   ~ 0
60MHz
Text Label 5100 1650 2    98   ~ 0
rst
$EndSCHEMATC
