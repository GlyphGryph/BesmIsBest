class Team < ApplicationRecord
  belongs_to :character, required: false
  belongs_to :battle, required: false
  has_many :team_memberships, -> { order "position ASC" }, dependent: :destroy
  has_many :spirits, through: :team_memberships
  belongs_to :active_spirit, class_name: 'Spirit', required: false

  before_create :setup
  after_create :setup_associations

  def customization_data
    { spirits: spirits.map{ |spirit| spirit.customization_data } }
  end

  def reset_state
    spirits.each{ |spirit| spirit.reset_state; spirit.save! }
    self.active_spirit = spirits.first
    clear_history
    self.save!
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

  def defeated?
    !spirits.any?{|spirit| spirit.alive?}
  end

  def ready_to_act?
    if(active_spirit)
      active_spirit.time_units >= TimeUnit.multiplied(TimeUnit.max)
    end
  end

  def action_selected(move_id)
    reload
    if(ready_to_act? && active_spirit.can_move?(move_id) && battle.current_team == self)
      Move.execute(move_id, battle, active_spirit)
    else
      p "Attempted to use move #{move_id} but..."
      if(battle.current_team != self)
        raise "Attempted to act out of turn!"
      elsif(!active_spirit.can_move?(move_id))
        raise "Attempted to use a move they don't know!"
      else
        raise "Something went wrong, you were not ready despite it being your turn."
      end
    end
  end

  def request_ai_turn
    if(!has_player?)
      move_to_use = active_spirit.usable_moves.sample
      battle.take_ai_turn(self, {'move_id' => move_to_use.move_id})
    end
  end

  def add_event(body)
    if has_player?
      reload
      self.state['events'] << body
      self.state['history'] << body
      self.save!
    end
  end

  def add_text(text)
    add_event({type: 'text', value: text})
  end

  def add_delay(delay)
    add_event({type: 'delay', value: delay})
  end

  def add_display_update(spirit, stat, value)
    add_event({type: 'update', side: (spirit == active_spirit ? 'own' : 'enemy'), stat: stat, value: value })
  end

  def add_swap(spirit)
    if(spirit.team == self)
      add_event({type: 'swap', side: 'own', value: spirit.own_state_hash })
    else
      add_event({type: 'swap', side: 'enemy', value: spirit.visible_state_hash })
    end
  end

  def add_battle_end
    if has_player?
      if(defeated?)
        add_text('Defeat! You have lost the fight!')
      else
        add_text('The enemy has been defeated!')
      end
      self.state['last_event'] = {type: 'end_battle'}
      self.save!
    end
  end

  def add_wait
    if has_player?
      self.reload.state['last_event'] = {type: 'wait'}
      self.save!
    end
  end

  def add_take_turn
    if has_player?
      self.reload.state['last_event'] = {type: 'take_turn'}
      self.save!
    end
  end

  def add_wild_spirit
    reload
    spirit = Spirit.create!(species_id: rand(4)+1)
    TeamMembership.create!(team: self, spirit: spirit, position: spirits.size)
    3.times do
      spirit.equip_move(spirit.known_moves.sample.move_id)
    end
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
  
  def update_status 
    if(active_spirit.defeated?)
      process_defeated_spirit
    end
  end

  def process_defeated_spirit
    add_text("#{active_spirit.name} has fallen!")
    self.active_spirit = spirits.alive.first
    self.save!
    if(active_spirit)
      active_spirit.swap_in
      battle.add_swap(active_spirit)
      battle.add_text("#{active_spirit.name} has entered the fray!")
    end
  end

  def broadcast_events
    reload
    if has_player?
      BattleChannel.broadcast_to(
        character.user,
        action: 'updateEvents',
        mode: 'battle',
        events: events 
      )
    end
    clear_events
  end

  def has_player?
    character && character.user
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
