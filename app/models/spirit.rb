class Spirit < ApplicationRecord
  has_one :team_membership
  has_one :team, through: :team_membership
  has_many :known_moves, dependent: :destroy
  has_many :equipped_moves, dependent: :destroy

  before_create :setup
  after_create :setup_associations

  validates :species_id, presence: true

  scope :alive, -> { where('health > ?', 0) }

  def alive?
    health > 0
  end

  def defeated?
    !alive?
  end

  def max_moves
    species['smarts']
  end
  
  def non_passive_moves
    equipped_moves.select do |em|
      move = Move.find(em.move_id.to_sym)
      !move.types.include?(:passive)
    end
  end

  def player_moves
    [:swap, :wait, :flee, :capture].inject([]) do |array, id|
      move = Move.find(id.to_sym)
      array << OpenStruct.new(name: move.name, move_id: id.to_s)
      array
    end
  end

  def usable_moves
    non_passive_moves + player_moves
  end

  def shaped_usable_moves
    usable_moves.map do |em|
      move = Move.find(em.move_id.to_sym)
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
    if can_buff?(buff_id)
      self.buffs << buff_id
      team.battle.add_display_update(self, :buffs, self.buffs)
      return true
    else
      return false
    end
  end

  def remove_debuff(debuff_id=nil)
    if(debuff_id)
      self.debuffs.delete(debuff_id)
      team.battle.add_display_update(self, :debuffs, self.debuffs)
    else
      self.debuffs.delete(self.debuffs.sample)
      team.battle.add_display_update(self, :debuffs, self.debuffs)
    end
  end

  def remove_buff(buff_id=nil)
    if(buff_id)
      self.buffs.delete(buff_id)
      team.battle.add_display_update(self, :buffs, self.buffs)
    else
      self.buffs.delete(self.buffs.sample)
      team.battle.add_display_update(self, :buffs, self.buffs)
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

  def has_buff?(buff_id)
    buffs.include?(buff_id)
  end

  def can_debuff?(debuff_id)
    if(
      has_debuff?(debuff_id) ||
      (debuff_id == 'hesitant' && can_move?(:no_fear)) ||
      (debuff_id == 'panic' && can_move?(:no_fear)) ||
      (debuff_id == 'despair' && can_move?(:no_fear))
    )
      return false
    else
      return true
    end
  end

  def can_buff?(buff_id)
    if(
      has_buff?(buff_id)
    )
      return false
    else
      return true
    end
  end
  
  def can_move?(move_id)
    usable_moves.find{|move| move.move_id == move_id}
  end

  def reset_state
    reload
    self.time_units = TimeUnit.multiplied(TimeUnit.max)
    self.health = self.max_health
    self.buffs = []
    self.debuffs = []
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
      moves: shaped_usable_moves,
      buffs: buffs,
      debuffs: debuffs
    }
  end

  def customization_data
    reload
    equip_ids = equipped_moves.map{|em| em.move_id}
    {
      id: id,
      name: name,
      number_equipped_moves: equip_ids.count,
      max_equipped_moves: max_moves,
      image: ActionController::Base.helpers.image_url(image),
      health: max_health,
      smarts: species['smarts'],
      experience: {
        total: total_experience,
        natures: state['experience']['nature'].map{|key, value| {id: key, name: Nature.name_for(key), value: value} }
      },
      moves: known_moves.map do |km|
        { move_id: km.move_id,
          name: Move.find(km.move_id).name,
          equipped: equip_ids.include?(km.move_id)
        }
      end
    }
  end

  def equip_move(move_id)
    if(equipped_moves.count < max_moves && known_moves.where(move_id: move_id).count > 0)
      EquippedMove.create(spirit: self, move_id: move_id)
      if(team.try(:character))
        team.character.world.broadcast_update_for(team.character.user)
      end
    end
  end

  def unequip_move(move_id)
    if(equipped_moves.count > 1)
      target_move = equipped_moves.find_by(move_id: move_id)
      target_move.destroy
      if(team.try(:character))
        team.character.world.broadcast_update_for(team.character.user)
      end
    end
  end
  
  def advance_time
    self.time_units -= TimeUnit.multiplier/4 if(has_debuff?('hesitant'))
    self.time_units -= TimeUnit.multiplier/3 if(has_debuff?('panic'))
    self.time_units += TimeUnit.multiplier
    
    if(has_buff?('regenerate'))
      self.health += 1
      team.battle.add_display_update(self, :health, health)
      if(health >= max_health)
        remove_buff('regenerate')
        team.battle.add_text("#{name} has finished regenerating!")
      end
    end

    self.save!
    team.battle.add_display_update(self, :time_units, TimeUnit.reduced(time_units))
  end

  def reduce_time_units(amount)
    amount = TimeUnit.multiplied(amount)
    if(time_units - amount >= 0)
      self.time_units -= amount
      return true
    else
      return false
    end
  end

  def reduce_time_units!(amount)
    self.time_units -= TimeUnit.multiplied(amount)
    if time_units < 0
      self.time_units = 0
    end
  end

  def swap_in
    reduce_time_units!(swap_cost)
    self.save!
  end

  def species
    Species.find(species_id)
  end

  def swap_cost
    2
  end

  def total_experience
    state['experience']['total']
  end

  def nature_experience(nature_id)
    state['experience']['nature'][nature_id]
  end

  def species_experience(species_id)
    state['experience']['species'][species_id.to_s] || 0
  end

  def add_experience_from(spirit)
    species = Species.find(spirit.species_id)
    amount = (species['type']=='eidolon') ? 3 : 1
    state['experience']['total'] += amount
    state['experience']['nature'][species['nature_id']] += amount
    state['experience']['species'][species['id']] = species_experience(species_id) + 1
    self.save!
    learnable_moves.each do |move_id|
      KnownMove.create(spirit: self, move_id: move_id)
      team.add_text("#{name} learned a new technique! #{name} now knows '#{Move.find(move_id).name}'")
    end
  end


  def learnable_moves
    known_move_ids = known_moves
    move_data = Species.find(species_id)['learnable_moves']
    return [] unless move_data
    move_data = move_data.select do |learnable_move|
      ignored = known_moves.map(&:id).include?(learnable_move['id'])
      !ignored && total_experience >= learnable_move['experience']['total']
    end
    move_data.map{|learnable_move| learnable_move['id']}
  end

private
  def setup
    spec = species
    self.name ||= spec['name']
    self.max_health = spec['max_health']
    self.health = self.max_health
    self.time_units = TimeUnit.multiplied(TimeUnit.max) 
    self.image = spec['image']
    self.buffs = []
    self.debuffs = []
    self.state = {
      experience: {
        total: 0,
        nature: {
          faith: 0,
          fear: 0,
          persistence: 0,
          passion: 0,
          cunning: 0,
          strength: 0
        },
        species: {}
      }
    }
  end

  def setup_associations
    moves = species['starting_moves']
    moves.each do |move_id|
      KnownMove.create(spirit: self, move_id: move_id)
    end
    EquippedMove.create(spirit: self, move_id: moves.first)
  end
end
