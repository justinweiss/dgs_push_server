require 'test_helper'

class GameMovesTest < ActionDispatch::IntegrationTest
  test "Playing a move in a game with another registered player triggers a notification" do
    player = players(:player_with_two_tokens)
    game = player.games.first

    assert_difference "ForceFetchGamesForPlayer.jobs.size", 1 do
      post "/players/#{player.dgs_user_id}/games/#{game.dgs_game_id}/move.json"
    end
    assert_equal [game.opponent.id], ForceFetchGamesForPlayer.jobs.last["args"]
  end

  test "Attempting to play a move in a game that doesn't belong to the player triggers a 404" do
    player = players(:player_with_two_tokens)
    assert_difference "Rpush::Notification.count", 0 do
      assert_raises(ActiveRecord::RecordNotFound) do
        post "/players/#{player.dgs_user_id}/games/1/move.json"
      end
    end
  end
end
