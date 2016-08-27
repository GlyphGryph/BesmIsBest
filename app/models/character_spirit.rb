class CharacterSpirit < ApplicationRecord
  belongs_to :character
  belongs_to :spirit, dependent: :destroy
end
