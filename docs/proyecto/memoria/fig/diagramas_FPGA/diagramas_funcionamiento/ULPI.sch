EESchema Schematic File Version 4
LIBS:diagramas_funcionamiento-cache
EELAYER 26 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 3 9
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
S 700  700  1050 250 
U 5C769474
F0 "ULPI_REG_WRITE" 79
F1 "ULPI_REG_WRITE.sch" 79
$EndSheet
$Sheet
S 700  1250 1050 250 
U 5C769477
F0 "ULPI_REG_READ" 79
F1 "ULPI_REG_READ.sch" 79
$EndSheet
$Sheet
S 700  1750 1050 250 
U 5C76947A
F0 "ULPI_RECV" 79
F1 "ULPI_RECV.sch" 79
$EndSheet
$Comp
L modulos:ULPI_RECV U?
U 1 1 5C76CA70
P 6900 8100
F 0 "U?" H 6900 10550 79  0001 C CNN
F 1 "ULPI_RECV" H 6900 10450 79  0001 C CNN
F 2 "" H 9000 9400 79  0001 C CNN
F 3 "" H 9000 9400 79  0001 C CNN
F 4 "ULPI_RV" H 6900 10550 50  0000 C CNN "name"
	1    6900 8100
	1    0    0    -1  
$EndComp
$Comp
L modulos:ULPI_REG_READ U?
U 1 1 5C76CAED
P 6650 5300
F 0 "U?" H 6650 6550 79  0001 C CNN
F 1 "ULPI_REG_READ" H 6650 6450 79  0001 C CNN
F 2 "" H 6700 5200 79  0001 C CNN
F 3 "" H 6700 5200 79  0001 C CNN
F 4 "ULPI_RR" H 6650 6450 50  0000 C CNN "name"
	1    6650 5300
	1    0    0    -1  
$EndComp
$Comp
L modulos:ULPI_REG_WRITE U?
U 1 1 5C76CB7F
P 6700 3800
F 0 "U?" H 6700 5100 79  0001 C CNN
F 1 "ULPI_REG_WRITE" H 6700 5100 79  0001 C CNN
F 2 "" H 6700 5100 79  0001 C CNN
F 3 "" H 6700 5100 79  0001 C CNN
F 4 "ULPI_RW" H 6700 5050 50  0000 C CNN "name"
	1    6700 3800
	1    0    0    -1  
$EndComp
$Comp
L modulos:states_machine_ulpi U?
U 1 1 5C76CC18
P 9650 3750
F 0 "U?" H 9650 5100 79  0001 C CNN
F 1 "states_machine_ulpi" H 9650 5000 79  0001 C CNN
F 2 "" H 9600 3750 79  0001 C CNN
F 3 "" H 9600 3750 79  0001 C CNN
	1    9650 3750
	1    0    0    -1  
$EndComp
Text GLabel 3850 1850 0    98   Input ~ 0
rst
Text GLabel 3850 2100 0    98   Input ~ 0
clk_ice
Text GLabel 3850 2350 0    98   Input ~ 0
clk_ULPI
Text GLabel 3850 5600 0    98   Input ~ 0
PrW
Text GLabel 3850 5850 0    98   Input ~ 0
PrR
Text GLabel 3850 3250 0    98   Input ~ 0
ADDR[5:0]
Text GLabel 3850 7350 0    98   Input ~ 0
DATA_re
Text GLabel 3850 7600 0    98   Input ~ 0
INFO_re
Text GLabel 3850 8550 0    98   Input ~ 0
DIR
Text GLabel 3850 8800 0    98   Input ~ 0
NXT
Text GLabel 3850 9050 0    98   Input ~ 0
DATA_in[7:0]
Text GLabel 12350 2900 2    98   Output ~ 0
status[1:0]
Text GLabel 12350 3300 2    98   Output ~ 0
busy
Text GLabel 12350 5900 2    98   Output ~ 0
REG_VAL_R[7:0]
Text GLabel 3850 3500 0    98   Input ~ 0
REG_VAL_W[7:0]
Text GLabel 12350 6350 2    98   Output ~ 0
RxCMD[7:0]
Text GLabel 12350 6550 2    98   Output ~ 0
RxLineState[1:0]
Text GLabel 12350 6750 2    98   Output ~ 0
RxVbusState[1:0]
Text GLabel 12350 6950 2    98   Output ~ 0
RxActive
Text GLabel 12350 7150 2    98   Output ~ 0
RxError
Text GLabel 12350 7350 2    98   Output ~ 0
RxHostDisconnect
Text GLabel 12350 7550 2    98   Output ~ 0
RxID
Text GLabel 12350 8050 2    98   Output ~ 0
USB_DATA[7:0]
Text GLabel 12350 8250 2    98   Output ~ 0
USB_INFO_DATA[15:0]
Text GLabel 12350 8450 2    98   Output ~ 0
DATA_buff_full
Text GLabel 12350 8650 2    98   Output ~ 0
DATA_buff_empty
Text GLabel 12350 8850 2    98   Output ~ 0
INFO_buff_full
Text GLabel 12350 9050 2    98   Output ~ 0
INFO_buff_empty
Text GLabel 12350 4200 2    98   Output ~ 0
DATA_out[7:0]
Text GLabel 12350 5400 2    98   Output ~ 0
STP[7:0]
Text GLabel 12350 1850 2    98   Output ~ 0
U_RST
Wire Wire Line
	3850 2350 6000 2350
