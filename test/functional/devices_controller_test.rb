require 'test_helper'

class DevicesControllerTest < ActionController::TestCase
  include JSONRequiredTest

  setup do
    @app_id = "net.uberweiss.DGS"
    @request.env["X_BUNDLE_IDENTIFIER"] = @app_id
    @request.accept = "application/json"

    @main_player = players(:justin)
    @main_device = apns_devices(:justins_main_device)
    @main_encoded_device_token = encode_device_token(@main_device.device_token)

    @new_device_token = "7e0fdef2cefd84e7"
    @new_encoded_device_token = encode_device_token(@new_device_token)
  end

  # ApnsDevicesController#create

  test "A new token gets created properly" do
    post :create, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @new_encoded_device_token }
    assert_response :success
    assert_equal @new_device_token, ApnsDevice.last.device_token
    assert_equal @app_id, ApnsDevice.last.rapns_app.name
  end

  test "If we get a new token without a device id but with a player, create the device and associate it with the player" do
    assert_difference "ApnsDevice.count", 1 do
      assert_difference "Player.count", 0 do
        assert_difference "@main_player.reload.apns_devices.count", 1 do
          post :create, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @new_encoded_device_token }
          assert_response :success
        end
      end
    end
  end

  test "If we already have this device token, return the existing token and don't create anything" do

    assert_difference "ApnsDevice.count", 0 do
      assert_difference "Player.count", 0 do
        post :create, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @main_encoded_device_token }
        assert_response :success
        assert_equal @main_device.device_token, assigns(:device).device_token
        assert_equal @main_device.id, assigns(:device).id
        assert_equal @main_player.dgs_user_id, assigns(:device).dgs_user_id
      end
    end
  end

  test "If we already have this device token, but with a different player, re-associate the device token with the new player and don't create a new device" do
    assert_difference "ApnsDevice.count", 0 do
      assert_difference "Player.count", 0 do
        assert_difference "@main_player.reload.apns_devices.count", -1 do
          post :create, player_id: players(:player_without_tokens), device: { encoded_device_token: @main_encoded_device_token }
          assert_response :success
          assert_equal players(:player_without_tokens).dgs_user_id, assigns(:device).dgs_user_id
          assert_equal players(:player_without_tokens).dgs_user_id, @main_device.reload.dgs_user_id
        end
      end
    end
  end

  test "Render a 404 if we don't have an app passed in" do
    @request.env.delete("X_BUNDLE_IDENTIFIER")
    assert_raises(ActiveRecord::RecordNotFound) do
      post :create, player_id: 1000, device: { encoded_device_token: @new_encoded_device_token }
    end
  end

  test "After being created, the app should return a particular set of parameters" do
    post :create, player_id: @main_player, device: { encoded_device_token: @new_encoded_device_token }
    assert_response :success

    assert_correct_response(dgs_user_id: @main_player.dgs_user_id, device_token: @new_device_token)
  end

  # ApnsDevicesController#update
  test "If we match a token but the device id doesn't match, return the matching device id" do
    put :update, id: 100, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @main_encoded_device_token }
    assert_response :success
    assert_equal @main_device.id, assigns(:device).id
  end

  test "If we match a token but the user doesn't match, reassign the token to the passed in user" do

    assert_difference "Player.count", 0 do
      assert_difference "ApnsDevice.count", 0 do
        assert_difference "players(:player_without_tokens).apns_devices.count", 1 do
          put :update, id: @main_device.id, player_id: players(:player_without_tokens).dgs_user_id, device: { encoded_device_token: @main_device.device_token }
        end
      end
    end
    assert_response :success
  end

  test "If we pass in a new token for a device id, update the token" do
    put :update, id: @main_device.id, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @new_encoded_device_token }

    assert_equal @new_device_token, @main_device.reload.device_token
  end

  test "If we pass in completely new data, create all the necessary records" do
    assert_difference "Player.count", 0 do
      assert_difference "ApnsDevice.count", 1 do
        put :update, id: 123456, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @new_encoded_device_token }
        assert_response :success
      end
    end
    assert_equal @new_device_token, @main_player.reload.apns_devices.first.device_token
  end

  test "Update returns the correct json" do
    put :update, id: @main_device.id, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @new_encoded_device_token }
    assert_response :success
    assert_correct_response(dgs_user_id: @main_player.dgs_user_id, device_token: @new_device_token)
  end

  test "Can't lookup a token with a different app id for updating" do
    @request.env["X_BUNDLE_IDENTIFIER"] = "net.uberweiss.Unused"
    assert_raises(ActiveRecord::RecordNotFound) do
      put :update, id: @main_device.id, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @new_encoded_device_token }
    end
  end

  test "Render a 404 if we don't have an app passed in for updating" do
    @request.env.delete("X_BUNDLE_IDENTIFIER")
    assert_raises(ActiveRecord::RecordNotFound) do
      put :update, id: @main_device.id, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @new_encoded_device_token }
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      put :update, id: 1000, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @main_encoded_device_token }
    end
  end

  # Delete:
  test "Delete can delete a device by device id" do
    assert_difference "ApnsDevice.count", -1 do
      delete :destroy, player_id: @main_player.dgs_user_id, id: @main_device.id
      assert_response :success
    end
  end

  test "Delete can delete a device by encoded device token" do
    assert_difference "ApnsDevice.count", -1 do
      delete :destroy, player_id: @main_player.dgs_user_id, id: 1234, device: { encoded_device_token: @main_encoded_device_token }
      assert_response :success
    end
  end

  test "Can't lookup a token with a different app id for deleting" do
    @request.env["X_BUNDLE_IDENTIFIER"] = "net.uberweiss.Unused"
    assert_raises(ActiveRecord::RecordNotFound) do
      delete :destroy, player_id: @main_player.dgs_user_id, id: @main_device.id
    end
  end

  test "The token should get touched even if there are no changes" do
    old_timestamp = @main_device.updated_at
    Time.stub :now, 1.minute.from_now do
      put :update, id: @main_device.id, player_id: @main_player.dgs_user_id, device: { encoded_device_token: @main_device.device_token }
      refute_equal old_timestamp, @main_device.reload.updated_at
    end
  end

  private

  def assert_correct_response(options = {})
    response_json = JSON.parse(@response.body)
    assert response_json["id"].present?, "Response should include an id"
    assert_equal options[:device_token], response_json["device_token"]
    assert_equal options[:dgs_user_id], response_json["dgs_user_id"]
    refute response_json["created_at"].present?, "Response should not include timestamps"
  end
end
