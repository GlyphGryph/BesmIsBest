class FixColumnNamesForSpirit < ActiveRecord::Migration[5.0]
  def change
    change_table :spirits do |t|
      t.rename :hp, :health
      t.rename :max_hp, :max_health
      t.rename :ap, :time_units
    end
  end
end
