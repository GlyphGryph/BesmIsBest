Move.new(
  id: :attack,
  name: 'Attack',
  types: [:attack],
  nature_id: :normal,
  time_units: 3,
  description: 'Deals 5 damage.',
  damage: 5
)
Move.new(
  id: :juke,
  name: 'Juke',
  types: [:incomplete, :hidden, :temporary, :trap],
  time_units: 3,
  description: 'Hidden move. Avoid the next enemy attack, if it happens before your next action.',
  special: lambda do |battle, owner, enemy|
  end,
  trigger: lambda do |battle, owner, enemy, attack|
  end,
  expire: lambda do |battle, owner, enemy, attack|
  end
)
Move.new(
  id: :shake_off,
  name: 'Shake Off',
  types: [:special],
  time_units: 3,
  description: 'Remove one of your debuffs at random.',
  special: lambda do |battle, owner, enemy|
    if(owner.remove_debuff)
      battle.add_text("#{owner.name} has shaken off a debuff.")
    else
      battle.add_text("#{owner.name} tried to shake off a debuff, but failed.")
    end
  end
)
