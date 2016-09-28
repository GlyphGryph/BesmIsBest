class CreateSpiritSubspecies < ActiveRecord::Migration[5.0]
  def change
    create_table :spirit_subspecies do |t|
      t.string :subspecies_id
      t.string :gained_move_id

      t.timestamps
    end
  end
end
