# Always fetch the games for the player, even if they've been recently
# fetched. This is mostly used when we know there's going to be
# updated games, because someone just played a move against this
# player.
class ForceFetchGamesForPlayer
  include Sidekiq::Worker
  def perform(player_id)
    player = Player.find_by_id(player_id)
    player && player.fetch_new_games!
  end
end
