require 'test_helper'

class PlayerTest < ActiveSupport::TestCase

  setup do
    @main_player = players(:justin)
  end

  test "A new player has their last_checked_at set to the current time" do
    time = Time.mktime(2013, 1, 17)
    Time.stub :now, time do
      @player = Player.create!(dgs_user_id: 42)
    end
    assert_equal time, @player.last_checked_at
  end

  test "An existing player doesn't have their last_checked_at changed on update" do
    time = Time.mktime(2013, 1, 17)
    assert_no_difference "@main_player.last_checked_at" do
      Time.stub :now, time do
        @main_player.update_attributes!(dgs_user_id: 42)
      end
    end
  end

  test "A player can request their list of games" do
    mock_dgs_with_response game_csv(3) do
      @main_player.fetch_new_games!
      games = @main_player.reload.games
      assert_equal 3, games.length
      assert_equal 1000, games.first.dgs_game_id
    end
  end

  test "fetch_new_games! deletes games that are no longer on the server" do
    game = @main_player.games.first
    mock_dgs_with_response game_csv(1) do
      @main_player.fetch_new_games!
    end
    refute_includes @main_player.reload.games, game
  end

  test "fetch_new_games! adds new games to the server" do
    mock_dgs_with_response game_csv(1) do
      @main_player.fetch_new_games!
    end
    assert_includes @main_player.reload.games.map(&:dgs_game_id), 1000
  end

  test "fetch_new_games! creates a push notification if there are new games" do
    assert_difference "Rpush::Apns::Notification.count", 1 do
      mock_dgs_with_response game_csv(1) do
        @main_player.fetch_new_games!
      end
    end
  end

  test "fetch_new_games! doesn't push anything if there aren't any new games" do
    game_data = [{dgs_game_id: 1, updated_at: @main_player.games.first.updated_at}]
    game_list = csv_for_game_data(game_data)

    assert_difference "Rpush::Apns::Notification.count", 0 do
      mock_dgs_with_response game_list do
        @main_player.fetch_new_games!
      end
    end
  end

  test "ready_for_fetching returns only players with games ready for fetching" do
    player = Player.create!(:dgs_user_id => 1)
    refute_includes Player.ready_for_fetching, player
    assert_includes Player.ready_for_fetching, players(:justin)
  end

  test "game messages are generated correctly for a single game" do
    game_list = GameCSVParser.new(csv_for_game_data([{:opponent_name => 'justin'}])).games
    assert_equal "justin is ready for you to move.", Player.new.send(:alert_message, GameMerger.new([], game_list))
  end

  test "game messages are generated correctly for 3 new players" do
    game_data = [{:opponent_name => 'justin'}, {:opponent_name => 'bob'}, {:opponent_name => 'bill'}]
    game_list = GameCSVParser.new(csv_for_game_data(game_data)).games
    assert_equal "justin, bob, and bill are ready for you to move.", Player.new.send(:alert_message, GameMerger.new([], game_list))
  end

  test "game messages are generated correctly for > 3 new games" do
    game_list = GameCSVParser.new(game_csv(4)).games
    assert_equal "4 games are ready for you to move.", Player.new.send(:alert_message, GameMerger.new([], game_list))
  end

  test "game messages are generated correctly for games with duplicate opponents" do
    game_data = [{:opponent_name => 'justin'}, {:opponent_name => 'bob'}, {:opponent_name => 'bill'}, {:opponent_name => 'justin'}]
    game_list = GameCSVParser.new(csv_for_game_data(game_data)).games
    assert_equal "justin, bob, and bill are ready for you to move.", Player.new.send(:alert_message, GameMerger.new([], game_list))
  end

  test "only added opponents are taken into account" do
    game_data = [{:dgs_game_id => 2000, :opponent_name => 'justin'}, {:dgs_game_id => 2001, :opponent_name => 'bob'}]
    game_list = GameCSVParser.new(csv_for_game_data(game_data)).games

    assert_equal "justin and bob are ready for you to move.", Player.new.send(:alert_message, GameMerger.new(GameCSVParser.new(game_csv(2)).games, game_list))
  end
end
