Move.new(
  id: :swap,
  name: 'Swap',
  types: [:player, :targeted],
  nature_id: :normal,
  time_units: 2,
  special: lambda do |battle, owner, enemy, target_id|
    if(target_id && owner.team.spirits.alive.count > 1)
      owner.team.swap_to(owner.team.spirits.find(target_id))
    else
      battle.add_text("#{owner.name} tried to swap out, but there was no one to take their place.")
    end
  end,
  targets: lambda do |owner|
    owner.teammates.alive.map{|spirit| {id: spirit.id, name: spirit.name} }
  end
)
Move.new(
  id: :wait,
  name: 'Wait',
  types: [:player],
  nature_id: :normal,
  time_units: 1,
  special: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :item,
  name: 'Item',
  types: [:player],
  nature_id: :normal,
  time_units: 3,
  special: lambda do |battle, owner, enemy|
  end,
)
Move.new(
  id: :flee,
  name: 'Flee',
  types: [:player],
  nature_id: :normal,
  time_units: 1,
  special: lambda do |battle, owner, enemy|
    owner.team.flee
  end
)
Move.new(
  id: :capture,
  name: 'Capture',
  types: [:player],
  nature_id: :normal,
  time_units: 1,
  special: lambda do |battle, owner, enemy|
    owner.team.attempt_capture(enemy)
  end
)
