class AddForeignKeys < ActiveRecord::Migration
  def up
    add_foreign_key('games', 'player_id', 'players', 'id')
    add_foreign_key('apns_devices', 'player_id', 'players', 'id')
    add_foreign_key('apns_devices', 'rapns_app_id', 'rapns_apps', 'id')
    add_foreign_key('sessions', 'player_id', 'players', 'id')
  end

  def down
    remove_foreign_key('games', 'player_id')
    remove_foreign_key('apns_devices', 'player_id')
    remove_foreign_key('apns_devices', 'rapns_app_id')
    remove_foreign_key('sessions', 'player_id')
  end
end
