class AddHandleToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :handle, :string
    add_index :players, :handle
  end
end
