require 'uart'

class Receiver
  def initialize
    @uart = UART.new(unit: :RP2040_UART0, txd_pin: 0, rxd_pin: 1, baudrate: 115200)
    @line = ''
  end

  def get_message
    c = @uart.read(1)
    return nil unless c
    if c != "\x0a"
      @line << c
      return nil
    end
    return nil unless @line
    line = @line.chomp
    @line = ''
    line = line[1,line.length -1]
    return nil unless line.length == 14 || line[0,4].to_i(16) == 1

    # puts 'line:' + line
    line
  end
end

receiver = Receiver.new

loop do
  message = receiver.get_message
  puts message if message
end
