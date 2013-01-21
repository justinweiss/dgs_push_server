class ApnsDevice < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :player, inverse_of: :apns_devices
  belongs_to :rapns_app, class_name: "Rapns::Apns::App"

  validates_presence_of :device_token, :rapns_app, :player
  validates_uniqueness_of :device_token

  scope :find_by_encoded_device_token, lambda { |encoded_token| where(device_token: decode_device_token(encoded_token)) }

  after_update :touch_if_unchanged

  # An encoded device token is a base64-encoded push token which
  # contains binary data. A device token is the decoded, string
  # representation of that data.
  def encoded_device_token=(value)
    self.device_token = self.class.decode_device_token(value)
  end

  def dgs_user_id
    player.dgs_user_id
  end

  def as_json(options = {})
    super(:only => [:id, :device_token], :methods => [:dgs_user_id])
  end

  private

  # Always update the device's timestamps, so we can see if they're
  # still being used.
  def touch_if_unchanged
    touch if previous_changes.empty?
  end

  def self.decode_device_token(encoded_token)
    return nil unless encoded_token
    Base64.decode64(encoded_token).unpack("H*").first
  end
end
