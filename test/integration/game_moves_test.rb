require 'test_helper'

class GameMovesTest < ActionDispatch::IntegrationTest
  test "Playing a move in a game with another registered player triggers a notification" do
    player = players(:player_with_two_tokens)
    mock_dgs_with_response(game_csv(1)) do
      assert_difference "Rapns::Notification.count", 1 do
        post "/players/#{player.dgs_user_id}/games/#{player.games.first.dgs_game_id}/play.json"
      end
    end
  end

  test "Attempting to play a move in a game that doesn't belong to the player triggers a 404" do
    player = players(:player_with_two_tokens)
    assert_difference "Rapns::Notification.count", 0 do
      assert_raises(ActiveRecord::RecordNotFound) do
        post "/players/#{player.dgs_user_id}/games/1/play.json"
      end
    end
  end
end
