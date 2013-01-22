class Session < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :player, inverse_of: :session
  validates_presence_of :player, :cookie, :expires_at
  validates_uniqueness_of :cookie

  validate :validate_not_older_session
  validate :validate_session_actually_works, :if => lambda { errors[:expires_at].blank? && cookie_changed? }

  def expired?
    expires_at < Time.now
  end

  private

  def validate_not_older_session
    errors.add(:expires_at, "is too old") unless became_newer_session?
  end

  def validate_session_actually_works
    errors.add(:cookie, "is invalid") unless make_test_request!
  end

  def became_newer_session?
    return false if expired?

    if expires_at_changed?
      return Time(expires_at_was) < Time(expires_at)
    else
      # No matter what, if expires_at hasn't changed, skip the update.
      return false
    end
  end

  def make_test_request!
    player.fetch_new_games!
    true
  rescue DGS::NotLoggedInException
    # Your session is bad and you should feel bad
    false
  end

  def Time(value)
    value || Time.at(0)
  end
end
