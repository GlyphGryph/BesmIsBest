Move.new(
  id: :spy,
  name: 'Spy',
  types: [:incomplete, :special],
  nature_id: :cunning,
  time_units: 0,
  description: 'Reveal all equipped enemy moves.',
  special: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :counterplay,
  name: 'Counterplay',
  types: [:incomplete, :hidden, :trap],
  nature_id: :cunning,
  time_units: 1,
  description: "Guess next enemy action. If correct, enemy pays it's time unit cost, plus one, but the ability itself is cancelled",
  trigger: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :trap,
  name: 'Trap',
  types: [:incomplete, :hidden, :temporary, :trap],
  nature_id: :cunning,
  time_units: 2,
  description: 'If enemy attacks while this trap is active, they take 5 damage and gain the Hesitant debuff.',
  trigger: lambda do |battle, owner, enemy|
  end,
  expire: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :ambush,
  name: 'Ambush',
  types: [:incomplete, :hidden, :temporary, :trap],
  nature_id: :cunning,
  description: 'Adds 15 damage to your next attack, unless you are attacked before then',
  trigger: lambda do |battle, owner, enemy|
  end,
  expire: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :plan,
  name: 'Plan Ahead',
  types: [:incomplete, :temporary],
  nature_id: :cunning,
  time_units: 1,
  description: "Select another move. In 4 tics you gain 2ap, and automatically use the selected move if you can afford it's time unit cost.",
  expire: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :delayed_impact,
  name: 'Delayed Impact',
  types: [:incomplete, :temporary, :attack],
  nature_id: :cunning,
  time_units: 2,
  description: 'In addition to initial damage, the enemy takes 6 damage after their next action unless they switch out.',
  damage: 1,
  expire: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :lure,
  name: 'Lure',
  types: [:incomplete, :special],
  nature_id: :cunning,
  time_units: 4,
  description: 'Swap in an enemy of your choice. They can not swap out until this Eidolon swaps out or is defeated.',
  special: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :lockdown,
  name: 'Lockdown',
  types: [:incomplete, :trap, :debuff],
  nature_id: :cunning,
  time_units: 2,
  description: 'Next enemy action causes the enemy to gain the Locked Down debuff tied to that move, and it cannot be used again. Overwrites previous Lock Down debuffs.',
  trigger: lambda do |battle, owner, enemy|
  end
)
