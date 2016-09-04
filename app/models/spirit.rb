class Spirit < ApplicationRecord
  has_one :character_spirit
  has_one :character, through: :character_spirits
  has_one :battle, through: :character
  has_many :known_moves, dependent: :destroy
  has_many :equipped_moves, dependent: :destroy


  before_create :assign_defaults

  def equipped_move_hash
    equipped_moves.map do |em|
      move = Move.getMove(em.move_id.to_sym)
      {name: move.name, id: em.move_id}
    end
  end

  def apply_debuff(debuff_id)
    if can_debuff?(debuff_id)
      self.debuffs << debuff_id
    else
      return false
    end
  end

  def apply_buff(buff_id)
    if(self.buffs.include?(buff_id))
      return false
    else
      self.buffs << buff_id
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

private
  def assign_defaults
    self.name ||= 'Normalon'
    self.max_health ||= 22
    self.health ||= self.max_health
    self.time_units ||= 5
    self.image ||= 'faithdolon.png'
    self.buffs = []
    self.debuffs = []
    self.poisons = []
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
