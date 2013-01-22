require 'test_helper'

class GameTest < ActiveSupport::TestCase

  test "The game class can parse a list of games from a CSV" do
    game_csv = File.read(File.expand_path("test/fixtures/sample_responses/game_list.csv"))
    games = Game.parse_from_csv(game_csv)
    assert_equal 2, games.length
    assert_equal 783006, games.second.dgs_game_id
    assert_equal 'Tirog', games.first.opponent_name
    assert_equal Time.utc(2013, 1, 14, 23, 32, 00), games.first.updated_at
  end

  test "The game class can merge two sets of games" do
    game_csv = File.read(File.expand_path("test/fixtures/sample_responses/game_list.csv"))
    new_games = Game.parse_from_csv(game_csv)
    old_game_data = [{dgs_game_id: new_games.first.dgs_game_id}, {}, {}]

    old_games = Game.parse_from_csv(csv_for_game_data(old_game_data))
    added, deleted, existing = Game.merge_games(old_games, new_games)

    assert_equal 1, added.length
    assert_equal 783006, added.first.dgs_game_id

    assert_equal 2, deleted.length
    assert_equal 1001, deleted.first.dgs_game_id

    assert_equal 1, existing.length
    assert_equal 765115, existing.first.dgs_game_id
  end

  test "A game is considered new if it's newer than an existing game" do
    game_csv = File.read(File.expand_path("test/fixtures/sample_responses/game_list.csv"))
    new_games = Game.parse_from_csv(game_csv)
    old_game_data = [{dgs_game_id: new_games.first.dgs_game_id, updated_at: new_games.first.updated_at - 1.day}, {}, {}]

    old_games = Game.parse_from_csv(csv_for_game_data(old_game_data))
    added, deleted, existing = Game.merge_games(old_games, new_games)

    assert_equal 2, added.length
    assert_equal 765115, added.first.dgs_game_id

    assert_equal 2, deleted.length
    assert_equal 1001, deleted.first.dgs_game_id

    assert_equal 0, existing.length
  end
end
