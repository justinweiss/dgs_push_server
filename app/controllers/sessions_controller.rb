class SessionsController < ApplicationController
  respond_to :json

  def create
    @player = Player.find_by_dgs_user_id!(params[:player_id])
    @session = @player.session || @player.build_session
    @session.update_attributes(session_params)
    respond_with @player, @session, :location => nil
  end

  private

  def session_params
    params.require(:session).permit(:cookie, :expires_at)
  end
end
