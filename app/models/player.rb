class Player < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  has_many :games, dependent: :destroy, inverse_of: :player
  has_many :apns_devices, dependent: :destroy, inverse_of: :player
  has_one :session, dependent: :destroy, inverse_of: :player

  validates_presence_of :dgs_user_id
  validates_uniqueness_of :dgs_user_id

  before_create :set_last_checked_at

  scope :ready_for_fetching, lambda { where('last_checked_at < ?', 15.minutes.ago)}

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
    added_games, removed_games, existing_games = Game.merge_games(self.games, new_games)
    self.games = existing_games + added_games
    create_notifications_for_games!(added_games, existing_games)
    added_games
  end

  private

  def alert_message(added_games, existing_games)
    opponents = added_games.map(&:opponent_name).uniq
    games = added_games
    if opponents.length > 3
      message = "#{games.length} games are ready for you to move."
    else
      message = "#{opponents.to_sentence} #{opponents.length == 1 ? 'is' : 'are'} ready for you to move."
    end
  end

  def create_notifications_for_games!(added_games, existing_games)
    return if added_games.empty?
    games = added_games + existing_games
    self.apns_devices.each do |device|
      n = Rapns::Apns::Notification.new
      n.app = device.rapns_app
      n.device_token = device.device_token
      n.alert = alert_message(added_games, existing_games)
      n.badge = games.length
      # Fail silently
      n.save
    end
  end

  def set_last_checked_at
    self.last_checked_at = Time.now
  end
end
