class Player < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  has_many :games, dependent: :destroy, inverse_of: :player
  has_many :apns_devices, dependent: :destroy, inverse_of: :player
  has_one :session, dependent: :destroy, inverse_of: :player

  validates_presence_of :dgs_user_id
  validates_uniqueness_of :dgs_user_id

  before_create :set_last_checked_at

  scope :can_fetch, lambda { select('players.*').joins('inner join sessions on sessions.player_id = players.id').uniq }
  scope :can_notify, lambda { select('players.*').joins('inner join apns_devices on apns_devices.player_id = players.id').uniq }
  scope :ready_for_fetching, lambda { where('last_checked_at < ?', 15.minutes.ago) }

  # Translates the local id into a DGS user id, so our urls can all be
  # in terms of what DGS knows. This will make interfacing with other
  # apps easier.
  def to_param
    dgs_user_id
  end

  def handle=(value)
    # Don't update the handle if it's blank or nil
    write_attribute(:handle, value) if value.present?
    value
  end

  # Fetch new games and notify the player if we have new games or get
  # logged out. This will be a noop if the player doesn't have a
  # session or device tied to their account, since we won't bother
  # notifying them anyway! If this ever becomes more than just a push
  # server, we'll probably need to loosen that restriction.
  def fetch_new_games!
    if session && apns_devices.length > 0
      ActiveRecord::Base.transaction do
        if session.expired?
          handle_expired_session
        else
          fetch_games
        end
      end
    end
  ensure
    touch(:last_checked_at)
  end

  private

  # Makes a request to DGS, merges the games, and adds any needed
  # notifications to the notification list.
  def fetch_games
    game_csv = nil
    DGS::ConnectionPool.with do |dgs|
      game_csv = dgs.get(session, '/quick_status.php?version=2')
    end
    new_games = GameCSVParser.new(game_csv).games
    game_merger = GameMerger.new(self.games, new_games)
    self.games = game_merger.current_games
    create_notifications_for_games!(game_merger)
    game_merger.added_games
    #   rescue others => report & ignore, blow transaction?
  rescue DGS::NotLoggedInException
    handle_expired_session
  end

  def handle_expired_session
    create_notification_for_expired_session!
    session.destroy
  end

  def alert_message(game_merger)
    opponents = game_merger.added_games.map(&:opponent_name).uniq

    if opponents.length > 3
      message = "#{game_merger.current_games.length} games are ready for you to move."
    else
      message = "#{opponents.to_sentence} #{opponents.length == 1 ? 'is' : 'are'} ready for you to move."
    end
  end

  def create_notification_for_expired_session!
    apns_devices.each do |device|
      n = Rpush::Apns::Notification.new
      n.app = device.rpush_app
      n.device_token = device.device_token
      n.alert = "You have been logged out of DGS"
      # Fail silently
      n.save
    end
  end

  def create_notifications_for_games!(game_merger)
    return if game_merger.added_games.empty?
    self.apns_devices.each do |device|
      n = Rpush::Apns::Notification.new
      n.app = device.rpush_app
      n.device_token = device.device_token
      n.alert = alert_message(game_merger)
      n.badge = game_merger.current_games.length
      # Fail silently
      n.save
    end
  end

  def set_last_checked_at
    self.last_checked_at = Time.now
  end
end
