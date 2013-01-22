require 'test_helper'

class FetchGamesForPlayersTest < ActiveSupport::TestCase
  test "All players who are ready for fetching get queued" do
    assert_difference "FetchGamesForPlayer.jobs.size", 2 do
      FetchGamesForPlayers.new.perform
    end
  end
end
