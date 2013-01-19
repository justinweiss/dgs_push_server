class ApnsDevice < ActiveRecord::Base
  belongs_to :player, inverse_of: :apns_devices
  belongs_to :rapns_app, class_name: "Rapns::Apns::App"
  attr_accessible :device_token

  validates_presence_of :device_token, :rapns_app, :player
  validates_uniqueness_of :device_token

  def dgs_user_id
    player.dgs_user_id
  end

  def as_json(options = {})
    super(:only => [:id, :device_token], :methods => [:dgs_user_id])
  end
end
