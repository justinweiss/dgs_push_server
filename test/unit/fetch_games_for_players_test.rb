require 'test_helper'

class FetchGamesForPlayersTest < ActiveSupport::TestCase

  setup do
    @player_count = Player.can_fetch.can_notify.ready_for_fetching.count
  end

  test "All players who are ready for fetching get queued" do
    assert_difference "FetchGamesForPlayer.jobs.size", @player_count do
      FetchGamesForPlayers.new.perform
    end
  end

  test "Players without tokens don't get queued" do
    players(:justin).apns_devices.delete_all
    assert_difference "FetchGamesForPlayer.jobs.size", @player_count - 1 do
      FetchGamesForPlayers.new.perform
    end
  end

  test "Players with expired sessions still get queued" do
    # We want these people to get queued so we can send them a message
    # before we clear out their session.
    players(:justin).session.update_attributes(expires_at: 1.day.ago)
    assert_difference "FetchGamesForPlayer.jobs.size", @player_count do
      FetchGamesForPlayers.new.perform
    end
  end

  test "Players without sessions don't get queued" do
    players(:justin).session.delete
    assert_difference "FetchGamesForPlayer.jobs.size", @player_count - 1 do
      FetchGamesForPlayers.new.perform
    end
  end
end
