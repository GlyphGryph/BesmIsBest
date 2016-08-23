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
        health_percent: 100,
        time_units: 19,
        time_unit_percent: 19*100/20
      },
      side_two: {
        name: 'Faithdolon',
        image: ActionController::Base.helpers.image_url('faithdolon.png'),
        health: 75,
        max_health: 100,
        health_percent: 75,
        time_units: 10,
        time_unit_percent: 50
      }
    }
  end

private
  def setup
  end
end
