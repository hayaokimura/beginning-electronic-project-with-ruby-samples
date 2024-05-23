require 'adc'
adc = ADC.new(26)

loop do
  sleep 1
  puts adc.read
end
