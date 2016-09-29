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
  types: [:incomplete],
  nature_id: :persistence,
  time_units: 3,
  description: 'Causes POISONED debuff: Take 1 damage per tic.',
)
Move.new(
  id: :relentless,
  name: 'Relentless Assault',
  types: [:incomplete],
  nature_id: :persistence,
  time_units: 1,
  description: 'Deals 3 damage. You gain the LOCKED IN (Relentless Assault) debuff: You may not use any other ability, unless you cannot use this ability.'
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
  types: [:incomplete],
  nature_id: :persistence,
  time_units: 5,
  description: 'Regain full health, but reduce your maximum health by half for the remainder of the battle.',
)
Move.new(
  id: :conditioning,
  name: 'Conditioning',
  types: [:incomplete, :passive],
  nature_id: :persistence,
  description: 'Increases your maximum health by 10.',
)
