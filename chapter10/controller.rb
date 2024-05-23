require 'uart'
require 'adc'

class JoyStick
  def initialize(vertical_pin:, horizontal_pin:)
    @adc_vertical = ADC.new(vertical_pin)
    @adc_holizontal = ADC.new(horizontal_pin)
  end

  # return: 0V ~ 3.3V
  def vertical_voltage
    @adc_vertical.read
  end

  # return: 0V ~ 3.3V
  def horizontal_voltage
    @adc_holizontal.read
  end
end

class Twelite
  MESSAGE_PREFIX = ":7801"
  MESSAGE_SUFFIX = "X\r\n"

  def initialize(uart:)
    @uart = uart
  end

  def send(message)
    @uart.write MESSAGE_PREFIX + message + MESSAGE_SUFFIX
  end
end

class Controller
  def initialize
    @joy_stick = JoyStick.new(vertical_pin: 26, horizontal_pin: 27)
    @twelite = Twelite.new(uart: UART.new(unit: :RP2040_UART0, txd_pin: 0, rxd_pin: 1, baudrate: 115200))
  end

  def start!
    loop do
      vertical = normalize_voltage(@joy_stick.vertical_voltage)
      horizontal = normalize_voltage(@joy_stick.horizontal_voltage)
      @twelite.send vertical + horizontal
      sleep 0.05
    end
  end

  def normalize_voltage(voltage)
    voltage_s = (voltage * 1000).to_i.to_s(16).upcase
    voltage_s.length < 4 ? ("0" * (4 - voltage_s.length)) + voltage_s : voltage_s
  end
end

controller = Controller.new
controller.start!
