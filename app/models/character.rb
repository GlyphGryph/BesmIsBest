class Character < ApplicationRecord
  belongs_to :user
  belongs_to :world, required: false
  belongs_to :battle, required: false
  has_many :character_spirits, dependent: :destroy
  has_many :spirits, through: :character_spirits
  before_create :setup

  def request_update
    reload
    if(mode == :move)
      WorldChannel.broadcast_to user, action: 'update', map: world.reload.full_map, mode: 'world'
    elsif(mode == :battle)
      WorldChannel.broadcast_to user, action: 'update', state: battle.reload.full_state, mode: 'battle'
    end
  end
  
  def move(direction)
    p "Moving Character #{id} #{direction}"
    if mode != :move
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

  def mode
    self.battle ? :battle : :move
  end

  def enter_battle_mode
    p "Character #{id} has entered Battle!"
    self.battle = Battle.create()
    save!
    WorldChannel.broadcast_to user, action: 'enterBattle'
  end

  def leave_battle_mode
    if(self.reload.battle)
      p "Character #{id} has left Battle!"
      self.battle.destroy!
      WorldChannel.broadcast_to user, action: 'leaveBattle'
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
