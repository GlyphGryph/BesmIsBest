class Species
  @@species = HashWithIndifferentAccess.new(YAML.load(File.read(File.join(Rails.root,'app','data','species','species.yml'))))

  def self.find(id)
    @@species[id.to_s]
  end
end
