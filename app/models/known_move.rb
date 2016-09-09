class KnownMove < ApplicationRecord
  belongs_to :spirit
  validates_uniqueness_of :move_id, :scope => [:spirit_id]
end
