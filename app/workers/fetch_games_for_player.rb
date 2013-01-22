class FetchGamesForPlayer
  include Sidekiq::Worker
  def perform(player_id)
    player = Player.scoped_by_id(player_id).ready_for_fetching.first
    if player && player.apns_devices.length > 0 && player.session
      ActiveRecord::Base.transaction do
        if player.session.expired?
          handle_expired_session(player)
        else
          fetch_games(player)
        end
      end
    end
  ensure
    player.touch(:last_checked_at) if player
  end

  private

  def fetch_games(player)
    player.fetch_new_games!
    #   rescue others => report & ignore, blow transaction?
  rescue DGS::NotLoggedInException
    handle_expired_session(player)
  end

  def handle_expired_session(player)
    player.apns_devices.each do |device|
      n = Rapns::Apns::Notification.new
      n.app = device.rapns_app
      n.device_token = device.device_token
      n.alert = "You have been logged out of DGS"
      # Fail silently
      n.save
    end
    player.session.destroy
  end
end
