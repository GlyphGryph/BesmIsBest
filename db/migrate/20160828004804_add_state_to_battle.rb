class AddStateToBattle < ActiveRecord::Migration[5.0]
  def change
    add_column :battles, :state, :jsonb
  end
end
