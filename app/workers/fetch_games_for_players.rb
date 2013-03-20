class FetchGamesForPlayers
  include Sidekiq::Worker
  def perform
    Player.ready_for_fetching.can_fetch.can_notify.find_each do |player|
      FetchGamesForPlayer.perform_async(player.id)
    end
  end
end
