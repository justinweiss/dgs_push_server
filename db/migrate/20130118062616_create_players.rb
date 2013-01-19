class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :dgs_user_id, :null => false
      t.datetime :last_checked_at, :null => false

      t.timestamps
    end
    add_index :players, :dgs_user_id, :unique => true
    add_index :players, :last_checked_at
  end
end
