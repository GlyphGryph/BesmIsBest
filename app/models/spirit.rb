class Spirit < ApplicationRecord
  has_one :team_membership
  has_one :team, through: :team_membership
  has_many :known_moves, dependent: :destroy
  has_many :equipped_moves, dependent: :destroy

  before_create :setup
  after_create :setup_associations

  def equipped_move_hash
    equipped_moves.map do |em|
      move = Move.getMove(em.move_id.to_sym)
      {name: move.name, id: em.move_id}
    end
  end

  def apply_debuff(debuff_id)
    if can_debuff?(debuff_id)
      self.debuffs << debuff_id
      team.battle.add_display_update(self, :debuffs, self.debuffs)
      return true
    else
      return false
    end
  end

  def apply_buff(buff_id)
    if(self.buffs.include?(buff_id))
      return false
    else
      self.buffs << buff_id
      team.battle.add_display_update(self, :buffs, self.buffs)
      return true
    end
  end

  def remove_debuff(debuff_id=nil)
    if(debuff_id)
      self.debuffs.delete(debuff_id)
    else
      self.debuffs.delete(self.debuffs.sample)
    end
  end

  def remove_buff(buff_id=nil)
    if(buff_id)
      self.buffs.delete(buff_id)
    else
      self.buffs.delete(self.buffs.sample)
    end
  end

  def remove_debuffs
    self.debuffs = []
  end

  def remove_buffs
    self.buffs = []
  end

  def has_debuff?(debuff_id)
    debuffs.include?(debuff_id)
  end

  def can_debuff?(debuff_id)
    if(
      has_debuff?(debuff_id) ||
      (debuff_id == ':hesitant' && has_move?(:no_fear)) ||
      (debuff_id == ':panic' && has_move?(:no_fear)) ||
      (debuff_id == ':despair' && has_move?(:no_fear))
    )
      return false
    else
      return true
    end
  end
  
  def has_move?(move_id)
    self.equipped_moves.find{|move| move.move_id == move_id}
  end

  def reset_state
    self.time_units = TimeUnit.multiplied(TimeUnit.max)
    self.health = self.max_health
    self.buffs = []
    self.debuffs = []
    save!
  end

  def visible_state_hash
    {
      name: name,
      health: health,
      max_health: max_health,
      time_units: TimeUnit.reduced(time_units),
      image: ActionController::Base.helpers.image_url(image),
      buffs: buffs,
      debuffs: debuffs
    }
  end

  def own_state_hash
    {
      name: name,
      health: health,
      max_health: max_health,
      time_units: TimeUnit.reduced(time_units),
      image: ActionController::Base.helpers.image_url(image),
      moves: equipped_move_hash,
      buffs: buffs,
      debuffs: debuffs
    }
  end

private
  def setup 
    self.name ||= ['Normalon', 'Otheron', 'Faithdolon', 'Feardolon', 'Notdolon'].sample
    self.max_health ||= 22
    self.health ||= self.max_health
    self.time_units ||= TimeUnit.multiplied(TimeUnit.max) 
    self.image ||= 'faithdolon.png'
    self.buffs = []
    self.debuffs = []
  end

  def setup_associations
    if self.known_moves.empty?
      self.known_moves << KnownMove.create(move_id: :attack)
      self.known_moves << KnownMove.create(move_id: :wait)
      self.known_moves << KnownMove.create(move_id: :intimidate)
      self.known_moves << KnownMove.create(move_id: :shake_off)
      self.known_moves.each do |km|
        self.equipped_moves << EquippedMove.create(move_id: km.move_id)
      end
    end
  end
end
