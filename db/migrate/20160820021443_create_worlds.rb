class CreateWorlds < ActiveRecord::Migration[5.0]
  def change
    create_table :worlds do |t|
      t.jsonb :map

      t.timestamps
    end
  end
end
