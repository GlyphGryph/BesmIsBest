class World < ApplicationRecord
  before_save :generate_map
  has_many :characters
  
  def full_map
    map_copy = Marshal.load(Marshal.dump(map))
    characters.each do |c|
      map_copy[c.yy][c.xx] = 1
    end
    map_copy
  end

  def height
    map.length
  end

  def width
    map[0].length
  end

  private
  def generate_map
    unless self.map
      height = 5
      width = 6
      self.map = []
      height.times do
        row = []
        width.times do
          row.push(0)
        end
        self.map.push(row)
      end
    end
  end
end
