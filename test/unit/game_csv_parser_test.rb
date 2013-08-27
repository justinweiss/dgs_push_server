require 'test_helper'

class GameCSVParserTest < ActiveSupport::TestCase
  test "The game csv parser can parse a list of games from a CSV" do
    game_csv = File.read(File.expand_path("test/fixtures/sample_responses/game_list.csv"))
    games = GameCSVParser.new(game_csv).games
    assert_equal 2, games.length
    assert_equal 783006, games.second.dgs_game_id
    assert_equal 'Tirog', games.first.opponent_name
    assert_equal Time.utc(2013, 1, 14, 23, 32, 00), games.first.updated_at
  end

  test "The CSV parser re-escapes badly escaped text" do
    game_csv = File.read(File.expand_path("test/fixtures/sample_responses/game_list_with_bad_quotes.csv"))
    games = GameCSVParser.new(game_csv).games
    assert_equal 2, games.length
  end
end
