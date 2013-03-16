class GamesController < ApplicationController
  respond_to :json
  before_filter :load_player

  def update_all
    @player.games = params[:games].map do |dgs_game_id, game_params|
      attributes = game_params.merge(dgs_game_id: dgs_game_id)
      attributes.slice!(:dgs_game_id, :opponent_name, :updated_at, :player)
      Game.new(attributes)
    end

    respond_with :nothing
  end

  private
  def load_player
    @player = Player.find_by_dgs_user_id!(params[:player_id])
  end
end
