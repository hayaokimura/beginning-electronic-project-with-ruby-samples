require 'pwm'
require 'adc'

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

class Car
  MAX_VOLTAGE = 3.3
  NEUTRAL_VOLTAGE = 1.5
  NEUTRAL_RANGE = 0.05

  def initialize
    @right_motor = Motor.new(positive_pin: 17, negative_pin: 16)
    @left_motor = Motor.new(positive_pin: 19, negative_pin: 18)
    @joy_stick = JoyStick.new(vertical_pin: 26, horizontal_pin: 27)
    @right_duty = 0
    @left_duty = 0
  end

  def start!
    loop do
      update
    end
  end

  def update
    calculate_duty
    puts "left_duty: " + @left_duty.to_s
    puts "right_duty: " + @right_duty.to_s
    @left_motor.update_duty(@left_duty)
    @right_motor.update_duty(@right_duty)
  end

  def calculate_duty
    vertical_normalized_voltage = @joy_stick.vertical_voltage - NEUTRAL_VOLTAGE
    horizontal_normalized_voltage = @joy_stick.horizontal_voltage - NEUTRAL_VOLTAGE
    puts "vertical_normalized_voltage: " + vertical_normalized_voltage.to_s
    puts "horizontal_normalized_voltage: " + horizontal_normalized_voltage.to_s

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
