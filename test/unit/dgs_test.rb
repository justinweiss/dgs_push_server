require 'test_helper'

class DGSTest < ActiveSupport::TestCase

  setup do
    @dgs = DGS.new
    @session = sessions(:justins_session)
    @stubs = Faraday::Adapter::Test::Stubs.new
    connection = Faraday.new do |builder|
      builder.adapter :test, @stubs
      builder.use ParseDGSResponse
    end
    @dgs.instance_variable_set(:@connection, connection)
  end

  test "The non-stubbed DGS connection uses the ParseDGSResponse adapter" do
    connection = DGS.new.instance_variable_get(:@connection)
    assert_includes connection.builder.handlers, ParseDGSResponse
  end

  test "DGS.get will return a 401 when a user isn't logged in" do
    stub_status(200, {}, "[#Error: unknown_user]")
    assert_raises DGS::NotLoggedInException do
      @dgs.get(@session, '/quick_status.php?version=2')
    end
  end

  test "DGS.get will raise an exception when a user's cookie expires" do
    stub_status(200, {}, "[#Error: not_logged_in; quick_status.expired(justinweiss)]")
    assert_raises DGS::NotLoggedInException do
      @dgs.get(@session, '/quick_status.php?version=2')
    end
  end

  test "DGS.get will return a normal response on a successful request" do
    game_csv = "## G,game_id,'opponent_handle',player_color,'lastmove_date','time_remaining',game_action,game_status,move_id,tournament_id,shape_id,game_type,game_prio,opponent_lastaccess_date\nG,317416,'fractic',B,'2007-05-27 12:21:51','J: 83d 14h (+ 1d * 10)',2,PLAY,62,0,0,'GO',0,'2007-05-27 15:00:00'"
    stub_status(200, {}, game_csv)
    dgs_response = @dgs.get(@session, '/quick_status.php?version=2')
    assert_equal game_csv, dgs_response
  end

  test "DGS.get will raise an exception on an unknown error" do
    stub_status(200, {}, "[#Error: server_down]")
    assert_raises DGS::Exception do
      @dgs.get(@session, '/quick_status.php?version=2')
    end
  end

  private

  def stub_status(*args)
    @stubs.get('/quick_status.php?version=2') { args }
  end
end
