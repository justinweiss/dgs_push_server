require 'test_helper'
require 'mocha/setup'

class FetchGamesForPlayerTest < ActiveSupport::TestCase
  include FetchGamesWorkerTests

  test "When a player isn't ready for checking, the fetcher does nothing" do
    players(:justin).update_attribute(:last_checked_at, Time.now)
    assert_difference "Rapns::Apns::Notification.count", 0 do
      # The request will fail if this actually tried to make it
      worker_class.new.perform(players(:justin).id)
    end
  end

  private

  def worker_class
    FetchGamesForPlayer
  end
end
