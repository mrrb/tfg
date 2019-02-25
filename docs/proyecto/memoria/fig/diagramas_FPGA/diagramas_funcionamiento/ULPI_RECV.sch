EESchema Schematic File Version 4
LIBS:diagramas_funcionamiento-cache
EELAYER 26 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 6 9
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 11900 3100 2    98   Output ~ 0
RxCMD[7:0]
Text GLabel 11900 3300 2    98   Output ~ 0
RxLineState[1:0]
Text GLabel 11900 3500 2    98   Output ~ 0
RxVbusState[1:0]
Text GLabel 11900 3700 2    98   Output ~ 0
RxActive
Text GLabel 11900 3900 2    98   Output ~ 0
RxError
Text GLabel 11900 4100 2    98   Output ~ 0
RxHostDisconnect
Text GLabel 11900 4300 2    98   Output ~ 0
RxID
Text GLabel 11900 7800 2    98   Output ~ 0
USB_DATA[7:0]
Text GLabel 11900 8450 2    98   Output ~ 0
USB_INFO_DATA[15:0]
Text GLabel 11900 7600 2    98   Output ~ 0
DATA_buff_full
Text GLabel 11900 8000 2    98   Output ~ 0
DATA_buff_empty
Text GLabel 11900 8250 2    98   Output ~ 0
INFO_buff_full
Text GLabel 11900 8650 2    98   Output ~ 0
INFO_buff_empty
$Comp
L modulos:FIFO_BRAM_SYNC U?
U 1 1 5C769FC4
P 7150 7250
F 0 "U?" H 7400 8550 59  0001 C CNN
F 1 "FIFO_BRAM_SYNC" H 7150 8950 79  0001 C CNN
F 2 "" H 7150 7250 59  0001 C CNN
F 3 "" H 7150 7250 59  0001 C CNN
F 4 "8bits" H 7150 8650 59  0001 C CNN "DATA_WIDTH"
F 5 "1BRAM" H 7150 8550 59  0001 C CNN "FIFO_SIZE_ML"
F 6 "Almost_full >= 90%" H 7150 8750 39  0001 C CNN "ALMOST_FULL"
F 7 "Almost_empty <= 10%" H 7150 8850 39  0001 C CNN "ALMOST_EMPTY"
F 8 "INFO_BUFF" H 7150 8450 50  0000 C CNN "name"
	1    7150 7250
	1    0    0    -1  
$EndComp
$Comp
L modulos:FIFO_BRAM_SYNC U?
U 1 1 5C76A00A
P 9300 7250
F 0 "U?" H 9550 8550 59  0001 C CNN
F 1 "FIFO_BRAM_SYNC" H 9300 8950 79  0001 C CNN
F 2 "" H 9300 7250 59  0001 C CNN
F 3 "" H 9300 7250 59  0001 C CNN
F 4 "8bits" H 9300 8650 59  0001 C CNN "DATA_WIDTH"
F 5 "1BRAM" H 9300 8550 59  0001 C CNN "FIFO_SIZE_ML"
F 6 "Almost_full >= 90%" H 9300 8750 39  0001 C CNN "ALMOST_FULL"
F 7 "Almost_empty <= 10%" H 9300 8850 39  0001 C CNN "ALMOST_EMPTY"
F 8 "DATA_BUFF" H 9300 8450 50  0000 C CNN "name"
	1    9300 7250
	1    0    0    -1  
$EndComp
$Comp
L modulos:states_machine_ulpi_recv U?
U 1 1 5C76B603
P 7250 5500
F 0 "U?" H 7250 8100 59  0001 C CNN
F 1 "states_machine_ulpi_recv" H 7250 8100 59  0001 C CNN
F 2 "" H 7250 8100 59  0001 C CNN
F 3 "" H 7250 8100 59  0001 C CNN
	1    7250 5500
	1    0    0    -1  
$EndComp
Text GLabel 4600 2250 0    98   Input ~ 0
rst
Text GLabel 4600 2500 0    98   Input ~ 0
clk_ULPI
Text GLabel 4600 7100 0    98   Input ~ 0
DATA_re
Text GLabel 4600 7350 0    98   Input ~ 0
INFO_re
Text GLabel 4600 5050 0    98   Input ~ 0
DIR
Text GLabel 4600 5300 0    98   Input ~ 0
NXT
Text GLabel 4600 5550 0    98   Input ~ 0
DATA_in[7:0]
Text GLabel 11900 4750 2    98   Output ~ 0
busy
Text GLabel 11900 5250 2    98   Output ~ 0
DATA_out[7:0]
Text GLabel 6800 8050 0    79   UnSpc ~ 0
16
Text GLabel 7000 8050 0    79   UnSpc ~ 0
2
Text GLabel 8950 8050 0    79   UnSpc ~ 0
8
Text GLabel 9150 8050 0    79   UnSpc ~ 0
4
Wire Wire Line
	6850 8050 6850 7950
Wire Wire Line
	7050 8050 7050 7950