Wire Wire Line
	3850 1850 6100 1850
Wire Wire Line
	6200 2850 6100 2850
Wire Wire Line
	6100 2850 6100 1850
Connection ~ 6100 1850
Wire Wire Line
	6200 2950 6000 2950
Wire Wire Line
	6000 2950 6000 2350
Connection ~ 6000 2350
Wire Wire Line
	6200 4450 6100 4450
Wire Wire Line
	6100 4450 6100 2850
Connection ~ 6100 2850
Wire Wire Line
	6200 4550 6000 4550
Wire Wire Line
	6000 4550 6000 2950
Connection ~ 6000 2950
Wire Wire Line
	6200 5950 6100 5950
Wire Wire Line
	6100 5950 6100 4450
Connection ~ 6100 4450
Wire Wire Line
	6200 6050 6000 6050
Wire Wire Line
	6000 6050 6000 4550
Connection ~ 6000 4550
$Comp
L modulos:and3_neg1 U?
U 1 1 5C76EF8C
P 4450 5100
F 0 "U?" H 4450 5650 98  0001 C CNN
F 1 "and3_neg1" H 4450 5500 98  0001 C CNN
F 2 "" H 4400 5100 98  0001 C CNN
F 3 "" H 4400 5100 98  0001 C CNN
	1    4450 5100
	0    -1   -1   0   
$EndComp
$Comp
L modulos:and3_neg1 U?
U 1 1 5C76EFAE
P 4950 5100
F 0 "U?" H 4950 5650 98  0001 C CNN
F 1 "and3_neg1" H 4950 5500 98  0001 C CNN
F 2 "" H 4900 5100 98  0001 C CNN
F 3 "" H 4900 5100 98  0001 C CNN
	1    4950 5100
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3850 9050 5800 9050
Wire Wire Line
	3850 8800 5700 8800
Wire Wire Line
	3850 8550 4400 8550
Wire Wire Line
	5800 8000 6200 8000
Wire Wire Line
	5700 7900 6200 7900
Wire Wire Line
	5600 7800 6200 7800
Wire Wire Line
	5600 7800 5600 8550
Wire Wire Line
	5800 8000 5800 9050
Wire Wire Line
	5700 7900 5700 8800
Wire Wire Line
	5800 8000 5800 5200
Wire Wire Line
	5800 5200 6200 5200
Connection ~ 5800 8000
Wire Wire Line
	5700 7900 5700 5100
Wire Wire Line
	5700 5100 6200 5100
Connection ~ 5700 7900
Wire Wire Line
	5600 7800 5600 5000
Wire Wire Line
	5600 5000 6200 5000
Connection ~ 5600 7800
Wire Wire Line
	6200 3500 5600 3500
Wire Wire Line
	5600 3500 5600 5000
Connection ~ 5600 5000
Wire Wire Line
	6200 3600 5700 3600
Wire Wire Line
	5700 3600 5700 5100
Connection ~ 5700 5100
Wire Wire Line
	6200 3700 5800 3700
Wire Wire Line
	5800 3700 5800 5200
Connection ~ 5800 5200
Wire Wire Line
	3850 3250 5300 3250
Wire Wire Line
	3850 3500 5400 3500
Wire Wire Line
	5400 3500 5400 3350
Wire Wire Line
	5400 3350 6200 3350
Wire Wire Line
	3850 7600 5400 7600
Wire Wire Line
	5400 7600 5400 7450
Wire Wire Line
	5400 7450 6200 7450
