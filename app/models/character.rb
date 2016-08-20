class Character < ApplicationRecord
  belongs_to :user
  belongs_to :world, required: false
end
