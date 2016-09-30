Move.new(
  id: :flurry,
  name: 'Flurry',
  types: [:attack],
  nature_id: :persistence,
  time_units: 2,
  damage: 1,
  description: 'Attack 5 times for 1 damage per attack.',
  repeats: 5
)
Move.new(
  id: :poison,
  name: 'Poison',
  types: [:special],
  nature_id: :persistence,
  time_units: 3,
  description: 'Causes POISONED debuff: Take 1 damage per tic.',
  special: lambda do |battle, owner, enemy|
    if(enemy.apply_debuff('poison'))
      battle.add_text("#{enemy.name} can barely keep it together.")
    else
      battle.add_text("#{enemy.name} could not be poisoned.")
    end
  end
)
Move.new(
  id: :relentless,
  name: 'Relentless Assault',
  types: [:attack, :special],
  nature_id: :persistence,
  time_units: 2,
  damage: 7,
  description: 'Deals 7 damage. You gain the LOCKED IN (Relentless Assault) debuff: You may not use any other ability, unless you cannot use this ability.',
  special: lambda do |battle, owner, enemy|
    if(owner.apply_debuff('locked_in', :relentless))
      battle.add_text("#{owner.name} cannot use any other move.")
    else
      battle.add_text("#{owner.name} cannot be locked in, or already is locked in.")
    end
  end
)
Move.new(
  id: :recover,
  name: 'Recover',
  types: [:special],
  nature_id: :persistence,
  time_units: 3,
  description: 'Regain 6 health.',
  special: lambda do |battle, owner, enemy|
    owner.heal(6)
  end
)
Move.new(
  id: :persevere,
  name: 'Persevere',
  types: [:special],
  nature_id: :persistence,
  time_units: 5,
  description: 'Regain full health, but reduce your maximum health by half for the remainder of the battle.',
  special: lambda do |battle, owner, enemy|
    owner.max_health = owner.max_health/2
    battle.add_display_update(owner, :max_health)
    if(owner.health > owner.max_health)
      owner.health = owner.max_health
    end
    owner.heal(100)
  end
)
Move.new(
  id: :conditioning,
  name: 'Conditioning',
  types: [:passive],
  nature_id: :persistence,
  description: 'Increases your maximum health by 10.',
)