Wire Wire Line
	6200 7350 3850 7350
Wire Wire Line
	8950 2850 8850 2850
Wire Wire Line
	8850 2850 8850 1850
Wire Wire Line
	6100 1850 8850 1850
Wire Wire Line
	8950 2950 8750 2950
Wire Wire Line
	8750 2950 8750 2350
Wire Wire Line
	6000 2350 8750 2350
Wire Wire Line
	3850 5600 4200 5600
Wire Wire Line
	4200 5600 4200 5400
Wire Wire Line
	4700 5400 4700 5850
Wire Wire Line
	4700 5850 3850 5850
Wire Wire Line
	4800 4800 4800 4700
Wire Wire Line
	4800 4700 6200 4700
Wire Wire Line
	5300 3250 5300 4850
Wire Wire Line
	5300 4850 6200 4850
Connection ~ 5300 3250
Wire Wire Line
	5300 3250 6200 3250
Wire Wire Line
	4400 5400 4400 6050
Connection ~ 4400 8550
Wire Wire Line
	4400 8550 5600 8550
Wire Wire Line
	4300 5400 4300 5500
Wire Wire Line
	4300 5500 4800 5500
Wire Wire Line
	4800 5400 4800 5500
Connection ~ 4800 5500
Wire Wire Line
	4800 5500 5900 5500
Wire Wire Line
	4300 4800 4300 4600
Wire Wire Line
	4900 5400 4900 6050
Wire Wire Line
	4900 6050 4400 6050
Connection ~ 4400 6050
Wire Wire Line
	4400 6050 4400 8550
Wire Wire Line
	5600 8550 8750 8550
Wire Wire Line
	8750 8550 8750 3150
Wire Wire Line
	8750 3150 8950 3150
Connection ~ 5600 8550
Wire Wire Line
	7200 3100 8350 3100
Wire Wire Line
	7100 4700 8450 4700
Wire Wire Line
	8450 4700 8450 3350
Wire Wire Line
	8450 3350 8950 3350
Wire Wire Line
	7600 6200 8550 6200
Wire Wire Line
	8550 6200 8550 3450
Wire Wire Line
	8550 3450 8950 3450
Wire Wire Line
	8350 3250 8350 3100
Wire Wire Line
	8350 3250 8950 3250
Wire Wire Line
	4300 4600 4700 4600
Wire Wire Line
	4700 3100 6200 3100
Wire Wire Line
	8250 3650 8950 3650
Connection ~ 4800 4700
Wire Wire Line
	8150 3550 8950 3550
$Comp
L 74xx:74LS04 U?
U 1 1 5C7A0EDC
P 11800 1850
F 0 "U?" H 11800 2075 50  0001 C CNN
F 1 "74LS04" H 11800 2076 50  0001 C CNN
F 2 "" H 11800 1850 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 11800 1850 50  0001 C CNN
	1    11800 1850
	1    0    0    -1  
$EndComp
$Comp
L modulos:MUX_3_1 U?
U 1 1 5C7A4067
P 10750 5700
F 0 "U?" H 10750 5450 98  0001 C CNN
F 1 "MUX_3_1" H 10750 5600 98  0001 C CNN
F 2 "" H 10750 5700 98  0001 C CNN
F 3 "" H 10750 5700 98  0001 C CNN
	1    10750 5700
	1    0    0    -1  
$EndComp
$Comp
L modulos:MUX_3_1 U?
U 1 1 5C7A4089
P 10750 4500
F 0 "U?" H 10750 4250 98  0001 C CNN
F 1 "MUX_3_1" H 10750 4400 98  0001 C CNN
F 2 "" H 10750 4500 98  0001 C CNN
F 3 "" H 10750 4500 98  0001 C CNN
	1    10750 4500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6200 6200 5900 6200
Wire Wire Line
	7600 7600 8950 7600
Wire Wire Line
	7600 7500 9050 7500
Wire Wire Line
	7600 7400 9150 7400
Wire Wire Line
	7600 7300 9250 7300
Wire Wire Line
	7600 7200 9350 7200
Wire Wire Line
	7600 7100 9450 7100
Wire Wire Line
	8950 7600 8950 9050
Wire Wire Line
	9050 7500 9050 8850
Wire Wire Line
	9150 7400 9150 8650
Wire Wire Line
	9250 7300 9250 8450
Wire Wire Line
	9350 7200 9350 8250
Wire Wire Line
	9450 7100 9450 8050
Wire Wire Line
	7600 6950 9650 6950
