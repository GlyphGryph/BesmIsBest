class AddSpeciesIdToSpirit < ActiveRecord::Migration[5.0]
  def change
    add_column :spirits, :species_id, :integer
  end
end
