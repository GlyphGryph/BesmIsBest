class AddBattleStatesToSpirit < ActiveRecord::Migration[5.0]
  def change
    add_column :spirits, :buffs, :jsonb
    add_column :spirits, :debuffs, :jsonb
    add_column :spirits, :poisons, :jsonb
  end
end
