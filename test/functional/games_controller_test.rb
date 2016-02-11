require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  include JSONRequiredTest

  setup do
    @app_id = "net.uberweiss.DGS"
    @request.env["HTTP_X_BUNDLE_IDENTIFIER"] = @app_id
    @request.accept = "application/json"
  end

  # Post data looks like this:
  # {"games"=>{"789720"=>{"opponent_name"=>"SimpleHarry", "updated_at"=>"2013-03-13 12:44:15"}, "783006"=>{"updated_at"=>"2013-03-13 08:03:24", "opponent_name"=>"Catlemur"}, "795142"=>{"opponent_name"=>"Tatsumaki", "updated_at"=>"2013-03-13 13:23:10"}}, "player_id"=>"53292"}""}"}}
  # GamesControllerTest#update_all (global)
  test "If we get a list of games, they should be placed in the database" do
    player = players(:player_without_games)
    assert_difference "Game.count", 3 do
      put :update_all, player_id: player.dgs_user_id, games: {
        '1' => {opponent_name: 'Bob', updated_at: '2013-03-13 08:03:24'},
        '2' => {opponent_name: 'Bill', updated_at: '2013-03-13 08:03:24'},
        '3' => {opponent_name: 'Dave', updated_at: '2013-03-13 08:03:24'},
      }
    end
    assert_equal 'Dave', Game.last.opponent_name
    assert_equal 3, Game.last.dgs_game_id
    assert_equal player.id, Game.last.player.id
    assert_equal '2013-03-13 08:03:24', Game.last.created_at.strftime('%Y-%m-%d %H:%M:%S')
  end

  test "When we get a list of games, we should replace the existing games with our games" do
    player = players(:justin)
    game = player.games.first
    assert game, "Main player should have a game"
    assert_difference "Game.count", 3 - player.games.length do
      put :update_all, player_id: player.dgs_user_id, games: {
        '1' => {opponent_name: 'Bob', updated_at: '2013-03-13 08:03:24'},
        '2' => {opponent_name: 'Bill', updated_at: '2013-03-13 08:03:24'},
        '3' => {opponent_name: 'Dave', updated_at: '2013-03-13 08:03:24'},
      }
    end

    assert_equal 'Dave', Game.last.opponent_name
    assert_equal 3, Game.last.dgs_game_id
    assert_equal player.id, Game.last.player.id
    refute Game.find_by_id(game.dgs_game_id), "Original game should not have been found."
  end

  test "When we don't get a list of games, we should delete all the player's games" do
    player = players(:justin)
    game = player.games.first
    assert game, "Main player should have a game"
    assert_difference "Game.count", -player.games.length do
      put :update_all, player_id: player.dgs_user_id
    end

    assert_equal 0, player.reload.games.count
  end

  test "index returns a list of games by last move time" do
    player = players(:justin)
    get :index, player_id: player.to_param, after: (games(:justins_not_so_recent_game).updated_at + 1.day).to_s(:db)
    assert_equal 1, JSON.parse(response.body).count
  end

  test "index doesn't return games made in the same second as the query" do
    player = players(:justin)
    get :index, player_id: player.to_param, after: games(:justins_not_so_recent_game).updated_at.to_s(:db)
    assert_equal 1, JSON.parse(response.body).count
  end

  test "index returns all games if no value for after is passed" do
    player = players(:justin)
    get :index, player_id: player.to_param
    assert_equal player.games.count, JSON.parse(response.body).count
  end

end
