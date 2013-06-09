class GamesController < ApplicationController
  respond_to :json
  before_filter :load_player

  def update_all
    games = params[:games].map do |dgs_game_id, game_params|
      attributes = game_params.merge(dgs_game_id: dgs_game_id, created_at: game_params[:updated_at])
      attributes.slice!(:dgs_game_id, :opponent_name, :created_at, :updated_at, :player)
      Game.new(attributes)
    end

    @player.games = GameMerger.new(@player.games, games).current_games
    respond_with :nothing
  end

  def move
    game = @player.games.find_by_dgs_game_id!(params[:id])
    if game.opponent
      game.destroy
      ForceFetchGamesForPlayer.perform_async(game.opponent.id)
    end

    respond_with @player, game, location: nil
  end

  private
  def load_player
    @player = Player.find_by_dgs_user_id!(params[:player_id])
  end
end
