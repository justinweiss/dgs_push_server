class FetchGamesForPlayer
  include Sidekiq::Worker
  def perform(player_id)
    player = Player.scoped_by_id(player_id).ready_for_fetching.first
    player && player.fetch_new_games!
  end
end
