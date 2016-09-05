class Move
  def self.execute(id, battle, owner)
    enemy = battle.other_team(owner.team).active_spirit
    p "!! EXECUTING MOVE !!"
    action = getMove(id.to_sym)

    owner.time_units -= action.time_units
    # Early exist if there's not enough time_units for this move
    if(owner.time_units < 0)
      owner.time_units += action.time_units
      return false
    end
    battle.add_display_update(owner, :time_units, owner.time_units)

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

    owner.save!
    enemy.save!
    battle.save!
  end

  def self.getMove(id)
    if(move = @@all[id])
      return move
    else
      raise "#{id} is an Invalid move ID"
    end
  end

  @@all = {
    ## Normal type actions
    attack: OpenStruct.new(
      name: 'Attack',
      types: [:attack],
      nature: :normal,
      time_units: 12,
      description: 'Deals 5 damage.',
      damage: 5
    ),
    wait: OpenStruct.new(
      name: 'Wait',
      types: [],
      nature: :normal,
      description: 'Passes the time',
      time_units: 4
    ),
    juke: OpenStruct.new(
      name: 'Juke',
      types: [:incomplete, :hidden, :temporary, :trap],
      time_units: 12,
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
      time_units: 12,
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
      time_units: 4,
      description: "Guess next enemy action. If correct, enemy pays it's time unit cost, plus one, but the ability itself is cancelled",
      trigger: lambda do |battle, owner, enemy|
      end
    ),
    trap: OpenStruct.new(
      name: 'Trap',
      types: [:incomplete, :hidden, :temporary, :trap],
      nature: :cunning,
      time_units: 8,
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
      time_units: 4,
      description: "Select another move. In 4 tics you gain 2ap, and automatically use the selected move if you can afford it's time unit cost.",
      expire: lambda do |battle, owner, enemy|
      end
    ),
    delayed_impact: OpenStruct.new(
      name: 'Delayed Impact',
      types: [:incomplete, :temporary, :attack],
      nature: :cunning,
      time_units: 8,
      description: 'In addition to initial damage, the enemy takes 6 damage after their next action unless they switch out.',
      damage: 1,
      expire: lambda do |battle, owner, enemy|
      end
    ),
    lure: OpenStruct.new(
      name: 'Lure',
      types: [:incomplete, :special],
      nature: :cunning,
      time_units: 16,
      description: 'Swap in an enemy of your choice. They can not swap out until this Eidolon swaps out or is defeated.',
      special: lambda do |battle, owner, enemy|
      end
    ),
    lockdown: OpenStruct.new(
      name: 'Lockdown',
      types: [:incomplete, :trap, :debuff],
      nature: :cunning,
      time_units: 8,
      description: 'Next enemy action causes the enemy to gain the Locked Down debuff tied to that move, and it cannot be used again. Overwrites previous Lock Down debuffs.',
      trigger: lambda do |battle, owner, enemy|
      end
    ),

    # Faith
    smite: OpenStruct.new(
      name: 'Smite',
      types: [:attack],
      nature: :faith,
      time_units: 8,
      description: 'An attack fueled by faith.',
      damage: 6
    ),
    guide: OpenStruct.new(
      name: 'I Will Be Guided By Faith',
      types: [:incomplete, :passive],
      nature: :faith,
      description: 'Your attacks are guaranteed to hit, and can not be cancelled',
    ),
    'reset': OpenStruct.new(
      name: 'As You Were',
      types: [:special],
      nature: :faith,
      time_units: 8,
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
      time_units: 8,
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
        if(enemy.apply_debuff(:hesitant))
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
      time_units: 12,
      description: 'Causes PANIC: Lose a half of a time unit each tic',
      special: lambda do |battle, owner, enemy|
        if(enemy.apply_debuff(:panic))
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
      time_units: 8,
      description: 'Causes DESPAIR: Damage received is doubled.',
      special: lambda do |battle, owner, enemy|
        if(enemy.apply_debuff(:despair))
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
      time_units: 8,
      description: 'In addition to dealing damage, causes HESITANT: Lose a fourth of a time unit each tic',
      damage: 2,
      special: lambda do |battle, owner, enemy|
        if(enemy.apply_debuff(:hesitant))
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
      time_units: 20,
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
    assault: OpenStruct.new(
      name: 'Reckless Assault',
      types: [:attack, :temporary, :special, :debuff],
      nature: :fear,
      time_units: 20,
      description: 'Deal a large amount of damage, but until your next action gain RECKLESS: Receive double damage from all sources.',
      damage: 22,
      special: lambda do |battle, owner, enemy|
      end,
      expire: lambda do |battle, owner, enemy|
      end
    ),
    # : OpenStruct.new(
    #   name: '',
    #   types: [:],
    #   nature: :fear,
    #   time_units: ,
    #   description: '',
    #   damage: ,
    #   special: lambda do |battle, owner, enemy|
    #   end
    #   trigger: lambda do |battle, owner, enemy|
    #   end
    #   expire: lambda do |battle, owner, enemy|
    #   end
    # ),
    # : OpenStruct.new(
    #   name: '',
    #   types: [:],
    #   nature: :fear,
    #   time_units: ,
    #   description: '',
    #   damage: ,
    #   special: lambda do |battle, owner, enemy|
    #   end
    #   trigger: lambda do |battle, owner, enemy|
    #   end
    #   expire: lambda do |battle, owner, enemy|
    #   end
    # ),
    # : OpenStruct.new(
    #   name: '',
    #   types: [:],
    #   nature: :fear,
    #   time_units: ,
    #   description: '',
    #   damage: ,
    #   special: lambda do |battle, owner, enemy|
    #   end
    #   trigger: lambda do |battle, owner, enemy|
    #   end
    #   expire: lambda do |battle, owner, enemy|
    #   end
    # ),
    # : OpenStruct.new(
    #   name: '',
    #   types: [:],
    #   nature: :fear,
    #   time_units: ,
    #   description: '',
    #   damage: ,
    #   special: lambda do |battle, owner, enemy|
    #   end
    #   trigger: lambda do |battle, owner, enemy|
    #   end
    #   expire: lambda do |battle, owner, enemy|
    #   end
    # ),
    # : OpenStruct.new(
    #   name: '',
    #   types: [:],
    #   nature: :fear,
    #   time_units: ,
    #   description: '',
    #   damage: ,
    #   special: lambda do |battle, owner, enemy|
    #   end
    #   trigger: lambda do |battle, owner, enemy|
    #   end
    #   expire: lambda do |battle, owner, enemy|
    #   end
    # ),
    # : OpenStruct.new(
    #   name: '',
    #   types: [:],
    #   nature: :fear,
    #   time_units: ,
    #   description: '',
    #   damage: ,
    #   special: lambda do |battle, owner, enemy|
    #   end
    #   trigger: lambda do |battle, owner, enemy|
    #   end
    #   expire: lambda do |battle, owner, enemy|
    #   end
    # ),
    # : OpenStruct.new(
    #   name: '',
    #   types: [:],
    #   nature: :fear,
    #   time_units: ,
    #   description: '',
    #   damage: ,
    #   special: lambda do |battle, owner, enemy|
    #   end
    #   trigger: lambda do |battle, owner, enemy|
    #   end
    #   expire: lambda do |battle, owner, enemy|
    #   end
    # ),
    # : OpenStruct.new(
    #   name: '',
    #   types: [:],
    #   nature: :fear,
    #   time_units: ,
    #   description: '',
    #   damage: ,
    #   special: lambda do |battle, owner, enemy|
    #   end
    #   trigger: lambda do |battle, owner, enemy|
    #   end
    #   expire: lambda do |battle, owner, enemy|
    #   end
    # ),

  }
end
