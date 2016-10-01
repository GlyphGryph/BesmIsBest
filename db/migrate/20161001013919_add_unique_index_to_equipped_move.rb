class AddUniqueIndexToEquippedMove < ActiveRecord::Migration[5.0]
  def change
    add_index :equipped_moves, [:spirit_id, :move_id], unique: true
  end
end
