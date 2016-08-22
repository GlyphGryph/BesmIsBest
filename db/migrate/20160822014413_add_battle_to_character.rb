class AddBattleToCharacter < ActiveRecord::Migration[5.0]
  def change
    add_column :characters, :battle_id, :integer
  end
end
