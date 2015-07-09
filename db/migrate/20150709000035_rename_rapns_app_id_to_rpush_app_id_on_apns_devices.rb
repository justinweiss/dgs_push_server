class RenameRapnsAppIdToRpushAppIdOnApnsDevices < ActiveRecord::Migration
  def change
    change_table :apns_devices do |t|
      t.rename :rapns_app_id, :rpush_app_id
    end
  end
end
