class Species
  @@eidolons = HashWithIndifferentAccess.new(YAML.load(File.read(File.join(Rails.root,'app','data','species','eidolons.yml'))))
  @@figments = HashWithIndifferentAccess.new(YAML.load(File.read(File.join(Rails.root,'app','data','species','figments.yml'))))
  @@species = @@eidolons.merge(@@figments)

  def self.eidolons
    @@eidolons.values
  end

  def self.eidolons_with_nature(nature_id)
    eidolons.select{|ss| ss['nature_id'] == nature_id}
  end

  def self.find(id)
    @@species[id.to_s]
  end

  def self.all
    @@species.values
  end

  def self.sample
    all.sample
  end
end
