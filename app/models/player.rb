class Player < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  has_many :games, dependent: :destroy, inverse_of: :player
  has_many :apns_devices, dependent: :destroy, inverse_of: :player
  has_one :session, dependent: :destroy, inverse_of: :player

  validates_presence_of :dgs_user_id
  validates_uniqueness_of :dgs_user_id

  before_create :set_last_checked_at

  scope :can_fetch, lambda { joins('left outer join sessions on sessions.player_id = players.id').where("sessions.id is not null") }
  scope :can_notify, lambda { joins('left outer join apns_devices on apns_devices.player_id = players.id').where("apns_devices.id is not null") }
  scope :ready_for_fetching, lambda { where('last_checked_at < ?', 15.minutes.ago) }

  def to_param
    dgs_user_id
  end

  # Makes a request to DGS, merges the games, and adds any needed
  # notifications to the notification list.
  def fetch_new_games!(session = self.session)
    game_csv = nil
    DGS::ConnectionPool.with do |dgs|
      game_csv = dgs.get(session, '/quick_status.php?version=2')
    end
    new_games = GameCSVParser.new(game_csv).games
    game_merger = GameMerger.new(self.games, new_games)
    self.games = game_merger.current_games
    create_notifications_for_games!(game_merger)
    game_merger.added_games
  end

  private

  def alert_message(game_merger)
    opponents = game_merger.added_games.map(&:opponent_name).uniq

    if opponents.length > 3
      message = "#{game_merger.current_games.length} games are ready for you to move."
    else
      message = "#{opponents.to_sentence} #{opponents.length == 1 ? 'is' : 'are'} ready for you to move."
    end
  end

  def create_notifications_for_games!(game_merger)
    return if game_merger.added_games.empty?
    self.apns_devices.each do |device|
      n = Rapns::Apns::Notification.new
      n.app = device.rapns_app
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
