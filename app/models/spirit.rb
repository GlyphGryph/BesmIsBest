class Spirit < ApplicationRecord
  has_one :team_membership, dependent: :destroy
  has_one :team, through: :team_membership
  has_one :battle, through: :team
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

  def max_subspecies_moves
    1
  end

  def passive_moves
    equipped_moves.map{|em| Move.find(em.move_id)}.select do |move|
      move.has_type?(:passive)
    end
  end
  
  def non_passive_moves
    equipped_moves.map{|em| Move.find(em.move_id)}.select do |move|
      !move.has_type?(:passive)
    end
  end

  def player_moves
    moves = [:wait, :flee]
    if teammates.count > 0
      moves << :swap
    end
    if team.spirits.count < team.max_spirits && !(team.enemy_team.character.try(:user))
      if((!battle) || (battle && team.enemy_spirit.type == 'eidolon'))
        moves << :capture
      end
    end
    moves.map do |id|
      Move.find(id)
    end
  end

  def usable_moves
    non_passive_moves + player_moves
  end

  def shaped_usable_moves
    usable_moves.map do |move|
      {name: move.name, id: move.id, targets: move.targets(self)}
    end
  end

  def apply_debuff(debuff_id)
    if can_debuff?(debuff_id)
      self.debuffs << debuff_id
      apply_updates_for_debuff(buff_id)
      return true
    else
      return false
    end
  end

  def apply_buff(buff_id)
    if can_buff?(buff_id)
      self.buffs << buff_id
      apply_updates_for_buff(buff_id)
      return true
    else
      return false
    end
  end

  def remove_debuff(debuff_id=nil)
    if(debuff_id)
      self.debuffs.delete(debuff_id)
    else
      self.debuffs.delete(self.debuffs.sample)
    end
    apply_updates_for_debuff(buff_id)
  end

  def remove_buff(buff_id=nil)
    if(buff_id)
      self.buffs.delete(buff_id)
    else
      self.buffs.delete(self.buffs.sample)
    end
    apply_updates_for_buff(buff_id)
  end

  def remove_debuffs
    self.debuffs = []
  end

  def remove_buffs
    self.buffs = []
  end

  def apply_updates_for_buff(buff_id)
    if(buff_id == 'shrouded')
      battle.add_display_update(self, :health)
      battle.add_display_update(self, :max_health)
      battle.add_display_update(self, :debuffs)
      battle.add_display_update(self, :time_units)
    end
    battle.add_display_update(self, :buffs)
  end

  def apply_updates_for_debuff(debuff_id)
    battle.add_display_update(self, :debuffs)
  end

  def has_debuff?(debuff_id)
    debuffs.include?(debuff_id)
  end

  def has_buff?(buff_id)
    buffs.include?(buff_id)
  end

  def has_passive?(move_id)
    passive_moves.map(&:move_id).include?(move_id)
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
    !!usable_moves.find{|move| move.id.to_sym == move_id.to_sym}
  end

  def reset_state
    reload
    self.time_units = TimeUnit.multiplied(TimeUnit.max)
    self.health = self.max_health
    self.buffs = []
    self.debuffs = []
  end

  def visible_health
    has_buff?('shrouded') ? '???' : health
  end

  def visible_max_health
    has_buff?('shrouded') ? '???' : max_health
  end

  def visible_time_units
    has_buff?('shrouded') ? '???' : TimeUnit.reduced(time_units)
  end

  def visible_buffs
    has_buff?('shrouded') ? ['shrouded'] : buffs
  end

  def visible_debuffs
    has_buff?('shrouded') ? [] : debuffs
  end

  def visible_state_hash
    {
      name: name,
      health: visible_health,
      max_health: visible_max_health,
      time_units: TimeUnit.reduced(time_units),
      image: ActionController::Base.helpers.image_url(image),
      buffs: buffs,
      debuffs: debuffs,
      teammates: teammate_statuses
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
      debuffs: debuffs,
      teammates: teammate_statuses
    }
  end

  def teammate_statuses
    teammates.map do |mate|
      { name: mate.name,
        alive: mate.alive?
      }
    end
  end

  def teammates
    mates = team.spirits.where.not(id: id)
  end

  def customization_data
    reload
    {
      id: id,
      name: name,
      image: ActionController::Base.helpers.image_url(image),
      health: max_health,
      smarts: species['smarts'],
      species: species['name'],
      subspecies: {
        exists: !!subspecies,
        name: subspecies ? subspecies['name'] : nil,
        moves: shaped_subspecies_equippable_moves,
        number_equipped_moves: equipped_moves.where(belongs_to_subspecies: true).count,
        max_equipped_moves: max_subspecies_moves
      },
      moves: shaped_equippable_moves,
      number_equipped_moves: equipped_moves.count,
      max_equipped_moves: max_moves,
      experience: {
        total: total_experience,
        natures: state['experience']['nature'].map{|key, value| {id: key, name: Nature.name_for(key), value: value} }
      },
      moves: shaped_equippable_moves,
      dismissable: teammates.present?
    }
  end

  def shaped_equippable_moves
    equip_ids = equipped_moves.map(&:move_id)
    equippable_moves = known_moves.map(&:move_id).map do |move_id|
      { move_id: move_id,
        name: Move.find(move_id).name,
        equipped: equip_ids.include?(move_id)
      }
    end
    equippable_moves
  end

  def shaped_subspecies_equippable_moves
    equip_ids = equipped_moves.map(&:move_id)
    equippable_moves = []
    if(subspecies.present?)
      equippable_moves = subspecies['moves'].map do |move_id|
        { move_id: move_id,
          name: Move.find(move_id).name,
          equipped: equip_ids.include?(move_id)
        }
      end
    end
    equippable_moves
  end

  def equip_move(move_id)
    if(equipped_moves.count < max_moves && equipped_moves.where(move_id: move_id).blank?)
      if(known_moves.where(move_id: move_id).present?)
        EquippedMove.create(spirit: self, move_id: move_id)
        if(team.character.present?)
          team.character.world.broadcast_update_for(team.character.user)
        end
      elsif(subspecies['moves'].include?(move_id))
        if(equipped_moves.where(belongs_to_subspecies: true).count < max_subspecies_moves)
          EquippedMove.create(spirit: self, move_id: move_id, belongs_to_subspecies: true)
          if(team.character.present?)
            team.character.world.broadcast_update_for(team.character.user)
          end
        end
      else
        raise "Spirit '#{id} - #{name}' Tried to equip invalid move '#{move_id}'"
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
      battle.add_display_update(self, :health)
      if(health >= max_health)
        remove_buff('regenerate')
        battle.add_text("#{name} has finished regenerating!")
      end
    end

    self.save!
    battle.add_display_update(self, :time_units)
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

  def subspecies
    Species.find(species_id)['subspecies'][subspecies_id]
  end

  def type
    species['type']
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

  def nature_experiences
    state['experience']['nature']
  end

  def species_experience(species_id)
    state['experience']['species'][species_id.to_s] || 0
  end

  def add_experience_from(spirit)
    species = Species.find(spirit.species_id)
    amount = (type=='eidolon') ? 3 : 1
    state['experience']['total'] += amount
    state['experience']['nature'][species['nature_id']] += amount
    state['experience']['species'][species['id']] = species_experience(species_id) + 1
    self.save!
    learn_new_moves
    adopt_new_subspecies
  end
  
  def learn_new_moves
    learnable_moves.each do |move_id|
      KnownMove.create(spirit: self, move_id: move_id)
      team.add_text("#{name} learned a new technique! #{name} now knows '#{Move.find(move_id).name}'")
    end
  end

  def adopt_new_subspecies
    subspecies_found = nil
    nature_experiences.each do |key, value|
      if value > (total_experience * 0.4)
        subspecies_found = subspecies_candidate_for(key)
      end
    end
    if(subspecies_found.try(:[],'id') != subspecies_id)
      if(subspecies_found && subspecies)
        message = "#{name} is changing! #{name} is no longer a '#{subspecies['name']}' and is now a '#{species['subspecies'][subspecies_found['id']]['name']}'!"
      elsif(subspecies_found)
        message = "#{name} is changing! #{name} is now a '#{species['subspecies'][subspecies_found['id']]['name']}'!"
      else
        message = "#{name} is changing! #{name} is no longer a '#{subspecies['name']}'!"
      end
      self.state['subspecies_id'] = subspecies_found.try(:[],'id')
      self.image = subspecies ? subspecies['image'] : species['image']
      team.add_display_update(self, 'image', ActionController::Base.helpers.image_url(image))
      self.save!
      team.add_text(message)
    end
  end

  def subspecies_candidate_for(nature_id)
    return nil unless species['subspecies']
    candidates = species['subspecies'].values.select do |ss|
      ss['nature_id'] == nature_id
    end
    best = candidates.max{|aa, bb| species_experience(aa['id']) <=> species_experience(bb['id'])}
    return nil if best.nil? || (species_experience(best['id']) <= 0)
    return best
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

  def subspecies_id
    state['subspecies_id']
  end

  def dismiss
    if(teammates.count > 0)
      self.destroy
      team.shift_memberships
      if(team.try(:character))
        team.character.world.broadcast_update_for(team.character.user)
      end
    end
  end

  def shift_membership(amount)
    current_membership = team_membership
    target_membership = team.team_memberships.where(position: current_membership.position + amount).first
    if(target_membership.present?)
      current_membership.position = target_membership.position
      target_membership.position -= amount
      current_membership.save!
      target_membership.save!

      if(team.try(:character))
        team.character.world.broadcast_update_for(team.character.user)
      end
    end
  end

  def shift_membership_down
    shift_membership(1)
  end

  def shift_membership_up
    shift_membership(-1)
  end

  def enemy
    team.enemy_spirit
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
      },
      subspecies_id: nil
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
