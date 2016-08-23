class Battle < ApplicationRecord
  has_one :character
  before_create :setup

  def full_state
    {
      side_one: {
        name: 'Nightwing',
        image: ActionController::Base.helpers.image_url('feardolon.png'),
        health: 50,
        max_health: 50,
        time_units: 19,
        time_unit_percent: 19*100/20
      },
      side_two: {
        name: 'Faithdolon',
        image: ActionController::Base.helpers.image_url('faithdolon.png'),
        health: 100,
        max_health: 100,
        time_units: 10,
        time_unit_percent: 50
      }
    }
  end

private
  def setup
  end
end
