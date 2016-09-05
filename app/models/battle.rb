class Battle < ApplicationRecord
  has_many :teams

  before_create :setup
  after_create :setup_associations

  def broadcast_events
    finished = battle_finished?
    if(finished)
      add_battle_end()
    end

    teams.each do |team|
      if(own_team.try(:character).try(:user))
        BattleChannel.broadcast_to(
          own_team.character.user,
          action: 'update_events',
          events: own_teamstate['events']
        )
      end
      team.reset_state
    end

    if(finished)
      self.destroy!
    end
  end

  def broadcast_state
    teams.each{|team| broadcast_state_to_team(team) }
    teams.each{|team| team.reset_state }
  end

  def broadcast_state_to_team(own_team)
    enemy_team = other_team(own_team)
    if(own_team.try(:character).try(:user))
      BattleChannel.broadcast_to(
        own_team.character.user,
        action: 'update_state',
        max_time_units: 20,
        events: own_team.state['events'],
        own_state: own_team.active_spirit.own_state,
        enemy_state: enemy_team.active_spirit.enemy_state
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
    teams.each{|team| team.add_display_update(spirit, state, value) }
  end

  def add_battle_end
    teams.each{|team| team.add_battle_end }
  end

  def action_selected(move_id)
    Move.execute(move_id, self, character.spirit, spirit)
  end

  def advance_time
    if(battle_finished?)
      add_battle_end
      return false
    end

    tics_passed = 0
    while(!team_one.ready_to_act? && !team_two.ready_to_act?)
      teams.each do |team|
        spirit = team.active_spirit
        spirit.time_units -= 1 if(spirit.has_debuff?('hesitant'))
        spirit.time_units -= 2 if(spirit.has_debuff?('panic'))
        spirit.time_units += 4
        add_delay(1)
        add_display_update(spirit, :time_units, spirit.time_units)
      end
      tics_passed += 1
    end
    teams.each{|team| team.spirit.save!}
    teams.each do |team|
      if(team.ready_to_act?)
        add_text("#{tics_passed} tics have passed. #{team.spirit.name} can act!")
        unless(team_one.try(:character).try(:user))
          team.take_ai_turn
        end
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
  end
end
