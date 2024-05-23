require 'i2c'

class AHT25
  ADDRESS = 0x38

  def initialize(unit_name:, freq:, sda:, scl:)
    @i2c = I2C.new(unit: unit_name, frequency: freq, sda_pin: sda, scl_pin: scl)

    sleep 0.1
    if @i2c.read(ADDRESS, 0x01, [0x71]).bytes.first != 0x18
      puts "ATH25 module failed."
    end
  end

  def read_data
    sleep 0.01
    @i2c.write(ADDRESS, [0xAC, 0x33, 0x00])
    sleep 0.08
    @data = @i2c.read(ADDRESS, 0x07).bytes
  end

  def calc_temp
    temp_raw = ((@data[3] & 0x0F) << 16) | (@data[4] << 8) | @data[5]
    return ((temp_raw * 200) >> 20) - 50
  end

  def calc_hum
    hum_raw = (@data[1] << 12) | (@data[2] << 4) | ((@data[3] & 0xF0) >> 4)
    return ((hum_raw * 100) >> 20)
  end
end

aht25 = AHT25.new(unit_name: :RP2040_I2C1, freq: 100 * 1000, sda: 6, scl: 7)

loop do
  aht25.read_data
  puts("temp: #{aht25.calc_temp.to_s} C")
  puts("hum: #{aht25.calc_hum.to_s} %")
  sleep 1
end