Wire Wire Line
	9650 6950 9650 7550
Wire Wire Line
	7600 6850 9750 6850
Wire Wire Line
	7600 6750 9850 6750
Wire Wire Line
	7600 6650 9950 6650
Wire Wire Line
	7600 6550 10050 6550
Wire Wire Line
	7600 6450 10150 6450
Wire Wire Line
	9750 6850 9750 7350
Wire Wire Line
	9850 6750 9850 7150
Wire Wire Line
	9950 6650 9950 6950
Wire Wire Line
	10050 6550 10050 6750
Wire Wire Line
	10150 6450 10150 6550
Connection ~ 5900 5500
Wire Wire Line
	5900 5500 7800 5500
Wire Wire Line
	5900 5500 5900 6200
Wire Wire Line
	4700 3100 4700 3900
Wire Wire Line
	4700 3900 8150 3900
Connection ~ 4700 3900
Wire Wire Line
	4700 3900 4700 4600
Wire Wire Line
	8150 3900 8150 3550
Wire Wire Line
	4800 4000 4800 4700
Wire Wire Line
	8250 4000 8250 3650
Wire Wire Line
	4800 4000 8250 4000
Wire Wire Line
	10100 4450 10100 4100
Wire Wire Line
	10100 4100 10400 4100
Wire Wire Line
	10200 4650 10200 4200
Wire Wire Line
	10200 4200 10400 4200
Wire Wire Line
	10300 4850 10300 4300
Wire Wire Line
	10300 4300 10400 4300
Wire Wire Line
	10100 5300 10400 5300
Wire Wire Line
	10000 5400 10400 5400
Wire Wire Line
	9900 5500 10400 5500
Wire Wire Line
	10350 3400 10650 3400
Wire Wire Line
	10350 3500 10750 3500
Wire Wire Line
	10350 3600 10850 3600
Wire Wire Line
	10650 3700 10650 3400
Wire Wire Line
	10750 3700 10750 3500
Wire Wire Line
	10850 3700 10850 3600
Wire Wire Line
	7600 7800 8350 7800
Wire Wire Line
	8350 7800 8350 5250
Wire Wire Line
	7600 7900 8450 7900
Wire Wire Line
	8450 7900 8450 5350
Wire Wire Line
	7200 3650 7850 3650
Wire Wire Line
	7200 3550 7950 3550
Wire Wire Line
	7850 4950 7850 3650
Wire Wire Line
	7950 3550 7950 4850
Wire Wire Line
	9900 5350 9900 5500
Wire Wire Line
	8450 5350 9900 5350
Wire Wire Line
	10000 5150 10000 5400
Wire Wire Line
	7100 5150 10000 5150
Wire Wire Line
	10100 4950 10100 5300
Wire Wire Line
	7850 4950 10100 4950
Wire Wire Line
	9800 5250 9800 4850
Wire Wire Line
	9800 4850 10300 4850
Wire Wire Line
	8350 5250 9800 5250
Wire Wire Line
	9700 5050 9700 4650
Wire Wire Line
	9700 4650 10200 4650
Wire Wire Line
	7100 5050 9700 5050
Wire Wire Line
	9600 4850 9600 4450
Wire Wire Line
	9600 4450 10100 4450
Wire Wire Line
	7950 4850 9600 4850
Wire Wire Line
	10850 3600 11200 3600
Wire Wire Line
	11200 3600 11200 4800
Wire Wire Line
	11200 4800 10850 4800
Wire Wire Line
	10850 4800 10850 4900
Connection ~ 10850 3600
Wire Wire Line
	10750 3500 11300 3500
Wire Wire Line
	11300 3500 11300 4700
Wire Wire Line
	11300 4700 10750 4700
Wire Wire Line
	10750 4700 10750 4900
Connection ~ 10750 3500
Wire Wire Line
	10650 4900 10650 4600
Wire Wire Line
	10650 4600 11400 4600
Wire Wire Line
	11400 4600 11400 3400
Wire Wire Line
	11400 3400 10650 3400
Connection ~ 10650 3400
Wire Wire Line
	7800 5500 7800 5800
Wire Wire Line
	7800 5800 11500 5800
Wire Wire Line
	7700 4850 7700 5900
Wire Wire Line
	11500 5800 11500 3300
Wire Wire Line
	11500 3300 10350 3300
