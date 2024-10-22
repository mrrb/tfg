EESchema Schematic File Version 4
LIBS:diagramas_funcionamiento-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 8 9
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 1750 1000 0    98   Input ~ 0
rst
Text GLabel 1750 1250 0    98   Input ~ 0
clk
Text GLabel 9150 2450 2    98   Output ~ 0
Tx
Text GLabel 1750 4000 0    98   Input ~ 0
I_DATA[7:0]
Text GLabel 1750 4200 0    98   Input ~ 0
send_data
Text GLabel 9150 1500 2    98   Output ~ 0
clk_Tx
Text GLabel 9150 5800 2    98   Output ~ 0
TiP
Text GLabel 9150 3950 2    98   Output ~ 0
Tx_FULL
Text Notes 2550 700  2    98   ~ 0
UART_Tx
Text Label 2650 1250 2    79   ~ 0
60MHz
Text Label 2650 1000 2    98   ~ 0
rst
$Comp
L modulos:FIFO_BRAM_SYNC U?
U 1 1 5C99E6D9
P 7300 4500
F 0 "U?" H 7550 5800 59  0001 C CNN
F 1 "FIFO_BRAM_SYNC" H 7300 6200 79  0001 C CNN
F 2 "" H 7300 4500 59  0001 C CNN
F 3 "" H 7300 4500 59  0001 C CNN
F 4 "8bits" H 7300 5900 59  0001 C CNN "DATA_WIDTH"
F 5 "1BRAM" H 7300 5800 59  0001 C CNN "FIFO_SIZE_ML"
F 6 "Almost_full >= 90%" H 7300 6000 39  0001 C CNN "ALMOST_FULL"
F 7 "Almost_empty <= 10%" H 7300 6100 39  0001 C CNN "ALMOST_EMPTY"
F 8 "Tx_buffer" H 7300 5700 50  0000 C CNN "name"
	1    7300 4500
	1    0    0    -1  
$EndComp
Text GLabel 6950 5300 0    98   UnSpc ~ 0
8
Text GLabel 7150 5300 0    98   UnSpc ~ 0
1
Wire Wire Line
	7000 5300 7000 5200
Wire Wire Line
	7200 5300 7200 5200
NoConn ~ 7400 5200
NoConn ~ 7600 5200
$Comp
L modulos:shift_register U?
U 1 1 5C9A2E61
P 5250 4600
F 0 "U?" H 5200 6100 98  0001 C CNN
F 1 "shift_register" H 5250 5900 98  0001 C CNN
F 2 "" H 8350 4900 98  0001 C CNN
F 3 "" H 8350 4900 98  0001 C CNN
F 4 "shift_Tx" H 5250 5750 50  0000 C CNN "name"
	1    5250 4600
	1    0    0    -1  
$EndComp
$Comp
L modulos:clk_baud_pulse U?
U 1 1 5C9A554B
P 2750 2500
F 0 "U?" H 2700 3750 98  0001 C CNN
F 1 "clk_baud_pulse" H 2750 3650 98  0001 C CNN
F 2 "" H 2750 2500 98  0001 C CNN
F 3 "" H 2750 2500 98  0001 C CNN
F 4 "clk_baud_Tx" H 2750 3600 50  0000 C CNN "name"
	1    2750 2500
	1    0    0    -1  
$EndComp
$Comp
L modulos:states_machine_uart_tx U?
U 1 1 5C9A66E1
P 5350 6000
F 0 "U?" H 5300 7200 98  0001 C CNN
F 1 "states_machine_uart_tx" H 5350 7000 98  0001 C CNN
F 2 "" H 5350 6000 98  0001 C CNN
F 3 "" H 5350 6000 98  0001 C CNN
	1    5350 6000
	1    0    0    -1  
$EndComp
$Comp
L modulos:or2 U?
U 1 1 5C9AA71F
P 3850 2850
F 0 "U?" H 3850 3350 98  0001 C CNN
F 1 "or2" H 3850 3250 98  0001 C CNN
F 2 "" H 3800 2750 98  0001 C CNN
F 3 "" H 3800 2750 98  0001 C CNN
	1    3850 2850
	0    1    1    0   
$EndComp
$Comp
L modulos:and2 U?
U 1 1 5C9AA795
P 4150 2100
F 0 "U?" H 4150 2500 59  0001 C CNN
F 1 "and2" H 4150 2450 59  0001 C CNN
F 2 "" H 4150 2100 59  0001 C CNN
F 3 "" H 4150 2100 59  0001 C CNN
	1    4150 2100
	0    1    1    0   
$EndComp
$Comp
L modulos:and2_neg1 U?
U 1 1 5C9AA812
P 3550 2150
F 0 "U?" H 3550 2600 59  0001 C CNN
F 1 "and2_neg1" H 3500 2500 59  0001 C CNN
F 2 "" H 3550 2150 59  0001 C CNN
F 3 "" H 3550 2150 59  0001 C CNN
	1    3550 2150
	0    1    1    0   
