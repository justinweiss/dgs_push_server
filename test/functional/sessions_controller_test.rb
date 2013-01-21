require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  include JSONRequiredTest

  setup do
    @main_player = players(:justin)
    @request.accept = "application/json"
  end

  test "Creating a session for a nonexistent player fails" do
    Session.where(player_id: @main_player.id).destroy_all
    assert_raises ActiveRecord::RecordNotFound do
      post :create, player_id: 1000, session: {cookie: "123456", expires_at: 10.minutes.from_now}
    end
  end

  test "Creating a session for a player works properly" do
    Session.where(player_id: @main_player.id).destroy_all
    assert_difference "Session.count", 1 do
      post :create, player_id: @main_player, session: {cookie: "123456", expires_at: 10.minutes.from_now}
      assert_response :success
    end

    assert @main_player.session, "Session should have been created"
    assert_equal '123456', @main_player.session.cookie
  end

  test "Creating a session for a player who already has a session updates that session" do
    assert @main_player.session, "The player should already have a session"
    old_session = @main_player.session

    assert_difference "Session.count", 0 do
      post :create, player_id: @main_player, session: {cookie: "123456", expires_at: 10.minutes.from_now}
      assert_response :success
    end

    @main_player.reload
    refute_equal old_session.cookie, @main_player.session.cookie, "Cookie should be different"
    refute_equal old_session.expires_at, @main_player.session.expires_at, "Expires at should be different"
  end
end
