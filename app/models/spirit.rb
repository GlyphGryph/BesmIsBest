class Spirit < ApplicationRecord
  has_one :character_spirit
  has_one :character, through: :character_spirits
  has_one :battle, through: :character
  has_many :known_moves
  has_many :equipped_moves


  before_create :assign_defaults

  def equipped_move_hash
    equipped_moves.map do |em|
      move = Move.getMove(em.move_id.to_sym)
      {name: move.name, id: em.move_id}
    end
  end

private
  def assign_defaults
    self.name ||= 'Normalon'
    self.max_hp ||= 22
    self.hp ||= self.max_hp
    self.ap ||= 5
    self.image ||= 'faithdolon.png'
    if self.known_moves.empty?
      self.known_moves << KnownMove.create(move_id: :attack)
      self.known_moves << KnownMove.create(move_id: :wait)
      self.known_moves << KnownMove.create(move_id: :juke)
      self.known_moves << KnownMove.create(move_id: :shake_off)
      self.known_moves.each do |km|
        self.equipped_moves << EquippedMove.create(move_id: km.move_id)
      end
    end
  end
end
