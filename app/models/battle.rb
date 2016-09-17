class Battle < ApplicationRecord
  has_many :teams

  before_create :setup
  after_create :setup_associations
  belongs_to :current_team, class_name: 'Team', required: false

  @@time_unit_multiplier = 12
  @@max_time_units = 5

  def broadcast_events
    teams.each{|team| team.broadcast_events}
    self.destroy! if battle_finished?
  end

  def broadcast_state
    teams.each{|team| broadcast_state_to_team(team, team.history) }
    teams.each{|team| team.clear_events }
  end

  def broadcast_state_to_team(own_team, events)
    if(own_team.try(:character).try(:user))
      enemy_team = other_team(own_team)
      MasterChannel.broadcast_to(
        own_team.character.user,
        action: 'joinedBattle',
        max_time_units: TimeUnit.max,
        events: events,
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

  def add_turn
    current_team.add_take_turn
    other_team(current_team).add_wait
  end

  def take_player_turn(team, data)
    if current_team == team
      team.action_selected(data['move_id'])
      advance_time
      broadcast_events
    end
  end

  def take_ai_turn(team, data)
    if current_team == team
      team.action_selected(data['move_id'])
      advance_time
    end
  end

  def advance_time
    while(!teams.first.ready_to_act? && !teams.last.ready_to_act? && !battle_finished?)
      teams.each{|team| team.advance_time}
      add_delay(1)
    end

    if battle_finished?
      add_battle_end
    else # If the battle isn't finished, one of the teams must be ready to act
      self.current_team = teams.select{|team| team.ready_to_act?}.first
      self.save
      add_turn
      current_team.request_ai_turn
    end
  end

  def other_team(this_team)
    teams.find{|team| team != this_team}
  end

  def check_triggers(action, owner, enemy)
    return true
  end

  def battle_finished?
    return teams.any?{|team| team.defeated?}
  end
  
  def add_wild_team
    if(teams.count < 2)
      Team.create!(battle: self).add_wild_spirit
      return true
    end
    return false
  end

  def start
    teams.each{|team| team.reset_state; team.save! }
    add_text("What's this?")
    add_text("You've encountered a wild Eidolon!")
    add_text("Prepare to fight!")
    advance_time
    broadcast_state
  end

private
  def setup
  end
  
  def setup_associations
  end
end
