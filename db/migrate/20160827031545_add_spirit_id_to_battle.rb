class AddSpiritIdToBattle < ActiveRecord::Migration[5.0]
  def change
    add_column :battles, :spirit_id, :integer
  end
end
