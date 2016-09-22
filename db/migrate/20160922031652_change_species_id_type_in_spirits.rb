class ChangeSpeciesIdTypeInSpirits < ActiveRecord::Migration[5.0]
  def up
    change_column :spirits, :species_id, :string
  end

  def down
    change_column :spirits, :species_id, :id
  end
end
