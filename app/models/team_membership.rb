class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :spirit, dependent: :destroy
  validates :team, presence: true
  validates :spirit, uniqueness: {scope: :team}, presence: true
end
