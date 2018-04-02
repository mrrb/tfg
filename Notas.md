# Notas
*[30/03/2018]*
  * No vale I2s como entrada de reloj ya que ESP32 solo soporta hasta 40MHz de reloj máximo. *[19:37]*
  * Parece que a 60MHz, FREERTOS+ESP32 no soporta interrupts. *[19:37]*
  * Creo que es buena idea que reescriba parte del codigo teneiendo en cuenta lo anterior. *[19:37]*

*[31/03/2018]*
  * Borrón y cuenta nueva ;( *[17:35]*
  * Primero voy a hacer los exencial -> MainApp+USB3300+UART *[17:40]*

*[01/04/2018]*
  * Voy a mirar lo que tarda en leer un valor con la función gpio_get_level(...) y con la lectura directa de registro. *[18:03]*

*[02/04/2018]*
  * La configuración del SDK estaba a 160MHz 😭, la he cambido a 240MHz, en vez de utilizar gpio_get_level(), utilizaré acceso directo a registro para mejorar algo mas la velocidad de lectura ≅ 80% de mejora según resultdo de tests/speeds.c *[12:21]*