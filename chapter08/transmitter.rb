require 'uart'

uart = UART.new(unit: :RP2040_UART0, txd_pin: 0, rxd_pin: 1, baudrate: 115200)
loop do
  message = 'abcd'
  puts "send: " + message
  uart.write message
  sleep 0.1
end
