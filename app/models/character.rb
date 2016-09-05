class Character < ApplicationRecord
  belongs_to :user
  belongs_to :world, required: false
  has_one :team, dependent: :destroy

  before_create :setup
  after_create :setup_associations

  def move(direction)
    p "Moving Character #{id} #{direction}"
    if team.battle
      p "Could not move Character #{id} #{direction}. Character is in battle!"
      WorldChannel.broadcast_to world, action: 'commandProcessed', message: 'Invalid Command'
      return false
    end

    if(direction=='up')
      self.yy -= 1
      if(self.yy < 0)
        self.yy = 0
      end
    elsif(direction=='down')
      self.yy += 1
      if(self.yy >= world.height)
        self.yy = world.height-1
      end
    elsif(direction=='right')
      self.xx += 1
      if(self.xx >= world.width)
        self.xx = world.width-1
      end
    elsif(direction=='left')
      self.xx -= 1
      if(self.xx < 0)
        self.xx = 0
      end
    end
    p "New Character #{id} position: #{self.xx}, #{self.yy}"
    if rand(10)==1
      WorldChannel.broadcast_to world, action: 'update', map: world.reload.full_map, mode: 'world'
      enter_battle_mode()
    else
      save!
      WorldChannel.broadcast_to world, action: 'update', map: world.reload.full_map, mode: 'world'
    end
  end

private
  def setup
  end

  def setup_associations
    team ||= Team.create!(character: self)
  end
end
