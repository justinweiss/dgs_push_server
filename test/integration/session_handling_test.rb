require 'test_helper'

class SessionHandlingTest < ActionDispatch::IntegrationTest
  setup do
    @main_player = players(:justin)
  end

  test "Can handle a session being created with cookies" do
    @main_player.session.destroy if @main_player.session
    assert_difference "Session.count", 1 do
      post "/players/#{@main_player.dgs_user_id}/session.json", session_params
    end

  end

  test "Can't hit non-json urls" do
    assert_difference "Session.count", 0 do
      assert_raises ActionController::RoutingError do
        post "/players/#{@main_player.dgs_user_id}/session.html", session_params
      end

      assert_raises ActionController::RoutingError do
        post "/players/#{@main_player.dgs_user_id}/session", session_params
      end
    end
  end

  private

  def session_params
    {session: {cookie: "test cookie", expires_at: 1.week.from_now}}
  end
end
