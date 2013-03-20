require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "A game is smart enough to know that an updated_at string is in UTC" do
    game = Game.new(updated_at: '2013-03-13 09:03:24') # (1-ish PDT)
    assert_equal 'UTC', game.updated_at.zone
  end
end
