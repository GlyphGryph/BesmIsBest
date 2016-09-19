class Character < ApplicationRecord
  belongs_to :user
  belongs_to :world, required: false
  has_one :team, dependent: :destroy

  before_create :setup
  after_create :setup_associations
  
  def mode
    team.battle ? :battle : :world
  end

  def status
    { mode: mode }
  end

  def move(direction)
    reload
    p "Moving Character #{id} #{direction}"
    if mode == :battle
      p "Could not move Character #{id} #{direction}. Character is in battle!"
      MasterChannel.broadcast_to user, action: 'commandProcessed', message: 'Invalid Command: Could not move character, character is in battle'
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
    self.save!
    p "New Character #{id} position: #{self.xx}, #{self.yy}"
    if true # RANDOM CHANCE OF ENTERING BATTLE
      world.broadcast_update_for(self.user)
      start_battle
    else
      save!
      world.broadcast_update_for(self.user)
    end
  end
  
  def start_battle(opponent = nil)
    if(team.reload.battle.nil?)
      battle = Battle.create!
      battle.teams << team
      if(opponent)
        battle.teams << opponent.team
      else
        battle.add_wild_team
      end
      battle.save!
      battle.start
    else
      raise "You are already in battle."
    end
  end

  def join_battle
    if(team.battle)
      team.battle.broadcast_state_to_team(team, team.history)
    end
  end

private
  def setup
  end

  def setup_associations
    team = Team.create!(character: self)
    starter_spirit = Spirit.create!(species_id: 1)
    TeamMembership.create!(team: team, spirit: starter_spirit, position: 0)
    starter_spirit = Spirit.create!(species_id: 2)
    TeamMembership.create!(team: team, spirit: starter_spirit, position: 1)
    starter_spirit = Spirit.create!(species_id: 3)
    TeamMembership.create!(team: team, spirit: starter_spirit, position: 2)
   end
end
