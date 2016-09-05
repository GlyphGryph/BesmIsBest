class AddBattleIdToTeam < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :battle_id, :integer
  end
end
