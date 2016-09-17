class AddStartedToBattle < ActiveRecord::Migration[5.0]
  def change
    add_column :battles, :started, :bool
  end
end
