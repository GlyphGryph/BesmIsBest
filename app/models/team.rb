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
  end

  def clear_events
    self.state['events'] = []
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
    if(ready_to_act? && active_spirit.has_move?(move_id))
      Move.execute(move_id, battle, active_spirit)
    else
      if(!ready_to_act?)
        raise "Attempted to act out of turn!"
      else(!active_spirit.has_move?(move_id))
        raise "Attempted to use a move they don't know!"
      end
    end
  end

  def take_ai_turn
    move_to_use = active_spirit.equipped_moves.sample
    Move.execute(move_to_use.move_id, battle, active_spirit)
    battle.advance_time
  end

  def add_text(text)
    self.reload.state['events'] << {type: 'text', value: text}
    self.save!
  end

  def add_delay(delay)
    self.reload.state['events'] << {type: 'delay', value: delay}
    self.save!
  end

  def add_display_update(spirit, stat, value)
    self.reload.state['events'] << {type: 'update', side: (spirit == active_spirit ? 'own' : 'enemy'), stat: stat, value: value }
    self.save!
  end

  def add_battle_end
    self.reload.state['events'] << {type: 'end_battle'}
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

private
  def setup
    self.state = {
      events: []
    }
  end

  def setup_associations
  end
end
