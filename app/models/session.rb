class Session < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :player, inverse_of: :session, autosave: true
  validates_presence_of :player, :cookie, :expires_at
  validates_uniqueness_of :cookie

  validate :validate_not_older_session

  # We definitely don't want to hit DGS on every validation, only when
  # we're actually in the process of saving the session.
  before_save :verify_session_actually_works

  def expired?
    expires_at < Time.now
  end

  def cookie_handle
    cookie_hash = Hash[cookie.split(';').map {|entry| entry.strip.split('=', 2)}]
    cookie_hash['cookie_handle']
  end

  private

  def validate_not_older_session
    errors.add(:expires_at, "is too old") unless became_newer_session?
  end

  def verify_session_actually_works
    if cookie_changed? && !make_test_request!
      errors.add(:cookie, "is invalid")
      false
    end
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
    user_info = {}
    DGS::ConnectionPool.with do |dgs|
      user_info = JSON.parse(dgs.get(self, '/quick_do.php?obj=user&cmd=info'))
    end
    user_info['handle'] == cookie_handle
  rescue DGS::NotLoggedInException
    # Your session is bad and you should feel bad
    false
  end

  def Time(value)
    value || Time.at(0)
  end
end
