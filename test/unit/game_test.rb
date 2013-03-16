require 'test_helper'

class GameTest < ActiveSupport::TestCase

  test "The game class can merge two sets of games" do
    game_csv = File.read(File.expand_path("test/fixtures/sample_responses/game_list.csv"))
    new_games = GameCSVParser.new(game_csv).games
    old_game_data = [{dgs_game_id: new_games.first.dgs_game_id}, {}, {}]

    old_games = GameCSVParser.new(csv_for_game_data(old_game_data)).games
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
    new_games = GameCSVParser.new(game_csv).games
    old_game_data = [{dgs_game_id: new_games.first.dgs_game_id, updated_at: new_games.first.updated_at - 1.day}, {}, {}]

    old_games = GameCSVParser.new(csv_for_game_data(old_game_data)).games
    added, deleted, existing = Game.merge_games(old_games, new_games)

    assert_equal 2, added.length
    assert_equal 765115, added.first.dgs_game_id

    assert_equal 2, deleted.length
    assert_equal 1001, deleted.first.dgs_game_id

    assert_equal 0, existing.length
  end

  test "A game is smart enough to know that an updated_at string is in UTC" do
    game = Game.new(updated_at: '2013-03-13 09:03:24') # (1-ish PDT)
    assert_equal 'UTC', game.updated_at.zone
  end
end
