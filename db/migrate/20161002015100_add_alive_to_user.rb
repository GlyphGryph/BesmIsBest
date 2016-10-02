class AddAliveToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :alive, :bool, null: false, default: false
  end
end
