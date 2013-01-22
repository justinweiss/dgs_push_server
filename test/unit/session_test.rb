require 'test_helper'

class SessionTest < ActiveSupport::TestCase

  setup do
    @player = players(:justin)
    @session = Session.first
    @session_params = {cookie: 'test_session_id', expires_at: Time.now + 30.days}
  end

  test "A session can't be updated unless it's possible to make an actual request with the cookie" do
    Session.where(player_id: @player.id).destroy_all
    session = Session.new(@session_params)
    session.player = @player
    session.player.stub(:fetch_new_games!, lambda { raise DGS::NotLoggedInException }) do
      assert !session.valid?, "Session should have been invalid"
      assert_equal "is invalid", session.errors[:cookie].first
      refute session.save, "Save should not have succeeded"
    end
  end

  test "A session isn't updated unless it's better than the one we currently have" do
    old_cookie = @player.session.cookie
    @player.stub(:fetch_new_games!, true) do
      assert !@player.session.update_attributes(@session_params.merge({expires_at: @player.session.updated_at - 1.day})), "Session shouldn't have been updated"
    end
    assert_equal old_cookie, @player.session.reload.cookie
  end

  test "only make a test request when the session changes" do
    old_cookie = @player.session.cookie
    @player.stub(:fetch_new_games!, lambda { raise "Should not have been called!" }) do
      assert @player.session.update_attributes(@session_params.merge({cookie: @player.session.cookie}))
    end
    assert_equal old_cookie, @player.session.reload.cookie
  end

  test "don't allow already expired sessions" do
    Session.where(player_id: @player.id).destroy_all
    session = Session.new(@session_params.merge({expires_at: 1.day.ago}))
    session.player = @player
    assert !session.valid?, "Session should have been invalid"
    assert_equal "is too old", session.errors[:expires_at].first
    refute session.save, "Save should not have succeeded"
  end

end
