class CreateApnsDevices < ActiveRecord::Migration
  def change
    create_table :apns_devices do |t|
      t.references :player, :null => false
      t.references :rapns_app, :null => false
      t.string :device_token, :null => false

      t.timestamps
    end
    add_index :apns_devices, :player_id
    add_index :apns_devices, :rapns_app_id
    add_index :apns_devices, :device_token, :unique => true
  end
end
