class Move
  def self.execute(id, me, them)
    @@all[id].call(me, them)
  end

  def self.getMove(id)
    return @@all[id]
    raise "#{id} is an Invalid move ID"
  end

  @@all = {
    attack: {
      name: 'Attack',
      types: [:hidden, :temporary],
      ap: 3,
      result: lambda do |me, them|
      end
    },
    wait: {
      name: 'Wait',
      types: [:hidden, :temporary],
      ap: 1,
      result: lambda do |me, them|
      end
    },
    juke: {
      name: 'Juke',
      types: [:hidden, :temporary],
      ap: 3,
      result: lambda do |me, them|
      end
    },
    shake_off: {
      name: 'Shake Off',
      types: [:hidden, :temporary],
      ap: 3,
      result: lambda do |me, them|
      end
    }
  }
end
