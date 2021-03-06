class Move
  class << self
    def execute(id, battle, owner, target_id = nil)
      enemy = battle.other_team(owner.team).active_spirit
      p "!! EXECUTING MOVE #{id}!!"
      action = find(id.to_sym)

      if(action.id == :swap && owner.has_passive?(:cowardice))
        time_cost = 0
      else
        time_cost = action.time_units
      end
      # Return early if we fail to pay the time unit cost
      unless owner.reduce_time_units(time_cost)
        return false
      end

      battle.add_display_update(owner, :time_units, TimeUnit.reduced(owner.time_units))

      # TODO: Bug, figure out why this needs to be added twice or it gets skipped
      allowed = battle.check_triggers(action, owner, enemy)
      if(allowed)
        if(owner.has_buff?('shrouded'))
          owner.team.add_text("#{owner.name} uses #{action.name}")
          enemy.team.add_text("#{owner.name}'s action was shrouded in shadow.")
        elsif(action.types.include?(:hidden))
          battle.add_text("#{owner.name} has prepared a hidden technique.")
        else
          battle.add_text("#{owner.name} uses #{action.name}")
        end
        
        action.repeats.times do
          if(action.types.include?(:attack))
            enemy.harm(owner.modified_damage(action.damage))
          end

          if(action.types.include?(:special) || action.types.include?(:player))
            action.special(battle, owner, enemy, target_id)
          end
        end
      end
      owner.team.save!
      owner.save!
      enemy.team.save!
      enemy.save!
      battle.save!
    end

    def find(id)
      id = id.to_sym
      if(move = @@all[id])
        return move
      else
        raise "#{id} is an Invalid move ID"
      end
    end

    def all
      @@all.values
    end
  end

  @@all = {}

  attr_accessor :id, :name, :types, :nature_id, :time_units, :damage, :description, :repeats

  def initialize(args)
    @id = args[:id]
    @name = args[:name]
    @types = args[:types]
    @nature_id = args[:nature_id]
    @time_units = args[:time_units]
    @damage = args[:damage]
    @description = args[:description]
    @repeats = args[:repeats] || 1

    @special_lambda = args[:special]
    @targets_lambda = args[:targets]
    @expire_lambda = args[:expire]
    @trigger_lambda = args[:trigger]

    @@all[@id] = self
  end

  def has_type?(type)
    @types.include?(type.to_sym)
  end

  def special(battle, owner, enemy, target_id=nil)
    return false unless @special_lambda
    if(has_type?(:targeted))
      @special_lambda.call(battle, owner, enemy, target_id)
    else
      @special_lambda.call(battle, owner, enemy)
    end
  end

  def targets(owner)
    return [] unless @targets_lambda && has_type?(:targeted)
    @targets_lambda.call(owner)
  end

  def expire
    return false unless @expire_lambda
    @expire_lambda.call(battle, owner, enemy)
  end

  def trigger
    return false unless @trigger_lambda
    @trigger_lambda.call(battle, owner, enemy)
  end

  load 'moves/player.rb'
  load 'moves/normal.rb'
  load 'moves/faith.rb'
  load 'moves/fear.rb'
  load 'moves/persistence.rb'
  load 'moves/passion.rb'
  load 'moves/cunning.rb'
  load 'moves/strength.rb'
end
