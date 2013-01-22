require 'test_helper'

class SessionTest < ActiveSupport::TestCase

  setup do
    @session = Session.first
  end

  test "A session can't be updated unless it's possible to make an actual request with the cookie" do
    skip
  end

  test "A session isn't updated unless it's better than the one we currently have" do
    skip
  end

  test "only make a test request when the session id changes" do
    skip
  end
end
