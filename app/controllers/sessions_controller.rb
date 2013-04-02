class SessionsController < ApplicationController
  respond_to :json
  before_filter :load_player

  def create
    @session = @player.session || @player.build_session
    @session.attributes = session_params
    @session.player.handle = @session.cookie_handle
    @session.save

    respond_with @player, @session, :location => nil
  end

  private

  def load_player
    @player = Player.where(dgs_user_id: params[:player_id]).first_or_initialize
  end

  def session_params
    params.require(:session).permit(:cookie, :expires_at)
  end
end
