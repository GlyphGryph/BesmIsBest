class CreateCharacters < ActiveRecord::Migration[5.0]
  def change
    create_table :characters do |t|
      t.integer :user_id
      t.integer :world_id
      t.integer :xx
      t.integer :yy

      t.timestamps
    end
  end
end
