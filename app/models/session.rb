class Session < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :player, inverse_of: :session
  validates_presence_of :player, :cookie, :expires_at
  validates_uniqueness_of :cookie

  validate :validate_session, {:if => lambda { cookie_changed? }}

  def expired?
     expires_at < Time.now
  end

  private

  def validate_session
    errors.add(:cookie, "is invalid") unless make_test_request!
  end

  def make_test_request!
    return true #DGS.new.perform_request(self, 'quick_status.php?version=2')
  end
end
