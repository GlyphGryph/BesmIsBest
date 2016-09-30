Move.new(
  id: :smite,
  name: 'Smite',
  types: [:attack],
  nature_id: :faith,
  time_units: 2,
  description: 'An attack fueled by faith.',
  damage: 6
)
Move.new(
  id: :guide,
  name: 'I Will Be Guided By Faith',
  types: [:passive],
  nature_id: :faith,
  description: 'Your attacks are guaranteed to hit, and can not be cancelled',
)
Move.new(
  id: :reset,
  name: 'As You Were',
  types: [:special],
  nature_id: :faith,
  time_units: 2,
  description: 'Enemy is stripped of all buffs and debuffs.',
  special: lambda do |battle, owner, enemy|
    enemy.remove_debuffs
    enemy.remove_buffs
    battle.add_text("#{enemy.name} has been stripped of all buffs and debuffs.")
  end,
  trigger: lambda do |battle, owner, enemy|
  end,
  expire: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :no_fear,
  name: 'I Will Know No Fear',
  types: [:passive],
  nature_id: :faith,
  description: 'Immune to HESITANT, PANIC and DESPAIR debuffs.',
)
Move.new(
  id: :cleanse,
  name: 'We Shall Become As New',
  types: [:special],
  nature_id: :faith,
  time_units: 2,
  description: 'Remove all buffs and debuffs from all members of your team.',
  special: lambda do |battle, owner, enemy|
    owner.team.spirits.each do |spirit|
      spirit.remove_debuffs
      spirit.remove_buffs
      battle.add_text("#{owner.name}'s entire team has been stripped of all buffs and debuffs.")
    end
  end
)
Move.new(
  id: :magnet,
  name: 'I Will Be Your Shield',
  types: [:passive],
  nature_id: :faith,
  description: 'Damage and debuffs that would effect an ally effect this Eidolon instead.',
)
