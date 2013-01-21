class Player < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  has_many :games, dependent: :destroy, inverse_of: :player
  has_many :apns_devices, dependent: :destroy, inverse_of: :player
  has_one :session, dependent: :destroy, inverse_of: :player

  validates_presence_of :dgs_user_id
  validates_uniqueness_of :dgs_user_id

  before_create :set_last_checked_at

  def to_param
    dgs_user_id
  end

  # # Makes a request to DGS, merges the games, and adds any needed
  # # notifications to the notification list.
  # def fetch_new_games!(session = self.session)
  #   games = Game.fetch_games_from_dgs!(session)
  #   added_games = merge_games!(games)
  #   create_notifications_for_games!(added_games)
  #   added_games
  # end

  private

  def set_last_checked_at
    self.last_checked_at = Time.now
  end
end