Wire Wire Line
	9000 7950 9000 8050
Wire Wire Line
	9200 8050 9200 7950
NoConn ~ 9400 7950
NoConn ~ 9600 7950
NoConn ~ 7250 7950
NoConn ~ 7450 7950
NoConn ~ 9900 6800
NoConn ~ 9900 7150
NoConn ~ 7750 7150
NoConn ~ 7750 6800
Wire Wire Line
	6450 6450 6550 6450
Wire Wire Line
	6350 6350 6550 6350
Wire Wire Line
	8700 6450 8600 6450
Wire Wire Line
	8600 6450 8600 5900
Wire Wire Line
	8500 6000 8500 6350
Wire Wire Line
	8500 6350 8700 6350
Wire Wire Line
	6350 3050 6550 3050
Wire Wire Line
	6450 3150 6550 3150
Wire Wire Line
	8000 5050 8100 5050
Wire Wire Line
	6250 6600 6550 6600
Wire Wire Line
	8000 4800 8200 4800
Wire Wire Line
	8200 4800 8200 5700
Wire Wire Line
	8200 5700 6150 5700
Wire Wire Line
	6150 5700 6150 6750
Wire Wire Line
	6150 6750 6550 6750
Wire Wire Line
	8100 5050 8100 5800
Wire Wire Line
	8100 5800 6250 5800
Wire Wire Line
	6250 5800 6250 6600
Wire Wire Line
	8000 4950 8300 4950
Wire Wire Line
	8300 4950 8300 6600
Wire Wire Line
	6450 3150 6450 5900
Wire Wire Line
	6350 3050 6350 6000
Wire Wire Line
	8300 6600 8700 6600
Wire Wire Line
	6350 6000 8500 6000
Connection ~ 6350 6000
Wire Wire Line
	6350 6000 6350 6350
Wire Wire Line
	6450 5900 8600 5900
Connection ~ 6450 5900
Wire Wire Line
	6450 5900 6450 6450
Wire Wire Line
	8000 4700 8400 4700
Wire Wire Line
	8400 4700 8400 6750
Wire Wire Line
	8400 6750 8700 6750
Wire Wire Line
	7750 6700 8050 6700
Wire Wire Line
	8050 6700 8050 8250
Wire Wire Line
	7750 6950 7950 6950
Wire Wire Line
	7950 6950 7950 8450
Wire Wire Line
	7750 7050 7850 7050
Wire Wire Line
	7850 7050 7850 8650
Wire Wire Line
	9900 7050 10000 7050
Wire Wire Line
	10000 7050 10000 8000
Wire Wire Line
	9900 6950 10100 6950
Wire Wire Line
	10100 6950 10100 7800
Wire Wire Line
	9900 6700 10200 6700
Wire Wire Line
	10200 6700 10200 7600
NoConn ~ 8000 4550
$Comp
L modulos:and2_neg1 U?
U 1 1 5C77B8BD
P 5600 3850
F 0 "U?" H 5600 4300 59  0001 C CNN
F 1 "and2_neg1" H 5550 4200 59  0001 C CNN
F 2 "" H 5600 3850 59  0001 C CNN
F 3 "" H 5600 3850 59  0001 C CNN
	1    5600 3850
	1    0    0    -1  
$EndComp
$Comp
L modulos:and2 U?
U 1 1 5C77B964
P 5550 3450
F 0 "U?" H 5550 3850 59  0001 C CNN
F 1 "and2" H 5550 3800 59  0001 C CNN
F 2 "" H 5550 3450 59  0001 C CNN
F 3 "" H 5550 3450 59  0001 C CNN
	1    5550 3450
	1    0    0    -1  
$EndComp
Text GLabel 4600 2950 0    98   Input ~ 0
ReadAllow
Wire Wire Line
	6000 3300 6000 3450
Wire Wire Line
	6000 3450 6550 3450
Wire Wire Line
	5900 3300 6000 3300
Wire Wire Line
	5900 3700 6000 3700
Wire Wire Line
	6000 3700 6000 3550
Wire Wire Line
	6000 3550 6550 3550
Wire Wire Line
	4600 5300 5200 5300
Wire Wire Line
	4600 5050 5100 5050
Wire Wire Line
	5300 5050 5300 5200
Wire Wire Line
	5300 5200 6550 5200
Wire Wire Line
	4600 5550 5300 5550
Wire Wire Line
	5300 5550 5300 5400
Wire Wire Line
	5300 5400 6550 5400
Wire Wire Line
	5300 3800 5200 3800
Wire Wire Line
	5200 3800 5200 5300
Connection ~ 5200 5300
Wire Wire Line
	5200 5300 6550 5300
Wire Wire Line
	5200 3800 5200 3400
Wire Wire Line
	5200 3400 5300 3400
Connection ~ 5200 3800
Wire Wire Line
	5300 3200 5100 3200
Connection ~ 5100 5050
Wire Wire Line
	5100 5050 5300 5050
