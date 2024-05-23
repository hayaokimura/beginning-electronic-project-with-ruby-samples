require 'adc'
require 'pwm'

class JoyStick
  MAX_VOLTAGE = 3.3
  MIN_VOLTAGE = 0.0
  NEUTRAL_VOLTAGE = 1.50
  NEUTRAL_THRESHOLD = 0.05

  def initialize
    @adc = ADC.new(26)
  end

  # return: 100 ~ -100
  def duty
    voltage = @adc.read
    if voltage <= NEUTRAL_VOLTAGE + NEUTRAL_THRESHOLD && voltage > NEUTRAL_VOLTAGE - NEUTRAL_THRESHOLD
      0
    elsif voltage > NEUTRAL_VOLTAGE + NEUTRAL_THRESHOLD
      (voltage - NEUTRAL_VOLTAGE)*2/MAX_VOLTAGE * 40 + 60
    else
      (voltage - NEUTRAL_VOLTAGE)/NEUTRAL_VOLTAGE * 40 - 60
    end
  end
end

class Motor
  def initialize
    @output_positive = PWM.new(17, frequency: 100000, duty: 0)
    @output_negative = PWM.new(16, frequency: 100000, duty: 0)
  end

  def update_duty(duty)
    if duty >= 0
      @output_positive.duty(duty)
      @output_negative.duty(0)
    else
      @output_positive.duty(0)
      @output_negative.duty(-duty)
    end
  end
end

joy_stick = JoyStick.new
motor = Motor.new

loop do
  duty = joy_stick.duty
  puts duty
  motor.update_duty(duty)
end
