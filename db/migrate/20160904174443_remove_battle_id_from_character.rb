class RemoveBattleIdFromCharacter < ActiveRecord::Migration[5.0]
  def change
    remove_column :characters, :battle_id
  end
end
