class Nature
  @@natures = HashWithIndifferentAccess.new(YAML.load(File.read(File.join(Rails.root,'app','data','natures','natures.yml'))))

  def self.name_for(id)
    @@natures[id.to_s]['name']
  end

  def self.adjective_for(id)
    @@natures[id.to_s]['adjective']
  end
end
