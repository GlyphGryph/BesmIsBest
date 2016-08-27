class CreateCharacterSpirits < ActiveRecord::Migration[5.0]
  def change
    create_table :character_spirits do |t|
      t.integer :character_id
      t.integer :spirit_id
      t.integer :position

      t.timestamps
    end
  end
end
