class AddStateToTeam < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :state, :jsonb
  end
end
