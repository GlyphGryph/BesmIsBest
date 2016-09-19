class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :spirit, dependent: :destroy
  validates :position, uniqueness: {scope: :team}, presence: true
end
