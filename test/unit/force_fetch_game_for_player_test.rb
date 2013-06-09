require 'test_helper'
require 'mocha/setup'

class ForceFetchGamesForPlayerTest < ActiveSupport::TestCase
  include FetchGamesWorkerTests

  test "When a player isn't ready for checking, the fetcher still fetches and notifications are sent" do
    players(:justin).update_attribute(:last_checked_at, Time.now)
    mock_dgs_with_response(game_csv(1)) do
      assert_difference "Rapns::Apns::Notification.count", 1 do
        worker_class.new.perform(players(:justin).id)
        assert 1.minute.ago < players(:justin).reload.last_checked_at, "last_checked_at should have been updated"
      end
    end
  end

  private

  def worker_class
    ForceFetchGamesForPlayer
  end
end
