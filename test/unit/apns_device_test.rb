require 'test_helper'

class ApnsDeviceTest < ActiveSupport::TestCase
  setup do
    @encoded_token = "wOLZacrtMc/Dcpx/iiy3jl2mg25OV6P0ztWYzqbUUP4="
    @decoded_token = "c0e2d969caed31cfc3729c7f8a2cb78e5da6836e4e57a3f4ced598cea6d450fe"

    @device = ApnsDevice.first
  end

  test "When the encoded token is set, it decodes it and updates the device_token field" do
    refute_equal @decoded_token, @device.device_token
    @device.encoded_device_token = @encoded_token
    assert_equal @decoded_token, @device.device_token
  end

  test "Can find a device by encoded token" do
    encoded_token = encode_device_token(@device.device_token)
    assert_equal @device, ApnsDevice.find_by_encoded_device_token(encoded_token).first
  end
end
