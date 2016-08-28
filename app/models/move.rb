class Move
  def self.execute(id, battle, owner, enemy)
    action = getMove(id)
    # owner.ap -= action.ap
    # # Early exist if there's not enough ap for this move
    # if(owner.ap < 0)
    #   owner.ap += action.ap
    #   return false
    # end
    allowed = battle.check_triggers(action, owner, enemy)
    if(allowed)
      if(action.types.include?(:attack))
        enemy.hp -= action.damage
      end
      action.try(:special).try(:call, owner, enemy)
    end
    owner.save!
  end

  def self.getMove(id)
    return @@all[id]
    raise "#{id} is an Invalid move ID"
  end

  @@all = {
    attack: OpenStruct.new(
      name: 'Attack',
      types: [:attack],
      ap: 3,
      damage: 5
    ),
    wait: OpenStruct.new(
      name: 'Wait',
      types: [:action],
      ap: 1
    ),
    juke: OpenStruct.new(
      name: 'Juke',
      types: [:hidden, :temporary, :trap],
      ap: 3,
      special: lambda do |owner, enemy|
      end,
      trigger: lambda do |owner, enemy, attack|
      end,
      expire: lambda do |owner, enemy, attack|
      end
    ),
    shake_off: OpenStruct.new(
      name: 'Shake Off',
      types: [:action],
      ap: 3,
      special: lambda do |owner, enemy|
      end
    )
  }
end
