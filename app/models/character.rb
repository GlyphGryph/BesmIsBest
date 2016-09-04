class Character < ApplicationRecord
  belongs_to :user
  belongs_to :world, required: false
  belongs_to :battle, required: false, dependent: :destroy
  has_many :character_spirits, dependent: :destroy
  has_many :spirits, through: :character_spirits, dependent: :destroy
  before_create :setup

  def move(direction)
    p "Moving Character #{id} #{direction}"
    if battle
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

  def spirit
    spirits.first
  end

private
  def setup
    self.character_spirits << CharacterSpirit.create(spirit: Spirit.create(name: 'Nightwing'), position: 0)
  end
end
