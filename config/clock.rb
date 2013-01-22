require 'sidekiq'
require_relative "../app/workers/fetch_games_for_players"


module Clockwork
  every 1.minute, "fetch.games" do
    FetchGamesForPlayers.perform_async
  end
end
