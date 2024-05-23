pin = GPIO.new(25, GPIO::OUT)
loop do
  pin.write 1
  sleep 1
  pin.write 0
  sleep 1
end
