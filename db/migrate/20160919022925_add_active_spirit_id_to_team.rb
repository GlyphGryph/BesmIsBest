class AddActiveSpiritIdToTeam < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :active_spirit_id, :integer
  end
end
