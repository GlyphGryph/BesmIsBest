class AddBelongsToSubspeciesToEquippedMove < ActiveRecord::Migration[5.0]
  def change
    add_column :equipped_moves, :belongs_to_subspecies, :bool, default: false, null: false
  end
end
