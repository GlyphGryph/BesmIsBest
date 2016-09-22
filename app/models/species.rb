class Species
  @@eidolons = HashWithIndifferentAccess.new(YAML.load(File.read(File.join(Rails.root,'app','data','species','eidolons.yml'))))
  @@figments = HashWithIndifferentAccess.new(YAML.load(File.read(File.join(Rails.root,'app','data','species','figments.yml'))))
  @@species = @@eidolons.merge(@@figments)

  def self.find(id)
    @@species[id.to_s]
  end

  def self.all_ids
    @@species.map{|key, value| value['id']}
  end

  def self.sample
    all_ids.sample
  end
end
