class Battle < ApplicationRecord
  has_one :character
  belongs_to :spirit, required: false, dependent: :destroy
  before_create :setup

  def full_state
    {
      side_one: {
        name: character.spirit.name,
        health: character.spirit.hp,
        max_health: character.spirit.max_hp,
        health_percent: (character.spirit.hp * 100) / character.spirit.max_hp,
        time_units: character.spirit.ap,
        time_unit_percent: (character.spirit.ap * 100) / 5,
        image: ActionController::Base.helpers.image_url(character.spirit.image),
        texts: [
          "What's this?",
          "You've encountered a wild Eidolon!",
          "Prepare to fight!"
        ],
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
      }
    }
  end

private
  def setup
    self.spirit = Spirit.create(image: ActionController::Base.helpers.image_url('feardolon.png'))
  end
end
