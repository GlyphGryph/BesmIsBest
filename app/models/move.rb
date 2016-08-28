class Move
  def self.execute(id, battle, owner, enemy)
    action = getMove(id.to_sym)
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
      special: lambda do |battle, owner, enemy|
        battle.add_text("#{owner.name} has prepared a hidden technique.")
      end,
      trigger: lambda do |battle, owner, enemy, attack|
      end,
      expire: lambda do |battle, owner, enemy, attack|
      end
    ),
    shake_off: OpenStruct.new(
      name: 'Shake Off',
      types: [:action],
      ap: 3,
      special: lambda do |battle, owner, enemy|
        battle.add_text("#{owner.name} has shaken off a debuff.")
      end
    )
  }
end
