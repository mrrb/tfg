# Notas
*[30/03/2018]*
  * No vale I2s como entrada de reloj ya que ESP32 solo soporta hasta 40MHz de reloj máximo.
  * Parece que a 60MHz, FREERTOS+ESP32 no soporta interrupts.
  * Creo que es buena idea que reescriba parte del codigo teneiendo en cuenta lo anterior.