$Comp
L 74xx:74LS04 U?
U 1 1 5CB21171
P 11800 3300
F 0 "U?" H 11800 3525 50  0001 C CNN
F 1 "74LS04" H 11800 3526 50  0001 C CNN
F 2 "" H 11800 3300 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 11800 3300 50  0001 C CNN
	1    11800 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	12100 1850 12350 1850
Wire Wire Line
	11500 1850 8850 1850
Connection ~ 8850 1850
Wire Wire Line
	12350 2900 10350 2900
Wire Wire Line
	12100 3300 12350 3300
Wire Wire Line
	11100 4200 12350 4200
Wire Wire Line
	11100 5400 12350 5400
Wire Wire Line
	7700 5900 12350 5900
Wire Wire Line
	7600 6350 12350 6350
Wire Wire Line
	10150 6550 12350 6550
Wire Wire Line
	10050 6750 12350 6750
Wire Wire Line
	9950 6950 12350 6950
Wire Wire Line
	9850 7150 12350 7150
Wire Wire Line
	9750 7350 12350 7350
Wire Wire Line
	9650 7550 12350 7550
Wire Wire Line
	9450 8050 12350 8050
Wire Wire Line
	9350 8250 12350 8250
Wire Wire Line
	9250 8450 12350 8450
Wire Wire Line
	9150 8650 12350 8650
Wire Wire Line
	9050 8850 12350 8850
Wire Wire Line
	8950 9050 12350 9050
Wire Wire Line
	7100 4850 7700 4850
NoConn ~ 10350 3200
Wire Notes Line
	12200 9250 12200 1600
Wire Notes Line
	12200 1600 4000 1600
Wire Notes Line
	4000 1600 4000 9250
Wire Notes Line
	4000 9250 12200 9250
NoConn ~ 4400 2100
Text Notes 4000 1550 0    118  ~ 0
ULPI
Text Label 4250 3250 2    59   Italic 0
[6]
Text Label 4250 3500 2    59   Italic 0
[8]
Text Label 4250 9050 2    59   Italic 0
[8]
Text Label 4400 2100 2    59   Italic 0
12MHz
Wire Wire Line
	3850 2100 4400 2100
Text Label 4400 1850 2    59   Italic 0
rst
Text Label 4400 2350 2    59   Italic 0
60MHz
Text Label 6150 3250 0    59   Italic 0
[6]
Text Label 6150 3350 0    59   Italic 0
[8]
Text Label 6150 3700 0    59   Italic 0
[8]
Text Label 6150 4850 0    59   Italic 0
[6]
Text Label 6150 5200 0    59   Italic 0
[8]
Text Label 6150 8000 0    59   Italic 0
[8]
Text Label 10350 4100 0    59   Italic 0
[8]
Text Label 10350 4200 0    59   Italic 0
[8]
Text Label 10350 4300 0    59   Italic 0
[8]
Text Label 10350 5300 0    59   Italic 0
[8]
Text Label 10350 5400 0    59   Italic 0
[8]
Text Label 10350 5500 0    59   Italic 0
[8]
Text Label 12000 4200 0    59   Italic 0
[8]
Text Label 12000 5400 0    59   Italic 0
[8]
Text Label 12000 5900 0    59   Italic 0
[8]
Text Label 12000 2900 0    59   Italic 0
[2]
Text Label 12000 8050 0    59   Italic 0
[8]
Text Label 11950 8250 0    59   Italic 0
[16]
Text Label 7650 7800 2    59   Italic 0
[8]
Text Label 7650 7900 2    59   Italic 0
[8]
Text Label 7650 7100 2    59   Italic 0
[8]
Text Label 7700 7200 2    59   Italic 0
[16]
Text Label 7650 6350 2    59   Italic 0
[8]
Text Label 7650 6450 2    59   Italic 0
[2]
Text Label 7650 6550 2    59   Italic 0
[2]
Text Label 10400 2900 2    59   Italic 0
[2]
Text Label 11150 5400 2    59   Italic 0
[8]
Text Label 11150 4200 2    59   Italic 0
[8]
Text Label 12000 6350 0    59   Italic 0
[8]
Text Label 12000 6550 0    59   Italic 0
[2]
Text Label 12000 6750 0    59   Italic 0
[2]
Text Label 7150 5050 2    59   Italic 0
[8]
Text Label 7150 5150 2    59   Italic 0
[8]
Text Label 7150 4850 2    59   Italic 0
[8]
Text Label 7250 3550 2    59   Italic 0
[8]
Text Label 7250 3650 2    59   Italic 0
[8]
$EndSCHEMATC
