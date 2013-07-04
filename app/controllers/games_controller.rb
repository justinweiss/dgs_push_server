require 'time'
class GamesController < ApplicationController
  respond_to :json
  before_filter :load_player
  before_filter :normalize_after_params, :only => :index

  def index
    scope = @player.games
    scope = scope.where('updated_at >= ?', params[:after]) if params[:after]
    respond_with scope
  end

  def update_all
    games = Array(params[:games]).map do |dgs_game_id, game_params|
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

  # sqlite does milliseconds here, which is way more precise than we
  # have. So here, we have to do '>= time + 1 second' instead of '>
  # time'
  def normalize_after_params
    if params[:after]
      params[:after] = (Time.parse(params[:after]) + 1.second).to_s(:db)
    end
  end

  def load_player
    @player = Player.find_by_dgs_user_id!(params[:player_id])
  end
end
