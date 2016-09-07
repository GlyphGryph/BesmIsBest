class TimeUnit
  @multiplier = 12
  @max = 5

  def self.multiplier
    @multiplier
  end

  def self.max
    @max
  end

  def self.multiplied(value)
    value * @multiplier
  end

  def self.reduced(value)
    value / @multiplier
  end
end