$EndComp
Wire Wire Line
	3700 2450 3700 2500
Wire Wire Line
	3700 2500 3900 2500
Wire Wire Line
	3900 2500 3900 2550
Wire Wire Line
	4100 2550 4100 2500
Wire Wire Line
	4100 2500 4300 2500
Wire Wire Line
	4300 2500 4300 2450
Text GLabel 2950 2700 2    98   UnSpc ~ 0
0
Wire Wire Line
	2850 2700 2850 2600
Wire Wire Line
	1750 1250 2200 1250
Wire Wire Line
	2200 1250 2200 1700
Wire Wire Line
	2200 1700 2300 1700
Wire Wire Line
	2200 1250 4400 1250
Connection ~ 2200 1250
Wire Wire Line
	3200 1700 3300 1700
Wire Wire Line
	3300 1700 3300 1500
Wire Wire Line
	3300 1500 3800 1500
Wire Wire Line
	3800 1850 3800 1500
Connection ~ 3800 1500
Wire Wire Line
	4400 1850 4400 1250
Connection ~ 4400 1250
Wire Wire Line
	4200 1850 4200 1750
Wire Wire Line
	4200 1750 3600 1750
Wire Wire Line
	3600 1750 3600 1850
Text GLabel 5150 4800 0    98   UnSpc ~ 0
11
Wire Wire Line
	5250 4800 5250 4700
Wire Wire Line
	4500 3700 4000 3700
Text GLabel 4400 4000 0    98   Input ~ 0
1
Wire Wire Line
	3600 1750 3450 1750
Connection ~ 3600 1750
Wire Wire Line
	4500 5550 4800 5550
Wire Wire Line
	4500 3700 4500 5550
Wire Wire Line
	4600 5450 4800 5450
Wire Wire Line
	4700 5350 4800 5350
NoConn ~ 7900 4400
NoConn ~ 7900 4050
$Comp
L modulos:or2 U?
U 1 1 5C9E38D0
P 8200 2600
F 0 "U?" H 8200 3100 98  0001 C CNN
F 1 "or2" H 8200 3000 98  0001 C CNN
F 2 "" H 8150 2500 98  0001 C CNN
F 3 "" H 8150 2500 98  0001 C CNN
	1    8200 2600
	1    0    0    -1  
$EndComp
$Comp
L modulos:and2 U?
U 1 1 5C9E38D6
P 7450 2300
F 0 "U?" H 7450 2700 59  0001 C CNN
F 1 "and2" H 7450 2650 59  0001 C CNN
F 2 "" H 7450 2300 59  0001 C CNN
F 3 "" H 7450 2300 59  0001 C CNN
	1    7450 2300
	1    0    0    -1  
$EndComp
$Comp
L modulos:and2_neg1 U?
U 1 1 5C9E38DC
P 7500 2900
F 0 "U?" H 7500 3350 59  0001 C CNN
F 1 "and2_neg1" H 7450 3250 59  0001 C CNN
F 2 "" H 7500 2900 59  0001 C CNN
F 3 "" H 7500 2900 59  0001 C CNN
	1    7500 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	7800 2750 7850 2750
Wire Wire Line
	7850 2750 7850 2550
Wire Wire Line
	7850 2550 7900 2550
Wire Wire Line
	7900 2350 7850 2350
Wire Wire Line
	7850 2350 7850 2150
Wire Wire Line
	7850 2150 7800 2150
Text GLabel 7000 2650 0    98   Input ~ 0
1
Wire Wire Line
	7200 2850 7100 2850
Wire Wire Line
	7100 2250 7100 2850
Wire Wire Line
	7100 2250 7200 2250
Wire Wire Line
	7000 2650 7200 2650
Wire Wire Line
	6700 3600 6600 3600
Wire Wire Line
	6700 3700 6500 3700
NoConn ~ 5700 4150
Wire Wire Line
	1750 4000 2050 4000
Wire Wire Line
	2050 4000 2050 4050
Wire Wire Line
	1750 4200 2050 4200
Wire Wire Line
	2050 4200 2050 4150
Wire Wire Line
	4800 4300 4400 4300
Wire Wire Line
	4800 3850 4600 3850
Connection ~ 4600 3850
Wire Wire Line
	4600 3850 4600 5450
Wire Wire Line
	4800 3750 4700 3750
Connection ~ 4700 3750
Wire Wire Line
	4700 3750 4700 5350
Wire Wire Line
	4400 4000 4800 4000
Wire Wire Line
	5900 5800 6100 5800
Wire Wire Line
	6100 5800 6100 6200
Wire Wire Line
	6100 6200 3450 6200
Wire Wire Line
	2500 3400 2500 4150
Wire Wire Line
	2050 4150 2500 4150
