class DropCharacterSpirits < ActiveRecord::Migration[5.0]
  def up
    drop_table :character_spirits
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
