# Analizador USB

Trabajo Fin de Grado (TFG) de Mario Rubio para la Universidad de Castilla-La-Mancha (UCLM). 2018.
___
Sistema de monitorización pasivo del trafico existente en un bus USB (Tanto low speed como full speed) para su posterior o en vivo analisis.

Consta de los siguientes componentes:

* Una FPGA del fabricante Lattice, modelo ICE40HX-1k. Montada sobre la placa de desarrollo ICEStick con FTDI FT2232H configurado como UART y SPI.
* Modulo USB con integrado USB3300 que convierte USB2.0 a protocolo ULPI.

___

* __26/03/2018__ - _Reestructuración y nuevo punto de partida_
* __12/04/2018__ - _Añadida prueba de 60MHz externos en la placa ICEstick_
* __01/10/2018__ - _Multitud de cambios y añadidos [Por no haber ido actulizando esta lista de cámbios, no puedo especificar 🙁]_
* __01/10/2018__ - _Añadido módulo SPI (SPI\_COMM) que comunique el PC con la FPGA [V1]. TB incluido._