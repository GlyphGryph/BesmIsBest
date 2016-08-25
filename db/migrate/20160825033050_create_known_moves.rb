class CreateKnownMoves < ActiveRecord::Migration[5.0]
  def change
    create_table :known_moves do |t|
      t.string :move_id
      t.integer :spirit_id

      t.timestamps
    end
  end
end
