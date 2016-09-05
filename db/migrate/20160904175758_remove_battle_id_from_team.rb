class RemoveBattleIdFromTeam < ActiveRecord::Migration[5.0]
  def change
    remove_column :teams, :battle_id, :integer
  end
end
