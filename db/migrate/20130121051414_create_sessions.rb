class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.references :player
      t.string :cookie
      t.datetime :expires_at

      t.timestamps
    end
    add_index :sessions, :player_id
  end
end
