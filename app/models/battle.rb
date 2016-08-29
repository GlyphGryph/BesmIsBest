class Battle < ApplicationRecord
  has_one :character
  belongs_to :spirit, required: false, dependent: :destroy
  before_create :setup

  def request_update_for(target)
    BattleChannel.broadcast_to target, action: 'update', state: self.reload.full_state, mode: 'battle'
  end

  def request_update
    BattleChannel.broadcast_to character.user, action: 'update', state: self.reload.full_state, mode: 'battle'
  end

  def full_state
    if(battle_finished?)
      add_text('Victory! The enemy has been defeated!')
      message = {
        side_one: {
          name: character.spirit.name,
          health: character.spirit.hp,
          max_health: character.spirit.max_hp,
          health_percent: (character.spirit.hp * 100) / character.spirit.max_hp,
          time_units: character.spirit.ap,
          time_unit_percent: (character.spirit.ap * 100) / 5,
          image: ActionController::Base.helpers.image_url(character.spirit.image),
          moves: character.spirit.equipped_move_hash
        },
        side_two: {
          name: spirit.name,
          image: ActionController::Base.helpers.image_url(spirit.image),
          health: 0,
          max_health: spirit.max_hp,
          health_percent: (spirit.hp * 100) / spirit.max_hp,
          time_units: 0,
          time_unit_percent: (spirit.ap * 100) / 5,
          moves: spirit.equipped_move_hash
        },
        texts: state['texts'],
        battle_finished: true
      }
      self.destroy!
      message
    else
      advance_time
      message = {
        side_one: {
          name: character.spirit.name,
          health: character.spirit.hp,
          max_health: character.spirit.max_hp,
          health_percent: (character.spirit.hp * 100) / character.spirit.max_hp,
          time_units: character.spirit.ap,
          time_unit_percent: (character.spirit.ap * 100) / 5,
          image: ActionController::Base.helpers.image_url(character.spirit.image),
          moves: character.spirit.equipped_move_hash
        },
        side_two: {
          name: spirit.name,
          image: ActionController::Base.helpers.image_url(spirit.image),
          health: spirit.hp,
          max_health: spirit.max_hp,
          health_percent: (spirit.hp * 100) / spirit.max_hp,
          time_units: spirit.ap,
          time_unit_percent: (spirit.ap * 100) / 5,
          moves: spirit.equipped_move_hash
        },
        texts: state['texts'],
        battle_finished: false,
      }
      self.state['texts'] = []
      self.save!
      message
    end
  end

  def add_text(text)
    self.state['texts'] << text
  end

  def action_selected(move_id)
    Move.execute(move_id, self, character.spirit, spirit)
  end

  def current_turn
    if(character.spirit.ap >= 5)
      return :side_one
    else
      return :side_two
    end
  end

  def advance_time
    tics_passed = 0
    c_spirit = character.spirit
    while(c_spirit.ap < 5 && spirit.ap < 5)
      c_spirit.ap += 1
      spirit.ap += 1
      tics_passed += 1
    end
    c_spirit.save!
    spirit.save!
    if(current_turn == :side_one)
      add_text("#{tics_passed} tics have passed. #{character.spirit.name} can act!")
    else
      add_text("#{tics_passed} tics have passed. #{spirit.name} can act!")
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
    spirit.hp <= 0
  end

private
  def setup
    self.spirit = Spirit.create(image: ActionController::Base.helpers.image_url('feardolon.png'))
    self.state = {
      'texts': [
        "What's this?",
        "You've encountered a wild Eidolon!",
        "Prepare to fight!"
      ],
      'buffs': [],
      'debuffs': [],
      'pending': []
    }
  end
end
