class Buff
  def self.find(buff_id)
    # If definition doesn't exist, assume it's a generic buff
    @@buffs[buff_id.to_sym] || OpenStruct.new(
      buff_id: buff_id,
      name: buff_id.capitalize,
      max_stacks: 1
    )
  end

  def self.all
    @@buffs
  end

  @@buffs = {
    pumped: OpenStruct.new(
      buff_id: 'pumped',
      name: 'Pumped',
      max_stacks: 5
    )
  }
end
