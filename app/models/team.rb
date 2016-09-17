class Team < ApplicationRecord
  belongs_to :character, required: false
  belongs_to :battle, required: false
  has_many :team_memberships, dependent: :destroy
  has_many :spirits, through: :team_memberships

  before_create :setup
  after_create :setup_associations

  def customization_data
    { spirits: spirits.map{ |spirit| spirit.customization_data } }
  end

  def reset_state
    spirits.each{ |spirit| spirit.reset_state; spirit.save! }
    clear_history
  end

  def clear_events
    self.state['events'] = []
    self.save!
  end

  def clear_history
    self.state['events'] = []
    self.state['history'] = []
    self.state['last_event'] = nil
    self.save!
  end

  def active_spirit
    spirits.first
  end

  def defeated?
    active_spirit.health <= 0
  end

  def ready_to_act?
    active_spirit.time_units >= TimeUnit.multiplied(TimeUnit.max)
  end

  def action_selected(move_id)
    reload
    if(ready_to_act? && active_spirit.has_move?(move_id) && battle.current_team == self)
      Move.execute(move_id, battle, active_spirit)
    else
      if(battle.current_team != self)
        raise "Attempted to act out of turn!"
      elsif(!active_spirit.has_move?(move_id))
        raise "Attempted to use a move they don't know!"
      else
        raise "Something went wrong, you were not ready despite it being your turn."
      end
    end
  end

  def request_ai_turn
    if(character.nil?)
      move_to_use = active_spirit.equipped_moves.sample
      battle.take_ai_turn(self, {'move_id' => move_to_use.move_id})
    end
  end

  def add_text(text)
    self.reload.state['events'] << {type: 'text', value: text}
    self.reload.state['history'] << {type: 'text', value: text}
    self.save!
  end

  def add_delay(delay)
    self.reload.state['events'] << {type: 'delay', value: delay}
    self.reload.state['history'] << {type: 'delay', value: delay}
    self.save!
  end

  def add_display_update(spirit, stat, value)
    self.reload.state['events'] << {type: 'update', side: (spirit == active_spirit ? 'own' : 'enemy'), stat: stat, value: value }
    self.reload.state['history'] << {type: 'update', side: (spirit == active_spirit ? 'own' : 'enemy'), stat: stat, value: value }
    self.save!
  end

  def add_battle_end
    if(defeated?)
      add_text('Defeat! You have lost the fight!')
    else
      add_text('The enemy has been defeated!')
    end
    self.reload.state['last_event'] = {type: 'end_battle'}
    self.save!
  end

  def add_wait
    self.reload.state['last_event'] = {type: 'wait'}
    self.save!
  end

  def add_take_turn
    self.reload.state['last_event'] = {type: 'take_turn'}
    self.save!
  end

  def add_wild_spirit
    spirit = Spirit.create!(
      name: 'Wild Enemy',
      max_health: 22,
      image: 'faithdolon.png'
    )
    TeamMembership.create(team: self, spirit: spirit)
    KnownMove.create(spirit: spirit, move_id: :attack)
    EquippedMove.create(spirit: spirit, move_id: :attack)
  end

  def events
    state['events'] + [state['last_event']]
  end

  def history
    state['history'] + [state['last_event']]
  end

  def advance_time
    active_spirit.advance_time
  end

  def broadcast_events
    if(character && character.user)
      BattleChannel.broadcast_to(
        character.user,
        action: 'updateEvents',
        mode: 'battle',
        events: events 
      )
    end
    clear_events
  end

private
  def setup
    self.state = {
      events: [],
      history: [],
      last_event: nil
    }
  end

  def setup_associations
  end
end
