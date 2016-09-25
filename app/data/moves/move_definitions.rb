## Player actions
Move.new(
  id: :swap,
  name: 'Swap',
  types: [:player, :targeted],
  nature_id: :normal,
  time_units: 2,
  special: lambda do |battle, owner, enemy, target|
    if(owner.team.spirits.alive.count > 1)
      owner.team.swap_to(owner.team.spirits.find(target.id))
    else
      battle.add_text("#{owner.name} tried to swap out, but there was no one to take their place.")
    end
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

## Normal type actions
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

## Cunning type actions
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

# Faith
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
  types: [:incomplete, :passive],
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
  types: [:incomplete, :special],
  nature_id: :faith,
  time_units: 2,
  description: 'Remove all buffs and debuffs from all members of your team.',
  special: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :magnet,
  name: 'I Will Be Your Shield',
  types: [:incomplete, :passive],
  nature_id: :faith,
  description: 'Half the damage (rounded up) and all debuffs that would effect an ally effect this Eidolon instead.',
)

## Fear type actions
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
  types: [:incomplete, :buff, :special],
  nature_id: :fear,
  time_units: 0,
  description: 'Your health, time units, and the moves you use are not known by your opponent.',
  special: lambda do |battle, owner, enemy|
  end
)
Move.new(
  id: :cowardice,
  name: 'Cowardice',
  types: [:incomplete, :passive],
  nature_id: :fear,
  description: 'Switching out of battle has no time unit cost for this Eidolon.',
)

# Passion type actions
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

# Persistence Type Actions
Move.new(
  id: :flurry,
  name: 'Flurry',
  types: [:incomplete],
  nature_id: :persistence,
  time_units: 2,
  description: 'Attack 5 times for 1 damage per attack.',
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
  types: [:incomplete],
  nature_id: :persistence,
  time_units: 3,
  description: 'Regain 6 health.',
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

# Strength Type Actions
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
