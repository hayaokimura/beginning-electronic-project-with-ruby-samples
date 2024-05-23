require 'pwm'
require 'uart'

class Motor
  def initialize(positive_pin:, negative_pin:)
    @output_positive = PWM.new(positive_pin, frequency: 100000, duty: 0)
    @output_negative = PWM.new(negative_pin, frequency: 100000, duty: 0)
  end

  def update_duty(duty)
    if duty >= 0
      @output_positive.duty(duty > 100 ? 100 : duty)
      @output_negative.duty(0)
    else
      @output_positive.duty(0)
      @output_negative.duty(-duty > 100 ? 100 : -duty)
    end
  end
end

class Twelite
  def initialize(uart:)
    @uart = uart
    @line = ''
  end

  def get_message
    return unless c = @uart.read(1)
    if c != "\x0a"
      @line << c
      return
    end
    return unless @line
    line = @line.chomp
    @line = ''
    line = line[1,line.length -1]
    return unless line.length == 14 || line[0,4].to_i(16) == 1
    line[4,8]
  end
end

class Receiver
  attr_reader :vertical_voltage, :horizontal_voltage
  def initialize
    @twelite = Twelite.new(uart: UART.new(unit: :RP2040_UART0, txd_pin: 0, rxd_pin: 1, baudrate: 115200))
    @line = ''
    @vertical_voltage = nil
    @horizontal_voltage = nil
  end

  def receive_message
    message = @twelite.get_message
    return unless message
    @vertical_voltage = message[0,4].to_i(16).to_f / 1000
    @horizontal_voltage = message[4,4].to_i(16).to_f / 1000
  end
end

class Car
  MAX_VOLTAGE = 3.3
  NEUTRAL_VOLTAGE = 1.5
  NEUTRAL_RANGE = 0.05

  def initialize
    @right_motor = Motor.new(positive_pin: 5, negative_pin: 6)
    @left_motor = Motor.new(positive_pin: 7, negative_pin: 8)
    @receiver = Receiver.new
    @right_duty = 0
    @left_duty = 0
  end

  def start!
    loop do
      update
    end
  end

  def update
    next unless @receiver.receive_message
    next unless @receiver.vertical_voltage && @receiver.horizontal_voltage
    calculate_duty
    @left_motor.update_duty(@left_duty)
    @right_motor.update_duty(@right_duty)
  end

  def calculate_duty
    vertical_normalized_voltage = @receiver.vertical_voltage - NEUTRAL_VOLTAGE
    horizontal_normalized_voltage = @receiver.horizontal_voltage - NEUTRAL_VOLTAGE

    if vertical_normalized_voltage > NEUTRAL_RANGE
      @right_duty = (vertical_normalized_voltage + horizontal_normalized_voltage)/MAX_VOLTAGE*2 * 40 + 60
      @left_duty = (vertical_normalized_voltage - horizontal_normalized_voltage)/MAX_VOLTAGE*2 * 40 + 60
    elsif vertical_normalized_voltage < (-NEUTRAL_RANGE)
      @right_duty = (vertical_normalized_voltage - horizontal_normalized_voltage)/MAX_VOLTAGE*2 * 40 - 60
      @left_duty = (vertical_normalized_voltage + horizontal_normalized_voltage)/MAX_VOLTAGE*2 * 40 - 60
    else
      @right_duty = 0
      @left_duty = 0
    end
  end
end

Car.new.start!
