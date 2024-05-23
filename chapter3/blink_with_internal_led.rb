require 'internal_led'
internal_led = InternalLED.new
loop do
  internal_led.flip
  sleep 1
end
