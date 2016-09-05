class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :spirit, dependent: :destroy
end
