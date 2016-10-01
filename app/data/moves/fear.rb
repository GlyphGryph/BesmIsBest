Move.new(
  id: :intimidate,
  name: 'Intimidate',
  types: [:special, :debuff],
  nature_id: :fear,
  time_units: 0,
  description: 'Causes HESITANT: Lose a fourth of a time unit each tic',
  special: lambda do |battle, owner, enemy|
    if(enemy.apply_debuff('hesitant'))
      battle.add_text("#{enemy.name} has become hesitant to act!")
    else
      battle.add_text("#{enemy.name} could not be intimidated.")
    end
  end
)
Move.new(
  id: :terrify,
  name: 'Terrify',
  types: [:special, :debuff],
  nature_id: :fear,
  time_units: 3,
  description: 'Causes PANIC: Lose a half of a time unit each tic',
  special: lambda do |battle, owner, enemy|
    if(enemy.apply_debuff('panic'))
      battle.add_text("#{enemy.name} shakes with terror!")
    else
      battle.add_text("#{enemy.name} could not be terrified.")
    end
  end
)
Move.new(
  id: :doom,
  name: 'Doom',
  types: [:special, :debuff],
  nature_id: :fear,
  time_units: 2,
  description: 'Causes DESPAIR: Damage received is doubled.',
  special: lambda do |battle, owner, enemy|
    if(enemy.apply_debuff('despair'))
      battle.add_text("#{enemy.name} has lost all sense of self-preservation.")
    else
      battle.add_text("#{enemy.name} could not be doomed.")
    end
  end
)
Move.new(
  id: :painful_jab,
  name: 'Painful Jab',
  types: [:attack, :special, :debuff],
  nature_id: :fear,
  time_units: 2,
  description: 'In addition to dealing damage, causes HESITANT: Lose a fourth of a time unit each tic',
  damage: 2,
  special: lambda do |battle, owner, enemy|
    if(enemy.apply_debuff('hesitant'))
      battle.add_text("#{enemy.name} has become hesitant to act!")
    else
      battle.add_text("#{enemy.name} could not be made to fear the pain.")
    end
  end
)
Move.new(
  id: :hide,
  name: 'Hide',
  types: [:incomplete, :temporary, :hidden, :trap],
  nature_id: :fear,
  time_units: 5,
  description: 'Enemy attacks and debuffs miss, last until your next action',
  trigger: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :shroud,
  name: 'Shroud',
  types: [:buff, :special],
  nature_id: :fear,
  time_units: 0,
  description: 'Your health, time units, damage you take and your buffs and debuffs (except shroud) are not known by your opponent.',
  special: lambda do |battle, owner, enemy|
    if(owner.apply_buff('shrouded'))
      battle.add_text("#{owner.name} is acting from the shadows!")
    else
      battle.add_text("#{owner.name} could not be shrouded.")
    end
  end
)
Move.new(
  id: :cowardice,
  name: 'Cowardice',
  types: [:passive],
  nature_id: :fear,
  description: 'Switching this Eidolon out of battle is free.',
)
