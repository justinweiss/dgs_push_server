require 'test_helper'

class PlayerTest < ActiveSupport::TestCase

  test "A new player has their last_checked_at set to the current time" do
    time = Time.mktime(2013, 1, 17)
    Time.stub :now, time do
      @player = Player.create!(dgs_user_id: 42)
    end
    assert_equal time, @player.last_checked_at
  end

  test "An existing player doesn't have their last_checked_at changed on update" do
    time = Time.mktime(2013, 1, 17)
    assert_no_difference "players(:justin).last_checked_at" do
      Time.stub :now, time do
        players(:justin).update_attributes!(dgs_user_id: 42)
      end
    end
  end
end
