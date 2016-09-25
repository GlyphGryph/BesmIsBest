Move.new(
  id: :reckless,
  name: 'Reckless Assault',
  types: [:incomplete, :attack, :temporary, :special, :debuff],
  nature_id: :passion,
  time_units: 5,
  description: 'Deal a large amount of damage, but until your next action gain RECKLESS: Receive double damage from all sources.',
  damage: 22,
  special: lambda do |battle, owner, enemy|
  end,
  expire: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :regenerate,
  name: 'Regenerate',
  types: [:special, :buff],
  nature_id: :passion,
  time_units: 2,
  description: 'Apply the REGENERATE buff: Regain 1 health per tic',
  special: lambda do |battle, owner, enemy|
    if(owner.apply_buff('regenerate'))
      battle.add_text("#{owner.name} has started healing!")
    else
      battle.add_text("#{owner.name} could not begin healing.")
    end
  end
)
Move.new(
  id: :overexert,
  name: 'Overexert',
  types: [:incomplete],
  nature_id: :passion,
  time_units: 2,
  description: 'Deal 10 damage, but take 5',
)
Move.new(
  id: :aggress,
  name: 'Aggress',
  types: [:incomplete],
  nature_id: :passion,
  time_units: 0,
  description: 'Select as many abilities as you have the time units to afford, and immediately use them all.',
)
Move.new(
  id: :rage,
  name: 'Rage',
  types: [:incomplete, :passive],
  nature_id: :passion,
  description: 'Whenever you take damage, apply the RAGE buff: +1 damage to all attacks. This buff stacks up to 5 times.',
)
Move.new(
  id: :sprinter,
  name: 'Sprinter',
  types: [:incomplete, :passive],
  nature_id: :passion,
  description: 'Your attacks deal +3 damage, but every time you attack you gain the EXHAUSTED debuff: your attacks deal -1 damage.',
)
Move.new(
  id: :marathoner,
  name: 'Marathoner',
  types: [:incomplete],
  nature_id: :passion,
  description: 'Your attacks deal -3 damage, but every time you attack you gain the MOMENTUM debuff: your attacks deal +1 damage.',
)
