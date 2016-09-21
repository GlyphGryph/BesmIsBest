class AddStateToSpirit < ActiveRecord::Migration[5.0]
  def change
    add_column :spirits, :state, :jsonb
  end
end
