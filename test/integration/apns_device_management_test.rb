require 'test_helper'

class ApnsDeviceManagementTest < ActionDispatch::IntegrationTest

  setup do
    @headers = {"X_BUNDLE_IDENTIFIER" => 'net.uberweiss.DGS'}
  end

  test "The players controller can't be accessed" do
    assert_not_routed { get '/players' }
    assert_not_routed { get '/players/1.json' }
    assert_not_routed { post '/players.json', last_checked_at: Time.now }
  end

  test "The devices controller can't be hit with the html format" do
    post '/players/1/devices.json', {device: {device_token: "ABC123"}}, @headers
    assert_response :success

    assert_not_routed do
      post '/players/1/devices', {device: {device_token: "ABC123"}}
    end
  end

  private
  def assert_not_routed(&block)
    assert_raises ActionController::RoutingError, &block
  end
end
