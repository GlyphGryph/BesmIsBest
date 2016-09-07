class Battle < ApplicationRecord
  has_many :teams

  before_create :setup
  after_create :setup_associations

  @@time_unit_multiplier = 12
  @@max_time_units = 5

  def broadcast_events
    teams.each do |team|
      team.reload
      if(team.try(:character).try(:user))
        BattleChannel.broadcast_to(
          team.character.user,
          action: 'updateEvents',
          mode: 'battle',
          events: team.state['events']
        )
      end
      team.clear_events
    end

    if(battle_finished?)
      self.destroy!
    end
  end

  def broadcast_state
    reload
    teams.each{|team| broadcast_state_to_team(team) }
    teams.each{|team| team.clear_events }
  end

  def broadcast_state_to_team(own_team)
    enemy_team = other_team(own_team)
    if(own_team.try(:character).try(:user))
      BattleChannel.broadcast_to(
        own_team.character.user,
        action: 'updateState',
        mode: 'battle',
        max_time_units: TimeUnit.max,
        events: own_team.state['events'],
        own_state: own_team.active_spirit.own_state_hash,
        enemy_state: enemy_team.active_spirit.visible_state_hash
      )
    end
  end

  def add_text(text)
    teams.each{|team| team.add_text(text) }
  end

  def add_delay(delay)
    teams.each{|team| team.add_delay(delay) }
  end

  def add_display_update(spirit, stat, value)
    teams.each{|team| team.add_display_update(spirit, stat, value) }
  end

  def add_battle_end
    teams.each{|team| team.add_battle_end }
  end

  def advance_time
    if(battle_finished?)
      add_battle_end
      return false
    end

    tics_passed = 0
    while(!teams.first.ready_to_act? && !teams.last.ready_to_act?)
      teams.each do |team|
        spirit = team.active_spirit
        spirit.time_units -= TimeUnit.multiplier/4 if(spirit.has_debuff?('hesitant'))
        spirit.time_units -= TimeUnit.multiplier/3 if(spirit.has_debuff?('panic'))
        spirit.time_units += TimeUnit.multiplier
        
        if(spirit.has_buff?('regenerate'))
          spirit.health += 1
          add_display_update(spirit, :health, spirit.health)
          if(spirit.health >= spirit.max_health)
            spirit.remove_buff('regenerate')
            add_text("#{spirit.name} has finished regenerating!")
          end
        end

        spirit.save!
        add_display_update(spirit, :time_units, TimeUnit.reduced(spirit.time_units))
      end
      add_delay(1)
      tics_passed += 1
    end
    teams.each do |team|
      if(team.ready_to_act?)
        add_text("#{team.active_spirit.name} can act!")
        unless(team.try(:character).try(:user))
          # If this is an AI, let them take their turn and trigger more time advancement
          team.take_ai_turn 
        end
        # If we found someone who was ready, stop: no matter what, we don't check the other person
        return true
      end
    end
  end

  def other_team(this_team)
    teams.find{|team| team != this_team}
  end

  def check_triggers(action, owner, enemy)
    return true
  end

  def battle_finished?
    finished = false
    teams.each do |team|
      if(team.defeated?)
        finished = true
        team.add_text('Defeat! You have lost the fight!')
        other_team(team).add_text('The enemy has been defeated!')
      end
    end
    add_battle_end if finished
    finished
  end

private
  def setup
    add_text("What's this?")
    add_text("You've encountered a wild Eidolon!")
    add_text("Prepare to fight!")
  end
  
  def setup_associations
    while(teams.count < 2)
      Team.create!(battle: self)
    end
    teams.each{|team| team.reset_state; team.save! }
  end
end
