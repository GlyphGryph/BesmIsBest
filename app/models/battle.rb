class Battle < ApplicationRecord
  has_one :character, required: true
  belongs_to :spirit, required: false, dependent: :destroy
  before_create :setup

  def request_update_for(target)
    BattleChannel.broadcast_to target, action: 'update', state: self.reload.update_state, mode: 'battle'
  end

  def request_update
    BattleChannel.broadcast_to character.user, action: 'update', state: self.reload.update_state, mode: 'battle'
  end

  def update_state
    if(state['initial'] == true)
      c_spirit = character.spirit
      c_spirit.time_units = 20
      c_spirit.health = c_spirit.max_health
      c_spirit.save!

      self.state['initial'] = false
      message = {
        side_one: {
          name: character.spirit.name,
          health: character.spirit.health,
          max_health: character.spirit.max_health,
          time_units: character.spirit.time_units,
          max_time_units: 20,
          image: ActionController::Base.helpers.image_url(character.spirit.image),
          moves: character.spirit.equipped_move_hash
        },
        side_two: {
          name: spirit.name,
          image: ActionController::Base.helpers.image_url(spirit.image),
          health: spirit.health,
          max_health: spirit.max_health,
          time_units: spirit.time_units,
          max_time_units: 20,
          moves: spirit.equipped_move_hash
        },
        events: state['events'],
        initial: true
      }
      self.state['events'] = []
      self.save!
      message
    elsif(battle_finished?)
      add_text('Victory! The enemy has been defeated!')
      add_battle_end()
      message = {
        events: state['events']
      }
      self.destroy!
      message
    else
      advance_time
      message = {
        events: state['events']
      }
      self.state['events'] = []
      self.save!
      message
    end
  end

  def add_text(text)
    self.state['events'] << {type: 'text', value: text}
  end

  def add_delay(delay)
    self.state['events'] << {type: 'delay', value: delay}
  end

  def add_display_update(side, stat, value)
    if(side == character.spirit)
      side = :side_one
    elsif(side == spirit)
      side = :side_two
    end
    self.state['events'] << {type: 'update', side: side, stat: stat, value: value }
  end

  def add_battle_end
    self.state['events'] << {type: 'end_battle'}
  end

  def action_selected(move_id)
    Move.execute(move_id, self, character.spirit, spirit)
  end

  def current_turn
    if(character.spirit.time_units >= 20)
      return character.spirit
    else
      return spirit
    end
  end

  def advance_time
    if(battle_finished?)
      add_battle_end
      return false
    end

    tics_passed = 0
    c_spirit = character.spirit
    while(c_spirit.time_units < 20 && spirit.time_units < 20)
      c_spirit.time_units -= 1 if(c_spirit.has_debuff?('hesitant'))
      c_spirit.time_units -= 2 if(c_spirit.has_debuff?('panic'))
      c_spirit.time_units += 4
      add_delay(1)
      add_display_update(c_spirit, :time_units, c_spirit.time_units)

      spirit.time_units -= 1 if spirit.has_debuff?('hesitant')
      spirit.time_units += 4
      add_display_update(spirit, :time_units, spirit.time_units)

      tics_passed += 1
    end
    c_spirit.save!
    spirit.save!
    if(current_turn == character.spirit)
      # TODO: Figure out if this is redundant, remov it completely if it is?
      # add_text("#{tics_passed} tics have passed. #{character.spirit.name} can act!")
    else
      #add_text("#{tics_passed} tics have passed. #{spirit.name} can act!")
      take_ai_turn
    end
  end

  def take_ai_turn
    move_to_use = spirit.equipped_moves.sample
    Move.execute(move_to_use.move_id, self, spirit, character.spirit)
  end

  def check_triggers(action, owner, enemy)
    return true
  end

  def battle_finished?
    spirit.health <= 0
  end

private
  def setup
    self.spirit = Spirit.create(image: ActionController::Base.helpers.image_url('feardolon.png'))
    self.state = {
      'events': [
        {type: 'text', value: "What's this?"},
        {type: 'text', value: "You've encountered a wild Eidolon!"},
        {type: 'text', value: "Prepare to fight!"}
      ],
      'buffs': [],
      'debuffs': [],
      'pending': [],
      'initial': true
    }
  end
end
