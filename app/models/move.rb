class Move
  class << self
    def execute(id, battle, owner)
      enemy = battle.other_team(owner.team).active_spirit
      p "!! EXECUTING MOVE #{id}!!"
      action = find(id.to_sym)
      
      # Return early if we fail to pay the time unit cost
      unless owner.reduce_time_units(action.time_units)
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

        if(action.types.include?(:special) || action.types.include?(:player))
          action.special.call(battle, owner, enemy)
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

  attr_accessor :name, :types, :nature_id, :damage, :description

  def initialize(args)
    @id = args[:id]
    @name = args[:name]
    @types = args[:types]
    @nature_id = args[:nature_id]
    @time_units = args[:time_units]
    @damage = args[:damage]
    @description = args[:description]

    @special_lambda = args[:special]
    @targets_lambda = args[:targets]
    @expire_lambda = args[:expire]
    @trigger_lambda = args[:trigger]

    @@all[@id] = self
  end

  def has_type?(type)
    @types.include?(type.to_sym)
  end

  def special(battle, owner, enemy, target=nil)
    return false unless @special_lambda
    if(has_type?(:targeted))
      @special_lambda.call(battle, owner, enemy, target)
    else
      @special_lambda.call(battle, owner, enemy)
    end
  end

  def targets
    return false unless @targets_lambda
    @targets_lambda.call(battle, owner, enemy)
  end

  def expire
    return false unless @expire_lambda
    @expire_lambda.call(battle, owner, enemy)
  end

  def trigger
    return false unless @trigger_lambda
    @trigger_lambda.call(battle, owner, enemy)
  end
end

require 'moves/player'
require 'moves/normal'
require 'moves/faith'
require 'moves/fear'
require 'moves/persistence'
require 'moves/passion'
require 'moves/cunning'
require 'moves/strength'
