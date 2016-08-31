class Move
  def self.execute(id, battle, owner, enemy)
    p "execute move"
    action = getMove(id.to_sym)

    owner.time_units -= action.time_units
    # Early exist if there's not enough time_units for this move
    if(owner.time_units < 0)
      owner.time_units += action.time_units
      return false
    end
    battle.add_display_update(owner, :time_units, owner.time_units)

    allowed = battle.check_triggers(action, owner, enemy)
    if(allowed)
      if(action.types.include?(:hidden))
        battle.add_text("#{owner.name} has prepared a hidden technique.")
        battle.add_text("#{owner.name} has prepared a hidden technique.")
      else
        battle.add_text("#{owner.name} uses #{action.name}")
        battle.add_text("#{owner.name} uses #{action.name}")
      end

      if(action.types.include?(:attack))
        enemy.health -= action.damage
        battle.add_display_update(enemy, :health, enemy.health)
        battle.add_text("#{enemy.name} takes #{action.damage} damage from the attack!")
      end
      action.try(:special).try(:call, battle, owner, enemy)
    end

    owner.save!
    enemy.save!
    battle.save!
    battle.request_update
  end

  def self.getMove(id)
    if(move = @@all[id])
      return move
    else
      raise "#{id} is an Invalid move ID"
    end
  end

  @@all = {
    attack: OpenStruct.new(
      name: 'Attack',
      types: [:attack],
      time_units: 3,
      damage: 5
    ),
    wait: OpenStruct.new(
      name: 'Wait',
      types: [:action],
      time_units: 1
    ),
    juke: OpenStruct.new(
      name: 'Juke',
      types: [:hidden, :temporary, :trtime_units],
      time_units: 3,
      special: lambda do |battle, owner, enemy|
      end,
      trigger: lambda do |battle, owner, enemy, attack|
      end,
      expire: lambda do |battle, owner, enemy, attack|
      end
    ),
    shake_off: OpenStruct.new(
      name: 'Shake Off',
      types: [:action],
      time_units: 3,
      special: lambda do |battle, owner, enemy|
        battle.add_text("#{owner.name} has shaken off a debuff.")
      end
    )
  }
end