Wire Wire Line
	5300 3600 5100 3600
Wire Wire Line
	5100 3200 5100 3600
Connection ~ 5100 3600
Wire Wire Line
	5100 3600 5100 5050
Wire Wire Line
	6550 7100 4600 7100
Wire Wire Line
	4600 2950 6250 2950
Wire Wire Line
	6250 2950 6250 3300
Wire Wire Line
	6250 3300 6550 3300
Wire Wire Line
	4600 2500 6450 2500
Wire Wire Line
	6450 2500 6450 3150
Connection ~ 6450 3150
Wire Wire Line
	6350 2250 6350 3050
Connection ~ 6350 3050
Wire Wire Line
	4600 2250 6350 2250
$Comp
L 74xx:74LS04 U?
U 1 1 5C79F51C
P 11050 4750
F 0 "U?" H 11050 4975 50  0001 C CNN
F 1 "74LS04" H 11050 4976 50  0001 C CNN
F 2 "" H 11050 4750 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 11050 4750 50  0001 C CNN
	1    11050 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	7850 8650 11900 8650
Wire Wire Line
	11900 8000 10000 8000
Wire Wire Line
	11900 7800 10100 7800
Wire Wire Line
	11900 7600 10200 7600
Wire Wire Line
	8050 8250 11900 8250
Wire Wire Line
	7950 8450 11900 8450
Wire Wire Line
	8000 4300 11900 4300
Wire Wire Line
	8000 4200 10900 4200
Wire Wire Line
	10900 4200 10900 4100
Wire Wire Line
	10900 4100 11900 4100
Wire Wire Line
	8000 4100 10800 4100
Wire Wire Line
	10800 3900 11900 3900
Wire Wire Line
	10800 3900 10800 4100
Wire Wire Line
	8000 4000 10700 4000
Wire Wire Line
	10700 4000 10700 3700
Wire Wire Line
	10700 3700 11900 3700
Wire Wire Line
	8000 3900 10600 3900
Wire Wire Line
	10600 3900 10600 3500
Wire Wire Line
	10600 3500 11900 3500
Wire Wire Line
	8000 3800 10500 3800
Wire Wire Line
	10500 3800 10500 3300
Wire Wire Line
	10500 3300 11900 3300
Wire Wire Line
	8000 3700 10400 3700
Wire Wire Line
	10400 3700 10400 3100
Wire Wire Line
	10400 3100 11900 3100
Wire Wire Line
	11350 4750 11900 4750
Wire Wire Line
	8000 4450 10400 4450
Wire Wire Line
	10400 4450 10400 4750
Wire Wire Line
	10400 4750 10750 4750
Text GLabel 11900 5500 2    98   Output ~ 0
STP
Wire Wire Line
	11900 5250 8000 5250
Wire Wire Line
	8000 5350 10400 5350
Wire Wire Line
	10400 5350 10400 5500
Wire Wire Line
	10400 5500 11900 5500
Wire Wire Line
	4600 7350 6050 7350
Wire Wire Line
	6050 7350 6050 8750
Wire Wire Line
	6050 8750 8600 8750
Wire Wire Line
	8600 8750 8600 7100
Wire Wire Line
	8600 7100 8700 7100
Wire Notes Line
	11700 8900 11700 2050
Wire Notes Line
	11700 2050 4800 2050
Wire Notes Line
	4800 2050 4800 8900
Wire Notes Line
	4800 8900 11700 8900
Text Notes 4800 2000 0    118  ~ 0
ULPI_RECV
Text Label 6500 5400 0    59   Italic 0
[8]
Text Label 5150 2250 2    59   Italic 0
rst
Text Label 5150 2500 2    59   Italic 0
60MHz
Text Label 5000 5550 2    59   Italic 0
[8]
Text Label 8050 5250 2    59   Italic 0
[8]
Text Label 11650 5250 2    59   Italic 0
[8]
Text Label 11650 3100 2    59   Italic 0
[8]
Text Label 11650 3300 2    59   Italic 0
[2]
Text Label 11650 3500 2    59   Italic 0
[2]
Text Label 11650 8450 2    59   Italic 0
[16]
Text Label 11650 7800 2    59   Italic 0
[8]
Text Label 6450 6600 0    59   Italic 0
[16]
Text Label 8650 6600 0    59   Italic 0
[8]
Text Label 7850 6950 2    59   Italic 0
[16]
Text Label 9950 6950 2    59   Italic 0
[8]
Text Label 8050 4950 2    59   Italic 0
[8]
Text Label 8100 5050 2    59   Italic 0
[16]
Text Label 8050 3700 2    59   Italic 0
[8]
Text Label 8050 3800 2    59   Italic 0
[2]
Text Label 8050 3900 2    59   Italic 0
[2]
Wire Wire Line
	6800 8050 6850 8050
Wire Wire Line
	7000 8050 7050 8050
Wire Wire Line
	8950 8050 9000 8050
Wire Wire Line
	9150 8050 9200 8050
$EndSCHEMATC
