require 'test_helper'

class GameMergerTest < ActiveSupport::TestCase

  test "The game merger class can merge two sets of games" do
    game_csv = File.read(File.expand_path("test/fixtures/sample_responses/game_list.csv"))
    new_games = GameCSVParser.new(game_csv).games
    old_game_data = [{dgs_game_id: new_games.first.dgs_game_id}, {}, {}]

    old_games = GameCSVParser.new(csv_for_game_data(old_game_data)).games
    game_merger = GameMerger.new(old_games, new_games)

    assert_equal 1, game_merger.added_games.length
    assert_equal 783006, game_merger.added_games.first.dgs_game_id

    assert_equal 2, game_merger.removed_games.length
    assert_equal 1001, game_merger.removed_games.first.dgs_game_id

    assert_equal 1, game_merger.existing_games.length
    assert_equal 765115, game_merger.existing_games.first.dgs_game_id
  end

  test "A game is considered new if it's newer than an existing game" do
    game_csv = File.read(File.expand_path("test/fixtures/sample_responses/game_list.csv"))
    new_games = GameCSVParser.new(game_csv).games
    old_game_data = [{dgs_game_id: new_games.first.dgs_game_id, updated_at: new_games.first.updated_at - 1.day}, {}, {}]

    old_games = GameCSVParser.new(csv_for_game_data(old_game_data)).games
    game_merger = GameMerger.new(old_games, new_games)

    assert_equal 2, game_merger.added_games.length
    assert_equal 765115, game_merger.added_games.first.dgs_game_id

    assert_equal 2, game_merger.removed_games.length
    assert_equal 1001, game_merger.removed_games.first.dgs_game_id

    assert_equal 0, game_merger.existing_games.length
  end
end
