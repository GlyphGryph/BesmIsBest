class AddCurrentTeamIdToBattle < ActiveRecord::Migration[5.0]
  def change
    add_column :battles, :current_team_id, :integer
  end
end
