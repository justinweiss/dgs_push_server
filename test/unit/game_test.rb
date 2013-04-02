require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "A game is smart enough to know that an updated_at string is in UTC" do
    # Pretty sure this is actually incorrect -- updated_at is in the
    # user's timezone. Can't figure out yet how to get the player's
    # timezone.
    game = Game.new(updated_at: '2013-03-13 09:03:24') # (1-ish PDT)
    assert_equal 'UTC', game.updated_at.zone
  end

  test "A game's opponent can be matched to a player" do
    game = games(:game_vs_justin)
    assert_equal players(:justin), game.opponent
  end

  test "If a game's opponent can't be matched, just return nil" do
    game = games(:justins_first_game)
    assert_equal nil, game.opponent, "Opponent should be nil"
  end
end
