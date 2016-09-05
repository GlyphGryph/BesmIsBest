class CreateTeamMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :team_memberships do |t|
      t.integer :team_id
      t.integer :spirit_id
      t.integer :position
    end
    add_index(:team_memberships, [:team_id, :spirit_id], unique: true)
  end
end
