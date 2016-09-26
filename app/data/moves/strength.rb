Move.new(
  id: :slam,
  name: 'Slam',
  types: [:attack],
  nature_id: :strength,
  time_units: 4,
  damage: 16,
  description: 'Deals 16 damage.',
)
Move.new(
  id: :pump,
  name: 'Pump Up',
  types: [:incomplete],
  nature_id: :strength,
  time_units: 1,
  description: 'Gain the BOOSTED buff: +3 damage to your next attack. Can be stacked up to 5 times.',
)
Move.new(
  id: :bash,
  name: 'Bash',
  types: [:attack],
  nature_id: :strength,
  time_units: 2,
  damage: 7,
  description: 'Deals 7 damage.',
)
Move.new(
  id: :breakthrough,
  name: 'Breakthrough',
  types: [:incomplete, :passive],
  nature_id: :strength,
  description: 'Your abilities cannot be locked down or cancelled.',
)
Move.new(
  id: :shield,
  name: 'Shield',
  types: [:incomplete, :passive],
  nature_id: :strength,
  description: 'Prevent 1 damage from all incoming attacks.',
)
Move.new(
  id: :armor,
  name: 'Armor',
  types: [:incomplete, :passive],
  nature_id: :strength,
  description: 'Prevent 1 damage from all incoming attacks.',
)