require 'uart'

class Controller
  def initialize
    @uart = UART.new(unit: :RP2040_UART0, txd_pin: 0, rxd_pin: 1, baudrate: 115200)
  end

  def send
    send_message = ":7801" + "0001" + "0002" + "X\r\n"
    puts send_message
    @uart.write send_message
  end
end

controller = Controller.new

loop do
  controller.send
  sleep 0.05
end
