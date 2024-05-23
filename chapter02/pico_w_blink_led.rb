CYW43.init
pin = CYW43::GPIO.new(CYW43::GPIO::LED_PIN)
pin.write 1
pin.write 0
pin.write 1
pin.write 0
