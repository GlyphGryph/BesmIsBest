class Team < ApplicationRecord
  belongs_to :character, required: false
  belongs_to :battle, required: false
  has_many :team_memberships, dependent: :destroy
  has_many :spirits, through: :team_memberships

  before_create :setup
  after_create :setup_associations

  def reset_state
    self.state['events'] = []
    self.save!
  end

  def active_spirit
    spirits.first
  end

  def defeated?
    active_spirit.hp <= 0
  end

  def ready_to_act?
    active_spirit.time_units >= 20
  end

  def take_ai_turn
    move_to_use = active_spirit.equipped_moves.sample
    Move.execute(move_to_use.move_id, battle, active_spirit)
  end

  def add_text(text)
    self.state['events'] << {type: 'text', value: text}
  end

  def add_delay(delay)
    self.state['events'] << {type: 'delay', value: delay}
  end

  def add_display_update(spirit, stat, value)
    self.state['events'] << {type: 'update', side: (spirit == active_spirit ? 'own_state' : 'enemy_state'), stat: stat, value: value }
  end

  def add_battle_end
    self.state['events'] << {type: 'end_battle'}
  end

private
  def setup
    self.state = {
      events: []
    }
  end

  def setup_associations
    if(team_memberships.count < 1)
      TeamMembership.create(team: self, spirit: Spirit.create!)
    end
  end
end
