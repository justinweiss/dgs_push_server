require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  include JSONRequiredTest

  setup do
    @main_player = players(:justin)
    @request.accept = "application/json"
  end

  test "Creating a session for a nonexistent player creates the player" do
    assert_difference "Session.count", 1 do
      assert_difference "Player.count", 1 do
        mock_dgs_with_new_session session_params, @main_player.handle do
          post :create, player_id: 12345, session: session_params
          assert_response :success
        end
      end
    end
  end

  test "Creating a session for a player works properly" do
    Session.where(player_id: @main_player.id).destroy_all
    assert_difference "Session.count", 1 do
      mock_dgs_with_new_session session_params do
        post :create, player_id: @main_player, session: session_params
        assert_response :success
      end
    end

    assert @main_player.session, "Session should have been created"
    assert_equal session_params[:cookie], @main_player.session.cookie
  end

  test "Creating a session for a player who already has a session updates that session" do
    assert @main_player.session, "The player should already have a session"
    old_session = @main_player.session
    session_params = {cookie: dgs_cookie, expires_at: old_session.expires_at + 1.day}

    assert_difference "Session.count", 0 do
      mock_session_test_request(@main_player.handle, @main_player.session) do |dgs|
        post :create, player_id: @main_player, session: session_params
      end
      assert_response :success
    end

    @main_player.reload
    refute_equal old_session.cookie, @main_player.session.cookie, "Cookie should be different"
    refute_equal old_session.expires_at, @main_player.session.expires_at, "Expires at should be different"
  end

  test "Creating a session without a player and a bad session will not create a player" do
    assert_no_difference "Session.count" do
      assert_no_difference "Player.count" do
        mock_dgs do |dgs|
          dgs.expect(:get, nil) { raise DGS::NotLoggedInException }
          post :create, player_id: 12345, session: session_params
        end
      end
    end
  end

  test "Sessions will populate the player handle when creating a player" do
    params = session_params(dgs_cookie('justinweiss'))
    mock_dgs_with_new_session(params, 'justinweiss') do
      assert_difference "Session.count", 1 do
        assert_difference "Player.count", 1 do
          post :create, player_id: 12345, session: params
        end
      end
    end
    assert_equal 'justinweiss', Player.find_by_dgs_user_id(12345).handle
  end

  test "Session updates will update the player handle if it changes" do
    Session.where(player_id: @main_player.id).destroy_all
    refute_equal 'new_handle', @main_player.handle

    params = session_params(dgs_cookie('new_handle'))

    mock_dgs_with_new_session(params, 'new_handle') do
      post :create, player_id: @main_player.dgs_user_id, session: params
    end

    assert_equal 'new_handle', @main_player.reload.handle
  end

  test "Session updates will not update the player handle if it doesn't validate" do
    Session.where(player_id: @main_player.id).destroy_all
    params = session_params(dgs_cookie('new_handle'))

    mock_dgs do |dgs|
      dgs.expect(:get, nil) { raise DGS::NotLoggedInException }
      post :create, player_id: @main_player.dgs_user_id, session: params
    end
    refute_equal 'new_handle', @main_player.reload.handle
  end

  private

  def dgs_cookie(handle = @main_player.handle)
    "cookie_handle=#{handle}; cookie_sessioncode=7062D09AD9DEA0AF3AC2EA1D892D63930CE96EE71"
  end

  def session_params(cookie = dgs_cookie)
    {cookie: cookie, expires_at: 1.week.from_now}
  end
end