Wire Wire Line
	2400 4050 2400 3300
Wire Wire Line
	2050 4050 2400 4050
Wire Wire Line
	6400 3300 6400 3850
Wire Wire Line
	6400 3850 6700 3850
Wire Wire Line
	6700 4000 6300 4000
Wire Wire Line
	6300 4000 6300 3400
Wire Wire Line
	4800 4150 4300 4150
Wire Wire Line
	4300 4150 4300 6300
Wire Wire Line
	2400 3300 6400 3300
Wire Wire Line
	2500 3400 6300 3400
Wire Wire Line
	5900 5900 6200 5900
Wire Wire Line
	6200 2850 7100 2850
Connection ~ 7100 2850
Wire Wire Line
	8500 2450 9150 2450
Wire Wire Line
	8500 5800 8600 5800
Wire Wire Line
	5700 4000 6100 4000
Wire Wire Line
	6100 2050 7200 2050
$Comp
L modulos:negand2 U?
U 1 1 5CAAF155
P 6550 4750
F 0 "U?" H 6550 5300 98  0001 C CNN
F 1 "negand2" H 6550 5200 98  0001 C CNN
F 2 "" H 6200 5150 98  0001 C CNN
F 3 "" H 6200 5150 98  0001 C CNN
	1    6550 4750
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6400 4450 6400 4350
Wire Wire Line
	6400 4350 6700 4350
$Comp
L 74xx:74LS04 U?
U 1 1 5CA9BBEF
P 8200 5800
F 0 "U?" H 8200 6025 50  0001 C CNN
F 1 "74LS04" H 8200 6026 50  0001 C CNN
F 2 "" H 8200 5800 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 8200 5800 50  0001 C CNN
	1    8200 5800
	1    0    0    -1  
$EndComp
Wire Wire Line
	5900 5700 6300 5700
Wire Wire Line
	6300 5700 6300 5800
Wire Wire Line
	6300 5800 7900 5800
Wire Wire Line
	7900 3950 9150 3950
Wire Wire Line
	6500 5050 6500 5450
Wire Wire Line
	6500 5450 8000 5450
Wire Wire Line
	8000 5450 8000 4300
Wire Wire Line
	8000 4300 7900 4300
Wire Wire Line
	6300 5050 6300 5550
Wire Wire Line
	6300 5550 8600 5550
Wire Wire Line
	8600 5550 8600 5800
Connection ~ 8600 5800
Wire Wire Line
	8600 5800 9150 5800
Wire Wire Line
	8700 6300 8700 4200
Wire Wire Line
	8700 4200 7900 4200
Wire Wire Line
	4300 6300 8700 6300
Wire Wire Line
	3800 1500 9150 1500
Wire Notes Line
	8950 6500 8950 750 
Wire Notes Line
	8950 750  1950 750 
Wire Notes Line
	1950 6500 8950 6500
Wire Notes Line
	1950 750  1950 6500
Wire Wire Line
	1750 1000 4700 1000
Wire Wire Line
	4400 1250 4600 1250
Wire Wire Line
	4700 1000 4700 3750
Connection ~ 4700 1000
Wire Wire Line
	4700 1000 6600 1000
Wire Wire Line
	4600 1250 4600 3850
Connection ~ 4600 1250
Wire Wire Line
	4600 1250 6500 1250
Wire Wire Line
	6500 1250 6500 3700
Wire Wire Line
	6600 1000 6600 3600
Wire Wire Line
	6100 2050 6100 4000
Wire Wire Line
	6200 2850 6200 3200
Wire Wire Line
	4000 3150 4000 3700
Wire Wire Line
	2300 1850 2200 1850
Wire Wire Line
	2200 1850 2200 3200
Wire Wire Line
	2200 3200 6200 3200
Connection ~ 6200 3200
Wire Wire Line
	6200 3200 6200 5900
Wire Wire Line
	3450 1750 3450 6200
Wire Wire Line
	4400 4300 4400 5050
Text Label 2250 4050 2    59   ~ 0
[8]
Text Label 6650 3850 0    59   ~ 0
[8]
Text Label 7950 4200 2    59   ~ 0
[8]
Text Label 4750 4150 0    59   ~ 0
[8]
Text Label 4750 4300 0    59   ~ 0
[2]
Text Label 5950 5450 2    59   ~ 0
[2]
Text GLabel 2650 6700 3    98   UnSpc ~ 0
BAUDS
Wire Wire Line
	2650 6700 2650 2600
Wire Wire Line
	5950 5450 6050 5450
Wire Wire Line
	6050 5450 6050 5050
Wire Wire Line
	6050 5050 4400 5050
Wire Wire Line
	2850 2700 2950 2700
Wire Wire Line
	5150 4800 5250 4800
Wire Wire Line
	6950 5300 7000 5300
Wire Wire Line
	7150 5300 7200 5300
$EndSCHEMATC
