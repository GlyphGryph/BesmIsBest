class Move
  def self.execute(id, battle, owner)
    enemy = battle.other_team(owner.team).active_spirit
    p "!! EXECUTING MOVE #{id}!!"
    action = get_move(id.to_sym)

    owner.time_units -= TimeUnit.multiplied(action.time_units)

    # Early exit if there's not enough time_units for this move
    if(owner.time_units < 0)
      owner.time_units += TimeUnit.multiplied(action.time_units)
      return false
    end

    battle.add_display_update(owner, :time_units, TimeUnit.reduced(owner.time_units))

    # TODO: Bug, figure out why this needs to be added twice or it gets skipped
    allowed = battle.check_triggers(action, owner, enemy)
    if(allowed)
      if(action.types.include?(:hidden))
        battle.add_text("#{owner.name} has prepared a hidden technique.")
      else
        battle.add_text("#{owner.name} uses #{action.name}")
      end

      if(action.types.include?(:attack))
        enemy.health -= action.damage
        battle.add_display_update(enemy, :health, enemy.health)
        battle.add_text("#{enemy.name} takes #{action.damage} damage from the attack!")
      end

      if(action.types.include?(:special))
        action.special.call(battle, owner, enemy)
      end
    end
    owner.team.save!
    owner.save!
    enemy.team.save!
    enemy.save!
    battle.save!
  end

  def self.get_move(id)
    id = id.to_sym
    if(move = @@all[id])
      return move
    else
      raise "#{id} is an Invalid move ID"
    end
  end

  def self.all
    @@all
  end

  @@all = {
    ## Normal type actions
    attack: OpenStruct.new(
      name: 'Attack',
      types: [:attack],
      nature: :normal,
      time_units: 3,
      description: 'Deals 5 damage.',
      damage: 5
    ),
    wait: OpenStruct.new(
      name: 'Wait',
      types: [],
      nature: :normal,
      description: 'Passes the time',
      time_units: 1
    ),
    juke: OpenStruct.new(
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
    ),
    shake_off: OpenStruct.new(
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
    ),

    ## Cunning type actions
    spy: OpenStruct.new(
      name: 'Spy',
      types: [:incomplete, :special],
      nature: :cunning,
      time_units: 0,
      description: 'Reveal all equipped enemy moves.',
      special: lambda do |battle, owner, enemy|
      end
    ),
    counterplay: OpenStruct.new(
      name: 'Counterplay',
      types: [:incomplete, :hidden, :trap],
      nature: :cunning,
      time_units: 1,
      description: "Guess next enemy action. If correct, enemy pays it's time unit cost, plus one, but the ability itself is cancelled",
      trigger: lambda do |battle, owner, enemy|
      end
    ),
    trap: OpenStruct.new(
      name: 'Trap',
      types: [:incomplete, :hidden, :temporary, :trap],
      nature: :cunning,
      time_units: 2,
      description: 'If enemy attacks while this trap is active, they take 5 damage and gain the Hesitant debuff.',
      trigger: lambda do |battle, owner, enemy|
      end,
      expire: lambda do |battle, owner, enemy|
      end
    ),
    ambush: OpenStruct.new(
      name: 'Ambush',
      types: [:incomplete, :hidden, :temporary, :trap],
      nature: :cunning,
      description: 'Adds 15 damage to your next attack, unless you are attacked before then',
      trigger: lambda do |battle, owner, enemy|
      end,
      expire: lambda do |battle, owner, enemy|
      end
    ),
    plan: OpenStruct.new(
      name: 'Plan Ahead',
      types: [:incomplete, :temporary],
      nature: :cunning,
      time_units: 1,
      description: "Select another move. In 4 tics you gain 2ap, and automatically use the selected move if you can afford it's time unit cost.",
      expire: lambda do |battle, owner, enemy|
      end
    ),
    delayed_impact: OpenStruct.new(
      name: 'Delayed Impact',
      types: [:incomplete, :temporary, :attack],
      nature: :cunning,
      time_units: 2,
      description: 'In addition to initial damage, the enemy takes 6 damage after their next action unless they switch out.',
      damage: 1,
      expire: lambda do |battle, owner, enemy|
      end
    ),
    lure: OpenStruct.new(
      name: 'Lure',
      types: [:incomplete, :special],
      nature: :cunning,
      time_units: 4,
      description: 'Swap in an enemy of your choice. They can not swap out until this Eidolon swaps out or is defeated.',
      special: lambda do |battle, owner, enemy|
      end
    ),
    lockdown: OpenStruct.new(
      name: 'Lockdown',
      types: [:incomplete, :trap, :debuff],
      nature: :cunning,
      time_units: 2,
      description: 'Next enemy action causes the enemy to gain the Locked Down debuff tied to that move, and it cannot be used again. Overwrites previous Lock Down debuffs.',
      trigger: lambda do |battle, owner, enemy|
      end
    ),

    # Faith
    smite: OpenStruct.new(
      name: 'Smite',
      types: [:attack],
      nature: :faith,
      time_units: 2,
      description: 'An attack fueled by faith.',
      damage: 6
    ),
    guide: OpenStruct.new(
      name: 'I Will Be Guided By Faith',
      types: [:incomplete, :passive],
      nature: :faith,
      description: 'Your attacks are guaranteed to hit, and can not be cancelled',
    ),
    reset: OpenStruct.new(
      name: 'As You Were',
      types: [:special],
      nature: :faith,
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
    ),
    no_fear: OpenStruct.new(
      name: 'I Will Know No Fear',
      types: [:passive],
      nature: :faith,
      description: 'Immune to HESITANT, PANIC and DESPAIR debuffs.',
    ),
    cleanse: OpenStruct.new(
      name: 'We Shall Become As New',
      types: [:incomplete, :special],
      nature: :faith,
      time_units: 2,
      description: 'Remove all buffs and debuffs from all members of your team.',
      special: lambda do |battle, owner, enemy|
      end
    ),
    magnet: OpenStruct.new(
      name: 'I Will Be Your Shield',
      types: [:incomplete, :passive],
      nature: :faith,
      description: 'Half the damage (rounded up) and all debuffs that would effect an ally effect this Eidolon instead.',
    ),

    ## Fear type actions
    intimidate: OpenStruct.new(
      name: 'Intimidate',
      types: [:special, :debuff],
      nature: :fear,
      time_units: 0,
      description: 'Causes HESITANT: Lose a fourth of a time unit each tic',
      special: lambda do |battle, owner, enemy|
        if(enemy.apply_debuff('hesitant'))
          battle.add_text("#{enemy.name} has become hesitant to act!")
        else
          battle.add_text("#{enemy.name} could not be intimidated.")
        end
      end
    ),
    terrify: OpenStruct.new(
      name: 'Terrify',
      types: [:special, :debuff],
      nature: :fear,
      time_units: 3,
      description: 'Causes PANIC: Lose a half of a time unit each tic',
      special: lambda do |battle, owner, enemy|
        if(enemy.apply_debuff('panic'))
          battle.add_text("#{enemy.name} shakes with terror!")
        else
          battle.add_text("#{enemy.name} could not be terrified.")
        end
      end
    ),
    doom: OpenStruct.new(
      name: 'Doom',
      types: [:special, :debuff],
      nature: :fear,
      time_units: 2,
      description: 'Causes DESPAIR: Damage received is doubled.',
      special: lambda do |battle, owner, enemy|
        if(enemy.apply_debuff('despair'))
          battle.add_text("#{enemy.name} has lost all sense of self-preservation.")
        else
          battle.add_text("#{enemy.name} could not be doomed.")
        end
      end
    ),
    needle: OpenStruct.new(
      name: 'Painful Jab',
      types: [:attack, :special, :debuff],
      nature: :fear,
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
    ),
    hide: OpenStruct.new(
      name: 'Hide',
      types: [:incomplete, :temporary, :hidden, :trap],
      nature: :fear,
      time_units: 5,
      description: 'Enemy attacks and debuffs miss, last until your next action',
      trigger: lambda do |battle, owner, enemy|
      end
    ),
    shroud: OpenStruct.new(
      name: 'Shroud',
      types: [:incomplete, :buff, :special],
      nature: :fear,
      time_units: 0,
      description: 'Your health, time units, and the moves you use are not known by your opponent.',
      special: lambda do |battle, owner, enemy|
      end
    ),
    cowardice: OpenStruct.new(
      name: 'Cowardice',
      types: [:incomplete, :passive],
      nature: :fear,
      description: 'Switching out of battle has no time unit cost for this Eidolon.',
    ),

    # Passion type actions
    reckless: OpenStruct.new(
      name: 'Reckless Assault',
      types: [:incomplete, :attack, :temporary, :special, :debuff],
      nature: :passion,
      time_units: 5,
      description: 'Deal a large amount of damage, but until your next action gain RECKLESS: Receive double damage from all sources.',
      damage: 22,
      special: lambda do |battle, owner, enemy|
      end,
      expire: lambda do |battle, owner, enemy|
      end
    ),
    regenerate: OpenStruct.new(
      name: 'Regenerate',
      types: [:special, :buff],
      nature: :passion,
      time_units: 2,
      description: 'Apply the REGENERATE buff: Regain 1 health per tic',
      special: lambda do |battle, owner, enemy|
        if(owner.apply_buff('regenerate'))
          battle.add_text("#{owner.name} has started healing!")
        else
          battle.add_text("#{owner.name} could not begin healing.")
        end
      end
    ),
    overexert: OpenStruct.new(
      name: 'Overexert',
      types: [:incomplete],
      nature: :passion,
      time_units: 2,
      description: 'Deal 10 damage, but take 5',
    ),
    aggress: OpenStruct.new(
      name: 'Aggress',
      types: [:incomplete],
      nature: :passion,
      time_units: 0,
      description: 'Select as many abilities as you have the time units to afford, and immediately use them all.',
    ),
    rage: OpenStruct.new(
      name: 'Rage',
      types: [:incomplete, :passive],
      nature: :passion,
      description: 'Whenever you take damage, apply the RAGE buff: +1 damage to all attacks. This buff stacks up to 5 times.',
    ),
    sprinter: OpenStruct.new(
      name: 'Sprinter',
      types: [:incomplete, :passive],
      nature: :passion,
      description: 'Your attacks deal +3 damage, but every time you attack you gain the EXHAUSTED debuff: your attacks deal -1 damage.',
    ),
    marathoner: OpenStruct.new(
      name: 'Marathoner',
      types: [:incomplete],
      nature: :passion,
      description: 'Your attacks deal -3 damage, but every time you attack you gain the MOMENTUM debuff: your attacks deal +1 damage.',
    ),

    # Persistence Type Actions
    flurry: OpenStruct.new(
      name: 'Flurry',
      types: [:incomplete],
      nature: :persistence,
      time_units: 2,
      description: 'Attack 5 times for 1 damage per attack.',
    ),
    poison: OpenStruct.new(
      name: 'Poison',
      types: [:incomplete],
      nature: :persistence,
      time_units: 3,
      description: 'Causes POISONED debuff: Take 1 damage per tic.',
    ),
    relentless: OpenStruct.new(
      name: 'Relentless Assault',
      types: [:incomplete],
      nature: :persistence,
      time_units: 1,
      description: 'Deals 3 damage. You gain the LOCKED IN (Relentless Assault) debuff: You may not use any other ability, unless you cannot use this ability.'
    ),
    recover: OpenStruct.new(
      name: 'Recover',
      types: [:incomplete],
      nature: :persistence,
      time_units: 3,
      description: 'Regain 6 health.',
    ),
    persevere: OpenStruct.new(
      name: 'Persevere',
      types: [:incomplete],
      nature: :persistence,
      time_units: 5,
      description: 'Regain full health, but reduce your maximum health by half for the remainder of the battle.',
    ),
    conditioning: OpenStruct.new(
      name: 'Conditioning',
      types: [:incomplete, :passive],
      nature: :persistence,
      description: 'Increases your maximum health by 10.',
    ),

    # Strength Type Actions
    slam: OpenStruct.new(
      name: 'Slam',
      types: [:attack],
      nature: :strength,
      time_units: 4,
      damage: 16,
      description: 'Deals 16 damage.',
    ),
    pump: OpenStruct.new(
      name: 'Pump Up',
      types: [:incomplete],
      nature: :strength,
      time_units: 1,
      description: 'Gain the BOOSTED buff: +3 damage to your next attack. Can be stacked up to 5 times.',
    ),
    bash: OpenStruct.new(
      name: 'Bash',
      types: [:attack],
      nature: :strength,
      time_units: 2,
      damage: 7,
      description: 'Deals 7 damage.',
    ),
    breakthrough: OpenStruct.new(
      name: 'Breakthrough',
      types: [:incomplete, :passive],
      nature: :strength,
      description: 'Your abilities cannot be locked down or cancelled.',
    ),
    shield: OpenStruct.new(
      name: 'Shield',
      types: [:incomplete, :passive],
      nature: :strength,
      description: 'Prevent 1 damage from all incoming attacks.',
    ),
    armor: OpenStruct.new(
      name: 'Armor',
      types: [:incomplete, :passive],
      nature: :strength,
      description: 'Prevent 1 damage from all incoming attacks.',
    ),
  }
end
