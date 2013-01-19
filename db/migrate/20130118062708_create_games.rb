class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :dgs_game_id, :null => false
      t.string :opponent_name
      t.references :player, :null => false

      t.timestamps
    end
    add_index :games, :dgs_game_id
    add_index :games, :player_id
  end
end
