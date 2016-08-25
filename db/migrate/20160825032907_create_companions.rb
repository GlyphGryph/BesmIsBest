class CreateCompanions < ActiveRecord::Migration[5.0]
  def change
    create_table :companions do |t|
      t.string :image
      t.integer :hp
      t.integer :ap
      t.integer :max_hp
      t.string :name

      t.timestamps
    end
  end
end
