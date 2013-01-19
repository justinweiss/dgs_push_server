class Player < ActiveRecord::Base
  attr_accessible :dgs_user_id
  has_many :games, dependent: :destroy, inverse_of: :player
  has_many :apns_devices, dependent: :destroy, inverse_of: :player

  validates_presence_of :dgs_user_id
  validates_uniqueness_of :dgs_user_id

  before_create :set_last_checked_at

  private

  def set_last_checked_at
    self.last_checked_at = Time.now
  end
end
