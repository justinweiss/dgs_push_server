require 'test_helper'

class SessionTest < ActiveSupport::TestCase

  setup do
    @session = Session.first
  end

  test "A session can't be updated unless it's possible to make an actual request with the cookie" do

  end

  # only update the session data when the expires time is better than what we have
  # only try to ping DGS when the session id changes
end
